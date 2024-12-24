#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 远程文件 URL
ACCOUNTS_URL="https://api.zjcc.cloudns.be/CSV/main/accounts.json"

# 使用 curl 从远程服务器获取 accounts.json
ACCOUNTS_JSON=$(curl -s "$ACCOUNTS_URL")

# 如果 curl 获取失败，则退出
if [[ $? -ne 0 || -z "$ACCOUNTS_JSON" ]]; then
  echo -e "${RED}无法从远程获取 accounts.json 文件，请检查 URL 或网络连接${NC}"
  exit 1
fi

# 从 JSON 中提取环境变量
WXPUSHER_TOKEN=$(echo "$ACCOUNTS_JSON" | jq -r '.WXPUSHER_CONFIG.TOKEN')
WXPUSHER_USER_ID=$(echo "$ACCOUNTS_JSON" | jq -r '.WXPUSHER_CONFIG.USER_ID')
PUSHPLUS_TOKEN=$(echo "$ACCOUNTS_JSON" | jq -r '.PUSHPLUS_CONFIG.TOKEN')
TG_BOT_TOKEN=$(echo "$ACCOUNTS_JSON" | jq -r '.TELEGRAM_CONFIG.BOT_TOKEN')
TG_CHAT_ID=$(echo "$ACCOUNTS_JSON" | jq -r '.TELEGRAM_CONFIG.CHAT_ID')

# WXPUSHER、PUSHPLUS 和 TELEGRAM 的 URL
WXPUSHER_URL="https://wxpusher.zjiecode.com/api/send/message"
PUSHPLUS_URL="http://www.pushplus.plus/send"
TELEGRAM_URL="https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage"

# 显示启用的通知方式
echo -e "${YELLOW}当前启用的通知方式:${NC}"
if [[ -n "$TG_BOT_TOKEN" && -n "$TG_CHAT_ID" ]]; then
  echo -e "✅ Telegram"
fi
if [[ -n "$WXPUSHER_TOKEN" && -n "$WXPUSHER_USER_ID" ]]; then
  echo -e "✅ WxPusher"
fi
if [[ -n "$PUSHPLUS_TOKEN" ]]; then
  echo -e "✅ PushPlus"
fi
echo "———————————————————————"

# 结果摘要标题
RESULT_SUMMARY="青龙自动进程内容：\n———————————————————————\n 哪吒V1面板 ‖ 探针 ‖ singbox ‖ sun-panel ‖ webssh ‖ alist \n———————————————————————\n"

# 发送 WXPUSHER 消息
send_wxpusher_message() {
  local title="$1"
  local content="$2"
  if [[ -z "$WXPUSHER_TOKEN" || -z "$WXPUSHER_USER_ID" ]]; then
    return
  fi
  curl -s -X POST "$WXPUSHER_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"appToken\": \"$WXPUSHER_TOKEN\",
      \"content\": \"$content\",
      \"title\": \"$title\",
      \"uids\": [\"$WXPUSHER_USER_ID\"]
    }"
}

# 发送 PUSHPLUS 消息
send_pushplus_message() {
  local title="$1"
  local content="$2"
  if [[ -z "$PUSHPLUS_TOKEN" ]]; then
    return
  fi
  curl -s -X POST "$PUSHPLUS_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"token\": \"$PUSHPLUS_TOKEN\",
      \"title\": \"$title\",
      \"content\": \"<pre>$content</pre>\"
    }"
}

# 发送 TELEGRAM 消息
send_telegram_message() {
  local title="$1"
  local content="$2"
  if [[ -z "$TG_BOT_TOKEN" || -z "$TG_CHAT_ID" ]]; then
    return
  fi
  curl -s -X POST "$TELEGRAM_URL" \
    -H "Content-Type: application/json" \
    -d "{
      \"chat_id\": \"$TG_CHAT_ID\",
      \"text\": \"$title $content\"
    }"
}

