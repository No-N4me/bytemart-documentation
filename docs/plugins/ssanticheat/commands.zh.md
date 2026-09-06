# 命令

ssAntiCheat 有两类命令：以 `ssac.` 为前缀的**控制台/RCON**命令，以及以
`!` 为前缀的**游戏内聊天**命令（可通过
[`CommandPrefix`](configuration.md#top-level-keys) 配置）。

控制台和 RCON 访问权限本身就是管理员权限，因此 `ssac.` 命令不需要额外
的权限。聊天命令会检查你是否为**服务器管理员**（`enablecheats`），
否则会静默地什么都不做。

## 控制台 / RCON 命令

| 命令 | 渠道 | 说明 |
| ------- | -------- | ----------- |
| `ssac.help [page]` | Console, RCON | 分页列出所有已注册的命令。 |
| `ssac.status` | Console, RCON | 许可证、服务器 ID，以及仪表盘遥测状态。 |
| `ssac.detections` | Console, RCON | 按 Steam ID 分组列出最近的检测记录。 |
| `ssac.pendingbans` | Console, RCON | 列出排队等待下一次封禁波次的玩家。 |
| `ssac.banwave` | Console, RCON | 立即执行待处理的封禁波次。 |
| `ssac.clearbanwave` | Console, RCON | 丢弃所有待处理的封禁，不封禁任何人。 |
| `ssac.ban <steamid> [r=<reason>] [d=<duration>]` | Console, RCON | 封禁一名玩家。 |
| `ssac.unban <ban-id>` | Console, RCON | 通过封禁 ID 取消一个封禁。 |
| `ssac.testdetection [steamid] [module]` | Console, RCON | 向仪表盘推送一次模拟检测。 |
| `ssac.go [steamid]` | Console | 观察一名玩家——指定的玩家，或最近一次被检测到的玩家。 |
| `ssac.command <reason> <command...>` | Console | 以你自己的身份运行一条控制台命令，并留下记录。 |

`ssac.go` 和 `ssac.command` 作用于*你自己*的角色，因此它们只能从游戏内
控制台使用——RCON 会话背后没有玩家角色。

### `ssac.status`

这是安装后应该运行的第一个命令，也是技术支持会首先要求你提供的信息。
它会打印插件版本、许可证是否已验证、本服务器的 ID、地图和服务器名称，
以及——当仪表盘遥测开启时——端点、服务器是否已注册、最近一次发送结果，
以及队列深度。

```bash
ssac.status
```

如果队列深度一直不为零且从不减少，说明仪表盘端点无法访问，或正在拒绝
你的事件。

### `ssac.detections`

列出内存中保存的检测记录（大约是**最近一小时**），按 Steam ID 分组，
并标明每一条是由哪个模块触发的。

```bash
ssac.detections
```

> ℹ️ **检测记录仅保存在内存中。** 它们不会在服务器重启后保留。封禁记录
> 则会——它们存储在 MySQL 中。请将你的 Discord Webhook 作为检测记录的
> 永久留档。

### `ssac.ban` / `ssac.unban`

```
ssac.ban <steamid> [r=<reason>] [d=<duration>]
ssac.unban <ban-id>
```

| 参数 | 说明 |
| -------- | ----------- |
| `<steamid>` | 目标的 SteamID64（17 位数字）。 |
| `r=<reason>` | 封禁原因。如果包含空格，请用引号括起来。默认值为 `No reason provided`。 |
| `d=<duration>` | 封禁时长，由 `d` / `h` / `m` / `s` 部分组成——例如 `7d`、`12h30m`、`1d6h`。省略它则为**永久**封禁。 |

```bash
ssac.ban 76561198000000000 r="Aimbot" d=7d
ssac.ban 76561198000000000                  # 永久封禁，无原因
ssac.unban 42                               # 解除 42 号封禁
```

该封禁会连同玩家的 IP（以及如果采集到的话，他们的硬件 ID）一起写入
MySQL，如果玩家在线，会立即使用你的 [`BanMessage`](bans.md#ban-message)
将其踢出。`ssac.unban` 使用的是**封禁 ID**，而不是 Steam ID——
`ssac.detections` 和 Discord 封禁嵌入消息都会显示它，它也是玩家看到的
踢出消息中的 `{ban_id}`。

### `ssac.banwave` / `ssac.clearbanwave` / `ssac.pendingbans`

```bash
ssac.pendingbans     # 谁在排队，以及原因
ssac.banwave         # 立即封禁所有人
ssac.clearbanwave    # 全部放行
```

待处理的封禁由检测模块排队，通常按计划执行——参见
[封禁与检测](bans.md#ban-waves)。这三条命令让你可以查看队列、提前清空
它，或者清除一个你认为是误报的队列。

### `ssac.go`

让你进入观察者模式并移动到某位玩家所在的位置。

```bash
ssac.go                       # 最近一次被检测到的玩家
ssac.go 76561198000000000     # 指定的玩家
```

不带参数时，它会跟随最近一次检测，这在你响应告警时正是你想要的。带上
一个 Steam ID 时，它会以该玩家为目标，并回显解析出的名字，方便你确认
抓对了人。

### `ssac.command`

以你自己的身份运行一条控制台命令，并记录该操作已获得 ssAntiCheat 的
批准，这样管理员保护模块就不会因为你使用它而标记你。

```
ssac.command <reason> <command...>
```

```bash
ssac.command investigating_dupe giveitemnum 1 1 0 0
```

第一个参数是用于审计记录的自由文本原因；它之后的所有内容都是要运行的
命令。

### `ssac.testdetection`

发出一次**模拟**检测，让你无需等待真正的作弊者出现，就能验证你的仪表盘
流程。它要求 [`Dashboard.Enabled`](configuration.md#dashboard) 为
`true`。

```
ssac.testdetection [steamid] [module]
```

```bash
ssac.testdetection                              # 针对你自己的检测（从游戏内控制台运行）
ssac.testdetection 76561198000000000 AutoLoot   # 针对指定玩家，标记为 AutoLoot
```

在游戏内控制台不带参数运行时，目标是**你自己**，因此仪表盘中的这一行
会显示真实的名字、部落和位置。测试事件会被标记为模拟事件，并被排除在
真实检测统计之外。它们不会发送到 Discord，也永远不会封禁任何人。

---

## 聊天命令 {#chat-commands}

在游戏内聊天中输入，仅限管理员使用，前缀为
[`CommandPrefix`](configuration.md#top-level-keys)（默认是 `!`）。当
某条命令需要 `<steamid>` 时，你可以省略它，命令会作用于**你正在看的
人**。

名称会按照下面所写的完全匹配，包括大小写。

### 调查

| 命令 | 说明 |
| ------- | ----------- |
| `!esp` | 为自己开关 ESP。 |
| `!espPlayers` | 开关玩家 ESP：在每个玩家上方显示名字、生命值和当前武器。 |
| `!EspStruct` | 开关建筑 ESP。 |
| `!espset <name>` | 在 [`Structure ESP`](configuration.md#admin-esp) 列表的基础上，额外高亮显示蓝图名称包含 `<name>` 的建筑。 |
| `!espHideEmpty` | 在建筑 ESP 中隐藏空容器。 |
| `!tracers` | 将附近的每一次射击都绘制为一条曳光线，颜色根据击中的身体部位而定。这是用肉眼判断瞄准辅助最有用的单一工具。 |
| `!vanish` | 开关你自己的隐身状态。 |
| `!spawn` | 在你当前的视角处重生，然后启用创造模式、对敌方隐身，以及飞行。 |
| `!cloud <steamid>` | 向自己打印出某玩家已上传（贡品）的物品。 |

`!esp` 是总开关——只有当你的 ESP 处于开启状态时，`!espPlayers` 和
`!EspStruct` 才会绘制内容。

### 互动

这些命令会直接作用于嫌疑人。请谨慎使用：它们对玩家是可见的，可能会
打草惊蛇，提醒一个你还在收集证据的作弊者。

| 命令 | 说明 |
| ------- | ----------- |
| `!unequip <steamid>` | 剥去玩家已装备的护甲。 |
| `!dropweapon <steamid>` | 强制玩家丢弃手持的武器。 |
| `!jump <steamid>` | 强制玩家跳跃。 |
| `!punch <steamid>` | 触发玩家的 Tek 拳套火箭拳。 |
| `!tekjump <steamid>` | 触发玩家的 Tek 胸甲推进。 |
| `!requestjoin <steamid>` | 向玩家发送一个假的部落邀请。 |
| `!outofrange <steamid>` | 向玩家显示“超出范围”的客户端提示。 |
| `!playpoopsound <steamid>` | 在玩家身上播放便便音效。 |
| `!playdeathsound <steamid>` | 在玩家身上播放死亡音效。 |

> ℹ️ **每一次管理员操作都会被记录。** 管理员聊天命令会被记录到本地
> 日志文件，并发布到 [`AdminTrollingWebhook`](configuration.md#webhooks)，
> 其中包含执行操作的管理员、目标，以及地点——从而确保管理员权限的
> 可问责性。
