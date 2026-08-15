# Configuration

ssAntiCheat is configured through a single `config.json` in the plugin folder:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ssAntiCheat/config.json
```

A second file, `config_commented.json`, ships alongside it. It is the **same
config with `//` comments** — read it, but don't rename it over `config.json`
(comments are not valid JSON).

The keys `LicenseKey`, `Verbose`, `LogToFile`, and `Database` are shared by every
Bytemart plugin and are documented on the
**[Common Configuration](../common-configuration.md)** page. This page covers only
the keys unique to ssAntiCheat.

> 💡 **Validate before you start.** Always validate your JSON after editing (e.g.
> with [JSONLint](https://jsonlint.com/)). A load error code of `1114` means a
> JSON syntax error.

> ⚠️ **Key names are load-bearing — copy them exactly.** Several keys contain
> spaces (`"Join Tracker"`, `"SaveWorld Cycles"`, `"Block Dedi Fill"`) and a few
> carry a historical misspelling (`Threshole`, `additionnalData`). They are
> matched byte-for-byte. "Fixing" a spelling silently disables the feature.

## Self-repairing config

On every load, ssAntiCheat compares your `config.json` against the schema it was
built with:

- **Missing keys** are added with their default values, and the console prints
  exactly what was added. Your original file is copied to `config.json.bak`
  first.
- **Type mismatches** (a string where a number is expected, and so on) **abort
  the load** with an error naming the key — the plugin will not run on a config
  it cannot trust.

This means an update that introduces new keys will not break your server, and you
can always trim your config down to just the keys you care about.

---

## Top-level keys

```json
"Debug": false,
"Use Discord": true,
"UseDiscordURL": true,
"SteamAPIKey": "",
"CommandPrefix": "!",
"Send Alert to Ingame Admins when someone is detected using a cheat": true
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Debug` | boolean | `false` | Internal debug flag. Leave it `false` — use [`Verbose`](../common-configuration.md#verbose) for troubleshooting output. |
| `Use Discord` | boolean | `true` | Master switch for Discord alerts. When `false`, no detection or ban embeds are posted anywhere. |
| `UseDiscordURL` | boolean | `true` | Whether Discord embeds include the ssAntiCheat icon/thumbnail images. Purely cosmetic. |
| `SteamAPIKey` | string | `""` | A [Steam Web API key](https://steamcommunity.com/dev/apikey). Required only by the connection gate (playtime / account age / VAC checks). Leave empty if you don't use it. |
| `CommandPrefix` | string | `"!"` | The prefix for the in-game admin chat commands. See [Commands](commands.md#chat-commands). |
| `Send Alert to Ingame Admins when someone is detected using a cheat` | boolean | `true` | Broadcast a coloured detection alert to every online admin. |

## Webhooks

```json
"DefaultWebhookUrl": "",
"BanWebhookUrl": "",
"AssociationBans": "",
"AdminTrollingWebhook": ""
```

All four are Discord webhook URLs, and all ship **empty**. An empty webhook means
"send nothing" — it is never an error.

| Field | Description |
| ----- | ----------- |
| `DefaultWebhookUrl` | Where detections go when the module has no webhook of its own. This is the one to fill in first. |
| `BanWebhookUrl` | Where **ban** alerts go. Falls back to `DefaultWebhookUrl` when empty. |
| `AssociationBans` | Where **IP-association** ban alerts go — i.e. a new account caught connecting from a banned player's IP. See [Bans & Detections](bans.md#ip-association-bans). |
| `AdminTrollingWebhook` | Audit log for the in-game admin chat commands: who ran what, on whom, and where. |

Any individual module may also carry its own `WebhookUrl` key, which overrides
`DefaultWebhookUrl` for that module only.

> 🔒 **A webhook URL is a credential.** Anyone who has it can post to your
> channel. Keep `config.json` out of public repositories and screenshots.

## `Dashboard`

```json
"Dashboard": {
  "Enabled": false,
  "LivePositions": false
}
```

Opt-in telemetry to the ssAnticheat dashboard: a live detection and ban feed,
ban history, and basic server health. **Both keys default to `false`** — nothing
leaves your machine until you turn them on.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `false` | Master switch for dashboard telemetry. |
| `LivePositions` | boolean | `false` | Additionally send player positions so the dashboard can draw a live map. This is effectively a live view of where every player is — leave it off unless you want that. |

Use [`ssac.status`](commands.md#ssacstatus) to check whether telemetry is
actually flowing, and [`ssac.testdetection`](commands.md#ssactestdetection) to
push a simulated detection through the pipeline.

## `Join Tracker`

```json
"Join Tracker": {
  "Enabled": true,
  "Include IP": true,
  "JoinLogs": ""
}
```

Posts a Discord embed every time a player joins, with their name, Steam ID, tribe,
and spawn location.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Toggle join logging. |
| `Include IP` | boolean | `true` | Include the connecting IP address in the embed. |
| `JoinLogs` | string | `""` | Webhook URL for join logs. Empty means join logs are collected but not posted. |

> ⚠️ **IP addresses are personal data.** If you enable `Include IP`, send join
> logs to a private, admin-only channel, and check what your local rules require
> of you before you keep them.

## `Admin ESP`

Settings for the in-game admin ESP overlay, toggled per admin with the
[`!esp` family](commands.md#chat-commands) of chat commands.

```json
"Admin ESP": {
  "Enabled": true,
  "RefreshTime": 0.1,
  "Range": 30000,
  "Structure ESP": ["Box"]
}
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Reserved. Access to the ESP commands is gated by ARK admin status, not by this key. |
| `RefreshTime` | number | `0.1` | How long each drawn label/box lives, in seconds. Lower = smoother, more client draw calls. |
| `Range` | number | `30000` | Scan radius (Unreal units) around the admin. |
| `Structure ESP` | array | `["Box"]` | Substrings of structure blueprint names to highlight when structure ESP is on. `"Box"` matches storage boxes; add e.g. `"Vault"` or `"Turret"`. |

## `ServerCrash`

```json
"ServerCrash": {
  "SaveWorld": true,
  "AutomaticRestart": true
}
```

What to do when the server process crashes.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `SaveWorld` | boolean | `true` | Attempt a world save from inside the crash handler, so a crash costs minutes instead of the whole save interval. |
| `AutomaticRestart` | boolean | `true` | Restart the server automatically a short delay after the crash. Turn this **off** if your server manager (ASM, ArkServerManager, a service wrapper, …) already restarts on exit — otherwise you get two restarts racing each other. |

## `Fixes`

Fixes for well-known server glitches and exploit routes. These are not detectors
— nobody gets flagged or banned by them; the broken behaviour is simply
prevented.

```json
"Fixes": {
  "Scout Glitch Fix":         { "Enabled": true },
  "Handcuff Glitch Fix":      { "Enabled": false },
  "Player Already Connected": { "Enabled": true },
  "Pull Fix":                 { "Enabled": true },
  "Lag Protector":            { "Enabled": true },
  "Dupe Fix":                 { "Enabled": true }
}
```

| Fix | Default | What it does |
| --- | ------- | ------------ |
| `Scout Glitch Fix` | `true` | Corrects the Scout's carry behaviour, closing the well-known Scout glitch. |
| `Handcuff Glitch Fix` | `false` | Re-equips handcuffs on a player who logs back in after logging off while cuffed — closing the "log out to escape the cuffs" trick. Off by default; enable it if handcuffs are part of how your admins or players operate. |
| `Player Already Connected` | `true` | Clears the stuck session that produces the "player already connected" error, so players don't have to wait it out. |
| `Pull Fix` | `true` | Blocks the Structures Plus **server pull** exploit, where a pull is used to drag restricted items (boss tributes and similar) out of a container in bulk. The player is told "You can't pull this craft". |
| `Lag Protector` | `true` | Anti-griefing protection against deliberate server-lag tricks. **Needs extra keys — see below.** |
| `Dupe Fix` | `true` | Destroys duplicated S+ death-item caches: a second death cache spawning on top of an existing one is removed instead of doubling its contents. |

Every fix takes an `Enabled` flag. `Lag Protector` takes three more.

### Lag Protector

`Lag Protector` ships with `Enabled` only, and each of its protections is
**opt-in** — add the keys yourself to switch them on:

```json
"Lag Protector": {
  "Enabled": true,
  "WhipProtection": true,
  "BlueprintProtection": true,
  "LagWebhook": ""
}
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `WhipProtection` | boolean | `false` | Kick a player who fires a weapon inside an area packed with enough structures to lag the server — the classic "whip in a mega-base" grief. |
| `BlueprintProtection` | boolean | `false` | Kick a player who queues an implausible burst of blueprint crafts in a few seconds. |
| `LagWebhook` | string | `""` | Webhook for lag-protection kicks. Falls back to sending nothing when empty. |

Kicks from this fix carry a deliberately opaque reason code, so a griefer learns
nothing from it: `0x7E3` is the whip protection, `0x4DE` the blueprint
protection.

> ℹ️ **Keys you add yourself are kept.** The config self-repair only ever *adds*
> missing keys — it never deletes keys it doesn't recognise, so the three above
> survive plugin updates.

## `IntegratedBanSystem` and `AutoBan`

These two sections drive the ban pipeline and are documented in full on the
**[Bans & Detections](bans.md)** page:

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
},
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

> ⚠️ **Change the `BanMessage` URL.** It ships with an `example.com` placeholder.
> Point it at your own store or appeal page.

---

## `Modules`

Every detector lives under `Modules`, in one of four categories:

| Category | What it covers |
| -------- | -------------- |
| `CombatCheats` | Combat-time cheats — aim assistance, fire-rate and ammo manipulation, consumable automation. |
| `MiscCheats` | Client automation and client-side tooling — auto-loot, auto-craft, spoofers, timing anomalies, plus the connection gate. |
| `Mod` | Checks that require the optional companion client mod (including hardware-ID capture and mod-bypass detection). Inert unless that mod is deployed — ask in the [Bytemart Discord](https://bytemart.net/discord) if you want it. |
| `Exploits` | Known game and mod exploits: duplication routes, crash vectors, unlockers, mount and structure abuse, admin protection, and more. |

The shape is always the same:

```json
"Modules": {
  "CombatCheats": {
    "Enabled": true,
    "SubModules": {
      "AutoFlak":   { "Enabled": true, "Block": true, "TimesUntilDetect": 6 },
      "NoOverheat": { "Enabled": true, "Block": true, "BanAfterDetections": 2 },
      "...":        { "...": "..." }
    }
  },
  "MiscCheats": { "Enabled": true, "SubModules": { "...": "..." } },
  "Mod":        { "Enabled": true, "SubModules": { "...": "..." } },
  "Exploits":   { "Enabled": true, "SubModules": { "...": "..." } }
}
```

A category's `Enabled: false` switches off **every** module inside it, whatever
the individual flags say. Your shipped `config.json` contains the complete list
of submodules with sensible defaults — the reference below explains the keys you
will find on them.

### Common submodule keys

| Key | Type | Meaning |
| --- | ---- | ------- |
| `Enabled` | boolean | Turn this specific detector on or off. |
| `Block` | boolean | Prevent the cheated action as well as reporting it. When `false`, the action goes through and you only get the alert — useful while you build confidence in a module on your own server. |
| `BanAfterDetections` | number | Queue the player for a ban after this many detections **by this module**. Absent or `0` means this module never bans on its own. |
| `InstantBan` | boolean | Execute that ban immediately instead of waiting for the next ban wave. |
| `OnlyAnalysis` | boolean | Detect and record, but don't post to your Discord webhook. A quiet mode for evaluating a module. |
| `WebhookUrl` | string | Send this module's alerts to a specific webhook instead of `DefaultWebhookUrl`. |
| `Threshole` / `*Threshold` | number | The module's sensitivity. Higher = more evidence required before it fires. The `Threshole` spelling is intentional in the keys that use it. |
| `BlockMovement` | boolean | Used by a few unlocker modules: freeze the offender in place rather than only flagging them. |

Some modules add keys of their own — for example a list of blueprint names to
exclude from a check, or an extra sub-flag for a specific variant of the exploit.
Those are described in `config_commented.json` where they are not self-evident.

> 💡 **Tuning advice.** Start with the shipped defaults. If a module produces
> false positives on your setup, prefer raising its threshold or its
> `BanAfterDetections` over disabling it outright — and set `OnlyAnalysis` while
> you watch it.

### The connection gate

One module in `MiscCheats` is worth calling out because it needs external setup:
the **session tracker** checks a joining player against the Steam Web API and can
reject accounts that look disposable.

```json
"SessionTracker": {
  "Enabled": true,
  "WebhookUrl": "",
  "Checks": {
    "AccountRestrictions": {
      "MinGameHours": 30,
      "BlockMinGameHours": false,
      "LogMinGameHours": true,
      "MinAccountAgeDays": 30,
      "BlockMinAccountAgeDays": false,
      "LogMinAccountAgeDays": true
    },
    "VacBanRestrictions": {
      "Block": false,
      "RecentDaysThreshole": 90,
      "Log": true
    }
  }
}
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `WebhookUrl` | string | `""` | Webhook for gate results. Falls back to `DefaultWebhookUrl`. |
| `MinGameHours` | number | `30` | Minimum ARK playtime, in hours. |
| `BlockMinGameHours` | boolean | `false` | Kick players below that playtime. |
| `LogMinGameHours` | boolean | `true` | Report players below that playtime. |
| `MinAccountAgeDays` | number | `30` | Minimum Steam account age, in days. |
| `BlockMinAccountAgeDays` | boolean | `false` | Kick accounts younger than that. |
| `LogMinAccountAgeDays` | boolean | `true` | Report accounts younger than that. |
| `VacBanRestrictions.RecentDaysThreshole` | number | `90` | How recent a VAC ban has to be to count. |
| `VacBanRestrictions.Block` | boolean | `false` | Kick players with a recent VAC ban. |
| `VacBanRestrictions.Log` | boolean | `true` | Report players with a recent VAC ban. |

> ℹ️ **Requires `SteamAPIKey`.** Without a key these checks can't run. Also note
> that a player with a **private** Steam profile hides their playtime — decide
> deliberately whether you want `Block*` on, since it will turn some legitimate
> players away.

---

**Next steps:**

- [Commands](commands.md) — console/RCON and in-game admin commands.
- [Bans & Detections](bans.md) — thresholds, ban waves, IP/HWID bans, unbanning.
- [Common Configuration](../common-configuration.md) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
