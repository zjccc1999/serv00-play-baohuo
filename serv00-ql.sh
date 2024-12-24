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
ALIST="${ALIST:-2}"                      # 默认不运行 Alist

# 默认启动 SINGBOX
SINGBOX="${SINGBOX:-1}"                  # 默认运行 singbox

# 启用所有服务的标志（默认为 false，不启用所有服务）
ENABLE_ALL_SERVICES="${ENABLE_ALL_SERVICES:-false}"

# 如果启用所有服务，则设置每个服务为启用状态
if [ "$ENABLE_ALL_SERVICES" == "true" ]; then
    SINGBOX=1
    NEZHA_DASHBOARD=1
    NEZHA_AGENT=1
    SUN_PANEL=1
    WEB_SSH=1
    ALIST=1
    colorize green "已启用所有服务"
fi

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
    if [[ $? -eq 0 ]]; then
        colorize green "WxPusher 消息发送成功"
    else
        colorize red "WxPusher 消息发送失败"
    fi
}

# 发送 PushPlus 消息的函数
send_pushplus_message() {
    local title="$1"
    local content="$2"
    curl -s -X POST "http://www.pushplus.plus/send" \
        -H "Content-Type: application/json" \
        -d "{\"token\":\"$PUSHPLUS_TOKEN\",\"title\":\"$title\",\"content\":\"<pre>$content</pre>\"}" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        colorize green "PushPlus 消息发送成功"
    else
        colorize red "PushPlus 消息发送失败"
    fi
}

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
[[ "$ALIST" -eq 1 ]] && colorize green "Alist"

# 将逗号分隔的账户信息解析成一个数组
IFS=',' read -ra SERVER_LIST <<< "$SERVERS"  # 按逗号分隔服务器列表
for SERVER in "${SERVER_LIST[@]}"; do
    # 分解每个服务器的用户名、密码、地址
    IFS=':' read -r SSH_USER SSH_PASS SSH_HOST <<< "$SERVER"
    SERVER_ID="${SSH_USER}-${SSH_HOST}"

    colorize yellow "开始执行 ${SERVER_ID}"

    ssh_cmd=""
    services_started=""

    # 统一检查各个服务的目录是否存在，跳过不存在的目录
    check_and_add_service() {
        local service_name=$1
        local service_path=$2
        if sshpass -p "$SSH_PASS" ssh -o LogLevel=QUIET -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SSH_HOST" "test -d $service_path"; then
            ssh_cmd+="cd $service_path || true; pkill -f '$service_name' || true; nohup ./$service_name > ${service_name}_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
            services_started+="$service_name, "
        else
            colorize red "目录 $service_path 不存在，跳过 $service_name 服务"
        fi
    }

    # 依次检查每个服务的目录并启动
    [[ "$SINGBOX" -eq 1 ]] && check_and_add_service "singbox" "/home/$SSH_USER/serv00-play/singbox"
    [[ "$NEZHA_DASHBOARD" -eq 1 ]] && check_and_add_service "nezha-dashboard" "/home/$SSH_USER/nezha_app/dashboard"
    [[ "$NEZHA_AGENT" -eq 1 ]] && check_and_add_service "nezha-agent" "/home/$SSH_USER/nezha_app/agent"
    [[ "$SUN_PANEL" -eq 1 ]] && check_and_add_service "sun-panel" "/home/$SSH_USER/serv00-play/sunpanel"
    [[ "$WEB_SSH" -eq 1 ]] && check_and_add_service "wssh" "/home/$SSH_USER/serv00-play/webssh"
    [[ "$ALIST" -eq 1 ]] && check_and_add_service "alist" "/home/$SSH_USER/serv00-play/alist"

    # 执行构建的 SSH 命令
    sshpass -p "$SSH_PASS" ssh -o LogLevel=QUIET -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SSH_HOST" "$ssh_cmd"

    # 如果有启动的服务，发送通知
    if [ -n "$services_started" ]; then
        services_started=${services_started%, }  # 去掉最后的逗号
        colorize green "${SERVER_ID} 执行成功"

        message="✅ ${SERVER_ID} 脚本执行完成：已执行服务：$services_started"

        # 根据选择的通知方式发送消息
        case "$NOTIFY_SERVICE" in
            1) send_tg_notification "$message" ;;
            2) send_wxpusher_message "$SERVER_ID 执行成功" "$message" ;;
            3) send_pushplus_message "$SERVER_ID 执行成功" "$message" ;;
            4)
                send_tg_notification "$message"
                send_wxpusher_message "$SERVER_ID 执行成功" "$message"
                ;;
            5)
                send_tg_notification "$message"
                send_pushplus_message "$SERVER_ID 执行成功" "$message"
                ;;
            *) colorize yellow "未启用通知服务" ;;
        esac
    fi
done
