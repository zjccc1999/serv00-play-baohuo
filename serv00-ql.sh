#!/bin/bash

# 颜色定义函数
colorize() {
    local color="$1"
    local text="$2"
    case "$color" in
        red)    echo -e "\033[0;31m$text\033[0m" ;;
        green)  echo -e "\033[0;32m$text\033[0m" ;;
        yellow) echo -e "\033[0;33m$text\033[0m" ;;
        blue)   echo -e "\033[0;34m$text\033[0m" ;;
        *)      echo "$text" ;;
    esac
}

# 从环境变量中读取信息
SERVERS="${SERVERS:-}"  # 多个服务器信息，格式为 user:pass:host 用逗号分隔
BOT_TOKEN="${BOT_TOKEN:-}"  # Telegram Bot Token，可选
CHAT_ID="${CHAT_ID:-}"      # Telegram Chat ID，可选
WXPUSHER_TOKEN="${WXPUSHER_TOKEN:-}"  # WxPusher Token
PUSHPLUS_TOKEN="${PUSHPLUS_TOKEN:-}"  # PushPlus Token
WXPUSHER_USER_ID="${WXPUSHER_USER_ID:-}"  # WxPusher User ID

# 通知服务选择（0: 不启用，1: TG，2: WxPusher，3: PushPlus，4: TG+WxPusher，5: TG+PushPlus）
NOTIFY_SERVICE="${NOTIFY_SERVICE:-0}"  # 默认为 0（不启用通知）

# 控制每个服务是否运行，默认值为 2（不运行）
NEZHA_DASHBOARD="${NEZHA_DASHBOARD:-2}"  # 默认不运行
NEZHA_AGENT="${NEZHA_AGENT:-2}"          # 默认不运行
SUN_PANEL="${SUN_PANEL:-2}"              # 默认不运行
WEB_SSH="${WEB_SSH:-2}"                  # 默认不运行

# 默认启动 SINGBOX
SINGBOX="${SINGBOX:-1}"                  # 默认运行 singbox

# 自定义 Telegram 通知函数（当 BOT_TOKEN 和 CHAT_ID 存在时才启用）
send_tg_notification() {
    local message=$1
    [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ] && { echo "Telegram 通知未启用"; return 0; }
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" -o /dev/null && colorize green "Telegram 消息发送成功" || colorize red "Telegram 消息发送失败"
}

# WxPusher 发送消息函数
send_wxpusher_message() {
  local title="$1"
  local content="$2"
  curl -s -X POST "https://wxpusher.zjiecode.com/api/send/message" \
    -H "Content-Type: application/json" \
    -d "{
      \"appToken\": \"$WXPUSHER_TOKEN\",
      \"content\": \"$content\",
      \"title\": \"$title\",
      \"uids\": [\"$WXPUSHER_USER_ID\"]
    }" > /dev/null 2>&1
}

# 发送 PushPlus 消息的函数
send_pushplus_message() {
  local title="$1"
  local content="$2"
  curl -s -X POST "http://www.pushplus.plus/send" \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$PUSHPLUS_TOKEN\",\"title\":\"$title\",\"content\":\"<pre>$content</pre>\"}" > /dev/null 2>&1
}

# 初始化结果汇总并增加表头
RESULT_SUMMARY="青龙自动化结果：\n--------------\n"

# 显示启用的通知服务和服务
colorize blue "启用的通知服务："
case "$NOTIFY_SERVICE" in
    1) colorize green "Telegram" ;;
    2) colorize green "WxPusher" ;;
    3) colorize green "PushPlus" ;;
    4) colorize green "Telegram 和 WxPusher" ;;
    5) colorize green "Telegram 和 PushPlus" ;;
    *) colorize red "没有启用通知" ;;
esac

colorize blue "启用的服务："
[[ "$SINGBOX" -eq 1 ]] && colorize green "Singbox"
[[ "$NEZHA_DASHBOARD" -eq 1 ]] && colorize green "Nezha Dashboard"
[[ "$NEZHA_AGENT" -eq 1 ]] && colorize green "Nezha Agent"
[[ "$SUN_PANEL" -eq 1 ]] && colorize green "Sun Panel"
[[ "$WEB_SSH" -eq 1 ]] && colorize green "Web SSH"

