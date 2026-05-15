# AGENTS — 전역 AI 규칙 진입점

이 파일은 Claude Code, Gemini CLI, Codex CLI, OpenCode 등 모든 AI 도구의 공통 규칙 진입점이다. 각 도구의 진입점 파일에서 이 파일로 redirect 되어 함께 로드된다.

본문은 분야별 파일에 분리돼 있다. AGENTS.md 는 orchestration 만 담당한다. 아래 파일을 모두 함께 로드한다.

| 분야 | 파일 | 내용 |
|---|---|---|
| 공통 원칙 | [rules/common.md](rules/common.md) | 규칙 폴더 사전 확인, 웹 검색, 파일명 규약 |
| 문체 | [rules/style.md](rules/style.md) | 콜론, 가운뎃점 사용 규칙 (단일 원본) |
| 문서화 | [rules/docs.md](rules/docs.md) | README/docs 구조, 업데이트 타이밍 |
| 코딩 | [rules/coding.md](rules/coding.md) | 프로젝트 초기화 (git init), behavioral guidelines |
| Docker | [rules/docker.md](rules/docker.md) | ghostdesk 컨테이너 기동 시 이미지 확인, 임시 컨테이너 기본값 |
| Notion | [rules/notion.md](rules/notion.md) | 규칙 로딩, 룰 피드백, 기본 저장 위치 |
| 권한 + 도구 경로 | [rules/permissions.md](rules/permissions.md) | allow/deny 베이스라인, 도구별 설정 파일 경로 |

## 규칙 추가/수정 가이드

- 새 규칙은 가장 가까운 분야 파일에 추가한다. 분야가 애매하면 `rules/common.md` 에 둔다.
- 새 분야가 필요하면 `rules/<category>.md` 를 만들고 위 표에 등록한다.
- AGENTS.md 본문에는 규칙을 적지 않는다. 이 파일은 항상 orchestration 만.
- 문체 규칙은 `rules/style.md` 가 단일 원본. 다른 위치에 복사하지 말고 링크로 참조한다.
