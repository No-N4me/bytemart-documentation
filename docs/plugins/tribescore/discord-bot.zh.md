# 🤖 Discord 机器人

Tribescore 附带一个配套的 **Discord 机器人**，它把你服务器上的竞争带入
Discord —— 一个实时、自动刷新的排行榜，用于查询任意部落的斜杠命令，以及一套
自动的滥用检测系统，用于标记可疑的计分行为。

该机器人**直接连接插件所使用的同一个 MySQL/MariaDB 数据库**。它只会*读取*
插件的分数表——绝不会改动你的分数——因此可以安全地与运行中的服务器并行运行。

## 功能

- **实时排行榜** —— 在你选择的频道中发布并自动刷新排名靠前的部落，并在计分
  周期之间显示 ▲/▼ 升降箭头。
- **图片或嵌入式渲染** —— 可将排行榜显示为经典的 Discord 嵌入消息，或显示为
  由七套内置设计之一渲染出的精美 PNG（`podium`、`spotlight`、`cards`、`bars`、
  `terminal`、`ark`、`dark`）。这些模板是纯 HTML，你可以为自己的服务器重新
  定制样式和品牌。
- **斜杠命令** —— `/tribepoints` 和 `/getrank` 让玩家可以查询任意部落的分数和
  排名。命令名称和消息均可配置。
- **滥用检测** —— 三个相互独立的检测器会在计分看起来可疑时发布警报，每条警报
  都带有一个*“忽略此警报”*按钮，用于消除误报。
- **独立可执行文件** —— 以单个自包含的 Windows `.exe` 形式分发。即使是图片
  渲染，也无需浏览器和任何额外安装。

## 要求

- 已安装 Tribescore 插件并正在向 MySQL/MariaDB 数据库写入数据（参见
  [配置](configuration.md)和
  [通用配置](../common-configuration.md#database)）。
- 一个在
  [Discord 开发者门户](https://discord.com/developers/applications)上创建的
  Discord 应用和机器人令牌。
- 一台用于运行机器人的 Windows 机器——只要能访问数据库，它可以运行在任何地方。

## 安装

1. 从你的 **Bytemart 控制台**下载机器人并解压。
2. 打开 `config.yml` 并进行配置（见下文）。
3. 设置你的机器人令牌和数据库密码——可以直接在 `config.yml` 中设置，也可以
   通过 `LEADERBOARD_BOT_TOKEN` 和 `MYSQL_PASSWORD` 环境变量设置
   （推荐，这样密钥就不会出现在配置文件中）。
4. 将机器人邀请到你的服务器，并授予它在排行榜频道和警报频道中发送消息、嵌入
   消息和附件的权限。
5. 运行可执行文件。首次启动时，它会注册自己的斜杠命令并发布排行榜。

> 💡 如果你在 `config.yml` 中重命名了某个斜杠命令，Discord 可能需要先将机器人
> 踢出再重新邀请，更改才会生效。

## 配置（`config.yml`）

机器人完全通过 `config.yml` 进行配置。关键设置：

| 设置 | 说明 |
| ------- | ----------- |
| `bot-token` | 你的 Discord 机器人令牌。留空并改为设置 `LEADERBOARD_BOT_TOKEN`。 |
| `period-start` | 用于设定新计分周期何时开始的 Cron 表达式（届时排行榜会对升降进行快照）。参见 [crontab.guru](https://crontab.guru/)。 |
| `timezone` | 用于调度和交易比较的时区——必须与你数据库的时区一致。 |
| `refresh-cooldown` | 周期内排行榜刷新之间的间隔秒数。 |
| `leaderboard-channel` | 发布排行榜的频道 ID。 |
| `keep-leaderboard-history` | 为 `true` 时，每个周期都会发布一条全新的排行榜消息，而不是编辑现有的那条。 |
| `leaderboard-render-mode` | `embed`（Discord 嵌入消息）或 `image`（渲染的 PNG）。 |
| `leaderboard-image` | 图片模式选项：`template`、`title`、`lines`、`width`、`scale`。 |
| `mysql` | 数据库连接：`host`、`port`、`user`、`password`、`database`、`leaderboard-table`、`transactions-table`、`timezone`。 |
| `commands` | 命令名称、描述和回复消息。 |
| `abuse-detection` | 启用并调校滥用检测模块。 |

> ⚠️ `leaderboard-table` 和 `transactions-table` 必须与插件的表相匹配——默认为
> `ts_leaderboard` 和 `ts_transactions`。机器人会读取这些表，绝不会向其写入。

### 排行榜显示

通过 `leaderboard-render-mode` 选择排行榜的渲染方式：

```yaml
leaderboard-render-mode: "image"   # 或 "embed"
leaderboard-image:
  template: "spotlight"   # podium | spotlight | cards | bars | terminal | ark | dark
  title: "Tribes Leaderboard"
  lines: 15               # 显示的部落数量
  width: 820
  scale: 2                # 2 = 清晰 / 视网膜级输出
```

在 `embed` 模式下，排行榜是由 `leaderboard_embed.json` 构建的文本嵌入消息。在
`image` 模式下，它由 `templates/leaderboard/<name>/` 下的 HTML 模板渲染而成。
如果图片渲染发生失败，机器人会自动回退到嵌入消息，因此排行榜永远不会离线。

### 斜杠命令

| 命令（默认） | 说明 |
| ----------------- | ----------- |
| `/tribepoints <tribe>` | 显示某部落的当前分数。 |
| `/getrank <tribe>` | 显示某部落的排名和分数。 |

命令名称及其回复消息均可在 `config.yml` 的 `commands` 下配置，可使用
`{tribe}`、`{points}` 和 `{rank}` 占位符。

### 滥用检测

当 `abuse-detection.enabled` 为 `true` 时，机器人会定期扫描排名靠前的部落，并
在某个模块被触发时向配置的 `channel-id` 发布警报。每条警报都带有一个
**“忽略此警报”**按钮，可抑制该部落组合日后重复出现的警报。

| 模块 | 检测内容 |
| ------ | ------- |
| `rapid-increase` | 某部落在一个计分周期内获得了异常大量的分数。 |
| `massive-transaction` | 从一个部落向另一个部落一次性转移了超过阈值的分数。 |
| `prefered-source` | 某部落的大部分分数都来自单一的来源部落（并可选进行互惠“镜像”检查）。 |

每个模块都有各自的 `cooldown`、阈值以及警报 `title` / `message`——可用的占位符
在 `config.yml` 中已随附文档说明。

> ℹ️ 机器人会创建一个属于它自己的表 `ts_ignored_alerts`，用于记住你已忽略了
> 哪些警报。这是它唯一会写入的表；你的分数数据绝不会被修改。
