# 封禁与检测

ssAntiCheat 将**检测**作弊者与**移除**作弊者区分开来。检测始终会触发
告警；只有当某个模块的阈值被满足时才会发生封禁，即便如此，通常也会被
延后到下一次**封禁波次**才执行。这种延迟是刻意为之——它能阻止作弊者将
“我做了 X，一秒后就被封了”联系起来，从而推断出是哪项检查抓到了他们。

## 流程

```
1. 检测器触发
2. 记录检测结果  ──> 游戏内管理员告警
                ──> Discord webhook
                ──> 仪表盘（如果启用）
3. 模块是否已达到其 BanAfterDetections 次数？   ── 否 ──> 结束
                          │ 是
4. 玩家被排入封禁队列
5. 队列在下一次封禁波次中被执行
6. 执行：运行 AutoBan.ExecuteCommand，告警管理员，
   并（如果 IntegratedBanSystem 已开启）写入封禁记录并踢出
7. 在其下一次尝试加入时，该封禁会在登录时被强制执行
```

第 3–4 步是按模块进行的——参见
[`BanAfterDetections`](configuration.md#common-submodule-keys)。没有
该键的模块会检测并告警，但永远不会自行触发封禁。

## 封禁波次 {#ban-waves}

当以下**任意**情况发生时，排队中的封禁就会被执行：

| 触发条件 | 说明 |
| ------- | ----- |
| 每 *N* 次世界存档 | *N* 是 [`AutoBan."SaveWorld Cycles"`](#autoban)——默认为 `2`。这是正常的执行路径。 |
| 排队中的玩家断线 | 他们会在离开时被封禁，而不是被放任自由直到下一次波次。 |
| 模块设置了 `InstantBan: true` | 保留给那些几乎不可能产生误报的检测。 |
| 管理员运行了 `ssac.banwave` | 立即清空整个队列。 |

在排队和执行之间，你可以用 `ssac.pendingbans` 查看队列，用
`ssac.clearbanwave` 将其清空。参见
[命令](commands.md#ssacbanwave-ssacclearbanwave-ssacpendingbans)。

### `AutoBan`

```json
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `SaveWorld Cycles` | number | `2` | 每隔这么多次世界存档运行一次封禁波次。以 15 分钟的存档间隔为例，`2` 意味着最多延迟 30 分钟。 |
| `ExecuteCommand` | string | `"banplayer {steamid} "` | 针对每个被封禁玩家运行的控制台命令。`{steamid}` 会被替换为他们的 SteamID64。留空则只依赖内置封禁系统。 |

`ExecuteCommand` 是你将 ssAntiCheat 接入你现有系统的方式。默认设置会把
玩家添加到 ARK 自身的封禁列表；你也可以改为调用另一个插件的封禁命令，
或是一个跨集群的命令。

> 💡 **集群提示。** ARK 的 `banplayer` 是按服务器生效的。如果你运行的是
> 一个集群，要么将 `ExecuteCommand` 指向一个支持集群的封禁命令，要么让
> 所有服务器使用内置封禁系统并共享**同一个 MySQL 数据库**——这样每台
> 服务器都会在登录时强制执行每一个封禁。

## `IntegratedBanSystem`

内置的封禁存储：封禁会被写入你的 MySQL 数据库，并在玩家尝试连接时被
强制执行。

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
}
```

| 字段 | 类型 | 默认值 | 说明 |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | 在 MySQL 中存储并强制执行封禁。当为 `false` 时，只会运行 `AutoBan.ExecuteCommand`。 |
| `UseIPBans` | boolean | `true` | 同时拒绝来自被封禁玩家 IP 地址的连接。见下文。 |
| `UseHWIDBans` | boolean | `false` | 同时拒绝来自被封禁玩家硬件 ID 的连接。需要可选的配套客户端模组来采集硬件 ID——没有它，这个选项不会起任何作用。 |
| `Exclude IPS` | array | `[]` | 永远不会被视为关联的 IP 地址。请将共享/NAT 地址放在这里。 |
| `BanMessage` | string | 见上方 | 玩家看到的消息。 |

封禁记录保存在一张表（`ssAntiCheat_bans`）中，包含 Steam ID、IP、
硬件 ID、原因、封禁日期和到期时间。将多台服务器指向同一个数据库，
封禁就会在它们之间通用。

### 封禁消息 {#ban-message}

`BanMessage` 支持两个占位符：

| 占位符 | 替换为 |
| ----------- | ------------- |
| `{reason}` | 封禁原因。 |
| `{ban_id}` | 数字形式的封禁 ID——管理员使用 `ssac.unban` 时需要的值。 |

```json
"BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nAppeal at: https://yourserver.example/appeal"
```

> ⚠️ **请替换占位符 URL。** 出厂消息指向的是 `store.example.com`。请务必
> 包含 `{ban_id}`——没有它，申诉封禁的玩家将无法提供任何可供查询的凭据，
> 你就得手动搜索数据库。

### IP 关联封禁 {#ip-association-bans}

启用 `UseIPBans` 后，从属于某个生效中封禁的地址连接的玩家会被拒绝，
**并被记录为他们自己的封禁**，因此从那时起，这个小号会按 Steam ID
被封禁。一条告警会发送到 [`AssociationBans`](configuration.md#webhooks)，
其中会指明两个账号。

这项检查刻意设计得比较保守——只有当 IP 确实匹配、不在 `Exclude IPS`
中，并且属于一个*不同*的 Steam 账号时，它才会触发。

> ⚠️ **IP 封禁会误伤同一住所和共享连接。** 兄弟姐妹、室友、网吧，或是
> 共享的 VPN 出口，看起来都会像是同一个玩家。在你信任这项功能之前，
> 请先观察关联频道一段时间，并将合法的共享地址添加到 `Exclude IPS` 中。

## 封禁时长

| 封禁的产生方式 | 时长 |
| -------------------- | -------- |
| 带 `d=…` 的 `ssac.ban` | 在该时长后到期。 |
| 不带 `d=…` 的 `ssac.ban` | 永久。 |
| 自动（某个模块的 `BanAfterDetections`） | 永久。 |

要解除任何封禁，使用它的封禁 ID：

```bash
ssac.unban 42
```

## 在检测变成封禁之前进行审查

检测和封禁波次之间的间隔就是你的审查窗口。一个行之有效的流程是：

1. Discord 告警（或游戏内管理员告警）会指明玩家和模块。
2. `ssac.go` —— 立即观察他们，不带参数即可跳转到最近一次检测。
3. `!tracers` —— 观察他们的射击；用这种方式，瞄准辅助用肉眼就能一目
   了然。
4. `ssac.pendingbans` —— 查看他们是否已经在排队，以及是为了什么。
5. 做出决定：让波次自然执行、用 `ssac.banwave` 立即处理，或者如果你
   认为这是误报，就用 `ssac.clearbanwave`。

如果某个模块在你的环境中反复产生误报，请提高它的阈值，或为其设置
`OnlyAnalysis`，而不是直接关闭它——参见
[调优建议](configuration.md#common-submodule-keys)。

---

**后续步骤：**

- [配置](configuration.md) —— `config.json` 中的每一个键。
- [命令](commands.md) —— 完整的命令参考。
