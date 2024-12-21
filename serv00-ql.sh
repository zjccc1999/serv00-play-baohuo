#!/bin/bash

# 从环境变量中读取信息
SERVERS="${SERVERS:-}"  # 多个服务器信息，格式为 user:pass:host 用逗号分隔
BOT_TOKEN="${BOT_TOKEN:-}"  # Telegram Bot Token，可选
CHAT_ID="${CHAT_ID:-}"      # Telegram Chat ID，可选

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

    # 检查是否配置了 Telegram 的相关变量
    if [ -z "$BOT_TOKEN" ] || [ -z "$CHAT_ID" ]; then
        echo "Telegram 通知未启用（未设置 BOT_TOKEN 或 CHAT_ID）。"
        return 0
    fi

    response=$(curl -s -w "%{http_code}" -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" -o /dev/null)

    if [ "$response" -eq 200 ]; then
        echo "Telegram 消息发送成功：${message}"
    else
        echo "Telegram 消息发送失败，错误代码: $response"
    fi
}

# 遍历每个服务器
IFS=',' read -ra SERVER_LIST <<< "$SERVERS"  # 按逗号分隔服务器列表
for SERVER in "${SERVER_LIST[@]}"; do
    # 分解每个服务器的用户名、密码、地址
    IFS=':' read -r SSH_USER SSH_PASS SSH_HOST <<< "$SERVER"

    # 组合 SSH 用户和主机名
    SERVER_ID="${SSH_USER}-${SSH_HOST}"

    echo "开始执行 ${SERVER_ID}"

    # 启动服务列表
    services_started=""

    # 构建服务启动命令
    ssh_cmd=""

    # 如果启用了 SINGBOX 服务
    if [ "$SINGBOX" -eq 1 ]; then
        ssh_cmd+="cd /home/$SSH_USER/serv00-play/singbox || true; nohup ./start.sh > serv00-play_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
        services_started+="singbox, "
    fi

    # 如果启用了 NEZHA_DASHBOARD 服务
    if [ "$NEZHA_DASHBOARD" -eq 1 ]; then
        ssh_cmd+="cd /home/$SSH_USER/nezha_app/dashboard || true; pkill -f 'nezha-dashboard' || true; nohup ./nezha-dashboard > nezha-dashboard_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
        services_started+="nezha-dashboard, "
    fi

    # 如果启用了 NEZHA_AGENT 服务
    if [ "$NEZHA_AGENT" -eq 1 ]; then
        ssh_cmd+="cd /home/$SSH_USER/nezha_app/agent || true; pgrep -f '/nezha-agent -c /home/$SSH_USER/nezha_app/agent/config.yml' | xargs -r kill -9; nohup sh nezha-agent.sh > nezha-agent_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
        services_started+="nezha-agent, "
    fi

    # 如果启用了 SUN_PANEL 服务
    if [ "$SUN_PANEL" -eq 1 ]; then
        ssh_cmd+="cd /home/$SSH_USER/serv00-play/sunpanel || true; nohup ./sun-panel > sunpanel_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
        services_started+="sun-panel, "
    fi

    # 如果启用了 WEB_SSH 服务
    if [ "$WEB_SSH" -eq 1 ]; then
        ssh_cmd+="cd /home/$SSH_USER/serv00-play/webssh || true; nohup ./wssh > webssh_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
        services_started+="webssh, "
    fi

    # 去掉最后一个逗号和空格
    services_started=$(echo "$services_started" | sed 's/, $//')

    # 执行 SSH 操作
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$SSH_USER@$SSH_HOST" <<EOF > /dev/null 2>&1
$ssh_cmd
ps -A > /dev/null 2>&1
exit
EOF

    # 检查 SSH 执行状态
    if [ $? -eq 0 ]; then
        if [ -z "$services_started" ]; then
            services_started="无"
        fi
        echo "${SERVER_ID} 执行成功，启用的服务: $services_started"
        send_tg_notification "✅ [$SERVER_ID] 脚本执行完成：服务已启动。启用的服务: $services_started"
    else
        echo "${SERVER_ID} 执行失败"
        send_tg_notification "❌ [$SERVER_ID] 脚本执行失败：请检查远程服务器。"
    fi
done
