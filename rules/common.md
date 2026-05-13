# 공통 원칙

모든 AI 도구 (Claude Code, Gemini CLI, Codex CLI, OpenCode 등) 에 공통 적용된다.

- **Before answering any question or request**, check if there are AGENT rule-related folders or documents first. These may include names containing keywords such as `agent`, `rule`, `direction`, `readme`, or `instruction`. If found, read them before responding.
- ALWAYS web search first.
- When creating Markdown report/document files, append `_{YYYYMMDD}_{HHmm}_{모델명}` at the end of the filename before the `.md` extension. Keep the model name as short as possible and use the actual model name, not the tool/client name. Example: `report_name_20260430_1435_claude.md`
