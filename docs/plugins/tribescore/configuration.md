# Configuration

Tribescore is configured through **three** files in the plugin folder
(`ShooterGame/Binaries/Win64/ArkApi/Plugins/Tribescore/`):

| File | Purpose |
| ---- | ------- |
| `config.json` | Main settings: license, database, activation, eligibility, scoring modifiers, holograms, and chat commands. |
| `structures.json` | Point values for structures, by build tier and per-blueprint. |
| `dinos.json` | Point values and counting rules for dinos, per species. |

> 💡 **Validate before you start.** Always validate your JSON after editing (e.g.
> with [JSONLint](https://jsonlint.com/)). A load error code of `1114` means a JSON
> syntax error.

The keys `LicenseKey`, `Verbose`, `LogToFile`, and `Database` are shared by every
Bytemart plugin and are documented on the
**[Common Configuration](../index.md)** page. This page covers only
the keys unique to Tribescore.

---

## `config.json`

### `DebugMode`

```json
"DebugMode": false
```

When `true`, the console becomes more verbose **and** you are allowed to earn
tribescore from your own tribe — useful for testing scoring on a dev server. Leave
it `false` on a live server.

### `TribescoreActivation`

Delays scoring globally after a server (wipe) start, so tribes have time to
re-establish before the competition begins.

```json
"TribescoreActivation": {
  "Activation": {
    "Type": "delay",
    "Value": 7200
  },
  "Message": "Tribescore is globally enabled after 2 hours, please wait {cooldown}"
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Activation.Type` | string | `"delay"` — enable scoring `Value` seconds after server start. `"timestamp"` — enable scoring at a fixed [Unix timestamp](https://www.unixtimestamp.com/). |
| `Activation.Value` | number | Seconds of delay (for `delay`) or the Unix timestamp (for `timestamp`). Set to `0` to disable the feature and enable scoring immediately. |
| `Message` | string | Shown to players who trigger scoring while it is still on cooldown. The `{cooldown}` placeholder is replaced with the time remaining. |

### `TribescoreEligibility`

Gates which tribes can earn score based on membership size.

```json
"TribescoreEligibility": {
  "MinPlayers": 1,
  "MinOnlinePlayers": 0
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `MinPlayers` | number | Minimum number of members a tribe must have (total) to earn score. |
| `MinOnlinePlayers` | number | Minimum number of members that must be **online** for the tribe to earn score. `0` disables this check. |

### `Scoring`

The heart of the plugin. Base values live here (and in `structures.json` /
`dinos.json`); the `Modifiers` sub-section multiplies them.

```json
"Scoring": {
  "GainLossRatio": 0.75,
  "Structures": { "Enabled": true, "DefaultValue": 10.0 },
  "Dinos":      { "Enabled": true, "DefaultValue": 25.0 },
  "Players":    { "Enabled": true, "Value": 150.0 },
  "Modifiers": { "...": "..." }
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `GainLossRatio` | number | When no explicit `LossOverride` is set (in `structures.json` / `dinos.json`), the **defender's** score loss is `gain × GainLossRatio`. At `0.75`, a defender loses 75% of what the attacker gained. |
| `Structures.Enabled` | boolean | Enable scoring from destroyed structures. Configure values in [`structures.json`](#structuresjson). |
| `Structures.DefaultValue` | number | Points for a structure with no tier or blueprint match. |
| `Dinos.Enabled` | boolean | Enable scoring from killed dinos. Configure values in [`dinos.json`](#dinosjson). |
| `Dinos.DefaultValue` | number | Points for a dino with no per-species override. |
| `Players.Enabled` | boolean | Enable scoring from killed enemy players. |
| `Players.Value` | number | Flat points awarded per enemy player kill. |

#### `Modifiers.OfflineProtection`

Reduces (or increases) score earned against a tribe that has been fully offline
for a while — discouraging offline raiding.

```json
"OfflineProtection": {
  "Enabled": true,
  "ActivatesAfter": 3600,
  "Modifier": 0.75
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Toggle the feature. |
| `ActivatesAfter` | number | Seconds a tribe must be fully offline before protection kicks in. |
| `Modifier` | number | Multiplier applied once active. `< 1` reduces the attacker's gain (e.g. `0.75` = −25%). |

*Applied based on the **defender**.*

#### `Modifiers.PermissionModifiers`

Boost (or nerf) score based on the attacker's ArkApi **permissions**. Requires the
[Permissions](https://github.com/ServersHub/ServerAPI) plugin from the ArkServerAPI.

```json
"PermissionModifiers": {
  "Enabled": true,
  "TribePermissionsOnly": false,
  "OnlinePlayersOnly": true,
  "Modifiers": [
    { "Permission": "ts.boost.10", "Value": 1.1 },
    { "Permission": "ts.boost.15", "Value": 1.15 },
    { "Permission": "ts.boost.25", "Value": 1.25 }
  ]
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Toggle the feature. |
| `TribePermissionsOnly` | boolean | When `true`, only check tribe-level permissions (ignore individual player permissions). |
| `OnlinePlayersOnly` | boolean | When `true`, only consider currently-online members' permissions; otherwise all members are checked. |
| `Modifiers[]` | array | Permission → multiplier pairs. **Only one modifier applies at a time**; if several match, the **largest** is used. |
| `Modifiers[].Permission` | string | The permission node the player/tribe must hold. |
| `Modifiers[].Value` | number | Multiplier applied (`> 1` increases the gain). |

*Applied based on the **attacker**.*

#### `Modifiers.ScoreDifferenceRatio`

Balances strong vs. weak tribes. The ratio compared is the **defender's** score
divided by the **attacker's** score; the matching interval's `Modifier` scales the
attacker's gain — so big tribes farming small ones are nerfed, and underdogs
attacking giants are boosted.

```json
"ScoreDifferenceRatio": {
  "Enabled": true,
  "Intervals": [
    { "UpperBound": -1,   "LowerBound": 2,    "Modifier": 1.2 },
    { "UpperBound": 2,    "LowerBound": 1.5,  "Modifier": 1.1 },
    { "UpperBound": 1.5,  "LowerBound": 1,    "Modifier": 1 },
    { "UpperBound": 1,    "LowerBound": 0.5,  "Modifier": 0.8 },
    { "UpperBound": 0.5,  "LowerBound": 0.25, "Modifier": 0.6 },
    { "UpperBound": 0.25, "LowerBound": 0,    "Modifier": 0.25 }
  ]
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Toggle the feature. |
| `Intervals[]` | array | Bands of the defender/attacker score ratio, each with a multiplier. |
| `LowerBound` / `UpperBound` | number | The ratio band this modifier covers. Use `-1` as the `UpperBound` of the top band to mean "no upper limit". |
| `Modifier` | number | Multiplier applied when the ratio falls in this band. |

**Reading the defaults:**

- Ratio `≥ 2` (defender has ≥ 2× the attacker's score) → **1.2×** boost for the
  attacking underdog.
- Ratio between `1.5` and `2` → **1.1×** boost.
- Ratio between `0.25` and `0.5` → **0.6×** nerf.
- Ratio `< 0.25` (defender has less than a quarter of the attacker's score) →
  **0.25×** — a stiff nerf on farming much weaker tribes.

*Uses **both** the attacker and the defender.*

### `Holograms`

Controls the floating point-numbers that appear in-world when score changes.
`Damager` is the `+points` text shown to the attacker; `Damagee` is the `-points`
text shown to the defender.

```json
"Holograms": {
  "DecimalPrecision": 1,
  "LifeSpan": 6.0,
  "Scale":    { "X": 0.5, "Y": 0.5 },
  "FadeTime": { "In": 2.0, "Out": 3.0 },
  "Velocity": { "X": 0, "Y": 0, "Z": 10.0 },
  "Damager": { "Enabled": true, "Text": "+ {points} points", "Color": { "R": 0,   "G": 255, "B": 0 } },
  "Damagee": { "Enabled": true, "Text": "- {points} points", "Color": { "R": 255, "G": 0,   "B": 0 } }
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `DecimalPrecision` | number | Decimal places shown in the `{points}` value. |
| `LifeSpan` | number | Seconds the hologram stays visible. |
| `Scale.X` / `Scale.Y` | number | Text size on each axis. |
| `FadeTime.In` / `FadeTime.Out` | number | Fade-in / fade-out duration in seconds. |
| `Velocity.X/Y/Z` | number | Drift speed of the text; the default floats it upward (`Z`). |
| `Damager` / `Damagee` | object | The gain / loss popups. `Enabled` toggles each; `Text` uses the `{points}` placeholder; `Color` is RGB (0–255). |

Players can turn holograms on or off for themselves with the `/holograms` chat
command (see [Commands](commands.md)).

### `ChatCommands`

Enables, renames, and styles the three in-game chat commands. Each has an
`Enabled` toggle and a customizable `Command` trigger; disabling one un-registers
it entirely.

```json
"ChatCommands": {
  "Holograms":   { "Enabled": true, "Command": "/holograms", "On": { "...": "..." }, "Off": { "...": "..." } },
  "Leaderboard": { "Enabled": true, "Lines": 15, "Command": "/leaderboard", "Text": "#{rank} [{tribe}] : {score}", "PerRankColor": { "...": "..." } },
  "MyTribeRank": { "Enabled": true, "Command": "/triberank", "Text": "Your tribe ({tribe}) is ranked #{rank} with {score}" }
}
```

Common fields on each command: `TextSize` (number), `Color` (RGB `{R,G,B}`), and
`DisplayTime` (seconds the message stays on screen).

**`Holograms`** — toggles the per-player hologram display. `On` and `Off` each
define the confirmation message (`Text`, `TextSize`, `Color`, `DisplayTime`) shown
when toggling.

**`Leaderboard`** — prints the top tribes.

| Field | Description |
| ----- | ----------- |
| `Lines` | How many tribes to list. |
| `Text` | Line format. Placeholders: `{rank}`, `{tribe}`, `{score}`. |
| `PerRankColor` | Optional per-place color overrides, keyed by rank (`"1"`, `"2"`, `"3"`, …), each an RGB object. |

**`MyTribeRank`** — prints the caller's own tribe rank. `Text` supports the same
`{rank}`, `{tribe}`, `{score}` placeholders.

### `Messages`

Reserved for message customization; empty (`{}`) by default.

---

## `structures.json`

Point values for structures, resolved by build **tier** first, then overridden by
specific **blueprints**. A structure that matches nothing uses `DefaultValue`.

```json
{
  "Tiers": {
    "Thatch": { "Value": 1.0,  "LossOverride": 0.5 },
    "Wood":   { "Value": 2.0,  "LossOverride": 1.25 },
    "Stone":  { "Value": 3.0,  "LossOverride": 2.0 },
    "Adobe":  { "Value": 5.0,  "LossOverride": 4.0 },
    "Metal":  { "Value": 10.0, "LossOverride": 7.0 },
    "Tek":    { "Value": 15.0, "LossOverride": 12.5 }
  },
  "DefaultValue": 10.0,
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Structures/Misc/PrimalItemStructure_HeavyTurret.PrimalItemStructure_HeavyTurret'",
      "Value": 25.0
    },
    {
      "BlueprintPath": "Blueprint'/Game/.../PrimalItemStructure_TurretTek.PrimalItemStructure_TurretTek'",
      "Value": 25.0,
      "LossOverride": 25.0
    }
  ]
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Tiers` | object | Per-tier values, keyed by build material (`Thatch`, `Wood`, `Stone`, `Adobe`, `Metal`, `Tek`). |
| `Tiers.<tier>.Value` | number | Points the attacker gains for destroying a structure of this tier. |
| `Tiers.<tier>.LossOverride` | number | *(optional)* Fixed points the defender loses. If omitted, `Value × GainLossRatio` is used. |
| `DefaultValue` | number | Fallback value when a structure matches no tier or custom entry. |
| `Customs[]` | array | Per-blueprint overrides that take precedence over the tier value. |
| `Customs[].BlueprintPath` | string | Full blueprint path of the structure. Use `ts.addstructure` to append the structure you're looking at automatically (see [Commands](commands.md)). |
| `Customs[].Value` | number | Points for this specific blueprint. |
| `Customs[].LossOverride` | number | *(optional)* Fixed loss for this blueprint. |

---

## `dinos.json`

Point values and counting rules per dino species. `Defaults` applies to every dino
not listed in `Customs`.

```json
{
  "Defaults": {
    "Value": 25.0,
    "LossOverride": 20.0,
    "CountBabies": true,
    "CountWithoutSaddle": true,
    "CountNotMounted": true,
    "ScoreFromWild": true
  },
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/Dinos/Giganotosaurus/Gigant_Character_BP.Gigant_Character_BP'",
      "Value": 50.0,
      "LossOverride": 45.0,
      "CountBabies": false
    }
  ]
}
```

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Value` | number | Points the attacker gains for killing this dino. |
| `LossOverride` | number | *(optional)* Fixed points the defender loses. If omitted, `Value × GainLossRatio` is used. |
| `CountBabies` | boolean | Whether killing baby/juvenile dinos scores. |
| `CountWithoutSaddle` | boolean | Whether an unsaddled tame scores. |
| `CountNotMounted` | boolean | Whether a dino that is not currently being ridden scores. |
| `ScoreFromWild` | boolean | Whether killing a **wild** (untamed) dino of this species scores. |
| `Customs[].BlueprintPath` | string | Full blueprint path of the species this override targets. |

Each `Customs` entry may set any subset of these fields; unspecified fields fall
back to `Defaults`.
