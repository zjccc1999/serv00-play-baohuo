# serv00-play 配套保活

## 20241222更新 增加了多个通知方式

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
| 环境变量                | 描述                             | 默认值            |
|------------------------|----------------------------------|------------------|
| `SERVERS`              | 服务器信息，格式为 `user:pass:host`，多个服务器用逗号分隔 | 无    必填           |
| `BOT_TOKEN`            | Telegram Bot Token               | 无        选填       |
| `CHAT_ID`              | Telegram Chat ID                 | 无        选填         |
| `WXPUSHER_TOKEN`       | WxPusher Token                   | 无        选填         |
| `PUSHPLUS_TOKEN`       | PushPlus Token                   | 无       选填          |
| `WXPUSHER_USER_ID`     | WxPusher 用户 ID                 | 无        选填         |
| `NOTIFY_SERVICE`       | 通知服务选择 (0: 不启用, 1: TG, 2: WxPusher, 3: PushPlus, 4: TG+WxPusher, 5: TG+PushPlus) | `0` (不启用通知) |
| `NEZHA_DASHBOARD`      | 是否启用 Nezha Dashboard 服务   | `2` (不启用)   选填    | 
| `NEZHA_AGENT`          | 是否启用 Nezha Agent 服务       | `2` (不启用)    选填   |
| `SUN_PANEL`            | 是否启用 Sun Panel 服务         | `2` (不启用)    选填   |
| `WEB_SSH`              | 是否启用 Web SSH 服务           | `2` (不启用)    选填   |
| `SINGBOX`              | 是否启用 Singbox 服务           | `1` (启用)      选填   |


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
    "BOT_TOKEN": "7632093319:AAFtgOWj6YenazWR5NqmmaHfU1RIJo0uhD0",
    "CHAT_ID": "5230469074"
  },
  "SERVERS": [
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "xxxx",
      "SSH_PASS": "xxxx" 
    },
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "sxxxx4012",
      "SSH_PASS": "Zxxxx&)%"
    },
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "xxx",
      "SSH_PASS": "xxx"
    },
    {
      "HOST": "s14.serv00.com",
      "SSH_USER": "xx14",
      "SSH_PASS": "xxxxx)%"
    }
  ],
  "FEATURES": {
    "SINGBOX": 1,
    "NEZHA_DASHBOARD": 2,
    "NEZHA_AGENT": 1,
    "SUN_PANEL": 2,
    "WEB_SSH": 2
  }
}

```
# JSON 配置说明

## NOTIFICATION
- `1`：启用 Telegram 通知
- `2`：不启用任何通知

## TELEGRAM_CONFIG
- `BOT_TOKEN`：Telegram 机器人的 Token。
- `CHAT_ID`：用于接收通知的 Telegram 聊天 ID。

## SERVERS
配置服务器的 SSH 连接信息：
- `HOST`：服务器的主机名或 IP 地址
- `SSH_USER`：SSH 用户名
- `SSH_PASS`：SSH 密码

## FEATURES
启用的功能服务：
- `SINGBOX`：启用或禁用 SingBox 服务
- `NEZHA_DASHBOARD`：启用或禁用 Nezha Dashboard 服务
- `NEZHA_AGENT`：启用或禁用 Nezha Agent 服务
- `SUN_PANEL`：启用或禁用 Sun Panel 服务
- `WEB_SSH`：启用或禁用 Web SSH 服务



# 注意
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行** 
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行**
**必须将变量修改为你自己的信息,自行修改脚本内容。在52行**


VPS示例:

![vps.png](https://jpg.zjccc.us.kg/file/1734885866468_vps.png)


### 后续可自行添加 

等等。。。  
