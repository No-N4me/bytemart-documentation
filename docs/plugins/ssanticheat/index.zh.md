# 🛡️ ssAntiCheat

ssAntiCheat 是一款面向 ARK: Survival Evolved 的**服务端反作弊**插件。它完全
作为 ArkApi 插件运行在你的服务器内部——玩家无需安装任何东西，也没有客户端
可供绕过。检测结果会告警到你的 Discord 和游戏内管理员，违规者会被排入
**封禁波次**，这样作弊者就无法得知是哪一项检测抓到了他们。

除了检测之外，ssAntiCheat 还会直接**拦截**大量已知的漏洞利用，并内置了
针对多个长期存在的服务器问题的修复——包括**崩溃漏洞**和**物品复制**。

## 功能

- **检测模块。** 数十个可单独开关的检测器，分为四大类：**Combat**、
  **Misc**、**Mod** 和 **Exploits**。举几个例子：自瞄和隐蔽自瞄检测、自动
  闪光弹、自动药膏、无过热、自动拾取和自动合成。每一项都可以单独启用、
  禁用和调整。
- **拦截漏洞利用，而不仅仅是报告。** 大多数漏洞利用模块既能*阻止*该行为，
  也能标记它，因此漏洞利用会直接失败，而不仅仅是被事后记录下来。
- **崩溃与复制防护。** 已知的服务器崩溃途径会被拦截，复制修复能够阻止
  常见的物品复制手法（转移复制、背包/传送器技巧等等）。
- **漏洞与卡顿修复。** 一个独立的 `Fixes` 部分涵盖了众所周知的服务器漏洞
  （Scout 漏洞、手铐漏洞、“玩家已连接”问题、拉取漏洞、卡顿防护，以及
  复制修复）。
- **内置封禁系统。** 封禁记录会持久化保存在 MySQL 中，并在登录时强制
  执行，支持可选的 **IP 关联**和 **HWID** 封禁。封禁波次会分批执行，
  一次性移除多名作弊者。参见[封禁与检测](bans.md)。
- **Discord 告警。** 检测、封禁、加入日志、IP 关联封禁，以及管理员操作
  日志，各自发送到你配置的一个 Webhook——也可以全部发送到同一个。
- **管理工具。** 一条命令即可观察被标记的玩家，为自己开关玩家和建筑
  ESP，以及一整套用于在游戏内处理嫌疑人的聊天命令。每一次管理员操作都
  会被记录。
- **连接门禁。** 可选的加入时 Steam Web API 检查：最低游戏时长、最低
  账号年龄，以及近期 VAC 封禁——每一项都可以仅记录或直接拦截。
- **仪表盘（可选）。** 可选择性地将遥测数据发送到 ssAnticheat 仪表盘，
  以获取实时检测动态、服务器健康状况，以及可选的实时玩家地图。默认
  关闭。

## 检测如何变成封禁

```
检测器触发
   └─> 记录检测结果  ──> 游戏内管理员告警
                    ──> Discord webhook
                    ──> 仪表盘（如果启用）
   └─> 模块的封禁阈值是否已达到？
          └─> 玩家被排入下一次封禁波次
                 └─> 封禁波次执行：在存档周期、玩家断线、
                     即时封禁模块触发时，或手动执行
```

阈值、拦截和即时封禁行为都是按模块设置的。完整流程——以及能够改变它的
每一个开关——都在[封禁与检测](bans.md)页面上。

## 要求

| 要求 | 说明 |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** 或更新版本 | 插件无法在更旧的 API 版本上加载。 |
| MySQL / MariaDB | 必需。封禁记录会持久化保存在此处。参见[通用配置](../index.md#database)。 |
| Bytemart 许可证密钥 | 在密钥验证通过之前，任何功能都不会激活。 |
| 出站 HTTPS | 许可验证、Discord webhook，以及（如果使用）Steam Web API 和仪表盘都需要它。 |

## 安装

1. 确保你的服务器上安装了 ArkApi **3.51+**。
2. 设置一个 MySQL/MariaDB 数据库——参见
   [通用配置](../index.md#database)。该数据库必须已经存在；
   插件会在其中创建自己的表。
3. 从你的 **Bytemart 控制台**下载 `ssAntiCheat.zip`。
4. 停止服务器（先运行 `saveworld`），或使用
   `plugins.unload ssAntiCheat` 卸载任何以前的版本。
5. 将压缩包解压到
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/` 内的一个 `ssAntiCheat` 文件夹中。
6. 打开 `config.json` 并填入你的 `LicenseKey` 和 `Database` 凭据
   （参见[配置](configuration.md)）。
7. 启动服务器，并确认启动过程中没有任何错误。
8. 从控制台或 RCON 运行 `ssac.status`，确认许可证已通过验证。

> ⚠️ **上线前请先设置好你的 Webhook。** 每个 Webhook 字段发布时都是空的。
> 在你至少填入 `DefaultWebhookUrl` 之前，检测结果只有游戏内管理员和服务器
> 日志中可见。

### 更新

- **手动方式：** `plugins.unload ssAntiCheat`，替换文件，然后
  `plugins.load ssAntiCheat`。
- **自动方式（热重载）：** 将新的 `ssAntiCheat.dll` 重命名为
  `ssAntiCheat.dll.arkapi` 并放入插件文件夹——ArkApi 会自动加载新版本并
  卸载旧版本。

更新时，请务必查看更新日志以了解配置变更。ssAntiCheat 会自动修复自己的
配置（缺失的键会以其默认值补上，原始文件会备份为 `config.json.bak`），
但诸如 [Diffchecker](https://www.diffchecker.com/) 之类的工具仍然有助于
发现值得调整的新键。

## 故障排查

- **插件无法加载，错误代码 `1114`** —— `config.json` 中存在 JSON 语法
  错误。请通过 [JSONLint](https://jsonlint.com/) 检查它。
- **“License key is missing”** —— `LicenseKey` 仍然是占位符值。
- **Discord 收不到任何消息** —— 检查 `Use Discord` 是否为 `true`，以及
  相应的 Webhook URL 是否已经填写。Webhook 是按用途区分的；参见
  [配置](configuration.md#webhooks)。
- **其他情况** —— 将 `LogToFile` 设为 `true` 并重现问题；插件会在
  `config.json` 旁边写入自己的滚动日志 `ssAntiCheat.log`，这样你就不必在
  共享的服务器日志中翻找。然后到 [Bytemart Discord](https://bytemart.net/discord)
  提问。

---

**后续步骤：**

- [配置](configuration.md) —— `config.json` 中的每一个键。
- [命令](commands.md) —— 控制台/RCON 命令和游戏内管理员聊天命令。
- [封禁与检测](bans.md) —— 阈值、封禁波次、IP/HWID 封禁，以及解封。
- [通用配置](../index.md#common-configuration) —— 共享的 `LicenseKey`、
  `Database`、`LogToFile` 和 `Verbose` 键。
