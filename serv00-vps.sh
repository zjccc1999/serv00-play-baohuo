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
    VPS_JSON_URL="https://xxxxxxxxxxxxx/serv00.json"  # 配置文件 URL
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

# 解析配置文件
BOT_TOKEN=$(jq -r '.TELEGRAM_CONFIG.BOT_TOKEN' serv00.json)
CHAT_ID=$(jq -r '.TELEGRAM_CONFIG.CHAT_ID' serv00.json)

# 解析通知方式
NOTIFICATION=$(jq -r '.NOTIFICATION' serv00.json)
ENABLED_NOTIFICATIONS=""
if [ "$NOTIFICATION" -eq 1 ]; then
    ENABLED_NOTIFICATIONS+="Telegram "
elif [ "$NOTIFICATION" -eq 2 ]; then
    ENABLED_NOTIFICATIONS+="无通知"
else
    ENABLED_NOTIFICATIONS="无通知"
fi

echo -e "${YELLOW}当前启用的通知方式：${NC} $ENABLED_NOTIFICATIONS"

# 获取功能开关
SINGBOX=$(jq -r '.FEATURES.SINGBOX' serv00.json)
NEZHA_DASHBOARD=$(jq -r '.FEATURES.NEZHA_DASHBOARD' serv00.json)
NEZHA_AGENT=$(jq -r '.FEATURES.NEZHA_AGENT' serv00.json)
SUN_PANEL=$(jq -r '.FEATURES.SUN_PANEL' serv00.json)
WEB_SSH=$(jq -r '.FEATURES.WEB_SSH' serv00.json)
ALIST=$(jq -r '.FEATURES.ALIST' serv00.json)

# 检查 ENABLE_ALL_SERVICES
ENABLE_ALL_SERVICES=$(jq -r '.ENABLE_ALL_SERVICES' serv00.json)

# 如果 ENABLE_ALL_SERVICES 为 true，则启用所有服务
if [ "$ENABLE_ALL_SERVICES" == "true" ]; then
    SINGBOX=1
    NEZHA_DASHBOARD=1
    NEZHA_AGENT=1
    SUN_PANEL=1
    WEB_SSH=1
    ALIST=1
fi

ENABLED_SERVICES=""

# 判断启用的服务
if [ "$SINGBOX" -eq 1 ]; then
    ENABLED_SERVICES+="SINGBOX "
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
if [ "$ALIST" -eq 1 ]; then
    ENABLED_SERVICES+="ALIST "
fi

echo -e "${YELLOW}当前启用的服务：${NC} $ENABLED_SERVICES"

# 发送 Telegram 通知的函数
send_tg_notification() {
    local message=$1
    response=$(curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$message")
    
    if [[ "$response" == *"ok"* ]]; then
        echo -e "${GREEN}通知发送成功！${NC}"
    else
        echo -e "${RED}通知发送失败！${NC}"
    fi
}

# 统一检查各个服务的目录是否存在，跳过不存在的目录
check_and_add_service() {
    local service_name=$1
    local service_path=$2
    if sshpass -p "$SSH_PASS" ssh -o LogLevel=QUIET -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SSH_HOST" "test -d $service_path"; then
        ssh_cmd+="cd $service_path || true; pkill -f '$service_name' || true; nohup ./$service_name > ${service_name}_$(date +%Y%m%d_%H%M%S).log 2>&1 & "
        services_started+="$service_name, "
    else
        echo -e "${RED}目录 $service_path 不存在，跳过 $service_name 服务${NC}"
    fi
}

# 遍历每个服务器执行 SSH 操作
for SERVER in $(jq -c '.SERVERS[]' serv00.json); do
    SSH_USER=$(echo "$SERVER" | jq -r '.SSH_USER')
    SSH_PASS=$(echo "$SERVER" | jq -r '.SSH_PASS')
    SSH_HOST=$(echo "$SERVER" | jq -r '.HOST')

    SERVER_ID="${SSH_USER}-${SSH_HOST}"

    echo -e "${YELLOW}开始执行 $SERVER_ID${NC}"

    ssh_cmd=""
    services_started=""

    # 依次检查每个服务的目录并启动
    [[ "$SINGBOX" -eq 1 ]] && check_and_add_service "singbox" "/home/$SSH_USER/serv00-play/singbox"
    [[ "$NEZHA_DASHBOARD" -eq 1 ]] && check_and_add_service "nezha-dashboard" "/home/$SSH_USER/nezha_app/dashboard"
    [[ "$NEZHA_AGENT" -eq 1 ]] && check_and_add_service "nezha-agent" "/home/$SSH_USER/nezha_app/agent"
    [[ "$SUN_PANEL" -eq 1 ]] && check_and_add_service "sun-panel" "/home/$SSH_USER/serv00-play/sunpanel"
    [[ "$WEB_SSH" -eq 1 ]] && check_and_add_service "wssh" "/home/$SSH_USER/serv00-play/webssh"
    [[ "$ALIST" -eq 1 ]] && check_and_add_service "alist" "/home/$SSH_USER/serv00-play/alist"

    # 执行构建的 SSH 命令
    sshpass -p "$SSH_PASS" ssh -o LogLevel=QUIET -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$SSH_USER@$SSH_HOST" "$ssh_cmd"

    # 检查 SSH 执行状态
    if [ $? -eq 0 ]; then
        if [ -n "$services_started" ]; then
            services_started=${services_started%, }  # 去掉最后的逗号
            if [ "$NOTIFICATION" -eq 1 ]; then
                send_tg_notification "✅ [$SERVER_ID] 脚本执行完成：已执行服务：$services_started"
            fi
        else
            echo -e "${RED}没有服务被启动，跳过通知！${NC}"
        fi
    else
        echo -e "${RED}SSH 执行失败：$SERVER_ID${NC}"
    fi
done
