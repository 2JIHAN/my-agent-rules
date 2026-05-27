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
    ;;
  capture)
    [ -f "$TARGET" ] || { echo "대상 없음: $TARGET" >&2; exit 1; }
    jq empty "$TARGET" || { echo "경고: $TARGET 이 valid JSON 아님, 중단" >&2; exit 1; }
    sed "s#$HOME#$PLACEHOLDER#g" "$TARGET" > "$TEMPLATE"
    echo "회수 완료 -> $TEMPLATE (이제 commit/push)"
    ;;
  *)
    echo "사용법: $0 [apply|capture]" >&2; exit 2 ;;
esac
