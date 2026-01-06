#!/bin/bash
cd "$(dirname "$0")"

SESSION="${2:-skill-chat}"

# 检查是否已有同名会话
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "❌ 会话 '$SESSION' 已存在"
    echo "查看: tmux attach -t $SESSION"
    echo "停止: tmux kill-session -t $SESSION"
    exit 1
fi

tmux new -d -s "$SESSION" "./chat.sh '$1' '$SESSION'"
echo "✅ 已启动会话: $SESSION"
echo ""
echo "查看对话:  tmux attach -t $SESSION"
echo "插入消息:  echo '你的指令' >> /tmp/hc_queue.$SESSION"
echo "停止运行:  tmux kill-session -t $SESSION"
