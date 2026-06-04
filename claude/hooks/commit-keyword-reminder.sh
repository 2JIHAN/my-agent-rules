#!/usr/bin/env bash
# UserPromptSubmit hook.
# 프롬프트에 커밋/푸시 관련 키워드가 있으면 caveman-commit 스킬을 쓰라는 컨텍스트를 주입한다.
prompt=$(jq -r '.prompt // ""' 2>/dev/null)
if printf '%s' "$prompt" | grep -qiE '커밋|푸시|푸쉬|commit|push'; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"커밋/푸시 관련 요청이다. git 커밋을 만들 때는 별도 지시가 없어도 먼저 caveman-commit 스킬을 invoke 해서 커밋 메시지를 생성하라."}}
JSON
fi
exit 0
