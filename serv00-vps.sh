#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'  # 没有颜色

# 自动获取脚本的路径
SCRIPT_PATH=$(realpath "$0")

# 设置每隔 8 小时执行一次
CRON_JOB="0 */8 * * * $SCRIPT_PATH"  # 使用自动获取的脚本路径

# 检查是否已存在该 cron 任务
if crontab -l | grep -F "$CRON_JOB" > /dev/null; then
    echo -e "${GREEN}定时任务已存在，跳过添加${NC}"
else
    (crontab -l; echo "$CRON_JOB") | crontab -
    echo -e "${YELLOW}已添加定时任务，每8小时执行一次${NC}"
fi

# 显示当前的 cron 配置，仅显示当前脚本的定时任务
echo -e "${YELLOW}当前的 cron 配置如下：${NC}"
crontab -l | grep "$SCRIPT_PATH"

# 安装依赖包
install_packages() {
    if [ -f /etc/debian_version ]; then
        package_manager="apt-get install -y"
        packages="sshpass curl netcat-openbsd cron jq"
    elif [ -f /etc/redhat-release ]; then
        package_manager="yum install -y"
        packages="sshpass curl netcat-openbsd cron jq"
    elif [ -f /etc/fedora-release ]; then
        package_manager="dnf install -y"
        packages="sshpass curl netcat-openbsd cron jq"
    elif [ -f /etc/alpine-release ]; then
        package_manager="apk add --no-cache"
        packages="openssh-client curl netcat-openbsd cronie jq"
    else
        echo -e "${RED}不支持的系统架构！${NC}"
        exit 1
    fi
    $package_manager $packages > /dev/null
}

install_packages

# 下载配置文件
download_json() {
    VPS_JSON_URL="https://替换你的地址/serv00.json"  # 配置文件 URL
    if ! curl -s "$VPS_JSON_URL" -o serv00.json; then
        echo -e "${RED}配置文件下载失败，尝试使用 wget 下载！${NC}"
        if ! wget -q "$VPS_JSON_URL" -O serv00.json; then
            echo -e "${RED}配置文件下载失败，请检查下载地址是否正确！${NC}"
            exit 1
        else
            echo -e "${GREEN}配置文件通过 wget 下载成功！${NC}"
        fi
    else
        echo -e "${GREEN}配置文件通过 curl 下载成功！${NC}"
    fi

    if [[ ! -s "serv00.json" ]]; then
        echo -e "${RED}配置文件 serv00.json 不存在或为空${NC}"
        exit 1
    fi
}

download_json

# 解析 Telegram 配置
BOT_TOKEN=$(jq -r '.TELEGRAM_CONFIG.BOT_TOKEN' serv00.json)
CHAT_ID=$(jq -r '.TELEGRAM_CONFIG.CHAT_ID' serv00.json)

# 定义发送 Telegram 通知的函数，并判断是否成功推送
send_tg_notification() {
    local message=$1
    local api_url="https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
    local data="chat_id=$CHAT_ID&text=$message"

    # 使用 curl 发送消息并检查返回状态
    response=$(curl -s -w "%{http_code}" -X POST $api_url -d "$data" -o /dev/null)
    
    if [ "$response" -eq 200 ]; then
        echo -e "${GREEN}Telegram 消息发送成功！${NC}"
    else
        echo -e "${RED}Telegram 消息发送失败，错误代码: $response${NC}"
    fi
}

# 读取服务器配置并执行操作
for SERVER in $(jq -c '.SERVERS[]' serv00.json); do
    SSH_USER=$(echo "$SERVER" | jq -r '.SSH_USER')
    SSH_PASS=$(echo "$SERVER" | jq -r '.SSH_PASS')
    SSH_HOST=$(echo "$SERVER" | jq -r '.HOST')

    SERVER_ID="${SSH_USER}-${SSH_HOST}"

    # 输出开始执行的消息
    echo -e "${YELLOW}开始执行 $SERVER_ID${NC}"

    # 获取功能开关
    SINGBOX=$(jq -r '.FEATURES.SINGBOX' serv00.json)
    NEZHA_DASHBOARD=$(jq -r '.FEATURES.NEZHA_DASHBOARD' serv00.json)
    NEZHA_AGENT=$(jq -r '.FEATURES.NEZHA_AGENT' serv00.json)
    SUN_PANEL=$(jq -r '.FEATURES.SUN_PANEL' serv00.json)
    WEB_SSH=$(jq -r '.FEATURES.WEB_SSH' serv00.json)

    ENABLED_SERVICES=""

    # 判断启用的服务
    if [ "$SINGBOX" -eq 1 ]; then
        ENABLED_SERVICES+="SINGBOX "
    fi
    if [ "$NEZHA_DASHBOARD" -eq 1 ]; then
        ENABLED_SERVICES+="NEZHA_DASHBOARD "
    fi
    if [ "$NEZHA_AGENT" -eq 1 ]; then
        ENABLED_SERVICES+="NEZHA_AGENT "
    fi
    if [ "$SUN_PANEL" -eq 1 ]; then
        ENABLED_SERVICES+="SUN_PANEL "
    fi
    if [ "$WEB_SSH" -eq 1 ]; then
        ENABLED_SERVICES+="WEB_SSH "
    fi

    # 执行 SSH 操作
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$SSH_USER@$SSH_HOST" <<EOF > /dev/null 2>&1
cd /home/$SSH_USER/serv00-play/singbox || exit
nohup ./start.sh > serv00-play.log 2>&1 &

cd /home/$SSH_USER/nezha_app/agent || exit
nohup sh nezha-agent.sh > nezha-agent.log 2>&1 &

ps -A > /dev/null 2>&1  
exit
EOF

    # 检查 SSH 执行状态
    if [ $? -eq 0 ]; then
        # 成功通知
        send_tg_notification "✅ [$SERVER_ID] 脚本执行完成：服务已启动。启用的服务: $ENABLED_SERVICES"
        echo -e "${GREEN}$SERVER_ID 执行成功，启用的服务: $ENABLED_SERVICES${NC}"
    else
        # 失败通知
        send_tg_notification "❌ [$SERVER_ID] 脚本执行失败：请检查远程服务器。"
        echo -e "${RED}$SERVER_ID 执行失败${NC}"
    fi
done
