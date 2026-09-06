# ⏳ ArkBossCooldown

ArkBossCooldown 在 Boss 开始之间设置了一个**全服冷却时间**。进入 Boss
竞技场是通过合成一个贡品来实现的，而没有任何东西能阻止一个团队连续
合成好几个——传送会层层叠加，玩家抵达竞技场时就已经死亡。这个插件会
让服务器拒绝开始新的 Boss，直到上一次的冷却时间到期为止。

它刻意保持精简：一个冷却时间、一条消息、一份贡品列表。

## 功能

- **整个服务器共用一个冷却时间。** 第一次合成 Boss 贡品会启动它；在它
  到期之前，其他所有贡品合成都会被拒绝。它*不是*按玩家或按部落计算
  的——如果一个团队开始了一场 Boss 战，所有人都要等待。
- **被拒绝的合成不会有任何损失。** 贡品不会被消耗，也不会发生传送，
  因此触发冷却的玩家只需在冷却结束后再次尝试即可。
- **告知玩家原因。** 一条可配置的聊天、通知或广播消息会显示剩余时间。
  也可以将其关闭，改为静默拒绝。
- **适用于任何地图，也支持模组。** 用于启动冷却的贡品只是配置中的一份
  蓝图路径列表，因此你可以添加模组竞技场，或移除你不想限制的 Boss。
- **仅此而已。** 除你所列出的物品之外，其他物品的合成完全正常。

> ℹ️ **这是一个防抖动，而不是 Boss 锁定。** `BossStartCooldown` 默认值
> 为**5 秒**——足够吞掉一连串的连续点击，又短到没人会注意到它。如果你
> 想要一个真正的“每小时一场 Boss”限制，请将其设置为一个大得多的数字，
> 并先阅读关于[重启与重新加载](configuration.md#bossstartcooldown)的
> 说明。

## 要求

| 要求 | 说明 |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** 或更新版本 | 插件无法在更旧的 API 版本上加载。 |
| MySQL / MariaDB | 插件会在启动时连接，因此需要有效的凭据——但 ArkBossCooldown 本身不会在其中存储任何内容。参见[通用配置](../index.md#database)。 |
| Bytemart 许可证密钥 | 在密钥验证通过之前，任何功能都不会激活。 |
| 出站 HTTPS | 许可验证需要它。 |

## 安装

1. 确保你的服务器上安装了 ArkApi **3.51+**。
2. 设置一个 MySQL/MariaDB 数据库——参见
   [通用配置](../index.md#database)。该数据库必须已经存在。
3. 从你的 **Bytemart 控制台**下载 `ArkBossCooldown.zip`。
4. 停止服务器（先运行 `saveworld`），或使用
   `plugins.unload ArkBossCooldown` 卸载任何以前的版本。
5. 将压缩包解压到
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/` 内的一个 `ArkBossCooldown` 文件夹中。
6. 打开 `config.json` 并填入你的 `LicenseKey` 和 `Database` 凭据。其他
   所有内容的出厂默认值都是可以直接使用的——参见[配置](configuration.md)。
7. 启动服务器，并确认启动过程中没有任何错误。
8. 连续合成两次 Boss 贡品，检查第二次尝试是否被拒绝，并且消息是否
   出现。

> 💡 **在一个不在默认列表中的地图或模组上游玩？** 打开
> [`TestMode`](configuration.md#testmode)，合成一次贡品，然后把控制台
> 打印出的蓝图路径复制到 `Bosses` 中。之后再将 `TestMode` 重新关闭。

### 更新

- **手动方式：** `plugins.unload ArkBossCooldown`，替换文件，然后
  `plugins.load ArkBossCooldown`。
- **自动方式（热重载）：** 将新的 `ArkBossCooldown.dll` 重命名为
  `ArkBossCooldown.dll.arkapi` 并放入插件文件夹——ArkApi 会自动加载新
  版本并卸载旧版本。

ArkBossCooldown 会在加载时修复自己的配置：缺失的键会以其默认值补上，
你的原始文件会先被备份为 `config.json.bak`。类型不匹配（本该是数字的
地方出现了字符串）则会中止加载，并报错指出具体的键。

## 命令

控制台和 RCON 访问权限本身就是管理员权限，因此这些命令不需要额外的
权限。

| 命令 | 渠道 | 说明 |
| ------- | -------- | ----------- |
| `ArkBossCooldown.help [page]` | Console, RCON | 分页列出所有已注册的命令。 |
| `ArkBossCooldown.reload` | Console, RCON | 重新读取 `config.json`，无需重启服务器。 |

`ArkBossCooldown.reload` 会从磁盘重新构建 Boss 列表、冷却时长、
`TestMode`，以及消息设置。它**不会**清除一个已经在运行中的冷却——
重新加载并不能免费开启一次 Boss。要清除冷却，请卸载并重新加载插件。
它同样不会重新运行配置修复流程，所以请在重新加载之前先验证你的
JSON。

## 故障排查

- **冷却从未触发** —— 你正在合成的贡品可能不在 `Bosses` 列表中。打开
  `TestMode`，合成它，然后从控制台读取路径。
- **插件无法加载，错误代码 `1114`** —— `config.json` 中存在 JSON 语法
  错误。请通过 [JSONLint](https://jsonlint.com/) 检查它。冗长的
  `Bosses` 数组很容易让人漏看一个多余的逗号。
- **“License key is missing”** —— `LicenseKey` 仍然是占位符值。
- **消息没有出现** —— 检查 `CooldownMessage.Enabled` 是否为 `true`，
  并注意 `Scale` 只适用于 `Notification` 渠道。
- **其他情况** —— 将 `LogToFile` 设为 `true` 并重现问题；插件会在
  `config.json` 旁边写入自己的滚动日志 `ArkBossCooldown.log`。然后到
  [Bytemart Discord](https://bytemart.net/discord) 提问。

---

**后续步骤：**

- [配置](configuration.md) —— 冷却时间、消息，以及 Boss 列表。
- [通用配置](../index.md#common-configuration) —— 共享的 `LicenseKey`、
  `Database`、`LogToFile` 和 `Verbose` 键。