# 遍历每个服务器
IFS=',' read -ra SERVER_LIST <<< "$SERVERS"  # 按逗号分隔服务器列表
for SERVER in "${SERVER_LIST[@]}"; do
    # 分解每个服务器的用户名、密码、地址
    IFS=':' read -r SSH_USER SSH_PASS SSH_HOST <<< "$SERVER"
    SERVER_ID="${SSH_USER}-${SSH_HOST}"

    colorize yellow "开始执行 ${SERVER_ID}"

    ssh_cmd=""

    # 执行服务命令（按需启动）
    [[ "$SINGBOX" -eq 1 ]] && ssh_cmd+="cd /home/$SSH_USER/serv00-play/singbox || true; pkill -f 'singbox' || true; nohup ./start.sh > singbox_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
    [[ "$NEZHA_DASHBOARD" -eq 1 ]] && ssh_cmd+="cd /home/$SSH_USER/nezha_app/dashboard || true; pkill -f 'nezha-dashboard' || true; nohup ./nezha-dashboard > nezha-dashboard_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
    [[ "$NEZHA_AGENT" -eq 1 ]] && ssh_cmd+="cd /home/$SSH_USER/nezha_app/agent || true; pkill -f 'nezha-agent' || true; nohup sh nezha-agent.sh > nezha-agent_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
    [[ "$SUN_PANEL" -eq 1 ]] && ssh_cmd+="cd /home/$SSH_USER/serv00-play/sunpanel || true; nohup ./sun-panel > sunpanel_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
    [[ "$WEB_SSH" -eq 1 ]] && ssh_cmd+="cd /home/$SSH_USER/serv00-play/webssh || true; nohup ./wssh > webssh_$(date +%Y%m%d_%H%M%S).log 2>&1 & "

    # 执行命令并检查是否成功
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$SSH_USER@$SSH_HOST" <<EOF > /dev/null 2>&1
$ssh_cmd
ps -A > /dev/null 2>&1
exit
EOF

    if [ $? -eq 0 ]; then
        colorize green "${SERVER_ID} 执行成功"
        services_started="singbox, nezha-dashboard, nezha-agent, sun-panel, webssh"  # 可以根据实际启用的服务修改
        # 根据选择的通知服务发送消息
        [[ "$NOTIFY_SERVICE" -eq 1 ]] && send_tg_notification "✅ [$SERVER_ID] 脚本执行完成：服务已启动。启用的服务: $services_started"
        [[ "$NOTIFY_SERVICE" -eq 2 ]] && send_wxpusher_message "执行完成" "服务器 [$SERVER_ID] 启动的服务: $services_started"
        [[ "$NOTIFY_SERVICE" -eq 3 ]] && send_pushplus_message "执行完成" "服务器 [$SERVER_ID] 启动的服务: $services_started"
        [[ "$NOTIFY_SERVICE" -eq 4 ]] && { send_tg_notification "✅ [$SERVER_ID] 脚本执行完成：服务已启动。启用的服务: $services_started"; send_wxpusher_message "执行完成" "服务器 [$SERVER_ID] 启动的服务: $services_started"; }
        [[ "$NOTIFY_SERVICE" -eq 5 ]] && { send_tg_notification "✅ [$SERVER_ID] 脚本执行完成：服务已启动。启用的服务: $services_started"; send_pushplus_message "执行完成" "服务器 [$SERVER_ID] 启动的服务: $services_started"; }
    else
        colorize red "${SERVER_ID} 执行失败"
        # 根据选择的通知服务发送消息
        [[ "$NOTIFY_SERVICE" -eq 1 ]] && send_tg_notification "❌ [$SERVER_ID] 脚本执行失败：请检查远程服务器。"
        [[ "$NOTIFY_SERVICE" -eq 2 ]] && send_wxpusher_message "执行失败" "服务器 [$SERVER_ID] 执行失败，请检查。"
        [[ "$NOTIFY_SERVICE" -eq 3 ]] && send_pushplus_message "执行失败" "服务器 [$SERVER_ID] 执行失败，请检查。"
        [[ "$NOTIFY_SERVICE" -eq 4 ]] && { send_tg_notification "❌ [$SERVER_ID] 脚本执行失败：请检查远程服务器。"; send_wxpusher_message "执行失败" "服务器 [$SERVER_ID] 执行失败，请检查。"; }
        [[ "$NOTIFY_SERVICE" -eq 5 ]] && { send_tg_notification "❌ [$SERVER_ID] 脚本执行失败：请检查远程服务器。"; send_pushplus_message "执行失败" "服务器 [$SERVER_ID] 执行失败，请检查。"; }
    fi
done
