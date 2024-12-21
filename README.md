# serv00-play 配套保活
- serv00ql 是青龙面板保活脚本
# 环境变量配置
使用变量名存储服务器信息，每个服务器用一个变量，例如：

变量名	变量值
SERVERS	user1:pass1:host1,user2:pass2:host2,user3:pass3:host3
BOT_TOKEN	你的 Telegram Bot Token
CHAT_ID	你的 Telegram Chat ID

- serv00vps 是vps保活脚本

注意:务必将`servers.conf` 文件存入私库或其他支持直链的云盘，避免信息泄露。git私库文件可用CM的私库项目获取可访问的直链
```
# Telegram 配置
BOT_TOKEN=your_telegram_bot_token
CHAT_ID=your_chat_id

# 服务器配置
user1:pass1:host1
user2:pass2:host2
user3:pass3:host3
```

必须将变量修改为你自己的信息,自行修改脚本内容
