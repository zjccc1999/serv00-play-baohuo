# serv00-play 配套保活

## 2024/12/23/00:45 更新serv00-ql  增加了多个通知方式 
## 2024/12/23/21:48 更新serv00-ql和serv00-vps  修复了webssh的bug,增加了alist 增加了服务项总开关`ENABLE_ALL_SERVICES` 修改了通知逻辑，动态通知。
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
  "NOTIFICATION": 1,
  "TELEGRAM_CONFIG": {
    "BOT_TOKEN": "xxxxx",
    "CHAT_ID": "xxxxx"
  },
  "SERVERS": [
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "SSH_USER_1",
      "SSH_PASS": "SSH_PASS_1"
    },
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "SSH_USER_2",
      "SSH_PASS": "SSH_PASS_2"
    },
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "SSH_USER_3",
      "SSH_PASS": "SSH_PASS_3"
    },
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "SSH_USER_4",
      "SSH_PASS": "SSH_PASS_4"
    },
    {
      "HOST": "s9.serv00.com",
      "SSH_USER": "SSH_USER_5",
      "SSH_PASS": "SSH_PASS_5"
    },
    {
      "HOST": "s15.serv00.com",
      "SSH_USER": "SSH_USER_6",
      "SSH_PASS": "SSH_PASS_6"
    },
    {
      "HOST": "cache10.serv00.com",
      "SSH_USER": "SSH_USER_7",
      "SSH_PASS": "SSH_PASS_7"
    },
    {
      "HOST": "cache12.serv00.com",
      "SSH_USER": "SSH_USER_8",
      "SSH_PASS": "SSH_PASS_8"
    },
    {
      "HOST": "s5.serv00.com",
      "SSH_USER": "SSH_USER_9",
      "SSH_PASS": "SSH_PASS_9"
    }
  ],
  "FEATURES": {
    "SINGBOX": 1,
    "NEZHA_DASHBOARD": 2,
    "NEZHA_AGENT": 1,
    "SUN_PANEL": 2,
    "WEB_SSH": 2,
    "ALIST": 2
  },
  "ENABLE_ALL_SERVICES": true
}

```
| 配置项                | 说明                                                                                   | 示例值                  |
|-----------------------|----------------------------------------------------------------------------------------|-------------------------|
| **NOTIFICATION**       | 通知方式，`1` 表示启用 Telegram 通知，`2` 表示不启用通知。                             | `1`                       |
| **TELEGRAM_CONFIG**    | Telegram 配置，包含 `BOT_TOKEN` 和 `CHAT_ID`，用于发送通知。                         | `{ "BOT_TOKEN": "xxx", "CHAT_ID": "yyy" }` |
| **SERVERS**            | 服务器列表，每个服务器包含 `HOST`（IP 地址）、`SSH_USER`（SSH 用户名）、`SSH_PASS`（SSH 密码）。 | `[ { "HOST": "192.168.1.1", "SSH_USER": "user", "SSH_PASS": "password" } ]` |
| **FEATURES**           | 各种服务的开关配置，启用服务为 `1`，禁用服务为 `2`。                                      | `"SINGBOX": 1, "WEB_SSH": 1, "ALIST": 2` |
| **SINGBOX**            | 启用 SINGBOX 服务，`1` 启用，`2` 禁用。                                                 | `1`                       |
| **NEZHA_DASHBOARD**    | 启用 NEZHA Dashboard 服务，`1` 启用，`2` 禁用。                                          | `2`                       |
| **NEZHA_AGENT**        | 启用 NEZHA Agent 服务，`1` 启用，`2` 禁用。                                              | `1`                       |
| **SUN_PANEL**          | 启用 SUN PANEL 服务，`1` 启用，`2` 禁用。                                                | `2`                       |
| **WEB_SSH**            | 启用 WEB SSH 服务，`1` 启用，`2` 禁用。                                                  | `1`                       |
| **ALIST**              | 启用 ALIST 服务，`1` 启用，`2` 禁用。                                                    | `2`                       |


# 注意
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行** 
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行**
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行**


VPS示例:

![vps.png](https://jpg.zjccc.us.kg/file/1734885866468_vps.png)


### 后续可自行添加其他进程或者通知方式