# 显示当前启用的用户
echo -e "${YELLOW}当前启用的用户:${NC}"
for account in $(echo "$ACCOUNTS_JSON" | jq -r '.info[] | @base64'); do
  _jq() {
    echo ${account} | base64 --decode | jq -r ${1}
  }
  USERNAME=$(_jq '.username')
  echo -e "✅ $USERNAME"
done

LOGIN_TIMEOUT=20    # 登录等待时间20秒
index=1            # 初始化 index

# 解析账户信息并遍历每个账户
for account in $(echo "$ACCOUNTS_JSON" | jq -r '.info[] | @base64'); do
  _jq() {
    echo ${account} | base64 --decode | jq -r ${1}
  }

  USERNAME=$(_jq '.username')
  PASSWORD=$(_jq '.password')
  SERVER=$(_jq '.host')

  # 尝试SSH登录
  sshpass -p "$PASSWORD" timeout $LOGIN_TIMEOUT ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -q "$USERNAME@$SERVER" exit
  if [[ $? -ne 0 ]]; then  # 如果SSH登录失败
    RESULT_SUMMARY+="❌      $index. $USERNAME       【 $SERVER 】 - 登录失败\n"  # 更新结果摘要
    ((index++))
    continue  # 跳过当前账户，处理下一个
  fi
  # SSH登录成功后，执行进程操作
  sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -tt "$USERNAME@$SERVER" <<EOF
  # 杀掉并重启 哪吒v1面板 进程
  pkill -f "nezha-dashboard" || true
  cd /home/$USERNAME/nezha_app/dashboard || true
  nohup ./nezha-dashboard &

  # 杀掉并重启 哪吒v1探针 进程
  pkill -f "nezha-agent" || true
  cd /home/$USERNAME/nezha_app/agent || true
  nohup sh nezha-agent.sh &

  # 重启 singbox 进程
  cd /home/$USERNAME/serv00-play/singbox || true
  nohup ./start.sh &

  # 杀掉并重启 sun-panel 进程
  pkill -f "sun-panel" || true
  cd /home/$USERNAME/serv00-play/sunpanel || true
  nohup ./sun-panel &

  # 重启 webssh 进程
  cd /home/$USERNAME/serv00-play/webssh || true
  nohup ./wssh &

  # 重启 alist 进程
  cd /home/$USERNAME/serv00-play/alist || true
  nohup ./alist &

  ps -A  # 查看当前运行的进程
  exit
EOF

  # 定义进程名称和对应的中文描述
  declare -A processes=( 
    ["nezha-dashboard"]="哪吒面板" 
    ["nezha-agent"]="探针" 
    ["serv00sb"]="singbox" 
    ["sun-panel"]="sun-panel" 
    ["wssh"]="webssh" 
    ["alist"]="alist"
  )

  # 获取当前服务器上运行的进程列表
  process_list=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USERNAME@$SERVER" "ps -A")
  PROCESS_DETAILS=""  # 初始化进程详情
  # 检查进程是否在运行
  for process in "${!processes[@]}"; do
    if echo "$process_list" | grep -q "$process"; then
      PROCESS_DETAILS+="    ${processes[$process]} |"  # 如果进程在运行，则添加到详情中
    fi
  done

  # 如果没有进程运行，标记操作结果为失败
  if [[ -z "$PROCESS_DETAILS" ]]; then
    PROCESS_DETAILS="无进程启动"
  fi

  RESULT_SUMMARY+="✅      $index. $USERNAME 【 $SERVER 】登录成功\n$PROCESS_DETAILS\n"  # 更新结果摘要
  ((index++))  # 更新索引
done

# 发送通知
if [[ -n "$WXPUSHER_TOKEN" && -n "$WXPUSHER_USER_ID" ]]; then
  send_wxpusher_message "青龙进程自动重启结果" "$RESULT_SUMMARY"
fi
if [[ -n "$PUSHPLUS_TOKEN" ]]; then
  send_pushplus_message "青龙进程自动重启结果" "$RESULT_SUMMARY"
fi
if [[ -n "$TG_BOT_TOKEN" && -n "$TG_CHAT_ID" ]]; then
  send_telegram_message "青龙进程自动重启结果" "$RESULT_SUMMARY"
fi
