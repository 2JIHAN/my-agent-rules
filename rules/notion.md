# Notion 규칙

## 규칙 로딩

Notion 산출물 작성 규칙은 `jihan-agent-source` repo 의 `source/` 가 단일 원본. Claude Code, OpenCode 배포물로 동기화하며 노션 페이지에서 가져오지 않는다.

1. Claude Code 플러그인이 깔려 있으면 (`claude plugin list` 로 `notion-writer@claude-code-plugin-pack` 확인) skill 자동 활성화.
    - `general-doc-rules` — 모든 산출물 공통 (문체, 길이/구조, 사전 조사, 일반화).
    - `method-doc-rules` — 단계별 가이드/설치/방법 문서 세부 규칙.
2. OpenCode 는 `~/.config/opencode/skills`, `~/.config/opencode/agents` 동기화 배포물 사용.
3. 새 카테고리 규칙은 `source/` 에 원본 추가 후 `scripts/sync-distributions.sh` 에 배포 추가.
4. 규칙 변경은 `~/jihan-agent-source` 의 `source/` 원본을 고치고 → `scripts/sync-distributions.sh` → `git commit && push`. 다른 머신은 `claude plugin update notion-writer` + OpenCode install script. 로컬/에이전트 메모리, CLAUDE.md, 노션에 따로 저장 안 함.
5. 플러그인 미설치면 `claude plugin marketplace add https://github.com/2JIHAN/jihan-agent-source` + `claude plugin install notion-writer@claude-code-plugin-pack`. 설치 전엔 사용자에게 알리고 로컬 규칙만으로 진행.

## 노션 페이지 룰 피드백

노션 산출물의 룰/문체/구조 피드백이 오면 **`notion-writer` 플러그인 소스 룰을 직접 업데이트**. 위치는 `~/jihan-agent-source/source/` 의 `skills/general-doc-rules/SKILL.md`, `skills/method-doc-rules/SKILL.md`, `agents/notion-writer.md` 중 해당 파일. 업데이트 후 `scripts/sync-distributions.sh` 실행 + `git commit && push`.

- 로컬/에이전트 메모리, CLAUDE.md, 노션에 룰을 따로 저장하지 않는다.
- general 인지 method 인지 분기 판단도 룰 자체에 명시. 외부 문서로 빼지 않는다.
- 애매하면 `general-doc-rules` 에 두고, `method-doc-rules` 는 단계별 절차 문서 전용 규칙만 추가.

## Notion 위치

- 노션 문서/산출물 작성 요청의 기본 위치는 `AI-workspace` 아래 `공유 문서함` DB. 별도 지정 시에만 그곳.
