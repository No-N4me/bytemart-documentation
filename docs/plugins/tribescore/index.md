# 🏆 Tribescore

Tribescore is a competitive **tribe scoring system** for ARK: Survival Evolved.
Tribes earn *tribescore* by destroying enemy structures, dinos, and players in PvP.
Scores are persisted in MySQL and surfaced through a leaderboard and ranking
system, while floating "hologram" numbers pop up in-world every time points are
gained or lost.

Point awards run through a configurable, multiplicative modifier pipeline so you
can keep the competition fair: offline protection, score-difference balancing
between strong and weak tribes, permission-based boosts, and admin-granted timed
boosts.

## Features

- **PvP scoring:** Award points for destroying enemy structures, killing tamed
  dinos, and killing enemy players. Every source is individually configurable and
  can be toggled off.
- **Per-tier & per-blueprint values:** Structures are scored by build tier
  (Thatch → Tek) with per-blueprint overrides; dinos are scored per species with
  fine-grained flags (babies, unsaddled, wild, …).
- **Modifier pipeline:** Balance the game with offline protection, a
  strong-vs-weak score-difference ratio, permission modifiers, and timed boosts.
- **Leaderboard & ranks:** In-game `/leaderboard` and `/triberank` chat commands,
  backed by a persistent MySQL leaderboard.
- **In-world holograms:** Configurable floating `+points` / `-points` text that
  players can toggle on or off for themselves.
- **Admin tooling:** Give/take score, grant timed boosts, audit a tribe's
  transaction history, and estimate a base's worth — all from the console/RCON.

## How scoring works

When an enemy structure, dino, or player is destroyed, the base point value comes
from the scoring tables (`structures.json`, `dinos.json`, or the flat player value
in `config.json`). That base value is then multiplied through the modifier
pipeline:

```
final score = base points
            × OfflineProtection(defender)
            × ScoreDifferenceRatio(attacker, defender)
            × PermissionModifier(attacker)
            × TimedBoost(attacker, type)
```

The attacking tribe **gains** the result; the defending tribe **loses** a
(separately configurable) amount. See the
[Configuration](configuration.md) page for every knob.

## Installation

1. Ensure you have a supported version of [ArkApi](https://arkserverapi.com/)
   installed on your server (Tribescore requires ArkApi **3.51** or newer).
2. Set up a MySQL/MariaDB database — see [Common Configuration](../common-configuration.md#database).
3. Download the `Tribescore.zip` from your **Bytemart Dashboard**.
4. Stop the server (run `saveworld` first), or unload any previous version with
   `plugins.unload Tribescore`.
5. Extract the archive into a `Tribescore` folder inside
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Open `config.json` and fill in your `LicenseKey` and `Database` credentials
   (see [Configuration](configuration.md)).
7. Start the server and confirm there are no errors during startup.

### Updating

- **Manual:** `plugins.unload Tribescore`, replace the files, then
  `plugins.load Tribescore`.
- **Automatic (hot-reload):** rename the new `Tribescore.dll` to
  `Tribescore.dll.arkapi` and drop it into the plugin folder — ArkApi loads the
  new version and unloads the old one automatically.

Always check the changelog for config changes when updating; a tool like
[Diffchecker](https://www.diffchecker.com/) helps spot new or renamed keys.

---

**Next steps:**

- [Configuration](configuration.md) — the full `config.json`, plus `structures.json` and `dinos.json`.
- [Commands](commands.md) — console/RCON admin commands and in-game chat commands.
- [Common Configuration](../common-configuration.md) — the shared `LicenseKey`, `Database`, `LogToFile`, and `Verbose` keys.
