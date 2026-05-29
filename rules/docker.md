# Docker / 로컬 컨테이너 규칙

## ghostdesk 컨테이너 기동

"ghostdesk 열어줘/띄워줘", "고스트데스크 실행" 등 요청 시,

- 기본 이미지를 임의로 정하지 않는다. 아래 둘 다 정당해서 **매번 AskUserQuestion 으로 확인**.
  - `ghostdesk-vscode:latest` — 로컬 빌드. screen_shot quality/scale 패치 + VSCode 풀스택. 2.7 GB. 평소 작업용.
  - `ghcr.io/yv17labs/ghostdesk:latest` — Upstream 베이스. 1.8 GB. 깔끔한 비교/재현용.
- 기본 컨테이너명 `ghostdesk-demo`, 포트 `-p 3000:3000 -p 6080:6080`.
- 사용자가 이미지를 지정하면 ("vscode 버전으로", "upstream으로") AskUserQuestion 생략.
- 이미 떠있으면 묻지 말고 `docker ps` 로 보여준다. 교체를 명시한 경우만 stop+rm+run.

## 일반

- `docker run` 시 사용자가 영구 동작(`--restart=always` 등)을 지정 안 하면 임시 컨테이너로 본다. 임의로 restart policy 를 붙이지 않는다.
- stop/rm 등 파괴적 동작은 명시 요청 시에만. `docker ps` 보여주고 확인받는 게 표준.
