# 插件

Bytemart 插件为你的 ARK 服务器扩展新功能。每个插件都以一个可从
**Bytemart 控制台**下载的 `.zip` 形式发布，你只需将其放入服务器的
插件文件夹即可。

## 共享配置

每个 Bytemart 插件都会读取一个顶层的 `config.json`，其中包含一小组共享的
键——你的许可证密钥、日志开关以及 MySQL 数据库凭据。这些内容只在一个
统一的地方进行说明：

- **[通用配置](common-configuration.md)** —— `LicenseKey`、`Verbose`、
  `LogToFile` 和 `Database`，这些对**所有**插件都通用。

每个插件自己的配置页面只涵盖该插件独有的键，并链接回上面的页面以说明
共享的键。

## 可用插件

| 插件 | 说明 |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | 一套竞技性的部落计分系统：部落通过在 PvP 中摧毁敌方建筑、恐龙和玩家来赚取分数，并通过排行榜和世界内全息投影呈现。 |
| [ssAntiCheat](ssanticheat/index.md) | 服务端反作弊：涵盖战斗作弊与漏洞利用的检测模块、带封禁波次的内置封禁系统、Discord 告警，以及针对已知崩溃与复制漏洞的修复。 |
