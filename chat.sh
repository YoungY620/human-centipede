#!/bin/bash
# Human Centipede: Skill Builder 与 Skill Tester 自动对谈
cd "$(dirname "$0")"

SESSION_NAME="${2:-$$}"
LOG="chat_$(date +%Y%m%d_%H%M%S).jsonl"
TASK="${1:-请帮我创建一个用于将 Markdown 文件转换为 PDF 的 skill，要求说明清晰、步骤具体、包含示例。}"

# 消息队列文件
MSG_QUEUE="/tmp/hc_queue.$SESSION_NAME"

# 每轮结束后追加的提示
BUILDER_SUFFIX="

[SYSTEM REMINDER] 完成本轮修改后，你必须执行 git add 和 git commit 提交你的改动，commit message 简洁描述本次改动。"

TESTER_SUFFIX="

[SYSTEM REMINDER] 请继续严格测试，找出所有问题。"

echo -e "\033[1;32m🚀 Human Centipede\033[0m"
echo -e "\033[0;90m任务: $TASK\033[0m"
echo -e "\033[0;90m日志: $LOG\033[0m"
echo -e "\033[0;90m插入消息: echo '你的消息' >> $MSG_QUEUE\033[0m"
echo -e "\033[0;90mCtrl+C 停止\033[0m\n"

cleanup() {
    echo -e "\n\033[1;31m⏹️  停止\033[0m"
    rm -f /tmp/hc_a.$SESSION_NAME /tmp/hc_b.$SESSION_NAME "$MSG_QUEUE"
    kill $(jobs -p) 2>/dev/null
    exit 0
}
trap cleanup EXIT INT TERM

FIFO_A="/tmp/hc_a.$SESSION_NAME"
FIFO_B="/tmp/hc_b.$SESSION_NAME"
rm -f "$FIFO_A" "$FIFO_B" "$MSG_QUEUE"
mkfifo "$FIFO_A" "$FIFO_B"
touch "$MSG_QUEUE"

# 检查并读取队列中的消息
check_queue() {
    if [ -s "$MSG_QUEUE" ]; then
        local msg=$(cat "$MSG_QUEUE")
        > "$MSG_QUEUE"  # 清空队列
        echo "$msg"
    fi
}

# 显示并转发，追加提示词和队列消息
relay() {
    local name="$1" color="$2" suffix="$3"
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        echo "$line" >> "$LOG"
        # 显示
        local txt=$(echo "$line" | jq -r 'select(.role=="assistant")|if .content|type=="array" then [.content[]|select(.type=="text")|.text]|join("") else .content//"" end' 2>/dev/null)
        [ -n "$txt" ] && echo -e "${color}[$name]\033[0m $txt" >&2
        
        # 检查队列
        local queue_msg=$(check_queue)
        local extra_suffix="$suffix"
        if [ -n "$queue_msg" ]; then
            extra_suffix="$suffix

[HUMAN INTERVENTION] $queue_msg"
            echo -e "\033[1;33m[Human]\033[0m $queue_msg" >&2
        fi
        
        # 转发：转换角色并追加提示
        echo "$line" | jq -c --arg suffix "$extra_suffix" '
            select(.role=="assistant") | 
            .role="user" | 
            if .content|type=="array" then 
                .content += [{"type":"text","text":$suffix}]
            else 
                .content = (.content // "") + $suffix 
            end
        ' 2>/dev/null
    done
}

# Builder: 收到消息后处理，完成后要 commit
cat "$FIFO_A" \
    | kimi --print -y --agent-file ./agents/skill-builder/agent.yaml --input-format stream-json --output-format stream-json 2>/dev/null \
    | relay "Builder" "\033[1;32m" "$TESTER_SUFFIX" \
    > "$FIFO_B" &

sleep 1

# Tester: 发起任务，收到 Builder 的结果后继续测试
INIT=$(jq -nc --arg c "$TASK" '{"role":"user","content":$c}')
{ echo "$INIT"; cat "$FIFO_B"; } \
    | kimi --print -y --agent-file ./agents/skill-tester/agent.yaml --input-format stream-json --output-format stream-json 2>/dev/null \
    | relay "Tester" "\033[1;34m" "$BUILDER_SUFFIX" \
    > "$FIFO_A"

wait
