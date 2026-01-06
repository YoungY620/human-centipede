#!/bin/bash
# 向运行中的 Human Centipede 注入消息
SESSION="${2:-skill-chat}"
QUEUE="/tmp/hc_queue.$SESSION"

if [ -z "$1" ]; then
    echo "用法: ./inject.sh '你的消息' [session-name]"
    echo "示例: ./inject.sh '请重点关注错误处理'"
    echo "      ./inject.sh '停止当前任务，改为...' my-session"
    exit 1
fi

if [ ! -e "$QUEUE" ]; then
    echo "❌ 会话 '$SESSION' 不存在或未运行"
    exit 1
fi

echo "$1" >> "$QUEUE"
echo "✅ 已注入消息到会话 '$SESSION'"
