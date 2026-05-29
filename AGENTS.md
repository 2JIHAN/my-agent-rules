# AGENTS — 전역 AI 규칙 진입점

Claude Code, Gemini CLI, Codex CLI, OpenCode 등 모든 AI 도구의 공통 규칙 진입점. 각 도구 진입점에서 이 파일로 redirect 된다. 본문은 분야별 파일에 있고, 이 파일은 orchestration 만 한다.

@rules/common.md
@rules/planning.md
@rules/style.md
@rules/docs.md
@rules/coding.md
@rules/docker.md
@rules/notion.md
@rules/permissions.md

위 `@import` 가 세션 시작 시 각 규칙 파일을 자동 로드한다. 아래는 같은 목록의 사람용 색인.

| 분야 | 파일 | 내용 |
|---|---|---|
| 공통 | [common.md](rules/common.md) | 규칙 폴더 사전 확인, 웹 검색, 파일명 규약 |
| 기획 | [planning.md](rules/planning.md) | 비자명한 계획/설계에서 grill-with-docs 디폴트 |
| 문체 | [style.md](rules/style.md) | 콜론, 가운뎃점 등 문체 (단일 원본) |
| 문서화 | [docs.md](rules/docs.md) | README/docs 구조, 업데이트 타이밍 |
| 코딩 | [coding.md](rules/coding.md) | 프로젝트 초기화, git author, ~/.agent 운영, 작업 자세 |
| Docker | [docker.md](rules/docker.md) | ghostdesk 기동 시 이미지 확인, 임시 컨테이너 |
| Notion | [notion.md](rules/notion.md) | 규칙 로딩, 룰 피드백, 기본 저장 위치 |
| 권한 | [permissions.md](rules/permissions.md) | allow/deny 베이스라인, 도구별 설정 경로 |

## 규칙 추가/수정

- 새 규칙은 가장 가까운 분야 파일에. 애매하면 `common.md`.
- 새 분야는 `rules/<category>.md` 를 만들고 위 표에 등록.
- 이 파일엔 규칙을 적지 않는다 (orchestration 전용). 문체는 `style.md` 단일 원본, 복사하지 말고 링크로 참조.
