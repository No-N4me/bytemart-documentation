# Configuration

DupeDetector is configured through a single `config.json` in the plugin folder:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/DupeDetector/config.json
```

A second file, `config_commented.json`, ships alongside it. It is the **same
config with `//` comments** — read it, but don't rename it over `config.json`
(comments are not valid JSON).

The keys `LicenseKey`, `Verbose`, `LogToFile`, and `Database` are shared by every
Bytemart plugin and are documented on the
**[Common Configuration](../common-configuration.md)** page. This page covers only
the `DupeDetection` block, which is unique to DupeDetector.

> 💡 **Validate before you start.** Always validate your JSON after editing (e.g.
> with [JSONLint](https://jsonlint.com/)). A load error code of `1114` means a
> JSON syntax error.

## `DupeDetection`

```json
"DupeDetection": {
  "AlertWebhook": "",
  "Punishment": {
    "PunishmentWebhook": "",
    "Command": "",
    "ClearInventory": false,
    "After": {
      "Min": 1,
      "Max": 1
    }
  }
}
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `AlertWebhook` | string | `""` | Discord webhook for **detections** — one message per detection, naming the player involved. Empty means detections are still counted, but nothing is posted. |

### `Punishment`

What happens once a player has accumulated enough detections. Every field is
optional: leave `Command` empty and `ClearInventory` false and DupeDetector
becomes report-only.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `PunishmentWebhook` | string | `""` | Discord webhook for **punishments**. Kept separate from `AlertWebhook` so you can route the (much rarer) punishments to an admin-only channel. Empty means nothing is posted. |
| `Command` | string | `""` | A server console command to run against the offender when the threshold is reached — for example `banplayer {steamid}` or `kickplayer {steamid}`. Empty means no command is run. |
| `ClearInventory` | boolean | `false` | Wipe the offender's inventory as part of the punishment. |
| `After.Min` | number | `1` | Lower bound of the detection threshold. |
| `After.Max` | number | `1` | Upper bound of the detection threshold. |

#### The `After` threshold

`Min` and `Max` bound how many detections a player may accumulate before the
punishment fires. Giving them **different** values leaves the exact threshold
unpredictable, which is the recommended setting — a fixed, known number is
something an offender can work around.

- `"Min": 1, "Max": 1` — punish on the first detection (the default).
- `"Min": 2, "Max": 5` — punish somewhere in that range.

Values are range-checked on load, so you cannot accidentally configure a
threshold that never fires.

> 💡 **Start report-only.** Leave `Command` empty and `ClearInventory` false for
> the first few days, watch what lands in `AlertWebhook`, and only then decide
> what a punishment should be.

## Webhooks

Both webhook fields must be **Discord webhook URLs**. These prefixes are
accepted:

```
https://discord.com/api/webhooks/...
https://discordapp.com/api/webhooks/...
https://ptb.discord.com/api/webhooks/...
https://canary.discord.com/api/webhooks/...
```

Anything else — including an empty string — is dropped, with a line in the plugin
log saying so. An empty webhook is never an error; it just means "send nothing".

> 🔒 **A webhook URL is a credential.** Anyone who has it can post to your
> channel. Keep `config.json` out of public repositories and screenshots.

## Full example

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  },
  "DupeDetection": {
    "AlertWebhook": "https://discord.com/api/webhooks/...",
    "Punishment": {
      "PunishmentWebhook": "https://discord.com/api/webhooks/...",
      "Command": "banplayer {steamid}",
      "ClearInventory": true,
      "After": {
        "Min": 2,
        "Max": 4
      }
    }
  }
}
```

---

**Next steps:**

- [Overview](index.md) — what the plugin covers, installation, and commands.
- [Common Configuration](../common-configuration.md) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
