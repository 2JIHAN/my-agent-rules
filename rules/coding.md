# 코딩 규칙

## 프로젝트 초기화

작업 디렉터리에서 처음 작업을 시작할 때 (세션의 첫 도구 호출 전에) 한 번 점검한다.

1. **git 확인**, `git rev-parse --is-inside-work-tree` 로 git repo 인지 확인.
2. **없으면 초기화**, repo 가 아니면 사용자에게 알린 뒤 `git init` 실행, 적절한 `.gitignore` 가 없으면 프로젝트 성격에 맞게 작성, 현재 트리를 `git add` 한 뒤 `chore: initial commit` 메시지로 첫 커밋 생성. 이미 untracked 파일이 있어도 사용자 의도일 수 있으므로 커밋 전에 한 번 보여준다.
3. **있으면 그대로 진행**, 추가 동작 없음. 사용자가 명시적으로 요청하기 전엔 기존 git 상태를 건드리지 않는다.

이 점검은 세션당 한 번이면 충분하다. 매 요청마다 반복하지 않는다.

## Git 커밋 author

- 모든 git 커밋의 author email 은 **`2jihan000@gmail.com`** (GitHub 계정 `2JIHAN`) 을 사용한다.
- author name 은 `JIHAN`.
- `git commit` 시 `-c user.email=...` / `-c user.name=...` 을 임의로 덮어쓰지 않는다. 사용자가 명시적으로 다른 계정을 지정한 경우에만 예외.
- `qhdus08233@gmail.com` 은 Claude 사용 계정일 뿐 커밋용이 아니다. 환경에서 자동 노출되더라도 커밋 author 로 쓰면 안 된다.
- 글로벌 `git config user.email` 은 이미 올바르게 설정돼 있으므로 그대로 두면 된다. 별도 override 만 피한다.

---

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
