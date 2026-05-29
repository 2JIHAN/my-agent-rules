#!/usr/bin/env bash
# Claude Code 설정 동기화 스크립트 (Plan L).
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
    ;;
  capture)
    [ -f "$TARGET" ] || { echo "대상 없음: $TARGET" >&2; exit 1; }
    jq empty "$TARGET" || { echo "경고: $TARGET 이 valid JSON 아님, 중단" >&2; exit 1; }
    sed "s#$HOME#$PLACEHOLDER#g" "$TARGET" > "$TEMPLATE"
    echo "회수 완료 -> $TEMPLATE (이제 commit/push)"
    sync_hooks capture
    ;;
  *)
    echo "사용법: $0 [apply|capture]" >&2; exit 2 ;;
esac
