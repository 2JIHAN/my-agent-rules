# 코딩 규칙

## 프로젝트 초기화

작업 디렉터리에서 처음 작업할 때 (세션 첫 도구 호출 전) 한 번만 점검한다. 매 요청마다 반복하지 않는다.

1. `git rev-parse --is-inside-work-tree` 로 git repo 인지 확인.
2. repo 가 아니면 사용자에게 알린 뒤 `git init`, 성격에 맞는 `.gitignore` 작성, 현재 트리를 보여주고 `chore: initial commit` 으로 첫 커밋.
3. 이미 repo 면 그대로 진행. 사용자가 요청하기 전엔 기존 git 상태를 건드리지 않는다.

## Git 커밋 author

- author email `2jihan000@gmail.com`, name `JIHAN` (GitHub 계정 `2JIHAN`).
- `git commit` 에 `-c user.email=...` / `-c user.name=...` override 를 임의로 붙이지 않는다. 글로벌 config 가 이미 맞다. 사용자가 다른 계정을 명시한 경우만 예외.
- `qhdus08233@gmail.com` 은 Claude 사용 계정일 뿐 커밋 author 로 쓰지 않는다. 환경에 노출돼도 쓰면 안 된다.

## 커밋 메시지 스타일

- 커밋 메시지는 항상 `caveman-commit` 스킬로 생성한다. 사용자가 별도 지시 없이 커밋을 요청해도 기본으로 이 스킬을 거쳐 메시지를 만든다. 스킬이 없는 환경에서는 같은 정신 (Conventional Commits, subject ≤50자, "왜"가 자명하지 않을 때만 body) 을 수동 적용.

## `~/.agent` 저장소 (원격 `2JIHAN/my-agent-rules`)

**이 섹션은 `~/.agent` 에만 적용된다. 다른 프로젝트엔 적용하지 않는다.**

- `~/.agent` 안의 파일을 수정, 추가, 삭제한 작업을 마치면 다시 묻지 않고 곧바로 `git add`, `commit`, `push origin main`. 이 저장소에 한해 커밋, 푸시 권한은 상시 위임. 메시지는 한 줄 요약 (예 `chore: update style rule`). `.gitignore` 항목 (`.omc/`, `.DS_Store`) 은 커밋하지 않는다.
- 머신 종속 설정도 이 repo 로 동기화한다. `~/.claude/settings.json` 을 바꾸면 (`/config`, 플러그인 포함) `claude/sync-claude.sh capture`, `npx skills` 로 스킬을 추가, 삭제하면 `skills/sync-skills.sh capture` 를 돌린 뒤 위 자동 커밋 규칙대로 반영한다. 절차와 주의점은 [claude/README.md](../claude/README.md), [skills/README.md](../skills/README.md).

# 작업 자세

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
