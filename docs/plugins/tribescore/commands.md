# Commands

Tribescore has two kinds of commands: **admin** commands run from the server
console or RCON, and **player** chat commands typed in-game. Admin commands are
prefixed with `ts.` and are only reachable through the console/RCON, so no separate
permission system gates them — access is implied by the channel. Chat commands are
configurable and optional (see [`ChatCommands`](configuration.md#chatcommands)).

## Console / RCON commands

| Command | Channels | Description |
| ------- | -------- | ----------- |
| `ts.help [page]` | Console, RCON | Show the paginated Tribescore help menu. |
| `ts.give <tribe-id> <score>` | Console | Add tribescore to a tribe. Logs a `system` transaction. |
| `ts.take <tribe-id> <score>` | Console | Remove tribescore from a tribe. Logs a `system` transaction. |
| `ts.boost <tribe-id> <type> <value> <duration>` | Console, RCON | Grant a timed score boost to a tribe. |
| `ts.boost <tribe-id> clear` | Console, RCON | Clear a tribe's active timed boost. |
| `ts.audit <tribe-id> [options]` | Console | Audit a tribe's score transactions and upload a report. |
| `ts.estimate <recipient-tribe-id> [options]` | Console | Estimate the tribescore of structures around you. |
| `ts.addstructure` | Console | Append the structure you're looking at to `structures.json`. |

### `ts.give` / `ts.take`

```bash
ts.give 1234567890 500      # add 500 score to tribe 1234567890
ts.take 1234567890 250      # remove 250 score from tribe 1234567890
```

Both write a `system`-type entry to the transaction history so manual adjustments
are auditable.

### `ts.boost`

Grants a temporary score multiplier that stacks into the modifier pipeline for a
set duration.

```
ts.boost <tribe-id> <type> <value> <duration>
ts.boost <tribe-id> clear
```

| Argument | Description |
| -------- | ----------- |
| `<tribe-id>` | The target tribe's ID. |
| `<type>` | What the boost applies to: `structures`, `dinos`, `players`, `all`, or a combination joined with `+` (e.g. `structures+dinos`). |
| `<value>` | The multiplier (e.g. `1.5` for +50%). |
| `<duration>` | Boost lifetime, in **seconds**. |

```bash
ts.boost 1234567890 structures+dinos 1.5 3600   # +50% on structures & dinos for 1h
ts.boost 1234567890 all 2 600                   # double all score for 10 minutes
ts.boost 1234567890 clear                        # remove the active boost
```

> ℹ️ **Also exposed to other plugins.** Timed boosts are part of Tribescore's
> public API (`SetTimedBoost` / `ClearTimedBoost` / `GetTimedBoost`), which the
> companion **Koth** plugin uses to reward event winners automatically.

### `ts.audit`

Builds an asynchronous report of a tribe's transactions (who they earned from, who
stole from them, per-cluster breakdowns) and uploads it, returning a URL.

```
ts.audit <tribe-id> [clusters_amount=X] [givers_amount=X] [stealers_amount=X] [start_date=YYYY-MM-DD] [end_date=YYYY-MM-DD]
```

| Option | Description |
| ------ | ----------- |
| `clusters_amount=X` | Number of top clusters to include. |
| `givers_amount=X` | Number of top tribes this tribe earned score from. |
| `stealers_amount=X` | Number of top tribes that took score from this tribe. |
| `start_date` / `end_date` | Restrict the audit to a date range (`YYYY-MM-DD`). |

```bash
ts.audit 1234567890 givers_amount=10 start_date=2026-07-01 end_date=2026-07-12
```

### `ts.estimate`

Scans structures within range of your character (via an octree scan, chunked over
several ticks) and estimates how much score they'd be worth to a given tribe.
Useful for tuning `structures.json` values.

```
ts.estimate <recipient-tribe-id> [modifiers=on|off] [range=X]
```

| Option | Description |
| ------ | ----------- |
| `modifiers=on\|off` | Whether to apply the modifier pipeline to the estimate. |
| `range=X` | Scan radius around your character. |

### `ts.addstructure`

Line-traces the structure you are looking at, appends it to `structures.json` as a
custom entry, and hot-reloads the file — a quick way to add per-blueprint values
without hunting down blueprint paths by hand.

---

## Chat commands

These are typed in the in-game chat. Names are configurable — the defaults below
come from the shipped [`ChatCommands`](configuration.md#chatcommands) config, and
each command can be disabled entirely.

| Command (default) | Description |
| ----------------- | ----------- |
| `/leaderboard` | Show the top tribes by score. |
| `/triberank` | Show your own tribe's rank and score. |
| `/holograms` | Toggle the floating `+/- points` holograms on or off for yourself. |

The wording, colors, size, on-screen duration, and (for the leaderboard) the
number of lines and per-rank colors are all set in
[`ChatCommands`](configuration.md#chatcommands).

---

## Permission nodes

Tribescore does not use permissions to gate its commands, but the
[`PermissionModifiers`](configuration.md#modifierspermissionmodifiers) feature
reads permission nodes to boost or nerf a tribe's score. Grant them through the
[Permissions](https://github.com/ServersHub/ServerAPI) plugin. With the default
config:

```bash
Permissions.AddGroup VIP
Permissions.Grant VIP ts.boost.15
```

Here a member of the `VIP` group would give their tribe a **1.15×** score multiplier,
per the `ts.boost.15` entry in `PermissionModifiers.Modifiers`. The node names are
arbitrary — they just have to match what you configure.
