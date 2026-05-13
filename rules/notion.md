# Notion 규칙

## 규칙 로딩

Notion 문서/산출물 작성 규칙은 `jihan-agent-source` repo 의 `source/` 를 단일 원본으로 두고, Claude Code 와 OpenCode 배포물로 동기화한다. 노션 페이지에서 가져오지 않는다.

1. Claude Code 플러그인이 설치돼 있으면 (`claude plugin list` 로 `notion-writer@claude-code-plugin-pack` 확인) 다음 skill 들이 자동으로 활성화된다.
    - `general-doc-rules`, 모든 산출물에 적용되는 공통 규칙 (문체, 길이/구조, 사전 조사, 일반화).
    - `method-doc-rules`, 단계별 실행 가이드/설치 문서/방법 문서에 적용되는 세부 규칙.
2. OpenCode 에서는 `~/.config/opencode/skills` 와 `~/.config/opencode/agents` 로 동기화된 배포물을 사용한다.
3. 다른 카테고리 규칙은 `source/` 아래 원본을 먼저 추가한 뒤 Claude Code, OpenCode 배포 규칙을 `scripts/sync-distributions.sh` 에 추가한다.
4. 규칙 변경은 repo (`~/jihan-agent-source`) 의 `source/` 아래 원본을 직접 update 한 뒤 `scripts/sync-distributions.sh`, `git commit && git push` 순서로 반영한다. 다른 머신은 `claude plugin update notion-writer` 와 OpenCode install script 로 반영. 로컬 메모리, 에이전트 메모리, CLAUDE.md, 노션에 별도로 저장하지 않는다.
5. 플러그인이 설치돼 있지 않으면 `claude plugin marketplace add https://github.com/2JIHAN/jihan-agent-source` + `claude plugin install notion-writer@claude-code-plugin-pack` 로 설치한다. 설치 전에는 한 번 사용자에게 알린 뒤 로컬 규칙만으로 진행한다.

## 노션 페이지 룰 피드백

노션 페이지(Notion 산출물) 의 룰, 문체, 구조에 관한 피드백/수정 요청이 들어오면 **반드시 `notion-writer` 플러그인 소스 룰을 직접 업데이트** 한다. 적용 위치는 `~/jihan-agent-source/source/` 아래 `skills/general-doc-rules/SKILL.md`, `skills/method-doc-rules/SKILL.md`, `agents/notion-writer.md` 중 해당 파일이다. 업데이트 후 `~/jihan-agent-source/scripts/sync-distributions.sh` 를 실행해 배포물에 반영하고, `git commit && git push` 로 원격에 올린다.

- 로컬 메모리, 에이전트 메모리, CLAUDE.md, 노션 페이지에 룰을 별도 저장하지 않는다.
- 룰 분기 판단 (general 인지 method 인지) 도 룰 자체에 명시한다. 외부 문서로 빼지 않는다.
- 룰이 어디에 속하는지 애매하면 `general-doc-rules` 에 두고 `method-doc-rules` 는 단계별 절차 문서 전용 규칙만 추가한다.

## Notion 위치 규칙

- 사용자가 노션 문서나 노션 산출물 작성을 요청하면 기본 위치는 `AI-workspace` 아래 `공유 문서함` 데이터베이스로 한다. 별도 위치를 지정한 경우에만 그 위치를 따른다.
