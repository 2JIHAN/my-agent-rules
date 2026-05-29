#!/usr/bin/env bash
# OpenCode 설정 동기화 스크립트.
#   apply   (기본): 템플릿 -> ~/.config/opencode/*  (__HOME__ -> 실제 $HOME)
#   capture       : ~/.config/opencode/* -> 템플릿  ($HOME -> __HOME__)
#
# 다른 머신에서: git pull 후 `apply`. 이 머신에서 설정을 바꿨으면 `capture` 후 commit/push.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_TEMPLATE="$REPO_DIR/opencode.json.template"
CONFIG_TARGET="$HOME/.config/opencode/opencode.json"
AGENTS_REPO="$REPO_DIR/AGENTS.md"
AGENTS_TARGET="$HOME/.config/opencode/AGENTS.md"
PLACEHOLDER="__HOME__"

backup_if_exists() {
  local target="$1"
  [ -f "$target" ] || return 0
  local bak="$target.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$target" "$bak"
  echo "기존 파일 백업: $bak"
}

apply_text_file() {
  local source="$1"
  local target="$2"
  [ -f "$source" ] || return 0
  mkdir -p "$(dirname "$target")"
  backup_if_exists "$target"
  sed "s#$PLACEHOLDER#$HOME#g" "$source" > "$target"
  echo "적용 완료 -> $target"
}

capture_text_file() {
  local source="$1"
  local target="$2"
  [ -f "$source" ] || return 0
  mkdir -p "$(dirname "$target")"
  sed "s#$HOME#$PLACEHOLDER#g" "$source" > "$target"
  echo "회수 완료 -> $target"
}

cmd="${1:-apply}"
case "$cmd" in
  apply)
    [ -f "$CONFIG_TEMPLATE" ] || { echo "템플릿 없음: $CONFIG_TEMPLATE" >&2; exit 1; }
    mkdir -p "$(dirname "$CONFIG_TARGET")"
    tmp="$(mktemp)"
    sed "s#$PLACEHOLDER#$HOME#g" "$CONFIG_TEMPLATE" > "$tmp"
    jq empty "$tmp" || { echo "경고: 생성된 opencode.json 이 valid JSON 아님" >&2; rm -f "$tmp"; exit 1; }
    backup_if_exists "$CONFIG_TARGET"
    mv "$tmp" "$CONFIG_TARGET"
    echo "적용 완료 -> $CONFIG_TARGET"
    apply_text_file "$AGENTS_REPO" "$AGENTS_TARGET"
    ;;
  capture)
    [ -f "$CONFIG_TARGET" ] || { echo "대상 없음: $CONFIG_TARGET" >&2; exit 1; }
    jq empty "$CONFIG_TARGET" || { echo "경고: $CONFIG_TARGET 이 valid JSON 아님, 중단" >&2; exit 1; }
    capture_text_file "$CONFIG_TARGET" "$CONFIG_TEMPLATE"
    capture_text_file "$AGENTS_TARGET" "$AGENTS_REPO"
    echo "회수 완료 (이제 commit/push)"
    ;;
  *)
    echo "사용법: $0 [apply|capture]" >&2; exit 2 ;;
esac
