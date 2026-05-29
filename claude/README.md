# Claude Code 설정 동기화 (Plan L)

`~/.claude/settings.json` 을 여러 머신 사이에서 git(`my-agent-rules` remote) 으로 동기화한다.

문제는 `settings.json` 안에 머신마다 다른 홈 경로(`/Users/<username>/...`)가 박혀 있다는 점이다. 그대로 복사하면 다른 컴퓨터에서 깨진다. 그래서 repo 에는 홈 경로를 `__HOME__` 플레이스홀더로 바꾼 **템플릿**만 저장하고, 각 머신에서 스크립트로 실제 경로를 끼워 넣어 `settings.json` 을 생성한다.

## 구성

| 파일 | 역할 |
|---|---|
| `settings.json.template` | 홈 경로를 `__HOME__` 로 치환한 설정 원본. 이것만 git 추적. |
| `hooks/` | `~/.claude/hooks/` 훅 스크립트의 추적 사본. 홈 경로는 `__HOME__` 로 치환됨. |
| `sync-claude.sh` | 템플릿, 훅 디렉터리와 실제 `~/.claude/` 사이 양방향 변환. |

## 빠른 시작

### 다른 머신에 설정 받아오기

```bash
git -C ~/.agent pull
~/.agent/claude/sync-claude.sh apply
```

`apply` 는 `__HOME__` 를 그 머신의 `$HOME` 으로 바꿔 `~/.claude/settings.json` 을 생성한다. 기존 파일이 있으면 `settings.json.bak.<날짜>` 로 자동 백업한다.

### 이 머신에서 바꾼 설정을 repo 에 반영하기

`/config`, 플러그인 설치, 직접 편집 등으로 `~/.claude/settings.json` 이 바뀐 뒤,

```bash
~/.agent/claude/sync-claude.sh capture
git -C ~/.agent add claude/settings.json.template
git -C ~/.agent commit -m "chore: update claude settings template"
git -C ~/.agent push
```

`capture` 는 현재 `~/.claude/settings.json` 의 `$HOME` 경로를 `__HOME__` 로 되돌려 템플릿에 덮어쓰고, `~/.claude/hooks/` 스크립트도 `hooks/` 로 회수한다. `add` 시 `claude/hooks/` 도 함께 스테이징한다.

## 동작 원리

- `apply` = `sed 's#__HOME__#$HOME#g' 템플릿 > settings.json`, 이어서 `hooks/*` 를 같은 치환으로 `~/.claude/hooks/` 에 기록.
- `capture` = `sed 's#$HOME#__HOME__#g' settings.json > 템플릿`, 이어서 `~/.claude/hooks/*` 를 역치환으로 `hooks/` 에 회수.
- settings 는 `jq empty` 로 valid JSON 인지 검사한 뒤에만 기록한다. 훅 스크립트는 실행 비트를 보존한다.

## 주의

- **홈 경로만 치환한다.** username 차이는 `__HOME__` 로 해결되지만, 머신에만 있는 도구 경로(예 `~/tools/trace/.venv`, `terminal-notifier`, gstack 스킬)는 다른 머신에 그 도구가 없으면 해당 hook 이 동작하지 않을 수 있다. 그런 hook 은 머신별로 가드(`[ -x 경로 ] && ...`)를 걸거나 비워 둔다.
- **homebrew 경로**(`/opt/homebrew` vs `/usr/local`)는 `__HOME__` 치환 대상이 아니다. Apple Silicon 과 Intel 을 섞어 쓰면 해당 줄을 직접 맞춘다.
- **비밀값 금지.** `settings.json` 에 토큰, API 키가 들어가면 그대로 공개 repo 에 올라간다. 현재 템플릿에는 비밀값이 없다. 추가될 경우 환경변수나 별도 비공개 경로로 빼고 템플릿에는 넣지 않는다.
- `apply` 가 만든 `.bak.*` 백업은 `~/.claude` 에 쌓인다. 주기적으로 정리한다.
