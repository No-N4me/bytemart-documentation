# 🏆 Tribescore

Tribescore 是一套面向 ARK: Survival Evolved 的竞技性**部落计分系统**。
部落通过在 PvP 中摧毁敌方建筑、恐龙和玩家来赚取 *tribescore（部落分数）*。
分数会持久化保存在 MySQL 中，并通过排行榜和排名系统呈现，同时每当获得或失去
分数时，都会在世界内弹出漂浮的“全息投影”数字。

分数的授予会经过一条可配置的、乘法式的修正管线，让你能够保持竞争的公平：
离线保护、强弱部落之间的分差平衡、基于权限的增益，以及管理员授予的限时增益。

## 功能

- **PvP 计分：** 为摧毁敌方建筑、击杀已驯服恐龙以及击杀敌方玩家授予分数。
  每一种来源都可以单独配置，也可以关闭。
- **按等级和按蓝图计值：** 建筑按建造等级（茅草 → Tek）计分，并支持按蓝图
  覆盖；恐龙按物种计分，并带有细粒度的标志（幼体、无鞍、野生……）。
- **修正管线：** 通过离线保护、强对弱的分差比率、权限修正以及限时增益来
  平衡游戏。
- **排行榜与排名：** 提供游戏内的 `/leaderboard` 和 `/triberank` 聊天命令，
  由持久化的 MySQL 排行榜支撑。
- **世界内全息投影：** 可配置的漂浮 `+points` / `-points` 文本，玩家可以为
  自己开启或关闭。
- **管理工具：** 给予/扣除分数、授予限时增益、审计某部落的交易历史，以及
  估算一处基地的价值——全部可从控制台/RCON 操作。

## 计分原理

当敌方的建筑、恐龙或玩家被摧毁时，基础分值来自计分表
（`structures.json`、`dinos.json`，或 `config.json` 中的固定玩家分值）。
该基础值随后会经过修正管线进行乘算：

```
final score = base points
            × OfflineProtection(defender)
            × ScoreDifferenceRatio(attacker, defender)
            × PermissionModifier(attacker)
            × TimedBoost(attacker, type)
```

进攻方部落**获得**计算结果；防守方部落**失去**一个（可单独配置的）数量。
参见[配置](configuration.md)页面了解每一个可调项。

## 安装

1. 确保你的服务器上安装了受支持版本的 [ArkApi](https://arkserverapi.com/)
   （Tribescore 需要 ArkApi **3.51** 或更新版本）。
2. 设置一个 MySQL/MariaDB 数据库——参见[通用配置](../common-configuration.md#database)。
3. 从你的 **Bytemart 控制台**下载 `Tribescore.zip`。
4. 停止服务器（先运行 `saveworld`），或使用
   `plugins.unload Tribescore` 卸载任何以前的版本。
5. 将压缩包解压到
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/` 内的一个 `Tribescore` 文件夹中。
6. 打开 `config.json` 并填入你的 `LicenseKey` 和 `Database` 凭据
   （参见[配置](configuration.md)）。
7. 启动服务器，并确认启动过程中没有任何错误。

### 更新

- **手动方式：** `plugins.unload Tribescore`，替换文件，然后
  `plugins.load Tribescore`。
- **自动方式（热重载）：** 将新的 `Tribescore.dll` 重命名为
  `Tribescore.dll.arkapi` 并放入插件文件夹——ArkApi 会自动加载新版本并卸载
  旧版本。

更新时，请务必查看更新日志以了解配置变更；诸如
[Diffchecker](https://www.diffchecker.com/) 之类的工具有助于发现新增或
重命名的键。

---

**后续步骤：**

- [配置](configuration.md) —— 完整的 `config.json`，以及 `structures.json` 和 `dinos.json`。
- [命令](commands.md) —— 控制台/RCON 管理命令和游戏内聊天命令。
- [通用配置](../common-configuration.md) —— 共享的 `LicenseKey`、`Database`、`LogToFile` 和 `Verbose` 键。
