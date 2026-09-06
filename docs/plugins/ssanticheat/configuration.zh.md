# 配置

ssAntiCheat 通过插件文件夹中的一个 `config.json` 文件进行配置：

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ssAntiCheat/config.json
```

还附带了第二个文件 `config_commented.json`。它是**带有 `//` 注释的相同
配置**——可以阅读它，但不要把它重命名覆盖 `config.json`（注释不是合法的
JSON）。

`LicenseKey`、`Verbose`、`LogToFile` 和 `Database` 这几个键由每个 Bytemart
插件共享，其说明位于
**[通用配置](../index.md#common-configuration)** 页面。本页只涵盖
ssAntiCheat 独有的键。

> 💡 **开始前先验证。** 编辑后请务必验证你的 JSON（例如
> 使用 [JSONLint](https://jsonlint.com/)）。加载错误代码 `1114` 意味着
> JSON 语法错误。

> ⚠️ **键名称是功能性的——请原样复制。** 有几个键名中包含空格
> （`"Join Tracker"`、`"SaveWorld Cycles"`、`"Block Dedi Fill"`），还有几个
> 带有历史遗留的拼写错误（`Threshole`、`additionnalData`）。它们是逐字节
> 匹配的。“修正”拼写会悄无声息地禁用该功能。

## 自我修复配置

每次加载时，ssAntiCheat 都会将你的 `config.json` 与其构建时所用的架构
进行比较：

- **缺失的键**会以其默认值补上，控制台会准确打印出添加了什么。你的
  原始文件会先被复制为 `config.json.bak`。
- **类型不匹配**（例如本该是数字的地方出现了字符串等等）会**中止加载**，
  并报错指出具体的键——插件不会在一个它无法信任的配置上运行。

这意味着引入新键的更新不会破坏你的服务器，而且你始终可以将配置精简到
只保留你关心的键。

---

## 顶层键 {#top-level-keys}

```json
"Debug": false,
"Use Discord": true,
"UseDiscordURL": true,
"SteamAPIKey": "",
"CommandPrefix": "!",
"Send Alert to Ingame Admins when someone is detected using a cheat": true
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Debug` | boolean | `false` | 内部调试标志。请保持 `false`——需要排查问题的输出请使用 [`Verbose`](../index.md#verbose)。 |
| `Use Discord` | boolean | `true` | Discord 告警的总开关。当为 `false` 时，任何检测或封禁的嵌入消息都不会被发布到任何地方。 |
| `UseDiscordURL` | boolean | `true` | Discord 嵌入消息是否包含 ssAntiCheat 的图标/缩略图。纯粹是外观上的。 |
| `SteamAPIKey` | string | `""` | 一个 [Steam Web API 密钥](https://steamcommunity.com/dev/apikey)。仅连接门禁（游戏时长/账号年龄/VAC 检查）需要它。如果不使用，请留空。 |
| `CommandPrefix` | string | `"!"` | 游戏内管理员聊天命令的前缀。参见[命令](commands.md#chat-commands)。 |
| `Send Alert to Ingame Admins when someone is detected using a cheat` | boolean | `true` | 向每一位在线管理员广播一条带颜色的检测告警。 |

## Webhook {#webhooks}

```json
"DefaultWebhookUrl": "",
"BanWebhookUrl": "",
"AssociationBans": "",
"AdminTrollingWebhook": ""
```

全部四个都是 Discord Webhook URL，并且都以**空**的形式发布。空的
Webhook 意味着“不发送任何内容”——这从不算是错误。

| 字段 | 说明 |
| ----- | ----------- |
| `DefaultWebhookUrl` | 当模块没有自己的 Webhook 时，检测结果会发送到这里。这是应该最先填写的一项。 |
| `BanWebhookUrl` | **封禁**告警会发送到这里。为空时回退到 `DefaultWebhookUrl`。 |
| `AssociationBans` | **IP 关联**封禁告警会发送到这里——也就是发现一个新账号从已被封禁玩家的 IP 连接时。参见[封禁与检测](bans.md#ip-association-bans)。 |
| `AdminTrollingWebhook` | 游戏内管理员聊天命令的审计日志：谁对谁执行了什么操作，以及在哪里执行的。 |

任何单独的模块也可以携带自己的 `WebhookUrl` 键，仅针对该模块覆盖
`DefaultWebhookUrl`。

> 🔒 **Webhook URL 是一种凭据。** 任何拥有它的人都可以向你的频道发布
> 消息。请不要将 `config.json` 放入公开的代码仓库或截图中。

## `Dashboard`

```json
"Dashboard": {
  "Enabled": false,
  "LivePositions": false
}
```

选择性加入的 ssAnticheat 仪表盘遥测：实时的检测和封禁动态、封禁历史，
以及基本的服务器健康状况。**两个键的默认值都是 `false`**——在你启用
它们之前，不会有任何数据离开你的机器。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `false` | 仪表盘遥测的总开关。 |
| `LivePositions` | boolean | `false` | 额外发送玩家位置，以便仪表盘绘制实时地图。这实际上相当于每个玩家所在位置的实时视图——除非你需要这个功能，否则请保持关闭。 |

使用 [`ssac.status`](commands.md#ssacstatus) 检查遥测数据是否确实在
流动，使用 [`ssac.testdetection`](commands.md#ssactestdetection) 将一个
模拟检测推送到整个流程中。

## `Join Tracker`

```json
"Join Tracker": {
  "Enabled": true,
  "Include IP": true,
  "JoinLogs": ""
}
```

每当有玩家加入时，都会发布一条 Discord 嵌入消息，包含他们的名字、
Steam ID、部落，以及出生位置。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | 开关加入日志功能。 |
| `Include IP` | boolean | `true` | 在嵌入消息中包含连接的 IP 地址。 |
| `JoinLogs` | string | `""` | 加入日志的 Webhook URL。为空表示加入日志仍会被收集，但不会被发布。 |

> ⚠️ **IP 地址属于个人数据。** 如果你启用了 `Include IP`，请将加入日志
> 发送到一个私密的、仅管理员可见的频道，并在保留它们之前先确认你当地的
> 法规对你有何要求。

## `Admin ESP`

游戏内管理员 ESP 叠加层的设置，通过 [`!esp` 系列](commands.md#chat-commands)
聊天命令按管理员分别开关。

```json
"Admin ESP": {
  "Enabled": true,
  "RefreshTime": 0.1,
  "Range": 30000,
  "Structure ESP": ["Box"]
}
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | 保留字段。ESP 命令的访问权限由 ARK 管理员身份决定，而不是由这个键决定。 |
| `RefreshTime` | number | `0.1` | 每个绘制的标签/方框存在的时长，以秒为单位。数值越低，越流畅，但客户端绘制调用也越多。 |
| `Range` | number | `30000` | 管理员周围的扫描半径（虚幻引擎单位）。 |
| `Structure ESP` | array | `["Box"]` | 当建筑 ESP 开启时，用于匹配并高亮显示的建筑蓝图名称子串。`"Box"` 匹配储物箱；可以添加例如 `"Vault"` 或 `"Turret"`。 |

## `ServerCrash`

```json
"ServerCrash": {
  "SaveWorld": true,
  "AutomaticRestart": true
}
```

服务器进程崩溃时该做什么。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `SaveWorld` | boolean | `true` | 在崩溃处理程序内部尝试进行一次世界存档，这样一次崩溃只会损失几分钟，而不是整个存档间隔。 |
| `AutomaticRestart` | boolean | `true` | 在崩溃后短暂延迟自动重启服务器。如果你的服务器管理器（ASM、ArkServerManager、某个服务包装器……）已经会在进程退出时重启，请将此项**关闭**——否则会出现两次重启相互竞争的情况。 |

## `Fixes`

针对众所周知的服务器漏洞和利用途径的修复。这些**不是**检测器——不会有
人因为它们而被标记或封禁；被破坏的行为只是单纯地被阻止了。

```json
"Fixes": {
  "Scout Glitch Fix":         { "Enabled": true },
  "Handcuff Glitch Fix":      { "Enabled": false },
  "Player Already Connected": { "Enabled": true },
  "Pull Fix":                 { "Enabled": true },
  "Lag Protector":            { "Enabled": true },
  "Dupe Fix":                 { "Enabled": true }
}
```

| 修复项 | 默认值 | 作用 |
| --- | ------- | ------------ |
| `Scout Glitch Fix` | `true` | 修正 Scout 的搬运行为，修复众所周知的 Scout 漏洞。 |
| `Handcuff Glitch Fix` | `false` | 为一名在戴着手铐时下线、又重新上线的玩家重新戴上手铐——修复“下线以逃脱手铐”的技巧。默认关闭；如果手铐是你的管理员或玩家日常操作的一部分，请启用它。 |
| `Player Already Connected` | `true` | 清除导致“玩家已连接”错误的卡住会话，这样玩家就不必等待它自行消失。 |
| `Pull Fix` | `true` | 拦截 Structures Plus 的**服务器拉取（server pull）**漏洞利用，即利用拉取功能从容器中批量拖出受限物品（Boss 贡品之类）。玩家会收到提示“You can't pull this craft”。 |
| `Lag Protector` | `true` | 针对蓄意制造服务器卡顿手段的反破坏防护。**需要额外的键——见下文。** |
| `Dupe Fix` | `true` | 销毁重复生成的 S+ 死亡物品箱：在一个已有死亡箱上方生成的第二个死亡箱会被移除，而不是使其内容翻倍。 |

每一项修复都有一个 `Enabled` 标志。`Lag Protector` 还多带三个。

### Lag Protector

`Lag Protector` 出厂时只带有 `Enabled`，它的每一项防护都是**选择性
启用**的——需要你自己添加相应的键来开启它们：

```json
"Lag Protector": {
  "Enabled": true,
  "WhipProtection": true,
  "BlueprintProtection": true,
  "LagWebhook": ""
}
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `WhipProtection` | boolean | `false` | 踢出在建筑密集到足以让服务器卡顿的区域内开火的玩家——经典的“在大型基地里甩鞭子”式破坏。 |
| `BlueprintProtection` | boolean | `false` | 踢出在几秒内排队进行不合理密集的蓝图合成的玩家。 |
| `LagWebhook` | string | `""` | 卡顿防护踢出事件的 Webhook。为空时不发送任何内容。 |

此修复触发的踢出会带有一个刻意含糊的原因代码，这样破坏者无法从中得知
任何信息：`0x7E3` 是甩鞭防护，`0x4DE` 是蓝图防护。

> ℹ️ **你自己添加的键会被保留。** 配置自我修复只会*添加*缺失的键——它
> 永远不会删除它不认识的键，因此上面这三个键能在插件更新后继续存在。

## `IntegratedBanSystem` 和 `AutoBan`

这两个部分驱动着封禁流程，完整文档见 **[封禁与检测](bans.md)** 页面：

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
},
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

> ⚠️ **请修改 `BanMessage` 中的 URL。** 它出厂时带有一个 `example.com`
> 的占位符。请将其指向你自己的商店或申诉页面。

---

## `Modules`

每一个检测器都位于 `Modules` 之下，属于以下四大类之一：

| 分类 | 涵盖内容 |
| -------- | -------------- |
| `CombatCheats` | 战斗时的作弊——瞄准辅助、射速与弹药操纵、消耗品自动化。 |
| `MiscCheats` | 客户端自动化和客户端工具——自动拾取、自动合成、欺骗工具、计时异常，以及连接门禁。 |
| `Mod` | 需要可选配套客户端模组的检查（包括硬件 ID 采集和模组绕过检测）。除非部署了该模组，否则不起作用——如果你需要它，请到 [Bytemart Discord](https://bytemart.net/discord) 询问。 |
| `Exploits` | 已知的游戏和模组漏洞利用：复制途径、崩溃手段、解锁器、坐骑与建筑滥用、管理员保护等等。 |

结构总是相同的：

```json
"Modules": {
  "CombatCheats": {
    "Enabled": true,
    "SubModules": {
      "AutoFlak":   { "Enabled": true, "Block": true, "TimesUntilDetect": 6 },
      "NoOverheat": { "Enabled": true, "Block": true, "BanAfterDetections": 2 },
      "...":        { "...": "..." }
    }
  },
  "MiscCheats": { "Enabled": true, "SubModules": { "...": "..." } },
  "Mod":        { "Enabled": true, "SubModules": { "...": "..." } },
  "Exploits":   { "Enabled": true, "SubModules": { "...": "..." } }
}
```

某个分类的 `Enabled: false` 会关闭其中的**每一个**模块，无论各自的标志
怎么设置。你出厂的 `config.json` 中包含了带有合理默认值的完整子模块
列表——下面的参考说明了你会在它们身上找到的键。

### 常见子模块键 {#common-submodule-keys}

| 键 | 类型 | 含义 |
| --- | ---- | ------- |
| `Enabled` | boolean | 开关这个特定的检测器。 |
| `Block` | boolean | 在报告作弊行为的同时也阻止它。当为 `false` 时，该行为会正常通过，你只会收到告警——在你对某个模块建立信心之前，这在你自己的服务器上很有用。 |
| `BanAfterDetections` | number | 当**该模块**产生这么多次检测后，将玩家排入封禁队列。缺省或为 `0` 表示该模块永远不会自行触发封禁。 |
| `InstantBan` | boolean | 立即执行该封禁，而不是等待下一次封禁波次。 |
| `OnlyAnalysis` | boolean | 检测并记录，但不发布到你的 Discord Webhook。一种用于评估模块的安静模式。 |
| `WebhookUrl` | string | 将该模块的告警发送到一个特定的 Webhook，而不是 `DefaultWebhookUrl`。 |
| `Threshole` / `*Threshold` | number | 模块的灵敏度。数值越高，触发前所需的证据越多。使用 `Threshole` 这种拼写的键中，这个拼写是刻意为之的。 |
| `BlockMovement` | boolean | 被少数解锁器模块使用：将违规者原地冻结，而不仅仅是标记他们。 |

有些模块会额外添加自己的键——例如一个要从检查中排除的蓝图名称列表，
或是针对该漏洞利用某个特定变体的额外子标志。这些内容在
`config_commented.json` 中有说明，前提是它们不是不言自明的。

> 💡 **调优建议。** 从出厂默认值开始。如果某个模块在你的环境中产生了
> 误报，优先考虑提高它的阈值或 `BanAfterDetections`，而不是直接禁用
> 它——在观察期间可以设置 `OnlyAnalysis`。

### 连接门禁

`MiscCheats` 中有一个模块值得特别说明，因为它需要额外的外部设置：
**会话追踪器（session tracker）**会针对 Steam Web API 检查加入的玩家，
并可以拒绝看起来像是一次性小号的账号。

```json
"SessionTracker": {
  "Enabled": true,
  "WebhookUrl": "",
  "Checks": {
    "AccountRestrictions": {
      "MinGameHours": 30,
      "BlockMinGameHours": false,
      "LogMinGameHours": true,
      "MinAccountAgeDays": 30,
      "BlockMinAccountAgeDays": false,
      "LogMinAccountAgeDays": true
    },
    "VacBanRestrictions": {
      "Block": false,
      "RecentDaysThreshole": 90,
      "Log": true
    }
  }
}
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `WebhookUrl` | string | `""` | 门禁结果的 Webhook。回退到 `DefaultWebhookUrl`。 |
| `MinGameHours` | number | `30` | 最低 ARK 游戏时长，以小时为单位。 |
| `BlockMinGameHours` | boolean | `false` | 踢出低于该游戏时长的玩家。 |
| `LogMinGameHours` | boolean | `true` | 报告低于该游戏时长的玩家。 |
| `MinAccountAgeDays` | number | `30` | 最低 Steam 账号年龄，以天为单位。 |
| `BlockMinAccountAgeDays` | boolean | `false` | 踢出比该年龄更年轻的账号。 |
| `LogMinAccountAgeDays` | boolean | `true` | 报告比该年龄更年轻的账号。 |
| `VacBanRestrictions.RecentDaysThreshole` | number | `90` | VAC 封禁需要在多近的时间内才会被计入。 |
| `VacBanRestrictions.Block` | boolean | `false` | 踢出有近期 VAC 封禁记录的玩家。 |
| `VacBanRestrictions.Log` | boolean | `true` | 报告有近期 VAC 封禁记录的玩家。 |

> ℹ️ **需要 `SteamAPIKey`。** 没有密钥，这些检查就无法运行。另外请注意，
> 将 Steam 个人资料设为**私密**的玩家会隐藏他们的游戏时长——请慎重决定
> 是否要开启 `Block*`，因为这会拒绝一部分合法玩家。

---

**后续步骤：**

- [命令](commands.md) —— 控制台/RCON 和游戏内管理员命令。
- [封禁与检测](bans.md) —— 阈值、封禁波次、IP/HWID 封禁、解封。
- [通用配置](../index.md#common-configuration) —— `LicenseKey`、`Database`、
  `LogToFile`、`Verbose`。
