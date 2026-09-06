# 🔍 DupeDetector

DupeDetector 是一款小巧而专注的 ArkApi 插件，用于捕捉**通过贡品库存
进行的物品复制**——即用于集群传输的方尖碑、空投终端和传送器上传商店。

它只做一件事，而且做得悄无声息：复制尝试会被报告到你的 Discord，
累犯可以被自动处理。

## 功能

- **检测复制行为**，通过贡品/上传商店进行，无需客户端模组，玩家也
  无需安装任何东西。
- **告警到你的 Discord。** 每一次检测都会发布到你配置的 Webhook。
- **惩罚累犯。** 一旦某玩家被检测到足够多次，DupeDetector 可以对其
  运行一条服务器命令（踢出、封禁，随你选择），并可选择清空其库存。
  惩罚会发送到它自己的 Webhook，这样你就可以将其路由到一个仅管理员
  可见的频道。
- **也可以仅报告。** 将惩罚选项留空，插件就只会告知你——它永远不会
  自行采取行动。

一名玩家在惩罚触发之前能获得多少宽限是可配置的，并且刻意不是一个
固定数字。参见 [`Punishment.After`](configuration.md#punishment)。

> ℹ️ **检测细节刻意不予公开。** 什么会触发检测，以及一名玩家被允许有
> 多少次检测，本文档中不作说明——那些信息只会帮助你想要抓住的人。
> 如果你需要理解某个具体的告警，请到
> [Bytemart Discord](https://bytemart.net/discord) 询问。

## 要求

| 要求 | 说明 |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** 或更新版本 | 插件无法在更旧的 API 版本上加载。 |
| MySQL / MariaDB | 插件会在启动时连接，因此需要有效的凭据。参见[通用配置](../index.md#database)。 |
| Bytemart 许可证密钥 | 在密钥验证通过之前，任何功能都不会激活。 |
| 出站 HTTPS | 许可验证和 Discord Webhook 都需要它。 |

## 安装

1. 确保你的服务器上安装了 ArkApi **3.51+**。
2. 设置一个 MySQL/MariaDB 数据库——参见
   [通用配置](../index.md#database)。该数据库必须已经存在。
3. 从你的 **Bytemart 控制台**下载 `DupeDetector.zip`。
4. 停止服务器（先运行 `saveworld`），或使用
   `plugins.unload DupeDetector` 卸载任何以前的版本。
5. 将压缩包解压到
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/` 内的一个 `DupeDetector` 文件夹中。
6. 打开 `config.json` 并填入你的 `LicenseKey`、`Database` 凭据，以及
   至少 `DupeDetection.AlertWebhook`——参见[配置](configuration.md)。
7. 启动服务器，并确认启动过程中没有任何错误。

> ⚠️ **上线前请先设置 `AlertWebhook`。** 它出厂时为空，空的 Webhook
> 意味着检测结果会被记录，但永远不会被发布到任何地方。

### 更新

- **手动方式：** `plugins.unload DupeDetector`，替换文件，然后
  `plugins.load DupeDetector`。
- **自动方式（热重载）：** 将新的 `DupeDetector.dll` 重命名为
  `DupeDetector.dll.arkapi` 并放入插件文件夹——ArkApi 会自动加载新
  版本并卸载旧版本。

DupeDetector 会在加载时修复自己的配置：缺失的键会以其默认值补上，你的
原始文件会先被备份为 `config.json.bak`。类型不匹配（本该是数字的地方
出现了字符串）则会中止加载，并报错指出具体的键。

## 命令

控制台和 RCON 访问权限本身就是管理员权限，因此这些命令不需要额外的
权限。

| 命令 | 渠道 | 说明 |
| ------- | -------- | ----------- |
| `DupeDetector.help [page]` | Console, RCON | 分页列出所有已注册的命令。 |
| `DupeDetector.reload` | Console, RCON | 重新读取 `config.json`，无需重启服务器。 |

`DupeDetector.reload` 会就地替换正在运行的配置，因此 Webhook 和惩罚
方面的更改会立即生效。它**不会**重新运行配置修复流程，所以请在重新
加载之前先验证你的 JSON。

## 故障排查

- **插件无法加载，错误代码 `1114`** —— `config.json` 中存在 JSON 语法
  错误。请通过 [JSONLint](https://jsonlint.com/) 检查它。
- **“License key is missing”** —— `LicenseKey` 仍然是占位符值。
- **Discord 收不到任何消息** —— 该 URL 必须是一个真实的 Discord
  Webhook 端点（`https://discord.com/api/webhooks/...`；
  `discordapp.com`、`ptb.` 和 `canary.` 形式也被接受）。其他任何形式
  都会被丢弃，并在日志中留下一行记录。
- **其他情况** —— 将 `LogToFile` 设为 `true` 并重现问题；插件会在
  `config.json` 旁边写入自己的滚动日志 `DupeDetector.log`。然后到
  [Bytemart Discord](https://bytemart.net/discord) 提问。

---

**后续步骤：**

- [配置](configuration.md) —— `DupeDetection` 部分。
- [通用配置](../index.md#common-configuration) —— 共享的 `LicenseKey`、
  `Database`、`LogToFile` 和 `Verbose` 键。
