# 권한 베이스라인 + 도구별 설정 경로

## 권한 베이스라인 (모든 AI 에이전트 공통)

각 에이전트 (Claude Code, Gemini CLI, OpenCode, Codex CLI 등) 는 자체 설정 형식으로 옮길 때 아래 의미를 보존한다. 키 이름은 도구별로 다를 수 있으므로 의미 기준으로 매핑한다.

```jsonc
{
  "permissions": {
    "defaultMode": "default",

    "allow": [
      // 파일 시스템
      "read",
      "write",
      "edit",

      // 셸 (위험 패턴은 아래 deny 로 차단됨)
      "bash:*",

      // 웹
      "web_search",
      "web_fetch",

      // 보조 도구
      "todo_write",
      "glob",
      "grep",
      "skill",
      "notebook_edit",

      // MCP 서버 (사용 중인 것만 화이트리스트로 추가)
      "mcp:notion:*",
      "mcp:gmail:*",
      "mcp:google_calendar:*",
      "mcp:google_drive:*",
      "mcp:vercel:*",
      "mcp:drawio:*"
    ],

    "deny": [
      // 권한 상승
      "bash:sudo *",

      // 파괴적 파일 삭제
      "bash:rm -rf *",
      "bash:rm -r *",
      "bash:rm /",
      "bash:find / -delete",
      "bash:shred *",

      // 시스템 이동/변조
      "bash:mv / *",

      // 파이프 실행 (위험한 원격 스크립트 실행)
      "bash:curl * | bash",
      "bash:wget * | bash",

      // git 파괴 작업
      "bash:git push --force *",
      "bash:git reset --hard *",
      "bash:git clean -fd*",
      "bash:git clean -fdx*",
      "bash:git checkout .",
      "bash:git restore .",

      // 시스템 종료, 재부팅
      "bash:reboot",
      "bash:shutdown *",

      // 디스크/파티션 파괴
      "bash:dd *",
      "bash:mkfs *",
      "bash:diskutil eraseDisk*",
      "bash:diskutil eraseVolume*",
      "bash:mkswap *",
      "bash:fdisk *",
      "bash:parted *",

      // 네트워크/방화벽 무력화
      "bash:iptables -F",
      "bash:ufw disable",

      // 자동화 파괴
      "bash:crontab -r*",

      // 권한 무력화
      "bash:chmod -R 777 *",
      "bash:chmod 777 *",
      "bash:chown -R *",

      // 프로세스 강제 종료
      "bash:killall *",
      "bash:kill -9 1",

      // 외부 부수효과가 있는 도구 중 되돌릴 수 없는 것
      "mcp:google_calendar:delete_event"
    ]
  }
}
```

표기 규약,

- `bash:<pattern>` 는 셸 호출 패턴, glob `*` 허용.
- `mcp:<server>:<tool>` 은 MCP 서버 도구 패턴, `*` 로 서버 단위 허용 가능.
- 도구별 실제 키 형식 (예 Claude `Bash(sudo *)`) 은 각 에이전트 설정 파일에서 위 의미에 맞게 변환해 등록한다.
- `allow` 와 `deny` 가 충돌하면 `deny` 우선.
- MCP 서버는 실제로 사용 중인 것만 등록한다. 사용하지 않는 서버를 미리 열어두지 않는다.

## 도구별 전용 설정 경로

| 도구 | 전역 설정 파일 | 전역 규칙 진입점 |
|---|---|---|
| Claude Code | `~/.claude/settings.json` | `~/.claude/CLAUDE.md` |
| Gemini CLI | `~/.gemini/settings.json` | - |
| Codex CLI | `~/.codex/config.toml` | - |
| OpenCode | `~/.config/opencode/opencode.json` | `~/.config/opencode/AGENTS.md` |
