#!/usr/bin/env bash
# Codex CLI 설정 동기화 스크립트.
#   apply   (기본): 템플릿 -> ~/.codex/*  (__HOME__, __TMPDIR__ -> 실제 값)
#   capture       : ~/.codex/* -> 템플릿  (실제 값 -> 플레이스홀더)
#
# 다른 머신에서: git pull 후 `apply`. 이 머신에서 설정을 바꿨으면 `capture` 후 commit/push.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_TEMPLATE="$REPO_DIR/config.toml.template"
CONFIG_TARGET="$HOME/.codex/config.toml"
AGENTS_REPO="$REPO_DIR/AGENTS.md"
AGENTS_TARGET="$HOME/.codex/AGENTS.md"
HOME_PLACEHOLDER="__HOME__"
TMP_PLACEHOLDER="__TMPDIR__"

tmp_dir() {
  local base="${TMPDIR:-/tmp}"
  base="${base%/}"
  if [ -d "$base" ]; then
    (cd "$base" && pwd -P)
  else
    printf '%s\n' "$base"
  fi
}

replace_placeholders() {
  local source="$1"
  local tmp_path
  tmp_path="$(tmp_dir)"
  sed \
    -e "s#$HOME_PLACEHOLDER#$HOME#g" \
    -e "s#$TMP_PLACEHOLDER#$tmp_path#g" \
    "$source"
}

capture_placeholders() {
  local source="$1"
  local tmp_path
  tmp_path="$(tmp_dir)"
  sed \
    -e "s#$HOME#$HOME_PLACEHOLDER#g" \
    -e "s#$tmp_path#$TMP_PLACEHOLDER#g" \
    "$source"
}

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
  replace_placeholders "$source" > "$target"
  echo "적용 완료 -> $target"
}

capture_text_file() {
  local source="$1"
  local target="$2"
  [ -f "$source" ] || return 0
  mkdir -p "$(dirname "$target")"
  capture_placeholders "$source" > "$target"
  echo "회수 완료 -> $target"
}

cmd="${1:-apply}"
case "$cmd" in
  apply)
    [ -f "$CONFIG_TEMPLATE" ] || { echo "템플릿 없음: $CONFIG_TEMPLATE" >&2; exit 1; }
    apply_text_file "$CONFIG_TEMPLATE" "$CONFIG_TARGET"
    apply_text_file "$AGENTS_REPO" "$AGENTS_TARGET"
    ;;
  capture)
    [ -f "$CONFIG_TARGET" ] || { echo "대상 없음: $CONFIG_TARGET" >&2; exit 1; }
    capture_text_file "$CONFIG_TARGET" "$CONFIG_TEMPLATE"
    capture_text_file "$AGENTS_TARGET" "$AGENTS_REPO"
    echo "회수 완료 (이제 commit/push)"
    ;;
  *)
    echo "사용법: $0 [apply|capture]" >&2; exit 2 ;;
esac
