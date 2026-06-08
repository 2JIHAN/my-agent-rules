#!/usr/bin/env bash
# Claude Code 설정 동기화 스크립트 (Plan L).
# settings.json + hooks/ + CLAUDE.md 의 AGENT-RULES import 블록을 함께 동기화한다.
#   apply   (기본): 템플릿 -> ~/.claude/settings.json  (__HOME__ -> 실제 $HOME)
#   capture       : ~/.claude/settings.json -> 템플릿  ($HOME -> __HOME__)
#
# 다른 머신에서: git pull 후 `apply`. 이 머신에서 설정을 바꿨으면 `capture` 후 commit/push.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$REPO_DIR/settings.json.template"
TARGET="$HOME/.claude/settings.json"
PLACEHOLDER="__HOME__"
HOOKS_REPO="$REPO_DIR/hooks"
HOOKS_TARGET="$HOME/.claude/hooks"
IMPORT_REPO="$REPO_DIR/CLAUDE.import.md"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

# 훅 스크립트 디렉터리 동기화. settings 와 같은 __HOME__ 치환.
#   apply:   repo/hooks/*  -> ~/.claude/hooks/*  (__HOME__ -> $HOME)
#   capture: ~/.claude/hooks/* -> repo/hooks/*   ($HOME -> __HOME__)
sync_hooks() {
  case "$1" in
    apply)
      [ -d "$HOOKS_REPO" ] || return 0
      mkdir -p "$HOOKS_TARGET"
      for f in "$HOOKS_REPO"/*; do
        [ -e "$f" ] || continue
        out="$HOOKS_TARGET/$(basename "$f")"
        sed "s#$PLACEHOLDER#$HOME#g" "$f" > "$out"
        [ -x "$f" ] && chmod +x "$out"
      done
      echo "훅 적용 완료 -> $HOOKS_TARGET"
      ;;
    capture)
      [ -d "$HOOKS_TARGET" ] || return 0
      mkdir -p "$HOOKS_REPO"
      for f in "$HOOKS_TARGET"/*; do
        [ -e "$f" ] || continue
        out="$HOOKS_REPO/$(basename "$f")"
        sed "s#$HOME#$PLACEHOLDER#g" "$f" > "$out"
        [ -x "$f" ] && chmod +x "$out"
      done
      echo "훅 회수 완료 -> $HOOKS_REPO"
      ;;
  esac
}

# ~/.claude/CLAUDE.md 의 AGENT-RULES import 블록 동기화.
# CLAUDE.md 본문은 OMC 가 관리하므로 통째로 덮지 않고, AGENT-RULES 마커 사이만 주입/회수한다.
# 블록엔 머신 종속 경로가 없어 __HOME__ 치환은 하지 않는다 (`@~/.agent/...` 그대로).
#   apply:   repo/CLAUDE.import.md -> CLAUDE.md 의 마커 블록 (없으면 OMC import 앞에 삽입)
#   capture: CLAUDE.md 의 마커 블록 -> repo/CLAUDE.import.md
sync_import() {
  case "$1" in
    apply)
      [ -f "$IMPORT_REPO" ] || return 0
      if [ ! -f "$CLAUDE_MD" ]; then
        echo "건너뜀: $CLAUDE_MD 없음 (OMC 설치 후 다시 apply)" >&2
        return 0
      fi
      local tmp
      tmp="$(mktemp)"
      awk -v blockfile="$IMPORT_REPO" '
        BEGIN { while ((getline line < blockfile) > 0) block = block line "\n" }
        /<!-- AGENT-RULES:START/ { skip=1; next }
        /<!-- AGENT-RULES:END -->/ { skip=0; printf "%s", block; done=1; next }
        skip { next }
        /<!-- OMC:IMPORT:START -->/ && !done { printf "%s", block; done=1 }
        { print }
        END { if (!done) printf "%s", block }
      ' "$CLAUDE_MD" > "$tmp"
      mv "$tmp" "$CLAUDE_MD"
      echo "CLAUDE.md import 블록 주입 완료 -> $CLAUDE_MD"
      ;;
    capture)
      [ -f "$CLAUDE_MD" ] || return 0
      local tmp
      tmp="$(mktemp)"
      awk '
        /<!-- AGENT-RULES:START/ { cap=1 }
        cap { print }
        /<!-- AGENT-RULES:END -->/ { cap=0 }
      ' "$CLAUDE_MD" > "$tmp"
      if [ -s "$tmp" ]; then
        mv "$tmp" "$IMPORT_REPO"
        echo "CLAUDE.md import 블록 회수 완료 -> $IMPORT_REPO"
      else
        rm -f "$tmp"
        echo "건너뜀: $CLAUDE_MD 에 AGENT-RULES 마커 없음" >&2
      fi
      ;;
  esac
}

cmd="${1:-apply}"
case "$cmd" in
  apply)
    [ -f "$TEMPLATE" ] || { echo "템플릿 없음: $TEMPLATE" >&2; exit 1; }
    mkdir -p "$(dirname "$TARGET")"
    if [ -f "$TARGET" ]; then
      bak="$TARGET.bak.$(date +%Y%m%d_%H%M%S)"
      cp "$TARGET" "$bak"
      echo "기존 설정 백업: $bak"
    fi
    sed "s#$PLACEHOLDER#$HOME#g" "$TEMPLATE" > "$TARGET"
    jq empty "$TARGET" || { echo "경고: 생성된 settings.json 이 valid JSON 아님" >&2; exit 1; }
    echo "적용 완료 -> $TARGET"
    sync_hooks apply
    sync_import apply
    ;;
  capture)
    [ -f "$TARGET" ] || { echo "대상 없음: $TARGET" >&2; exit 1; }
    jq empty "$TARGET" || { echo "경고: $TARGET 이 valid JSON 아님, 중단" >&2; exit 1; }
    sed "s#$HOME#$PLACEHOLDER#g" "$TARGET" > "$TEMPLATE"
    echo "회수 완료 -> $TEMPLATE (이제 commit/push)"
    sync_hooks capture
    sync_import capture
    ;;
  *)
    echo "사용법: $0 [apply|capture]" >&2; exit 2 ;;
esac
