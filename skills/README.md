# 글로벌 스킬 동기화 (npx skills)

`npx skills`(vercel-labs/skills)로 깐 **글로벌 에이전트 스킬**을 여러 머신 사이에서 git(`my-agent-rules` remote)으로 재현한다.

스킬 자체는 `~/.agents/skills/`에 설치되고, 그 목록과 출처는 `~/.agents/.skill-lock.json`이 관리한다. 이 repo에는 **스킬 파일을 복사하지 않고 락파일만** 기록한다(서드파티 내용을 떠안지 않기 위해). 다른 머신에서는 락의 출처 repo별로 `npx skills add`를 다시 돌려 같은 스킬셋을 재현한다.

## 구성

| 파일 | 역할 |
|---|---|
| `skill-lock.json` | `~/.agents/.skill-lock.json`의 git 추적 사본. 어떤 스킬을 어느 repo에서 깔았는지의 기록. |
| `sync-skills.sh` | `capture`(라이브 락 → repo) / `apply`(repo 락 → 재설치). |

## 빠른 시작

### 이 머신의 스킬 목록을 repo에 기록

```bash
~/.agent/skills/sync-skills.sh capture
git -C ~/.agent add skills/skill-lock.json
git -C ~/.agent commit -m "chore: update global skills lock"
git -C ~/.agent push
```

### 다른 머신에서 같은 스킬 재현

```bash
git -C ~/.agent pull
~/.agent/skills/sync-skills.sh apply
npx skills list -g   # 확인
```

`apply`는 락을 출처 repo별로 묶어 아래 형태로 재설치한다.

```bash
npx skills add JuliusBrussee/caveman -g -y -a claude-code -s "caveman,cavecrew,..."
npx skills add mattpocock/skills     -g -y -a claude-code -s "diagnose,grill-me,..."
npx skills add vercel-labs/skills    -g -y -a claude-code -s "find-skills"
```

## 왜 락만 기록하나

- `npx skills experimental_install`은 **프로젝트 전용**(cwd의 `skills-lock.json`)이라 글로벌 스킬 복원에는 못 쓴다. 그래서 글로벌은 출처 repo별 `add` 재실행으로 재현한다.
- 락파일에는 절대경로가 없다(출처 github repo, 내용 해시, 설치 시각, 대상 에이전트 목록만). 그래서 머신이 달라도 그대로 포팅된다.

## 주의

- **Node.js/npx 필요.** 복원 머신에 없으면 `apply`가 멈춘다.
- **대상 에이전트는 `claude-code` 고정.** 현재 `npx skills list -g` 기준 설치 대상이 Claude Code다. 다른 에이전트(codex, cursor 등)에도 깔려면 `sync-skills.sh`의 `-a claude-code`를 바꾼다.
- **버전 고정 아님.** `add`는 각 repo의 최신을 받는다. 업스트림이 바뀌면 재현물도 최신으로 따라간다. 정확한 버전 고정이 필요하면 락의 `skillFolderHash`를 별도로 대조한다.
- 스킬을 새로 깔거나 지운 뒤에는 `capture` → commit 해야 repo 기록이 최신이 된다.
