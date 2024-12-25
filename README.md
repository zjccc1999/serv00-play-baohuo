# serv00-play 配套保活

## 2024/12/23/00:45 更新serv00-ql  增加了多个通知方式 
## 2024/12/23/21:48 更新serv00-ql和serv00-vps  修复了webssh的bug,增加了alist 增加了服务项总开关`ENABLE_ALL_SERVICES` 修改了通知逻辑，动态通知。
## 2024/12/23/21:48 更新serv00-ql和serv00-vps  放弃本地环境变量 同步 `serv00-vps.sh` 采用远程变量 `serv00.json`  。
感谢[饭奇骏大佬的serv00-play项目](https://github.com/frankiejun).  [serv00-play项目地址](https://github.com/frankiejun/serv00-play).

感谢[vfhky大佬的nz项目](https://github.com/vfhky).    [serv00_ct8_nezha项目地址](https://github.com/vfhky/serv00_ct8_nezha).

# 青龙面板教程
- **serv00ql 是青龙面板保活脚本**
# 安装Linux依赖: 	jq  curl  sshpass

![依赖.png](https://jpg.zjccc.us.kg/file/1734808200086_依赖.png)

## ql面板环境变量配置
**1开 2关**

**1开 2关**
## 放弃本地环境变量 同步serv00-vps.sh 采用远程变量 `serv00.json`
## 具体看VPS那里的解释

推荐8小时运行一次
`0 */8 * * *`
命令
`task serv00-ql.sh`
青龙面板示例：
![动态通知.png](https://jpg.zjccc.us.kg/file/1734961881867_动态通知.png)
![青龙面板12-23.png](https://jpg.zjccc.us.kg/file/1734962008390_青龙面板12-23.png)

# vps教程
**1开 2关**

**1开 2关**

**1开 2关**

- **serv00vps 是vps保活脚本**
## JSON配置
注意:务必将`serv00.json` 文件存入私库或其他支持直链的云盘，避免信息泄露。git私库文件可用CM的私库项目获取可访问的直链 [cmliu / CF-Workers-Raw](https://github.com/zjccc1999?submit=Search&q=raw&tab=stars&type=&sort=&direction=&submit=Search)
```
{
    "NOTIFICATION": 3,
    "TELEGRAM_CONFIG": {
        "BOT_TOKEN": "1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghi",
        "CHAT_ID": "123456789"
    },
    "WXPUSHER_TOKEN": "wxpusher_token_value_here",
    "PUSHPLUS_TOKEN": "pushplus_token_value_here",
    "WXPUSHER_USER_ID": "wxpusher_user_id_value_here",
    "SERVERS": [
        {
            "SSH_USER": "user1",
            "SSH_PASS": "password1",
            "HOST": "server1.example.com"
        },
        {
            "SSH_USER": "user2",
            "SSH_PASS": "password2",
            "HOST": "server2.example.com"
        },
        {
            "SSH_USER": "user3",
            "SSH_PASS": "password3",
            "HOST": "server3.example.com"
        }
    ],
    "FEATURES": {
        "SINGBOX": 1,
        "NEZHA_DASHBOARD": 1,
        "NEZHA_AGENT": 1,
        "SUN_PANEL": 0,
        "WEB_SSH": 1,
        "ALIST": 0
    },
    "ENABLE_ALL_SERVICES": true
}

```
| 配置项                 | 值                                                                 | 说明                                      |
|------------------------|--------------------------------------------------------------------|-------------------------------------------|
| `NOTIFICATION`          | 3                                                                  | 设置通知方式，值为 `3` 表示启用 **PushPlus** 和 **WxPusher** 通知。当 NOTIFICATION = 1 时，意味着只启用 Telegram 作为通知服务。
若 NOTIFICATION = 2，则表示仅启用 WxPusher 通知服务。
对于 NOTIFICATION = 3 的情况， PushPlus 作为通知服务
当 NOTIFICATION = 4，它代表同时启用 Telegram 和 WxPusher 两种通知服务。 |
| `BOT_TOKEN`             | `1234567890:ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghi`                  | Telegram 机器人的 Bot Token，用于发送通知。 |
| `CHAT_ID`               | `123456789`                                                       | Telegram 聊天室或频道的 ID，用于指定通知发送的目标。 |
| `WXPUSHER_TOKEN`        | `wxpusher_token_value_here`                                        | WxPusher 的 Token，用于认证和授权通知发送。 |
| `WXPUSHER_USER_ID`      | `wxpusher_user_id_value_here`                                       | WxPusher 用户 ID，用于指定接收通知的用户。 |
| `PUSHPLUS_TOKEN`        | `pushplus_token_value_here`                                        | PushPlus 的 Token，用于认证和授权通知发送。 |
| **SERVERS**             |                                                                  |                                           |
| `SSH_USER`              | `user1`                                                           | 第一个服务器的 SSH 用户名。               |
| `SSH_PASS`              | `password1`                                                       | 第一个服务器的 SSH 密码。                 |
| `HOST`                  | `server1.example.com`                                             | 第一个服务器的主机地址。                 |
| `SSH_USER`              | `user2`                                                           | 第二个服务器的 SSH 用户名。               |
| `SSH_PASS`              | `password2`                                                       | 第二个服务器的 SSH 密码。                 |
| `HOST`                  | `server2.example.com`                                             | 第二个服务器的主机地址。                 |
| `SSH_USER`              | `user3`                                                           | 第三个服务器的 SSH 用户名。               |
| `SSH_PASS`              | `password3`                                                       | 第三个服务器的 SSH 密码。                 |
| `HOST`                  | `server3.example.com`                                             | 第三个服务器的主机地址。                 |
| **FEATURES**            |                                                                  |                                           |
| `SINGBOX`               | 1                                                                  | 启用 Singbox 功能。                        |
| `NEZHA_DASHBOARD`       | 1                                                                  | 启用 Nezha Dashboard 功能。                |
| `NEZHA_AGENT`           | 1                                                                  | 启用 Nezha Agent 功能。                    |
| `SUN_PANEL`             | 0                                                                  | 禁用 Sun Panel 功能。                      |
| `WEB_SSH`               | 1                                                                  | 启用 Web SSH 功能。                        |
| `ALIST`                 | 0                                                                  | 禁用 Alist 功能。                          |
| `ENABLE_ALL_SERVICES`   | `false`                                                            | 是否启用所有服务，值为 `false` 表示根据 上面6个变量 配置启用。值为`true` 表示 不根据上面6个变量来，直接全部启用 |


# 注意
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行** 
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行**
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行**


VPS示例:

![vps.png](https://jpg.zjccc.us.kg/file/1734885866468_vps.png)


### 后续可自行添加其他进程或者通知方式


