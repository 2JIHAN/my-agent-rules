#!/usr/bin/env bash
# npx skills 글로벌 스킬 동기화 스크립트.
#   capture (기본): 현재 글로벌 락(~/.agents/.skill-lock.json) -> repo 의 skill-lock.json
#                   라이브 락엔 없지만 디스크에 살아 있는 manual-install 항목은 기존 repo 락에서 보존
#   apply         : repo 의 skill-lock.json 을 읽어 각 소스 repo 에서 스킬 재배포
#                   1) 다중 -s 플래그로 `npx skills add` 시도 (쉼표 리스트 버그 회피)
#                   2) 누락분은 source repo 를 --depth 1 로 clone 해 SKILL 폴더 자체를 ~/.claude/skills/ 로 복사
#                   3) 마지막에 각 스킬의 SKILL.md 존재를 검증, 한 개라도 빠지면 비-0 종료
#
# 버전 정책: 항상 최신 (HEAD). `npx skills` 와 git clone 모두 핀 없음. 신규 회귀가 있으면 apply 가 검증 단계에서 비-0 로 잡아낸다.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_LOCK="$REPO_DIR/skill-lock.json"
LIVE_LOCK="$HOME/.agents/.skill-lock.json"
SKILL_TARGET_ROOT="$HOME/.claude/skills"

cmd="${1:-capture}"
case "$cmd" in
  capture)
    [ -f "$LIVE_LOCK" ] || { echo "글로벌 락 없음: $LIVE_LOCK (npx skills 로 스킬을 깐 적 없음?)" >&2; exit 1; }
    jq empty "$LIVE_LOCK" || { echo "락이 valid JSON 아님, 중단" >&2; exit 1; }

    if [ -f "$REPO_LOCK" ]; then
      # 보존 후보: 기존 repo 락에는 있지만 라이브 락엔 없는 스킬
      candidates="$(jq -r --slurpfile live "$LIVE_LOCK" '
        ($live[0].skills // {}) as $live_skills
        | .skills | to_entries
        | map(select(.key as $k | $live_skills | has($k) | not))[]
        | .key
      ' "$REPO_LOCK")"

      keep_keys=()
      while IFS= read -r k; do
        [ -z "$k" ] && continue
        if [ -f "$SKILL_TARGET_ROOT/$k/SKILL.md" ]; then
          keep_keys+=("$k")
        fi
      done <<<"$candidates"

      if [ ${#keep_keys[@]} -gt 0 ]; then
        keep_file="$(mktemp)"
        printf '%s\n' "${keep_keys[@]}" >"$keep_file"
        jq --slurpfile old "$REPO_LOCK" --rawfile keep "$keep_file" '
          ($old[0].skills // {}) as $os
          | (($keep | split("\n") | map(select(length > 0)))) as $ks
          | reduce $ks[] as $k (.; .skills[$k] = $os[$k])
        ' "$LIVE_LOCK" >"$REPO_LOCK.tmp"
        mv "$REPO_LOCK.tmp" "$REPO_LOCK"
        rm -f "$keep_file"
        echo "기록 완료 -> $REPO_LOCK (manual 보존: ${keep_keys[*]})"
      else
        cp "$LIVE_LOCK" "$REPO_LOCK"
        echo "기록 완료 -> $REPO_LOCK"
      fi
    else
      cp "$LIVE_LOCK" "$REPO_LOCK"
      echo "기록 완료 -> $REPO_LOCK"
    fi
    ;;

  apply)
    [ -f "$REPO_LOCK" ] || { echo "repo 락 없음: $REPO_LOCK" >&2; exit 1; }
    command -v npx >/dev/null || { echo "npx 없음 — Node.js 설치 필요" >&2; exit 1; }
    command -v jq  >/dev/null || { echo "jq 없음 — 설치 필요" >&2; exit 1; }
    command -v git >/dev/null || { echo "git 없음 — 설치 필요" >&2; exit 1; }
    mkdir -p "$SKILL_TARGET_ROOT"

    workdir="$(mktemp -d)"
    trap 'rm -rf "$workdir"' EXIT

    failed=()

    # 소스별로 묶기. tsv: source<TAB>sourceUrl<TAB>name1,name2<TAB>relPath1;relPath2
    mapfile -t rows < <(jq -r '
      .skills | to_entries | group_by(.value.source)[]
      | [
          .[0].value.source,
          .[0].value.sourceUrl,
          ([.[].key] | join(",")),
          ([.[].value.skillPath] | join(";"))
        ] | @tsv
    ' "$REPO_LOCK")

    for row in "${rows[@]}"; do
      IFS=$'\t' read -r src url names_csv paths_semi <<<"$row"
      IFS=',' read -ra names <<<"$names_csv"
      IFS=';' read -ra paths <<<"$paths_semi"

      echo
      echo "[$src] ${#names[@]}개"

      # 1차: npx skills add — 다중 -s 플래그 (1.5.x 의 -s "a,b,c" 파싱 버그 회피)
      add_args=(skills add "$src" -g -y -a claude-code)
      for n in "${names[@]}"; do add_args+=(-s "$n"); done
      if ! npx -y "${add_args[@]}" >/dev/null 2>&1; then
        echo "  ! npx 실패 또는 일부 거부 (PromptScript 등) — 폴백 진행"
      fi

      # 2차: 누락분만 git clone + cp -r 로 직접 배포
      missing=()
      missing_paths=()
      for i in "${!names[@]}"; do
        n="${names[$i]}"
        if [ ! -f "$SKILL_TARGET_ROOT/$n/SKILL.md" ]; then
          missing+=("$n")
          missing_paths+=("${paths[$i]}")
        fi
      done

      if [ ${#missing[@]} -gt 0 ]; then
        clone_dir="$workdir/$(echo "$src" | tr '/' '_')"
        if [ ! -d "$clone_dir" ]; then
          if ! git clone --depth 1 "$url" "$clone_dir" >/dev/null 2>&1; then
            echo "  ✗ git clone 실패: $url" >&2
            failed+=("${missing[@]}")
            continue
          fi
        fi
        for j in "${!missing[@]}"; do
          n="${missing[$j]}"
          rel="${missing_paths[$j]}"
          skill_dir="$clone_dir/$(dirname "$rel")"
          if [ ! -d "$skill_dir" ]; then
            echo "  ✗ $n: 소스에 $rel 없음" >&2
            failed+=("$n")
            continue
          fi
          rm -rf "$SKILL_TARGET_ROOT/$n"
          cp -r "$skill_dir" "$SKILL_TARGET_ROOT/$n"
          if [ ! -f "$SKILL_TARGET_ROOT/$n/SKILL.md" ]; then
            echo "  ✗ $n: 복사 후에도 SKILL.md 없음" >&2
            failed+=("$n")
          fi
        done
      fi

      # 보고
      for i in "${!names[@]}"; do
        n="${names[$i]}"
        if [ -f "$SKILL_TARGET_ROOT/$n/SKILL.md" ]; then
          via="npx"
          for m in "${missing[@]:-}"; do [ "$m" = "$n" ] && via="manual"; done
          echo "  ✓ $n ($via)"
        fi
      done
    done

    echo
    total="$(jq '.skills | length' "$REPO_LOCK")"
    if [ ${#failed[@]} -gt 0 ]; then
      echo "✗ 누락 ${#failed[@]}/${total}개: ${failed[*]}" >&2
      exit 1
    fi
    echo "✓ 복원 완료: $total개 모두 $SKILL_TARGET_ROOT/ 에 존재"
    ;;

  *)
    echo "사용법: $0 [capture|apply]" >&2; exit 2 ;;
esac
