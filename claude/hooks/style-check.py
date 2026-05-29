#!/usr/bin/env python3
"""Stop-hook style guard.

Reads the last assistant message from the transcript and blocks the stop
when it finds either of two style violations from rules/style.md:

  1. middot (`·` or `•`) used in text (enumeration should use commas).
  2. a line ending with a colon immediately before a fenced code block
     or a bullet/numbered list (labels that introduce lists/code must not
     end with a colon).

Code-fence interiors are ignored for the middot check.
"""

import json
import re
import sys

BULLET = re.compile(r"^([-*+]\s+|\d+[.)]\s+)")


def last_assistant_text(transcript_path):
    text = None
    try:
        with open(transcript_path, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    evt = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if evt.get("type") != "assistant":
                    continue
                msg = evt.get("message", {})
                if msg.get("role") != "assistant":
                    continue
                parts = []
                for block in msg.get("content", []):
                    if isinstance(block, dict) and block.get("type") == "text":
                        parts.append(block.get("text", ""))
                if parts:
                    text = "".join(parts)
    except OSError:
        return None
    return text


def find_violations(text):
    violations = []
    in_fence = False
    prev = None  # previous non-blank, non-fence line outside code
    for line in text.split("\n"):
        stripped = line.strip()
        if stripped.startswith("```"):
            if not in_fence and prev is not None and prev.rstrip().endswith(":"):
                violations.append('콜론 뒤 코드블록: "%s"' % prev.strip())
            in_fence = not in_fence
            prev = None
            continue
        if in_fence:
            continue
        if "·" in line or "•" in line:
            violations.append('가운뎃점: "%s"' % stripped)
        if BULLET.match(stripped) and prev is not None and prev.rstrip().endswith(":"):
            violations.append('콜론 뒤 목록: "%s"' % prev.strip())
        if stripped:
            prev = line
    return violations


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    if data.get("stop_hook_active"):
        sys.exit(0)

    transcript_path = data.get("transcript_path")
    if not transcript_path:
        sys.exit(0)

    text = last_assistant_text(transcript_path)
    if not text:
        sys.exit(0)

    violations = find_violations(text)
    if not violations:
        sys.exit(0)

    reason = (
        "문체 규칙 위반 감지. 마지막 응답 고치고 다시 출력.\n"
        + "\n".join("- " + v for v in violations[:20])
        + "\n\n규칙: 가운뎃점 대신 쉼표. 코드블록/목록 도입 레이블 뒤 콜론 제거."
    )
    print(json.dumps({"decision": "block", "reason": reason}))
    sys.exit(0)


if __name__ == "__main__":
    main()
