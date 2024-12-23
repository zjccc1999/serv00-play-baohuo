# serv00-play 配套保活

## 2024/12/23/00:45 更新serv00-ql  增加了多个通知方式

感谢[饭奇骏大佬的serv00-play项目](https://github.com/frankiejun).  [serv00-play项目地址](https://github.com/frankiejun/serv00-play).

感谢[vfhky大佬的nz项目](https://github.com/vfhky).    [serv00_ct8_nezha项目地址](https://github.com/vfhky/serv00_ct8_nezha).

# 青龙面板教程
- **serv00ql 是青龙面板保活脚本**
安装依赖:

![依赖.png](https://jpg.zjccc.us.kg/file/1734808200086_依赖.png)

## ql面板环境变量配置
**1开 2关**

**1开 2关**

使用变量名存储服务器信息，每个服务器用一个变量，例如：
# 环境变量配置
| 变量名            | 描述                           | 默认值   | 必填/选填 |
|-------------------|--------------------------------|----------|----------|
| `ENABLE_ALL_SERVICES` | 启用所有服务的标志，`true` 表示启用所有服务，`false` 表示不启用 | `false`  | 选填     |
| `SINGBOX`           | 启用 Singbox 服务，`1` 表示启用，`0` 表示禁用 | `1`      | 选填     |
| `NEZHA_DASHBOARD`   | 启用 Nezha Dashboard 服务，`1` 表示启用，`0` 表示禁用 | `2`      | 选填     |
| `NEZHA_AGENT`       | 启用 Nezha Agent 服务，`1` 表示启用，`0` 表示禁用 | `2`      | 选填     |
| `SUN_PANEL`         | 启用 Sun Panel 服务，`1` 表示启用，`0` 表示禁用 | `2`      | 选填     |
| `WEB_SSH`           | 启用 Web SSH 服务，`1` 表示启用，`0` 表示禁用 | `2`      | 选填     |
| `ALIST`             | 启用 Alist 服务，`1` 表示启用，`0` 表示禁用 | `2`      | 选填     |
| `NOTIFY_SERVICE`    | 启用通知的服务类型：`0` 不启用，`1` Telegram，`2` WxPusher，`3` PushPlus，`4` Telegram 和 WxPusher，`5` Telegram 和 PushPlus | `0`      | 选填     |
| `BOT_TOKEN`         | Telegram Bot 的 Token               | 未设置   | 选填     |
| `CHAT_ID`           | Telegram Chat 的 ID                | 未设置   | 选填     |
| `WXPUSHER_TOKEN`    | WxPusher 的 Token                  | 未设置   | 选填     |
| `PUSHPLUS_TOKEN`    | PushPlus 的 Token                  | 未设置   | 选填     |
| `WXPUSHER_USER_ID`  | WxPusher 的 User ID                | 未设置   | 选填     |
| `SERVERS`           | 服务器列表，格式为 `user:pass:host`，多个服务器用逗号分隔 | 未设置   | 必填     |


### 说明：
- **`SERVERS`**：多个服务器的信息，格式为 `user:pass:host`，多个服务器用逗号分隔。该项为必填。
- **`BOT_TOKEN` 和 `CHAT_ID`**：用于 Telegram 通知的配置，启用 Telegram 通知时需要提供 Bot Token 和 Chat ID。
- **`WXPUSHER_TOKEN` 和 `WXPUSHER_USER_ID`**：用于 WxPusher 通知的配置，启用 WxPusher 通知时需要提供 Token 和 User ID。
- **`PUSHPLUS_TOKEN`**：用于 PushPlus 通知的配置，启用 PushPlus 时需要提供 Token。
- **`NOTIFY_SERVICE`**：控制启用的通知服务。0 表示不启用通知，1 表示启用 Telegram，2 表示启用 WxPusher，3 表示启用 PushPlus，4 表示启用 Telegram 和 WxPusher，5 表示启用 Telegram 和 PushPlus。
- **服务控制变量**：`NEZHA_DASHBOARD`、`NEZHA_AGENT`、`SUN_PANEL`、`WEB_SSH`、`ALIST` 和 `SINGBOX` 控制各个服务是否启动。1 表示启用，2 表示禁用。
- #### **不想一个个服务项填**，直接填 `ENABLE_ALL_SERVICES` `true`
- #### 如果 ENABLE_ALL_SERVICES=false 且 SINGBOX=1，那么脚本仍然会执行 Singbox 服务。原因如下：

ENABLE_ALL_SERVICES=false 表示并不会启用所有服务，但是它并不阻止单独的服务（如 Singbox）的启动。
如果 SINGBOX=1，说明 Singbox 服务已经被单独启用，即使 ENABLE_ALL_SERVICES=false，该服务仍会按照单独的配置执行。

推荐8小时运行一次
`0 */8 * * *`
命令
`task serv00-ql.sh`
青龙面板示例：
![青龙细化通知方式.png](https://jpg.zjccc.us.kg/file/1734885865851_青龙细化通知方式.png)

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
    "BOT_TOKEN": "your_bot_token",
    "CHAT_ID": "your_chat_id"
  },
  "SERVERS": [
    {
      "HOST": "192.168.1.1",
      "SSH_USER": "user",
      "SSH_PASS": "password"
    }
  ],
  "FEATURES": {
    "SINGBOX": 1,
    "NEZHA_DASHBOARD": 2,
    "NEZHA_AGENT": 1,
    "SUN_PANEL": 2,
    "WEB_SSH": 1,
    "ALIST": 2
  }
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


