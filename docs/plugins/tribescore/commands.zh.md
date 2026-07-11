# 命令

Tribescore 有两类命令：从服务器控制台或 RCON 运行的**管理**命令，以及在
游戏内输入的**玩家**聊天命令。管理命令以 `ts.` 为前缀，且只能通过
控制台/RCON 使用，因此没有单独的权限系统来限制它们——访问权限由渠道
隐含决定。聊天命令是可配置且可选的（参见 [`ChatCommands`](configuration.md#chatcommands)）。

## 控制台 / RCON 命令

| 命令 | 渠道 | 说明 |
| ------- | -------- | ----------- |
| `ts.help [page]` | Console, RCON | 显示分页的 Tribescore 帮助菜单。 |
| `ts.give <tribe-id> <score>` | Console | 为某部落增加 tribescore。会记录一条 `system` 交易。 |
| `ts.take <tribe-id> <score>` | Console | 从某部落扣除 tribescore。会记录一条 `system` 交易。 |
| `ts.boost <tribe-id> <type> <value> <duration>` | Console, RCON | 为某部落授予一个限时的分数增益。 |
| `ts.boost <tribe-id> clear` | Console, RCON | 清除某部落当前生效的限时增益。 |
| `ts.audit <tribe-id> [options]` | Console | 审计某部落的分数交易并上传一份报告。 |
| `ts.estimate <recipient-tribe-id> [options]` | Console | 估算你周围建筑的 tribescore。 |
| `ts.addstructure` | Console | 将你正注视的建筑追加到 `structures.json`。 |

### `ts.give` / `ts.take`

```bash
ts.give 1234567890 500      # 为部落 1234567890 增加 500 分
ts.take 1234567890 250      # 从部落 1234567890 扣除 250 分
```

两者都会向交易历史写入一条 `system` 类型的条目，以便手动调整可被审计。

### `ts.boost`

授予一个在设定时长内叠加进修正管线的临时分数乘数。

```
ts.boost <tribe-id> <type> <value> <duration>
ts.boost <tribe-id> clear
```

| 参数 | 说明 |
| -------- | ----------- |
| `<tribe-id>` | 目标部落的 ID。 |
| `<type>` | 增益作用的对象：`structures`、`dinos`、`players`、`all`，或用 `+` 连接的组合（例如 `structures+dinos`）。 |
| `<value>` | 乘数（例如 `1.5` 表示 +50%）。 |
| `<duration>` | 增益的持续时间，以**秒**为单位。 |

```bash
ts.boost 1234567890 structures+dinos 1.5 3600   # 对建筑和恐龙 +50%，持续 1 小时
ts.boost 1234567890 all 2 600                   # 所有分数翻倍，持续 10 分钟
ts.boost 1234567890 clear                        # 移除生效中的增益
```

> ℹ️ **也向其他插件开放。** 限时增益是 Tribescore 公共 API 的一部分
> （`SetTimedBoost` / `ClearTimedBoost` / `GetTimedBoost`），配套的 **Koth**
> 插件会用它来自动奖励活动获胜者。

### `ts.audit`

异步构建一份某部落交易的报告（他们从谁那里赚取了分数、谁从他们那里
偷走了分数、按集群的细分），并将其上传，返回一个 URL。

```
ts.audit <tribe-id> [clusters_amount=X] [givers_amount=X] [stealers_amount=X] [start_date=YYYY-MM-DD] [end_date=YYYY-MM-DD]
```

| 选项 | 说明 |
| ------ | ----------- |
| `clusters_amount=X` | 要纳入的前几名集群的数量。 |
| `givers_amount=X` | 此部落从中赚取分数的前几名部落的数量。 |
| `stealers_amount=X` | 从此部落夺取分数的前几名部落的数量。 |
| `start_date` / `end_date` | 将审计限定在一个日期范围内（`YYYY-MM-DD`）。 |

```bash
ts.audit 1234567890 givers_amount=10 start_date=2026-07-01 end_date=2026-07-12
```

### `ts.estimate`

扫描你角色范围内的建筑（通过八叉树扫描，分块在多个 tick 上进行），并估算
它们对某个给定部落值多少分数。适合用来调校 `structures.json` 的分值。

```
ts.estimate <recipient-tribe-id> [modifiers=on|off] [range=X]
```

| 选项 | 说明 |
| ------ | ----------- |
| `modifiers=on\|off` | 是否对估算应用修正管线。 |
| `range=X` | 你角色周围的扫描半径。 |

### `ts.addstructure`

对你正注视的建筑进行射线追踪，将其作为一个自定义条目追加到
`structures.json`，并热重载该文件——这是无需手动查找蓝图路径即可快速添加
按蓝图分值的方法。

---

## 聊天命令

这些命令在游戏内聊天中输入。名称是可配置的——下面的默认值来自随插件发布的
[`ChatCommands`](configuration.md#chatcommands) 配置，且每个命令都可以被
完全禁用。

| 命令（默认） | 说明 |
| ----------------- | ----------- |
| `/leaderboard` | 按分数显示排名靠前的部落。 |
| `/triberank` | 显示你自己部落的排名和分数。 |
| `/holograms` | 为你自己开启或关闭漂浮的 `+/- points` 全息投影。 |

措辞、颜色、大小、屏幕停留时长，以及（对于排行榜而言）行数和按名次的
颜色，全部在
[`ChatCommands`](configuration.md#chatcommands) 中设置。

---

## 权限节点

Tribescore 不使用权限来限制其命令，但
[`PermissionModifiers`](configuration.md#modifierspermissionmodifiers) 功能
会读取权限节点来增益或削弱某部落的分数。请通过
[Permissions](https://github.com/ServersHub/ServerAPI) 插件来授予它们。在默认
配置下：

```bash
Permissions.AddGroup VIP
Permissions.Grant VIP ts.boost.15
```

在这里，`VIP` 组的成员会根据 `PermissionModifiers.Modifiers` 中的
`ts.boost.15` 条目，为其部落带来 **1.15×** 的分数乘数。节点名称是任意的
——它们只需与你配置的内容相匹配即可。
