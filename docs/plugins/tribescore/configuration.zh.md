# 配置

Tribescore 通过插件文件夹
（`ShooterGame/Binaries/Win64/ArkApi/Plugins/Tribescore/`）中的**三个**文件
进行配置：

| 文件 | 用途 |
| ---- | ------- |
| `config.json` | 主要设置：许可证、数据库、激活、资格、计分修正、全息投影和聊天命令。 |
| `structures.json` | 建筑的分值，按建造等级和按蓝图设置。 |
| `dinos.json` | 恐龙的分值和计数规则，按物种设置。 |

> 💡 **开始前先验证。** 编辑后请务必验证你的 JSON（例如
> 使用 [JSONLint](https://jsonlint.com/)）。加载错误代码 `1114` 意味着 JSON
> 语法错误。

`LicenseKey`、`Verbose`、`LogToFile` 和 `Database` 这几个键由每个 Bytemart
插件共享，其说明位于
**[通用配置](../index.md)** 页面。本页只涵盖 Tribescore
独有的键。

---

## `config.json`

### `DebugMode`

```json
"DebugMode": false
```

当设为 `true` 时，控制台会变得更加详细，**并且**你可以从自己的部落赚取
tribescore——这在开发服务器上测试计分时很有用。在正式服务器上请保持
`false`。

### `TribescoreActivation`

在服务器（清档）启动后全局延迟计分，让各部落在竞争开始前有时间重新
建立起来。

```json
"TribescoreActivation": {
  "Activation": {
    "Type": "delay",
    "Value": 7200
  },
  "Message": "Tribescore is globally enabled after 2 hours, please wait {cooldown}"
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Activation.Type` | string | `"delay"` —— 在服务器启动 `Value` 秒之后启用计分。`"timestamp"` —— 在一个固定的 [Unix 时间戳](https://www.unixtimestamp.com/)时启用计分。 |
| `Activation.Value` | number | 延迟的秒数（对于 `delay`）或 Unix 时间戳（对于 `timestamp`）。设为 `0` 可禁用该功能并立即启用计分。 |
| `Message` | string | 在计分仍处于冷却中时触发计分的玩家会看到此消息。`{cooldown}` 占位符会被替换为剩余时间。 |

### `TribescoreEligibility`

根据成员规模限制哪些部落可以赚取分数。

```json
"TribescoreEligibility": {
  "MinPlayers": 1,
  "MinOnlinePlayers": 0
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `MinPlayers` | number | 部落必须拥有的最少成员数（总数）才能赚取分数。 |
| `MinOnlinePlayers` | number | 必须**在线**的最少成员数，部落才能赚取分数。`0` 会禁用此项检查。 |

### `Scoring`

插件的核心所在。基础值存放于此（以及 `structures.json` /
`dinos.json` 中）；`Modifiers` 子部分会对它们进行乘算。

```json
"Scoring": {
  "GainLossRatio": 0.75,
  "Structures": { "Enabled": true, "DefaultValue": 10.0 },
  "Dinos":      { "Enabled": true, "DefaultValue": 25.0 },
  "Players":    { "Enabled": true, "Value": 150.0 },
  "Modifiers": { "...": "..." }
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `GainLossRatio` | number | 当没有设置显式的 `LossOverride`（在 `structures.json` / `dinos.json` 中）时，**防守方**的失分为 `gain × GainLossRatio`。在 `0.75` 时，防守方失去进攻方所得的 75%。 |
| `Structures.Enabled` | boolean | 启用来自被摧毁建筑的计分。在 [`structures.json`](#structuresjson) 中配置分值。 |
| `Structures.DefaultValue` | number | 未匹配到等级或蓝图的建筑所得的分值。 |
| `Dinos.Enabled` | boolean | 启用来自被击杀恐龙的计分。在 [`dinos.json`](#dinosjson) 中配置分值。 |
| `Dinos.DefaultValue` | number | 没有按物种覆盖的恐龙所得的分值。 |
| `Players.Enabled` | boolean | 启用来自击杀敌方玩家的计分。 |
| `Players.Value` | number | 每击杀一名敌方玩家授予的固定分值。 |

#### `Modifiers.OfflineProtection`

降低（或提高）针对一个已完全离线一段时间的部落所赚取的分数——以此
遏制离线突袭。

```json
"OfflineProtection": {
  "Enabled": true,
  "ActivatesAfter": 3600,
  "Modifier": 0.75
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Enabled` | boolean | 开关此功能。 |
| `ActivatesAfter` | number | 部落必须完全离线多少秒之后保护才会生效。 |
| `Modifier` | number | 生效后应用的乘数。`< 1` 会降低进攻方的所得（例如 `0.75` = −25%）。 |

*基于**防守方**应用。*

#### `Modifiers.PermissionModifiers`

根据进攻方的 ArkApi **权限**来增益（或削弱）分数。需要来自 ArkServerAPI 的
[Permissions](https://github.com/ServersHub/ServerAPI) 插件。

```json
"PermissionModifiers": {
  "Enabled": true,
  "TribePermissionsOnly": false,
  "OnlinePlayersOnly": true,
  "Modifiers": [
    { "Permission": "ts.boost.10", "Value": 1.1 },
    { "Permission": "ts.boost.15", "Value": 1.15 },
    { "Permission": "ts.boost.25", "Value": 1.25 }
  ]
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Enabled` | boolean | 开关此功能。 |
| `TribePermissionsOnly` | boolean | 当设为 `true` 时，只检查部落级别的权限（忽略单个玩家的权限）。 |
| `OnlinePlayersOnly` | boolean | 当设为 `true` 时，只考虑当前在线成员的权限；否则会检查所有成员。 |
| `Modifiers[]` | array | 权限 → 乘数的配对。**一次只应用一个修正**；如果有多个匹配，则使用**最大**的那个。 |
| `Modifiers[].Permission` | string | 玩家/部落必须持有的权限节点。 |
| `Modifiers[].Value` | number | 应用的乘数（`> 1` 会增加所得）。 |

*基于**进攻方**应用。*

#### `Modifiers.ScoreDifferenceRatio`

平衡强弱部落。比较的比率是**防守方**的分数除以**进攻方**的分数；匹配区间的
`Modifier` 会缩放进攻方的所得——因此大部落刷小部落会被削弱，而弱者
进攻巨头则会被增益。

```json
"ScoreDifferenceRatio": {
  "Enabled": true,
  "Intervals": [
    { "UpperBound": -1,   "LowerBound": 2,    "Modifier": 1.2 },
    { "UpperBound": 2,    "LowerBound": 1.5,  "Modifier": 1.1 },
    { "UpperBound": 1.5,  "LowerBound": 1,    "Modifier": 1 },
    { "UpperBound": 1,    "LowerBound": 0.5,  "Modifier": 0.8 },
    { "UpperBound": 0.5,  "LowerBound": 0.25, "Modifier": 0.6 },
    { "UpperBound": 0.25, "LowerBound": 0,    "Modifier": 0.25 }
  ]
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Enabled` | boolean | 开关此功能。 |
| `Intervals[]` | array | 防守方/进攻方分数比率的各个区间，每个区间带有一个乘数。 |
| `LowerBound` / `UpperBound` | number | 此修正覆盖的比率区间。将顶部区间的 `UpperBound` 设为 `-1` 表示“无上限”。 |
| `Modifier` | number | 当比率落入此区间时应用的乘数。 |

**解读默认值：**

- 比率 `≥ 2`（防守方分数 ≥ 进攻方的 2 倍）→ 对进攻的弱者给予 **1.2×**
  增益。
- 比率介于 `1.5` 到 `2` 之间 → **1.1×** 增益。
- 比率介于 `0.25` 到 `0.5` 之间 → **0.6×** 削弱。
- 比率 `< 0.25`（防守方分数不足进攻方的四分之一）→
  **0.25×** —— 对刷弱得多的部落给予严厉削弱。

*同时使用**进攻方**和**防守方**。*

### `Holograms`

控制在分数变化时于世界中出现的漂浮分数数字。
`Damager` 是展示给进攻方的 `+points` 文本；`Damagee` 是展示给防守方的
`-points` 文本。

```json
"Holograms": {
  "DecimalPrecision": 1,
  "LifeSpan": 6.0,
  "Scale":    { "X": 0.5, "Y": 0.5 },
  "FadeTime": { "In": 2.0, "Out": 3.0 },
  "Velocity": { "X": 0, "Y": 0, "Z": 10.0 },
  "Damager": { "Enabled": true, "Text": "+ {points} points", "Color": { "R": 0,   "G": 255, "B": 0 } },
  "Damagee": { "Enabled": true, "Text": "- {points} points", "Color": { "R": 255, "G": 0,   "B": 0 } }
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `DecimalPrecision` | number | `{points}` 值中显示的小数位数。 |
| `LifeSpan` | number | 全息投影保持可见的秒数。 |
| `Scale.X` / `Scale.Y` | number | 各轴上的文本大小。 |
| `FadeTime.In` / `FadeTime.Out` | number | 淡入 / 淡出时长（秒）。 |
| `Velocity.X/Y/Z` | number | 文本的漂移速度；默认值使其向上漂浮（`Z`）。 |
| `Damager` / `Damagee` | object | 得分 / 失分的弹出提示。`Enabled` 分别开关；`Text` 使用 `{points}` 占位符；`Color` 为 RGB（0–255）。 |

玩家可以使用 `/holograms` 聊天命令为自己开启或关闭全息投影
（参见[命令](commands.md)）。

### `ChatCommands`

启用、重命名并设置三个游戏内聊天命令的样式。每个命令都有一个 `Enabled`
开关和一个可自定义的 `Command` 触发词；禁用某个命令会将其完全注销。

```json
"ChatCommands": {
  "Holograms":   { "Enabled": true, "Command": "/holograms", "On": { "...": "..." }, "Off": { "...": "..." } },
  "Leaderboard": { "Enabled": true, "Lines": 15, "Command": "/leaderboard", "Text": "#{rank} [{tribe}] : {score}", "PerRankColor": { "...": "..." } },
  "MyTribeRank": { "Enabled": true, "Command": "/triberank", "Text": "Your tribe ({tribe}) is ranked #{rank} with {score}" }
}
```

每个命令的通用字段：`TextSize`（number）、`Color`（RGB `{R,G,B}`）以及
`DisplayTime`（消息停留在屏幕上的秒数）。

**`Holograms`** —— 切换每位玩家的全息投影显示。`On` 和 `Off` 各自定义在
切换时显示的确认消息（`Text`、`TextSize`、`Color`、`DisplayTime`）。

**`Leaderboard`** —— 打印排名靠前的部落。

| 字段 | 说明 |
| ----- | ----------- |
| `Lines` | 列出多少个部落。 |
| `Text` | 行格式。占位符：`{rank}`、`{tribe}`、`{score}`。 |
| `PerRankColor` | 可选的按名次颜色覆盖，以名次为键（`"1"`、`"2"`、`"3"`……），每个都是一个 RGB 对象。 |

**`MyTribeRank`** —— 打印调用者自己部落的排名。`Text` 支持相同的
`{rank}`、`{tribe}`、`{score}` 占位符。

### `Messages`

预留用于消息自定义；默认为空（`{}`）。

---

## `structures.json`

建筑的分值，先按建造**等级**解析，再由具体的**蓝图**覆盖。
未匹配到任何项的建筑会使用 `DefaultValue`。

```json
{
  "Tiers": {
    "Thatch": { "Value": 1.0,  "LossOverride": 0.5 },
    "Wood":   { "Value": 2.0,  "LossOverride": 1.25 },
    "Stone":  { "Value": 3.0,  "LossOverride": 2.0 },
    "Adobe":  { "Value": 5.0,  "LossOverride": 4.0 },
    "Metal":  { "Value": 10.0, "LossOverride": 7.0 },
    "Tek":    { "Value": 15.0, "LossOverride": 12.5 }
  },
  "DefaultValue": 10.0,
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Structures/Misc/PrimalItemStructure_HeavyTurret.PrimalItemStructure_HeavyTurret'",
      "Value": 25.0
    },
    {
      "BlueprintPath": "Blueprint'/Game/.../PrimalItemStructure_TurretTek.PrimalItemStructure_TurretTek'",
      "Value": 25.0,
      "LossOverride": 25.0
    }
  ]
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Tiers` | object | 按等级的分值，以建造材料为键（`Thatch`、`Wood`、`Stone`、`Adobe`、`Metal`、`Tek`）。 |
| `Tiers.<tier>.Value` | number | 进攻方摧毁此等级的建筑所获得的分值。 |
| `Tiers.<tier>.LossOverride` | number | *（可选）* 防守方失去的固定分值。如果省略，则使用 `Value × GainLossRatio`。 |
| `DefaultValue` | number | 当建筑未匹配到任何等级或自定义项时的回退值。 |
| `Customs[]` | array | 按蓝图的覆盖，优先级高于等级值。 |
| `Customs[].BlueprintPath` | string | 建筑的完整蓝图路径。使用 `ts.addstructure` 可自动追加你正注视的建筑（参见[命令](commands.md)）。 |
| `Customs[].Value` | number | 此特定蓝图的分值。 |
| `Customs[].LossOverride` | number | *（可选）* 此蓝图的固定失分。 |

---

## `dinos.json`

按恐龙物种的分值和计数规则。`Defaults` 适用于每一只未在 `Customs` 中
列出的恐龙。

```json
{
  "Defaults": {
    "Value": 25.0,
    "LossOverride": 20.0,
    "CountBabies": true,
    "CountWithoutSaddle": true,
    "CountNotMounted": true,
    "ScoreFromWild": true
  },
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/Dinos/Giganotosaurus/Gigant_Character_BP.Gigant_Character_BP'",
      "Value": 50.0,
      "LossOverride": 45.0,
      "CountBabies": false
    }
  ]
}
```

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Value` | number | 进攻方击杀此恐龙所获得的分值。 |
| `LossOverride` | number | *（可选）* 防守方失去的固定分值。如果省略，则使用 `Value × GainLossRatio`。 |
| `CountBabies` | boolean | 击杀幼体/幼年恐龙是否计分。 |
| `CountWithoutSaddle` | boolean | 无鞍的驯服恐龙是否计分。 |
| `CountNotMounted` | boolean | 当前未被骑乘的恐龙是否计分。 |
| `ScoreFromWild` | boolean | 击杀此物种的**野生**（未驯服）恐龙是否计分。 |
| `Customs[].BlueprintPath` | string | 此覆盖所针对物种的完整蓝图路径。 |

每个 `Customs` 条目都可以设置这些字段的任意子集；未指定的字段会回退到
`Defaults`。
