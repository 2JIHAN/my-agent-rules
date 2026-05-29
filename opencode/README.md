# OpenCode 설정 동기화

`~/.config/opencode/opencode.json` 과 `~/.config/opencode/AGENTS.md` 를 여러 머신 사이에서 git(`my-agent-rules` remote)으로 동기화한다.

Claude 설정과 같은 방식으로 repo에는 홈 경로를 `__HOME__` 플레이스홀더로 바꾼 템플릿을 저장하고, 각 머신에서 스크립트로 실제 `$HOME` 값을 끼워 넣는다.

## 구성

| 파일 | 역할 |
|---|---|
| `opencode.json.template` | 홈 경로를 `__HOME__` 로 치환한 OpenCode 설정 원본. |
| `AGENTS.md` | `~/.config/opencode/AGENTS.md` 의 추적 사본. 보통 `~/.agent/AGENTS.md` 를 읽도록 연결한다. |
| `sync-opencode.sh` | 템플릿과 실제 `~/.config/opencode/` 사이 양방향 변환. |

## 빠른 시작

### 다른 머신에 설정 받아오기

```bash
git -C ~/.agent pull
~/.agent/opencode/sync-opencode.sh apply
```

`apply` 는 `__HOME__` 를 그 머신의 `$HOME` 으로 바꿔 `~/.config/opencode/opencode.json` 을 생성한다. 기존 파일이 있으면 `.bak.<날짜>` 로 자동 백업한다.

### 이 머신에서 바꾼 설정을 repo 에 반영하기

```bash
~/.agent/opencode/sync-opencode.sh capture
git -C ~/.agent add opencode/opencode.json.template opencode/AGENTS.md opencode/README.md opencode/sync-opencode.sh
git -C ~/.agent commit -m "chore: add opencode settings sync"
git -C ~/.agent push
```

## 동작 원리

- `apply` = `opencode.json.template` -> `~/.config/opencode/opencode.json` (`__HOME__` -> `$HOME`), `AGENTS.md` -> `~/.config/opencode/AGENTS.md`.
- `capture` = `~/.config/opencode/opencode.json` -> `opencode.json.template` (`$HOME` -> `__HOME__`), `~/.config/opencode/AGENTS.md` -> `AGENTS.md`.
- `opencode.json` 은 `jq empty` 로 valid JSON 인지 검사한 뒤에만 기록한다.

## 주의

- 비밀값 금지. 토큰, API 키, 쿠키는 `opencode.json.template` 에 넣지 않는다.
- OpenCode는 설정을 시작 시점에 읽는다. `apply` 후에는 opencode를 재시작해야 적용된다.
