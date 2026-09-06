# 配置

ArkBossCooldown 通过插件文件夹中的一个 `config.json` 文件进行配置：

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ArkBossCooldown/config.json
```

还附带了第二个文件 `config_commented.json`。它是**带有 `//` 注释的相同
配置**——可以阅读它，但不要把它重命名覆盖 `config.json`（注释不是合法的
JSON）。

`LicenseKey`、`Verbose`、`LogToFile` 和 `Database` 这几个键由每个
Bytemart 插件共享，其说明位于
**[通用配置](../index.md#common-configuration)** 页面。本页涵盖
ArkBossCooldown 独有的键。

> 💡 **开始前先验证。** 编辑后请务必验证你的 JSON（例如
> 使用 [JSONLint](https://jsonlint.com/)）。加载错误代码 `1114` 意味着
> JSON 语法错误——在冗长的 `Bosses` 数组中很容易造成这种错误。

## `TestMode`

```json
"TestMode": false
```

当设为 `true` 时，插件会将**任何玩家合成的每一件物品的蓝图路径**
记录到服务器控制台。这是你找到要放入 [`Bosses`](#bosses) 中的贡品
确切路径的方法：

1. 将 `TestMode` 设为 `true` 并重新加载（`ArkBossCooldown.reload`）。
2. 合成你想要限制的贡品。
3. 从控制台的这一行复制路径——它看起来像
   `[TestMode] Crafted item blueprint: Blueprint'/Game/...'`。
4. 把它粘贴到 `Bosses` 中，将 `TestMode` 重新设为 `false`，然后再次
   重新加载。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `TestMode` | boolean | `false` | 记录每一件被合成物品的蓝图路径。 |

> ⚠️ **用完后请再次关闭它。** 当 `TestMode` 开启时，一个繁忙的服务器
> 会为*每一位玩家的每一次合成*都写入一行控制台记录。这是一个查找
> 工具，而不是应该长期开启的设置。

## `BossStartCooldown`

```json
"BossStartCooldown": 5
```

整个服务器在两次 Boss 开始之间必须等待的**秒数**。第一次贡品合成会
启动冷却；在它到期之前，其他所有贡品合成都会被拒绝。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `BossStartCooldown` | number | `5` | 全服范围内两次 Boss 开始之间的秒数。 |

默认值 `5` 是一种**防抖动**——它能吸收一连串的连续点击，在正常游戏中
不会被察觉。更大的数值会让插件变成一个真正的速率限制，这样也可以，
但请注意两点：

- **它是全服共用的。** 一个 30 分钟的冷却意味着一个部落开始 Boss 战
  会阻挡其他所有部落 30 分钟。这是你服务器的一项设计决定，而不是一个
  bug。
- **它不会在重启后保留。** 已启动的冷却存在于内存中，因此服务器重启
  （或插件的卸载/加载）会将其清除。对于几秒钟的设置无关紧要；但如果
  你把它设为几个小时，就需要了解这一点。

`ArkBossCooldown.reload` 会立即应用新的数值，但会刻意让一个已经启动的
冷却继续运行。

## `CooldownMessage`

```json
"CooldownMessage": {
  "Enabled": true,
  "Channel": "Notification",
  "Message": "Boss is on cooldown, please wait %delay%.",
  "Color": { "R": 255, "G": 0, "B": 0, "A": 255 },
  "Scale": 1.0,
  "Time": 5.0
}
```

被拒绝的玩家会看到的内容。只有该玩家会收到通知——不会向服务器上的
其他人广播任何内容。

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | 设为 `false` 可以静默地拒绝 Boss 开始。 |
| `Channel` | string | `"Notification"` | `"Chat"`、`"Notification"` 或 `"Broadcast"`。无法识别的值会回退到 `"Chat"`。 |
| `Message` | string | 见上方 | 消息文本。支持下方的占位符。 |
| `Color` | object | 红色 | `R`、`G`、`B`、`A`，每个都在 `0`–`255` 之间。`A` 是不透明度。 |
| `Scale` | number | `1.0` | 文本大小。**仅 `Notification` 渠道**——在其他渠道中会被忽略。 |
| `Time` | number | `5.0` | 消息在屏幕上停留的秒数。**仅 `Notification` 和 `Broadcast`**——聊天记录中的一行无论如何都会保留在聊天日志中。 |

### 占位符

| 占位符 | 展开为 | 示例 |
| ----------- | ---------- | ------- |
| `%delay%` | 拼写出的剩余时间 | `1 Minute, 5 Seconds` |
| `%seconds%` | 以纯数字形式表示的剩余秒数 | `65` |

如果消息是给玩家阅读的，使用 `%delay%`；如果你想要更简洁的内容，
使用 `%seconds%`：

```json
"Message": "Boss on cooldown - %seconds%s remaining."
```

> 💡 **`Notification` 还接受一个 `Icon`。** 添加一个带有材质路径的
> `"Icon"` 键，即可在通知旁显示一张图片。它不在出厂配置中；如果你
> 想要，需要自己添加——配置修复只会*添加*缺失的键，因此它会在更新后
> 继续存在。

## `Bosses`

```json
"Bosses": [
  "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'",
  "Blueprint'/Game/Fjordur/Boss/Arena/PrimalItem_BossTribute_FenrirBoss_Hard.PrimalItem_BossTribute_FenrirBoss_Hard'"
]
```

启动冷却的每一件贡品的蓝图路径。**不在此列表中的任何物品都会完全
正常地合成**——插件会忽略它。

| 字段 | 类型 | 说明 |
| ----- | ---- | ----------- |
| `Bosses` | array of strings | 完整的蓝图路径，包括 `Blueprint'...'` 包装，以及最后一个 `.` 之后重复的资源名称。会被精确匹配。 |

出厂列表涵盖了 **The Island**、**The Center**、**Scorched Earth**、
**Ragnarok**、**Aberration**、**Valguero**、**Fjordur**、
**Lost Island** 和 **Crystal Isles** 各个难度的贡品。

要限制其他任何东西——另一张地图、一个模组竞技场，或一个自定义贡品——
使用 [`TestMode`](#testmode) 捕获路径并将其添加到这里。要*停止*限制
某个 Boss，删除它所在的那一行即可。

> ⚠️ **请精确复制路径。** 匹配是针对整个路径逐字节进行的。缺少末尾的
> `'`、路径被截短，或者资源名称只写了一次而不是两次，都意味着
> “不匹配”，那么该贡品的合成将完全不受冷却限制。对于无法识别的路径
> 不会有任何报错，所以请用一次真实的合成来检查你的修改。

## 完整示例

一个在聊天中公告的 15 分钟限制：

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "TestMode": false,
  "BossStartCooldown": 900,
  "CooldownMessage": {
    "Enabled": true,
    "Channel": "Chat",
    "Message": "A boss fight has already started. Next one available in %delay%.",
    "Color": { "R": 255, "G": 180, "B": 0, "A": 255 },
    "Scale": 1.0,
    "Time": 8.0
  },
  "Bosses": [
    "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'"
  ],
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  }
}
```

> ℹ️ **`Database` 是必需的，但不会被使用。** ArkBossCooldown 会像每个
> Bytemart 插件一样在启动时连接，但不会存储任何属于自己的数据。将其
> 指向服务器可以访问的任意数据库即可。

---

**后续步骤：**

- [概述](index.md) —— 插件的功能、安装方法，以及命令。
- [通用配置](../index.md#common-configuration) —— `LicenseKey`、`Database`、
  `LogToFile`、`Verbose`。
