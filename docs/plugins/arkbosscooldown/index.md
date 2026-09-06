# ⏳ ArkBossCooldown

ArkBossCooldown puts a **server-wide cooldown between boss starts**. Boss arenas
are entered by crafting a tribute item, and nothing stops a group from crafting
several in a row — the teleports stack up and players arrive in the arena dead.
This plugin makes the server refuse a boss start until the cooldown from the last
one has expired.

It is deliberately small: one cooldown, one message, one list of tribute items.

## What it does

- **One cooldown for the whole server.** The first boss tribute craft arms it;
  every other tribute craft is refused until it expires. It is *not* per player
  or per tribe — if one group starts a boss, everyone waits.
- **The refused craft costs nothing.** The tribute item is not consumed and no
  teleport happens, so a player who hits the cooldown can simply try again once
  it has passed.
- **Tells the player why.** A configurable chat, notification, or broadcast
  message shows the remaining time. It can also be turned off to refuse silently.
- **Works on any map, and with mods.** The tribute items that arm the cooldown
  are just a list of blueprint paths in the config, so you can add modded arenas
  or remove bosses you don't want gated.
- **Nothing else.** Items other than the ones you list craft completely normally.

> ℹ️ **This is a debounce, not a boss lockout.** `BossStartCooldown` defaults to
> **5 seconds** — long enough to swallow a burst of spam clicks, short enough
> that nobody notices it. If you want a real "one boss per hour" limit, set it to
> a much larger number and read the note on
> [restarts and reloads](configuration.md#bossstartcooldown) first.

## Requirements

| Requirement | Notes |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** or newer | The plugin will not load on older API versions. |
| MySQL / MariaDB | The plugin connects on startup, so valid credentials are required — but ArkBossCooldown itself stores nothing there. See [Common Configuration](../index.md#database). |
| A Bytemart license key | Nothing activates until the key authenticates. |
| Outbound HTTPS | Needed for licensing. |

## Installation

1. Make sure you have ArkApi **3.51+** installed on your server.
2. Set up a MySQL/MariaDB database — see
   [Common Configuration](../index.md#database). The database must
   already exist.
3. Download `ArkBossCooldown.zip` from your **Bytemart Dashboard**.
4. Stop the server (run `saveworld` first), or unload any previous version with
   `plugins.unload ArkBossCooldown`.
5. Extract the archive into an `ArkBossCooldown` folder inside
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Open `config.json` and fill in your `LicenseKey` and `Database` credentials.
   The defaults for everything else are usable as they ship — see
   [Configuration](configuration.md).
7. Start the server and confirm there are no errors during startup.
8. Craft a boss tribute twice in a row to check that the second attempt is
   refused and the message appears.

> 💡 **Playing on a map or mod that isn't in the default list?** Turn on
> [`TestMode`](configuration.md#testmode), craft the tribute once, and copy the
> blueprint path the console prints into `Bosses`. Then turn `TestMode` back off.

### Updating

- **Manual:** `plugins.unload ArkBossCooldown`, replace the files, then
  `plugins.load ArkBossCooldown`.
- **Automatic (hot-reload):** rename the new `ArkBossCooldown.dll` to
  `ArkBossCooldown.dll.arkapi` and drop it into the plugin folder — ArkApi loads
  the new version and unloads the old one automatically.

ArkBossCooldown repairs its own config on load: missing keys are added with their
defaults and your original is backed up to `config.json.bak` first. A type
mismatch (a string where a number belongs) aborts the load instead, with an error
naming the key.

## Commands

Console and RCON access is admin access by definition, so these need no extra
permission.

| Command | Channels | Description |
| ------- | -------- | ----------- |
| `ArkBossCooldown.help [page]` | Console, RCON | Paginated list of every registered command. |
| `ArkBossCooldown.reload` | Console, RCON | Re-read `config.json` without restarting the server. |

`ArkBossCooldown.reload` rebuilds the boss list, the cooldown length, `TestMode`,
and the message settings from disk. It does **not** clear a cooldown that is
already running — reloading is not a free boss start. To clear one, unload and
reload the plugin. It also does not re-run the config repair pass, so validate
your JSON before reloading.

## Troubleshooting

- **The cooldown never triggers** — the tribute you're crafting probably isn't in
  the `Bosses` list. Turn on `TestMode`, craft it, and read the path from the
  console.
- **Plugin doesn't load, error code `1114`** — a JSON syntax error in
  `config.json`. Run it through [JSONLint](https://jsonlint.com/). The long
  `Bosses` array makes a stray comma easy to miss.
- **"License key is missing"** — `LicenseKey` is still the placeholder value.
- **The message doesn't appear** — check `CooldownMessage.Enabled` is `true`, and
  note that `Scale` only applies to the `Notification` channel.
- **Anything else** — set `LogToFile` to `true` and reproduce; the plugin writes
  its own rotating `ArkBossCooldown.log` next to `config.json`. Then ask in the
  [Bytemart Discord](https://bytemart.net/discord).

---

**Next steps:**

- [Configuration](configuration.md) — the cooldown, the message, and the boss list.
- [Common Configuration](../index.md#common-configuration) — the shared `LicenseKey`,
  `Database`, `LogToFile`, and `Verbose` keys.
