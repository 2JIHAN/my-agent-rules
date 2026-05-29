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

## `~/.agent` 저장소 (원격 `2JIHAN/my-agent-rules`)

**이 섹션은 `~/.agent` 에만 적용된다. 다른 프로젝트엔 적용하지 않는다.**

- `~/.agent` 안의 파일을 수정, 추가, 삭제한 작업을 마치면 다시 묻지 않고 곧바로 `git add`, `commit`, `push origin main`. 이 저장소에 한해 커밋, 푸시 권한은 상시 위임. 메시지는 한 줄 요약 (예 `chore: update style rule`). `.gitignore` 항목 (`.omc/`, `.DS_Store`) 은 커밋하지 않는다.
- 머신 종속 설정도 이 repo 로 동기화한다. `~/.claude/settings.json` 을 바꾸면 (`/config`, 플러그인 포함) `claude/sync-claude.sh capture`, `npx skills` 로 스킬을 추가, 삭제하면 `skills/sync-skills.sh capture` 를 돌린 뒤 위 자동 커밋 규칙대로 반영한다. 절차와 주의점은 [claude/README.md](../claude/README.md), [skills/README.md](../skills/README.md).

## 작업 자세

사소하지 않은 작업 전에 적용. 사소한 변경은 판단껏 건너뛴다.

- **가정 드러내기** 불명확하면 멈추고 묻는다. 해석이 여러 갈래면 임의로 고르지 말고 제시한다. 더 단순한 길이 있으면 말한다. (계획 단계는 [planning.md](planning.md) 의 grill 디폴트.)
- **최소 구현** 요청 범위 밖 기능, 단일 사용처 추상화, 안 시킨 유연성, 불가능한 시나리오의 에러 처리를 넣지 않는다. 200줄이 50줄로 되면 다시 쓴다.
- **수술적 변경** 고칠 것만 건드린다. 안 깨진 코드 리팩터 금지, 기존 스타일 유지. 내 변경이 만든 orphan (안 쓰는 import, 변수) 만 정리하고 기존 dead code 는 삭제 대신 언급. 바뀐 모든 줄이 요청에 직결돼야 한다.
- **성공 기준 먼저** 작업을 검증 가능한 목표로 바꾼다 (예 "검증 추가" → "잘못된 입력 테스트 작성 후 통과"). 완료를 주장하기 전에 그 기준으로 확인한다.
