# my-agent-rules

여러 AI 코딩 도구 (Claude Code, Codex CLI, OpenCode, Gemini CLI 등) 의 **전역 규칙과 머신 설정을 한 곳에서 관리하고 머신 사이에 동기화**하는 저장소. `~/.agent` 에 클론해 쓴다.

규칙 본문은 `rules/*.md` 단일 원본 하나로 두고, 각 도구는 자기 진입점에서 `AGENTS.md` 를 import 한다. 머신마다 다른 설정 (홈 경로, 훅, 스킬 목록) 은 도구별 폴더의 sync 스크립트로 템플릿 ↔ 실제 설정을 변환한다.

## 구성

| 경로 | 역할 |
|---|---|
| `AGENTS.md` | 모든 도구 공통 규칙 진입점. `rules/*.md` 를 import 하고 orchestration 만 한다. |
| `rules/` | 분야별 규칙 단일 원본 (common, planning, style, docs, coding, docker, notion, permissions). |
| `claude/` | Claude Code 설정 동기화 (`settings.json`, 훅, CLAUDE.md import 블록). [README](claude/README.md) |
| `codex/` | Codex CLI 설정 동기화 (`config.toml`, AGENTS import). [README](codex/README.md) |
| `opencode/` | OpenCode 설정 동기화 (`opencode.json`, AGENTS import). [README](opencode/README.md) |
| `skills/` | `npx skills` 글로벌 스킬 락파일 동기화. [README](skills/README.md) |

## 규칙 파일

`rules/` 가 규칙의 단일 원본. 새 규칙은 가장 가까운 분야 파일에 추가하고, 새 분야는 `rules/<category>.md` 를 만든 뒤 `AGENTS.md` 의 import 와 색인 표에 등록한다.

| 분야 | 파일 | 내용 |
|---|---|---|
| 공통 | [common.md](rules/common.md) | 규칙 폴더 사전 확인, 웹 검색, 파일명 규약 |
| 기획 | [planning.md](rules/planning.md) | 비자명한 계획/설계에서 grill-with-docs 디폴트 |
| 문체 | [style.md](rules/style.md) | 콜론, 가운뎃점 등 문체 (단일 원본) |
| 문서화 | [docs.md](rules/docs.md) | README/docs 구조, 업데이트 타이밍 |
| 코딩 | [coding.md](rules/coding.md) | 프로젝트 초기화, git author, 작업 자세 |
| Docker | [docker.md](rules/docker.md) | ghostdesk 기동, 임시 컨테이너 |
| Notion | [notion.md](rules/notion.md) | 규칙 로딩, 룰 피드백, 기본 저장 위치 |
| 권한 | [permissions.md](rules/permissions.md) | allow/deny 베이스라인, 도구별 설정 경로 |

## 빠른 시작

### 새 머신 셋업

```bash
git clone https://github.com/2JIHAN/my-agent-rules.git ~/.agent
~/.agent/claude/sync-claude.sh apply      # Claude Code 설정 + CLAUDE.md import 주입
~/.agent/skills/sync-skills.sh apply      # 글로벌 스킬 재설치 (Node.js 필요)
# Codex/OpenCode 도 쓰면
~/.agent/codex/sync-codex.sh apply
~/.agent/opencode/sync-opencode.sh apply
```

`apply` 는 템플릿의 `__HOME__` 플레이스홀더를 그 머신의 `$HOME` 으로 치환해 실제 설정을 생성한다. 도구별 세부는 각 폴더 README 참고.

### 규칙만 고치기

`rules/*.md` 나 `AGENTS.md` 를 편집하면 끝. 각 도구는 세션 시작 시 `~/.agent/AGENTS.md` 를 import 하므로 머신 설정 재적용 없이 바로 반영된다.

## 자동 커밋 정책

`~/.agent` 안의 파일을 고치면 다시 묻지 않고 곧바로 `git add` → `commit` → `push origin main`. 이 저장소 한정으로 커밋, 푸시 권한이 상시 위임돼 있다. 메시지는 한 줄 요약 (예 `chore: update style rule`). `.gitignore` 항목 (`.omc/`, `.DS_Store`) 은 커밋하지 않는다.

머신 종속 설정을 바꾸면 commit 전에 해당 `capture` 를 먼저 돌려 템플릿/락파일을 최신화한다.

- `~/.claude/settings.json` 변경 → `claude/sync-claude.sh capture`
- `npx skills` 추가/삭제 → `skills/sync-skills.sh capture`

절차와 주의점은 각 폴더 README 에 있다.
