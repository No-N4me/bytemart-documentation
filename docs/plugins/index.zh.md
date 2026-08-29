# 插件

Bytemart 插件为你的 ARK 服务器扩展新功能。每个插件都以一个可从
**Bytemart 控制台**下载的 `.zip` 形式发布，你只需将其放入服务器的
插件文件夹即可。

## 可用插件

| 插件 | 说明 |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | 一套竞技性的部落计分系统：部落通过在 PvP 中摧毁敌方建筑、恐龙和玩家来赚取分数，并通过排行榜和世界内全息投影呈现。 |
| [ssAntiCheat](ssanticheat/index.md) | 服务端反作弊：涵盖战斗作弊与漏洞利用的检测模块、带封禁波次的内置封禁系统、Discord 告警，以及针对已知崩溃与复制漏洞的修复。 |

## 通用配置

每个 Bytemart 插件都通过位于该插件自身文件夹中的 `config.json` 文件进行配置：

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/config.json
```

下面这些键出现在该文件的**顶层**，并且在每个插件中的行为都完全一致。
各个插件的页面只说明它们独有的键，并链接回此处以说明这些共享的键。

> 💡 **验证你的 JSON。** 一个位置错误的逗号或引号就会导致插件无法加载。
> 每次编辑后，请使用诸如
> [JSONLint](https://jsonlint.com/) 之类的验证工具检查你的配置。加载错误代码
> `1114` 几乎总是意味着 JSON 语法错误。

### `LicenseKey`

```json
"LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE"
```

你的 Bytemart 许可证密钥。**必填。** 插件在启动时会将此密钥与 Bytemart
许可服务器进行验证，只有验证成功后其功能才会激活。你可以在
[Bytemart 控制台](https://bytemart.net/)找到你的密钥。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `LicenseKey` | string | — | 为你的插件签发的许可证密钥。请妥善保密。 |

### `Verbose`

```json
"Verbose": false
```

启用插件的详细日志。当设为 `true` 时，插件会向服务器控制台打印额外的
诊断输出——排查问题时很有用，否则会显得杂乱。正常运行时请保持
`false`。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Verbose` | boolean | `false` | 启用详细（调试级别）的控制台日志。 |

### `LogToFile`

```json
"LogToFile": false
```

当设为 `true` 时，插件会将它记录的所有内容镜像写入其自身文件夹内的一个
滚动日志文件：

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/<PluginName>.log
```

该文件会自动滚动（每个文件约 5 MB，最多保留 3 个文件）。只有该插件自身的
输出会被写入——共享的 ArkApi/服务器日志永远不会被修改。这样在诊断问题时
可以轻松地隔离出单个插件的活动。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `LogToFile` | boolean | `false` | 将此插件的日志镜像到它自己的滚动 `.log` 文件。 |

### `Database`

```json
"Database": {
  "MysqlHost": "localhost",
  "MysqlPort": 3306,
  "MysqlUser": "username",
  "MysqlPass": "password",
  "MysqlDB": "database"
}
```

MySQL 连接凭据。需要持久化数据的插件（排行榜、冷却时间、交易记录……）
会使用这些值连接到你的 MySQL/MariaDB 服务器，并在首次运行时创建它们所需的
表。除非你有特定的理由要将它们分开，否则请让每个插件都指向同一个数据库。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `MysqlHost` | string | `localhost` | 你的 MySQL/MariaDB 服务器的主机名或 IP。 |
| `MysqlPort` | number | `3306` | 服务器端口。 |
| `MysqlUser` | string | — | 有权访问该数据库的用户名。 |
| `MysqlPass` | string | — | 该用户的密码。 |
| `MysqlDB` | string | — | 要使用的数据库名称。它必须已经存在；插件会在其中创建自己的表。 |

> ⚠️ **数据库必须已经存在。** 插件会自动创建它们的**表**，但**不会**创建
> 数据库本身。请在启动服务器前创建 `MysqlDB` 中指定名称的架构，并授予该用户
> 对它的 `SELECT`、`INSERT`、`UPDATE`、`DELETE` 和 `CREATE` 权限。
