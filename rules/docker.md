# Docker / 로컬 컨테이너 규칙

## ghostdesk 컨테이너 기동

"ghostdesk 열어줘", "ghostdesk 띄워줘", "고스트데스크 실행" 등 ghostdesk MCP 컨테이너를 시작하라는 요청을 받으면:

- 자동으로 기본 이미지를 정해서 띄우지 않는다. 다음 두 이미지가 공존하고 둘 다 정당한 선택지이므로 **AskUserQuestion 으로 매번 확인한다**.
  - `ghostdesk-vscode:latest` — 로컬 빌드. screen_shot quality/scale 패치 + VSCode 풀스택. 2.7 GB. 평소 작업용.
  - `ghcr.io/yv17labs/ghostdesk:latest` — Upstream 베이스. 1.8 GB. 깔끔한 비교/재현 환경이 필요할 때.
- 기본 컨테이너명은 `ghostdesk-demo`, 포트는 `-p 3000:3000 -p 6080:6080`.
- 사용자가 직접 이미지명을 지정한 경우(예: "vscode 버전으로 띄워줘", "upstream으로 띄워줘") AskUserQuestion 생략.
- 컨테이너가 이미 떠있으면 묻지 말고 `docker ps` 결과로 그대로 보여준다. 사용자가 교체를 명시한 경우에만 stop+rm+run.

## 일반

- `docker run` 할 때 사용자가 영구 동작(`--restart=always` 등)을 지정하지 않으면 임시 컨테이너로 간주한다. 임의로 restart policy 를 추가하지 않는다.
- 컨테이너 stop/rm 등 파괴적 동작은 사용자가 명시적으로 요청한 경우에만 실행. `docker ps` 보여준 뒤 확인 받는 게 표준.
