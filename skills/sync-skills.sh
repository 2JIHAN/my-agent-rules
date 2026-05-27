#!/usr/bin/env bash
# npx skills 글로벌 스킬 동기화 스크립트.
#   capture (기본): 현재 글로벌 락(~/.agents/.skill-lock.json) -> repo 의 skill-lock.json
#   apply         : repo 의 skill-lock.json 을 읽어 소스별 `npx skills add` 재실행 (다른 머신 복원)
#
# 락파일은 npx skills(vercel-labs/skills) 가 관리한다. experimental_install 은 프로젝트 전용이라
# 글로벌 복원에 못 쓰므로, 락의 소스 repo 별로 add 를 다시 돌려 재현한다.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_LOCK="$REPO_DIR/skill-lock.json"
LIVE_LOCK="$HOME/.agents/.skill-lock.json"

cmd="${1:-capture}"
case "$cmd" in
  capture)
    [ -f "$LIVE_LOCK" ] || { echo "글로벌 락 없음: $LIVE_LOCK (npx skills 로 스킬을 깐 적 없음?)" >&2; exit 1; }
    jq empty "$LIVE_LOCK" || { echo "락이 valid JSON 아님, 중단" >&2; exit 1; }
    cp "$LIVE_LOCK" "$REPO_LOCK"
    echo "기록 완료 -> $REPO_LOCK (이제 commit/push)"
    ;;
  apply)
    [ -f "$REPO_LOCK" ] || { echo "repo 락 없음: $REPO_LOCK" >&2; exit 1; }
    command -v npx >/dev/null || { echo "npx 없음 — Node.js 설치 필요" >&2; exit 1; }
    echo "소스 repo 별로 npx skills add 재실행:"
    # 소스별로 묶어 한 번에 설치. 대상 에이전트는 claude-code.
    jq -r '.skills | to_entries | group_by(.value.source)[]
           | "npx skills add " + .[0].value.source + " -g -y -a claude-code -s \"" + ([.[].key] | join(",")) + "\""' \
      "$REPO_LOCK" | while IFS= read -r line; do
        echo "  > $line"
        eval "$line"
      done
    echo "복원 완료. 확인: npx skills list -g"
    ;;
  *)
    echo "사용법: $0 [capture|apply]" >&2; exit 2 ;;
esac
