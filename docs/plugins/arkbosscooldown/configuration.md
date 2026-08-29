# Configuration

ArkBossCooldown is configured through a single `config.json` in the plugin folder:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ArkBossCooldown/config.json
```

A second file, `config_commented.json`, ships alongside it. It is the **same
config with `//` comments** — read it, but don't rename it over `config.json`
(comments are not valid JSON).

The keys `LicenseKey`, `Verbose`, `LogToFile`, and `Database` are shared by every
Bytemart plugin and are documented on the
**[Common Configuration](../index.md)** page. This page covers the
keys unique to ArkBossCooldown.

> 💡 **Validate before you start.** Always validate your JSON after editing (e.g.
> with [JSONLint](https://jsonlint.com/)). A load error code of `1114` means a
> JSON syntax error — easy to cause in the long `Bosses` array.

## `TestMode`

```json
"TestMode": false
```

When `true`, the plugin logs the **blueprint path of every item any player
crafts** to the server console. This is how you find the exact path of a tribute
item to put in [`Bosses`](#bosses):

1. Set `TestMode` to `true` and reload (`ArkBossCooldown.reload`).
2. Craft the tribute you want to gate.
3. Copy the path from the console line — it looks like
   `[TestMode] Crafted item blueprint: Blueprint'/Game/...'`.
4. Paste it into `Bosses`, set `TestMode` back to `false`, and reload again.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `TestMode` | boolean | `false` | Log every crafted item's blueprint path. |

> ⚠️ **Turn it off again.** With `TestMode` on, a busy server writes a console
> line for *every craft by every player*. It is a lookup tool, not a setting to
> leave enabled.

## `BossStartCooldown`

```json
"BossStartCooldown": 5
```

How many **seconds** the whole server must wait between two boss starts. The
first tribute craft arms the cooldown; every other tribute craft is refused until
it expires.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `BossStartCooldown` | number | `5` | Seconds between boss starts, server-wide. |

The default of `5` is a **debounce** — it absorbs a burst of spam clicks and is
invisible in normal play. Larger values turn the plugin into a real rate limit,
which works, but be aware of two things:

- **It is server-wide.** A 30-minute cooldown means one tribe starting a boss
  blocks every other tribe for 30 minutes. That is a design decision for your
  server, not a bug.
- **It does not survive a restart.** The armed cooldown lives in memory, so a
  server restart (or a plugin unload/load) clears it. Fine for a few seconds;
  worth knowing if you set it to hours.

`ArkBossCooldown.reload` picks up a new value immediately, but deliberately
leaves an already-armed cooldown running.

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

What the player who was refused sees. Only that player is notified — nothing is
broadcast to the rest of the server.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Set to `false` to refuse the boss start silently. |
| `Channel` | string | `"Notification"` | `"Chat"`, `"Notification"`, or `"Broadcast"`. An unrecognised value falls back to `"Chat"`. |
| `Message` | string | see above | The text. Supports the placeholders below. |
| `Color` | object | red | `R`, `G`, `B`, `A`, each `0`–`255`. `A` is opacity. |
| `Scale` | number | `1.0` | Text size. **`Notification` channel only** — ignored on the others. |
| `Time` | number | `5.0` | Seconds the message stays on screen. **`Notification` and `Broadcast` only** — a chat line stays in the chat log regardless. |

### Placeholders

| Placeholder | Expands to | Example |
| ----------- | ---------- | ------- |
| `%delay%` | The remaining time, spelled out | `1 Minute, 5 Seconds` |
| `%seconds%` | The remaining time as a plain number of seconds | `65` |

Use `%delay%` for a message players read, and `%seconds%` when you want something
compact:

```json
"Message": "Boss on cooldown - %seconds%s remaining."
```

> 💡 **`Notification` also accepts an `Icon`.** Add an `"Icon"` key with a
> texture path to show an image alongside the notification. It is not in the
> shipped config; add it yourself if you want one — the config repair only ever
> *adds* missing keys, so it will survive updates.

## `Bosses`

```json
"Bosses": [
  "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'",
  "Blueprint'/Game/Fjordur/Boss/Arena/PrimalItem_BossTribute_FenrirBoss_Hard.PrimalItem_BossTribute_FenrirBoss_Hard'"
]
```

The blueprint paths of every tribute item that arms the cooldown. **Anything not
in this list crafts completely normally** — the plugin ignores it.

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Bosses` | array of strings | Full blueprint paths, including the `Blueprint'...'` wrapper and the duplicated asset name after the final `.`. Matched exactly. |

The shipped list covers the tribute items for **The Island**, **The Center**,
**Scorched Earth**, **Ragnarok**, **Aberration**, **Valguero**, **Fjordur**,
**Lost Island**, and **Crystal Isles**, at every difficulty.

To gate anything else — another map, a modded arena, or a custom tribute — use
[`TestMode`](#testmode) to capture the path and add it here. To *stop* gating a
boss, delete its line.

> ⚠️ **Copy paths exactly.** The match is byte-for-byte on the full path. A
> missing trailing `'`, a shortened path, or the asset name typed once instead of
> twice all mean "no match", and the tribute will craft with no cooldown at all.
> There is no error for an unrecognised path, so check your change with a real
> craft.

## Full example

A 15-minute limit announced in chat:

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

> ℹ️ **`Database` is required but unused.** ArkBossCooldown connects on startup
> like every Bytemart plugin, but stores nothing of its own. Point it at any
> database the server can reach.

---

**Next steps:**

- [Overview](index.md) — what the plugin does, installation, and commands.
- [Common Configuration](../index.md) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
