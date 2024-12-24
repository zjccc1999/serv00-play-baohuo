放弃所有本地环境变量，全部远程链接  accounts.json

```
{
  "info": [
    {
      "host": "cache14.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache14.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache14.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache14.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache15.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache9.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "s5.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache10.serv00.com",
      "username": "****",
      "password": "****"
    },
    {
      "host": "cache12.serv00.com",
      "username": "****",
      "password": "****"
    }
  ],
  "WXPUSHER_CONFIG": {
    "TOKEN": "****",
    "USER_ID": "****"
  },
  "PUSHPLUS_CONFIG": {
    "TOKEN": ""
  },
  "TELEGRAM_CONFIG": {
    "BOT_TOKEN": "****",
    "CHAT_ID": "****"
  }
}
```

| 配置项                  | 描述                        | 说明                          |
|-------------------------|-----------------------------|-------------------------------|
| **info**                | 服务器信息                  | 存储了服务器的 `host`、`username` 和 `password` 用于远程连接 |
| **host**                | 服务器地址                  | 服务器的域名或 IP 地址       |
| **username**            | 登录用户名                  | 用于 SSH 登录的用户名        |
| **password**            | 登录密码                    | 用于 SSH 登录的密码          |
| **WXPUSHER_CONFIG**     | WxPusher 配置               | 配置用于推送消息的 Token 和 User ID |
| **TOKEN**               | WxPusher Token              | 用于发送通知的 Token         |
| **USER_ID**             | WxPusher User ID            | 用户的唯一 ID                 |
| **PUSHPLUS_CONFIG**     | PushPlus 配置               | 配置用于推送通知的 Token（未配置） |
| **TOKEN**               | PushPlus Token              | 用于 PushPlus 推送的 Token（为空） |
| **TELEGRAM_CONFIG**     | Telegram 配置               | 配置 Telegram 通知的 Bot Token 和 Chat ID |
| **BOT_TOKEN**           | Telegram Bot Token          | 用于发送 Telegram 消息的 Bot Token |
| **CHAT_ID**             | Telegram Chat ID            | 用于发送 Telegram 消息的 Chat ID |
