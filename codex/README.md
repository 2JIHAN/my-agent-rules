# Codex CLI 설정 동기화

`~/.codex/config.toml` 과 `~/.codex/AGENTS.md` 를 여러 머신 사이에서 git(`my-agent-rules` remote)으로 동기화한다.

Codex 설정에는 홈 경로와 macOS 임시 디렉터리 경로가 들어갈 수 있다. repo 에는 각각 `__HOME__`, `__TMPDIR__` 플레이스홀더로 바꾼 템플릿을 저장하고, 각 머신에서 스크립트로 실제 값을 끼워 넣는다.

## 구성

| 파일 | 역할 |
|---|---|
| `config.toml.template` | 홈 경로와 임시 디렉터리 경로를 치환한 Codex 설정 원본. |
| `AGENTS.md` | `~/.codex/AGENTS.md` 의 추적 사본. 보통 `~/.agent/AGENTS.md` 를 읽도록 연결한다. |
| `sync-codex.sh` | 템플릿과 실제 `~/.codex/` 사이 양방향 변환. |

## 빠른 시작

### 다른 머신에 설정 받아오기

```bash
git -C ~/.agent pull
~/.agent/codex/sync-codex.sh apply
```

`apply` 는 `__HOME__` 와 `__TMPDIR__` 를 그 머신의 값으로 바꿔 `~/.codex/config.toml` 을 생성한다. 기존 파일이 있으면 `.bak.<날짜>` 로 자동 백업한다.

### 이 머신에서 바꾼 설정을 repo 에 반영하기

```bash
~/.agent/codex/sync-codex.sh capture
git -C ~/.agent add codex/config.toml.template codex/AGENTS.md codex/README.md codex/sync-codex.sh
git -C ~/.agent commit -m "chore: add codex settings sync"
git -C ~/.agent push
```

## 동작 원리

- `apply` = `config.toml.template` -> `~/.codex/config.toml` (`__HOME__` -> `$HOME`, `__TMPDIR__` -> 현재 임시 디렉터리), `AGENTS.md` -> `~/.codex/AGENTS.md`.
- `capture` = `~/.codex/config.toml` -> `config.toml.template` (`$HOME` -> `__HOME__`, 현재 임시 디렉터리 -> `__TMPDIR__`), `~/.codex/AGENTS.md` -> `AGENTS.md`.
- TOML 은 Codex CLI 가 읽는 원본 형식을 유지한다. 스크립트는 JSON 검증을 하지 않는다.

## 동기화하지 않는 것

- `auth.json`, `installation_id` 처럼 계정이나 설치 식별자가 들어간 파일.
- `history.jsonl`, `sessions/`, `shell_snapshots/`, `logs_*.sqlite`, `state_*.sqlite`, `goals_*.sqlite`, `memories_*.sqlite` 같은 런타임 상태.
- `cache/`, `.tmp/`, `tmp/`, `vendor_imports/`, system skill cache 같은 재생성 가능한 캐시.

## 주의

- 비밀값 금지. 토큰, 세션, 쿠키는 `config.toml.template` 에 넣지 않는다.
- `apply` 후 이미 실행 중인 Codex 세션에는 새 설정이 자동 반영되지 않을 수 있다. 새 세션에서 확인한다.
- MCP 서버 경로처럼 머신에만 있는 도구 경로는 `__HOME__` 로 홈 경로만 해결된다. 다른 머신에도 같은 상대 경로로 도구가 있어야 한다.
