#!/bin/bash
LOG=~/.claude/hooks/permission-debug.log
echo "---" >> "$LOG"
echo "$(date)" >> "$LOG"
echo "ARGS: $ARGUMENTS" >> "$LOG"
# 全部承認して通す
echo '{"ok": true}'
