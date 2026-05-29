# 공통 원칙

모든 AI 도구 (Claude Code, Gemini CLI, Codex CLI, OpenCode 등) 공통.

- **답하기 전에** AGENT 규칙 관련 폴더/문서가 있는지 먼저 확인한다 (이름에 `agent`, `rule`, `direction`, `readme`, `instruction` 등 포함). 있으면 읽고 답한다.
- 항상 웹 검색 먼저.
- Markdown 리포트/문서 파일은 `.md` 앞에 `_{YYYYMMDD}_{HHmm}_{모델명}` 을 붙인다. 모델명은 툴/클라이언트명이 아닌 실제 모델명으로 짧게. 예 `report_name_20260430_1435_claude.md`.
