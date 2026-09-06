# 配置

DupeDetector 通过插件文件夹中的一个 `config.json` 文件进行配置：

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/DupeDetector/config.json
```

还附带了第二个文件 `config_commented.json`。它是**带有 `//` 注释的相同
配置**——可以阅读它，但不要把它重命名覆盖 `config.json`（注释不是合法的
JSON）。

`LicenseKey`、`Verbose`、`LogToFile` 和 `Database` 这几个键由每个
Bytemart 插件共享，其说明位于
**[通用配置](../index.md#common-configuration)** 页面。本页只涵盖
DupeDetector 独有的 `DupeDetection` 部分。

> 💡 **开始前先验证。** 编辑后请务必验证你的 JSON（例如
> 使用 [JSONLint](https://jsonlint.com/)）。加载错误代码 `1114` 意味着
> JSON 语法错误。

## `DupeDetection`

```json
"DupeDetection": {
  "AlertWebhook": "",
  "Punishment": {
    "PunishmentWebhook": "",
    "Command": "",
    "ClearInventory": false,
    "After": {
      "Min": 1,
      "Max": 1
    }
  }
}
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `AlertWebhook` | string | `""` | **检测**用的 Discord Webhook——每次检测发送一条消息，指明涉及的玩家。为空表示检测仍会被计入，但不会发布任何内容。 |

### `Punishment`

一旦玩家累积了足够多的检测次数会发生什么。每个字段都是可选的：将
`Command` 留空、`ClearInventory` 设为 false，DupeDetector 就会变成仅
报告模式。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `PunishmentWebhook` | string | `""` | **惩罚**用的 Discord Webhook。与 `AlertWebhook` 分开，这样你就可以将（少得多的）惩罚路由到一个仅管理员可见的频道。为空表示不会发布任何内容。 |
| `Command` | string | `""` | 当达到阈值时，针对违规者运行的服务器控制台命令——例如 `banplayer {steamid}` 或 `kickplayer {steamid}`。为空表示不会运行任何命令。 |
| `ClearInventory` | boolean | `false` | 作为惩罚的一部分，清空违规者的库存。 |
| `After.Min` | number | `1` | 检测阈值的下界。 |
| `After.Max` | number | `1` | 检测阈值的上界。 |

#### `After` 阈值

`Min` 和 `Max` 限定了玩家在惩罚触发之前可以累积多少次检测。给它们
设置**不同**的值会使确切的阈值变得不可预测，这是推荐的设置——一个
固定的、已知的数字是违规者可以设法规避的。

- `"Min": 1, "Max": 1` —— 在第一次检测时就惩罚（默认设置）。
- `"Min": 2, "Max": 5` —— 在该范围内的某个点进行惩罚。

数值会在加载时进行范围检查，因此你不会意外配置出一个永远不会触发的
阈值。

> 💡 **先从仅报告模式开始。** 在最初的几天里将 `Command` 留空、
> `ClearInventory` 设为 false，观察 `AlertWebhook` 中出现的内容，然后
> 再决定惩罚应该是什么样的。

## Webhook

两个 Webhook 字段都必须是**Discord Webhook URL**。以下前缀都会被
接受：

```
https://discord.com/api/webhooks/...
https://discordapp.com/api/webhooks/...
https://ptb.discord.com/api/webhooks/...
https://canary.discord.com/api/webhooks/...
```

其他任何形式——包括空字符串——都会被丢弃，并在插件日志中留下相应的
记录。空的 Webhook 从不算是错误；它只是意味着“不发送任何内容”。

> 🔒 **Webhook URL 是一种凭据。** 任何拥有它的人都可以向你的频道发布
> 消息。请不要将 `config.json` 放入公开的代码仓库或截图中。

## 完整示例

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  },
  "DupeDetection": {
    "AlertWebhook": "https://discord.com/api/webhooks/...",
    "Punishment": {
      "PunishmentWebhook": "https://discord.com/api/webhooks/...",
      "Command": "banplayer {steamid}",
      "ClearInventory": true,
      "After": {
        "Min": 2,
        "Max": 4
      }
    }
  }
}
```

---

**后续步骤：**

- [概述](index.md) —— 插件涵盖的内容、安装方法，以及命令。
- [通用配置](../index.md#common-configuration) —— `LicenseKey`、`Database`、
  `LogToFile`、`Verbose`。
