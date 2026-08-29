# 🔍 DupeDetector

DupeDetector is a small, focused ArkApi plugin that catches **item duplication
carried out through the tribute inventory** — the obelisk, supply drop terminal,
and transmitter upload store used for cluster transfers.

It does one thing and does it quietly: duplication attempts are reported to your
Discord, and repeat offenders can be dealt with automatically.

## What it does

- **Detects duplication** through the tribute/upload store, with no client mod
  and nothing for your players to install.
- **Alerts your Discord.** Every detection is posted to the webhook you
  configure.
- **Punishes repeat offenders.** Once a player has been detected enough times,
  DupeDetector can run a server command against them (kick, ban, whatever you
  choose) and optionally clear their inventory. Punishments go to their own
  webhook so you can route them to an admin-only channel.
- **Report-only if you want it.** Leave the punishment options empty and the
  plugin only ever tells you — it never acts on its own.

How much rope a player gets before a punishment fires is configurable, and
deliberately not a fixed number. See
[`Punishment.After`](configuration.md#punishment).

> ℹ️ **Detection details are intentionally not published.** What triggers a
> detection, and how many detections a given player is allowed, are not
> documented here — that information only helps the people you are trying to
> catch. If you need to understand a specific alert, ask in the
> [Bytemart Discord](https://bytemart.net/discord).

## Requirements

| Requirement | Notes |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** or newer | The plugin will not load on older API versions. |
| MySQL / MariaDB | The plugin connects on startup, so valid credentials are required. See [Common Configuration](../common-configuration.md#database). |
| A Bytemart license key | Nothing activates until the key authenticates. |
| Outbound HTTPS | Needed for licensing and for Discord webhooks. |

## Installation

1. Make sure you have ArkApi **3.51+** installed on your server.
2. Set up a MySQL/MariaDB database — see
   [Common Configuration](../common-configuration.md#database). The database must
   already exist.
3. Download `DupeDetector.zip` from your **Bytemart Dashboard**.
4. Stop the server (run `saveworld` first), or unload any previous version with
   `plugins.unload DupeDetector`.
5. Extract the archive into a `DupeDetector` folder inside
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Open `config.json` and fill in your `LicenseKey`, `Database` credentials, and
   at least `DupeDetection.AlertWebhook` — see [Configuration](configuration.md).
7. Start the server and confirm there are no errors during startup.

> ⚠️ **Set `AlertWebhook` before you go live.** It ships empty, and an empty
> webhook means detections are recorded but never posted anywhere.

### Updating

- **Manual:** `plugins.unload DupeDetector`, replace the files, then
  `plugins.load DupeDetector`.
- **Automatic (hot-reload):** rename the new `DupeDetector.dll` to
  `DupeDetector.dll.arkapi` and drop it into the plugin folder — ArkApi loads the
  new version and unloads the old one automatically.

DupeDetector repairs its own config on load: missing keys are added with their
defaults and your original is backed up to `config.json.bak` first. A type
mismatch (a string where a number belongs) aborts the load instead, with an error
naming the key.

## Commands

Console and RCON access is admin access by definition, so these need no extra
permission.

| Command | Channels | Description |
| ------- | -------- | ----------- |
| `DupeDetector.help [page]` | Console, RCON | Paginated list of every registered command. |
| `DupeDetector.reload` | Console, RCON | Re-read `config.json` without restarting the server. |

`DupeDetector.reload` swaps the live config in place, so webhook and punishment
changes take effect immediately. It does **not** re-run the config repair pass,
so validate your JSON before reloading.

## Troubleshooting

- **Plugin doesn't load, error code `1114`** — a JSON syntax error in
  `config.json`. Run it through [JSONLint](https://jsonlint.com/).
- **"License key is missing"** — `LicenseKey` is still the placeholder value.
- **Nothing reaches Discord** — the URL must be a real Discord webhook endpoint
  (`https://discord.com/api/webhooks/...`; the `discordapp.com`, `ptb.` and
  `canary.` forms are accepted too). Anything else is dropped with a line in the
  log.
- **Anything else** — set `LogToFile` to `true` and reproduce; the plugin writes
  its own rotating `DupeDetector.log` next to `config.json`. Then ask in the
  [Bytemart Discord](https://bytemart.net/discord).

---

**Next steps:**

- [Configuration](configuration.md) — the `DupeDetection` block.
- [Common Configuration](../common-configuration.md) — the shared `LicenseKey`,
  `Database`, `LogToFile`, and `Verbose` keys.
