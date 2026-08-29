# 🛡️ ssAntiCheat

ssAntiCheat is a **server-side anti-cheat** for ARK: Survival Evolved. It runs
entirely inside your server as an ArkApi plugin — players install nothing, and
there is no client to bypass. Detections are alerted to your Discord and to
in-game admins, and offenders are queued into a **ban wave** so cheaters don't
learn which check caught them.

Alongside detection, ssAntiCheat also **blocks** a large number of known exploits
outright, and ships fixes for several long-standing server issues — including
**crash exploits** and **item duplication**.

## Features

- **Detection modules.** Dozens of individually toggleable detectors, grouped
  into four categories: **Combat**, **Misc**, **Mod**, and **Exploits**. A few
  examples: aimbot and silent-aim detection, auto-flak, auto-medbrew, no-overheat,
  auto-loot and auto-craft. Each one can be enabled, disabled, and tuned on its
  own.
- **Exploit blocking, not just reporting.** Most exploit modules can *prevent*
  the action as well as flag it, so the exploit fails instead of merely being
  logged after the fact.
- **Crash & duplication protection.** Known server-crash vectors are blocked, and
  the duplication fixes stop the common item-dupe routes (transfer dupes, bag/
  transmitter tricks, and more).
- **Glitch & lag fixes.** A separate `Fixes` section covers well-known server
  glitches (scout glitch, handcuff glitch, "player already connected", the pull
  glitch, lag protection, and the dupe fix).
- **Integrated ban system.** Bans are persisted to MySQL and enforced at login,
  with optional **IP association** and **HWID** bans. Ban waves are batched so
  several cheaters are removed at once. See [Bans & Detections](bans.md).
- **Discord alerting.** Detections, bans, join logs, IP-association bans, and
  admin action logs each go to a webhook you configure — or all to one.
- **Admin tooling.** Spectate a flagged player in one command, toggle player and
  structure ESP for yourself, and a set of chat commands for handling suspects
  in-game. Every admin action is logged.
- **Connection gate.** Optional Steam Web API checks on join: minimum playtime,
  minimum account age, and recent VAC bans — each can log only, or block.
- **Dashboard (optional).** Opt-in telemetry to the ssAnticheat dashboard for a
  live detection feed, server health, and an optional live player map. Off by
  default.

## How a detection becomes a ban

```
detector fires
   └─> detection recorded  ──> in-game admin alert
                            ──> Discord webhook
                            ──> dashboard (if enabled)
   └─> module's ban threshold reached?
          └─> player queued for the next ban wave
                 └─> ban wave runs: on a save cycle, when the player
                     disconnects, on an instant-ban module, or manually
```

Thresholds, blocking, and instant-ban behaviour are per module. The full flow —
and every knob that changes it — is on the [Bans & Detections](bans.md) page.

## Requirements

| Requirement | Notes |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** or newer | The plugin will not load on older API versions. |
| MySQL / MariaDB | Required. Bans are persisted there. See [Common Configuration](../index.md#database). |
| A Bytemart license key | Nothing activates until the key authenticates. |
| Outbound HTTPS | Needed for licensing, Discord webhooks, and (if used) the Steam Web API and dashboard. |

## Installation

1. Make sure you have ArkApi **3.51+** installed on your server.
2. Set up a MySQL/MariaDB database — see
   [Common Configuration](../index.md#database). The database must
   already exist; the plugin creates its own tables inside it.
3. Download `ssAntiCheat.zip` from your **Bytemart Dashboard**.
4. Stop the server (run `saveworld` first), or unload any previous version with
   `plugins.unload ssAntiCheat`.
5. Extract the archive into an `ssAntiCheat` folder inside
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Open `config.json` and fill in your `LicenseKey` and `Database` credentials
   (see [Configuration](configuration.md)).
7. Start the server and confirm there are no errors during startup.
8. Run `ssac.status` from the console or RCON to confirm the license
   authenticated.

> ⚠️ **Set your webhooks before you go live.** Every webhook field ships empty.
> Until you fill in at least `DefaultWebhookUrl`, detections are only visible to
> in-game admins and in the server log.

### Updating

- **Manual:** `plugins.unload ssAntiCheat`, replace the files, then
  `plugins.load ssAntiCheat`.
- **Automatic (hot-reload):** rename the new `ssAntiCheat.dll` to
  `ssAntiCheat.dll.arkapi` and drop it into the plugin folder — ArkApi loads the
  new version and unloads the old one automatically.

Always check the changelog for config changes when updating. ssAntiCheat
auto-repairs its own config (missing keys are added with their defaults and the
original is backed up to `config.json.bak`), but a tool like
[Diffchecker](https://www.diffchecker.com/) still helps you spot new keys worth
tuning.

## Troubleshooting

- **Plugin doesn't load, error code `1114`** — a JSON syntax error in
  `config.json`. Run it through [JSONLint](https://jsonlint.com/).
- **"License key is missing"** — `LicenseKey` is still the placeholder value.
- **Nothing reaches Discord** — check that `Use Discord` is `true` and that the
  relevant webhook URL is filled in. Webhooks are per-purpose; see
  [Configuration](configuration.md#webhooks).
- **Anything else** — set `LogToFile` to `true` and reproduce; the plugin writes
  its own rotating `ssAntiCheat.log` next to `config.json`, so you don't have to
  dig through the shared server log. Then ask in the
  [Bytemart Discord](https://bytemart.net/discord).

---

**Next steps:**

- [Configuration](configuration.md) — every key in `config.json`.
- [Commands](commands.md) — console/RCON commands and in-game admin chat commands.
- [Bans & Detections](bans.md) — thresholds, ban waves, IP/HWID bans, and unbanning.
- [Common Configuration](../index.md) — the shared `LicenseKey`,
  `Database`, `LogToFile`, and `Verbose` keys.
