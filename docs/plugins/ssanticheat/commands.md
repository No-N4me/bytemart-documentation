# Commands

ssAntiCheat has two kinds of commands: **console/RCON** commands prefixed with
`ssac.`, and **in-game chat** commands prefixed with `!` (configurable via
[`CommandPrefix`](configuration.md#top-level-keys)).

Console and RCON access is admin access by definition, so `ssac.` commands need
no extra permission. The chat commands check that you are a **server admin**
(`enablecheats`) and silently do nothing otherwise.

## Console / RCON commands

| Command | Channels | Description |
| ------- | -------- | ----------- |
| `ssac.help [page]` | Console, RCON | Paginated list of every registered command. |
| `ssac.status` | Console, RCON | License, server ID, and dashboard telemetry status. |
| `ssac.detections` | Console, RCON | List recent detections, grouped by Steam ID. |
| `ssac.pendingbans` | Console, RCON | List players queued for the next ban wave. |
| `ssac.banwave` | Console, RCON | Execute the pending ban wave immediately. |
| `ssac.clearbanwave` | Console, RCON | Drop every pending ban without banning anyone. |
| `ssac.ban <steamid> [r=<reason>] [d=<duration>]` | Console, RCON | Ban a player. |
| `ssac.unban <ban-id>` | Console, RCON | Cancel a ban by its ban ID. |
| `ssac.testdetection [steamid] [module]` | Console, RCON | Push a simulated detection to the dashboard. |
| `ssac.go [steamid]` | Console | Spectate a player — the one given, or the last one detected. |
| `ssac.command <reason> <command...>` | Console | Run a console command as yourself, on the record. |

`ssac.go` and `ssac.command` act on *your* character, so they only work from the
in-game console — there is no player behind an RCON session.

### `ssac.status`

The first thing to run after installing, and the first thing support will ask
for. It prints the plugin version, whether the license authenticated, this
server's ID, the map and server name, and — when dashboard telemetry is on — the
endpoint, whether the server has registered, the last send result, and the queue
depth.

```bash
ssac.status
```

A non-zero queue depth that never drains means the dashboard endpoint is
unreachable or rejecting your events.

### `ssac.detections`

Lists the detections held in memory (roughly the **last hour**), grouped by Steam
ID, with the module that fired for each one.

```bash
ssac.detections
```

> ℹ️ **Detections are in-memory only.** They do not survive a server restart.
> Bans do — they are stored in MySQL. Use your Discord webhooks as the permanent
> record of detections.

### `ssac.ban` / `ssac.unban`

```
ssac.ban <steamid> [r=<reason>] [d=<duration>]
ssac.unban <ban-id>
```

| Argument | Description |
| -------- | ----------- |
| `<steamid>` | The target's SteamID64 (17 digits). |
| `r=<reason>` | Ban reason. Wrap it in quotes if it contains spaces. Defaults to `No reason provided`. |
| `d=<duration>` | Ban length, built from `d` / `h` / `m` / `s` parts — e.g. `7d`, `12h30m`, `1d6h`. Omit it for a **permanent** ban. |

```bash
ssac.ban 76561198000000000 r="Aimbot" d=7d
ssac.ban 76561198000000000                  # permanent, no reason
ssac.unban 42                               # lift ban #42
```

The ban is written to MySQL together with the player's IP (and their hardware ID
if one was captured), and the player is kicked immediately if online with your
[`BanMessage`](bans.md#ban-message). `ssac.unban` takes the **ban ID**, not the
Steam ID — `ssac.detections` and the Discord ban embed both show it, and it is
also the `{ban_id}` in the kick message the player sees.

### `ssac.banwave` / `ssac.clearbanwave` / `ssac.pendingbans`

```bash
ssac.pendingbans     # who is queued, and why
ssac.banwave         # ban all of them now
ssac.clearbanwave    # let all of them off
```

Pending bans are queued by detection modules and normally execute on a schedule
— see [Bans & Detections](bans.md#ban-waves). These three commands let you review
the queue, flush it early, or clear a queue you believe is a false positive.

### `ssac.go`

Puts you into spectator mode and moves you to a player.

```bash
ssac.go                       # the most recently detected player
ssac.go 76561198000000000     # a specific player
```

With no argument it follows the last detection, which is what you want when
reacting to an alert. With a Steam ID it targets that player and echoes the name
it resolved, so you can confirm you grabbed the right person.

### `ssac.command`

Runs a console command as yourself and records that ssAntiCheat sanctioned it, so
the admin-protection module doesn't flag you for using it.

```
ssac.command <reason> <command...>
```

```bash
ssac.command investigating_dupe giveitemnum 1 1 0 0
```

The first argument is a free-text reason for the audit trail; everything after it
is the command to run.

### `ssac.testdetection`

Emits a **simulated** detection so you can verify your dashboard pipeline without
waiting for a real cheater. It requires
[`Dashboard.Enabled`](configuration.md#dashboard) to be `true`.

```
ssac.testdetection [steamid] [module]
```

```bash
ssac.testdetection                              # a detection for yourself (from the in-game console)
ssac.testdetection 76561198000000000 AutoLoot   # for a specific player, labelled AutoLoot
```

Run with no arguments from the in-game console it targets **you**, so the
dashboard row shows a real name, tribe, and position. Test events are flagged as
simulated and are excluded from real detection statistics. They are not sent to
Discord and never ban anyone.

---

## Chat commands

Typed in the in-game chat, admin-only, prefixed with
[`CommandPrefix`](configuration.md#top-level-keys) (`!` by default). Where a
command takes `<steamid>`, you can omit it and it acts on **whoever you are
looking at**.

Names are matched exactly as written below, including capitalisation.

### Investigation

| Command | Description |
| ------- | ----------- |
| `!esp` | Toggle ESP for yourself. |
| `!espPlayers` | Toggle player ESP: name, health, and current weapon above each player. |
| `!EspStruct` | Toggle structure ESP. |
| `!espset <name>` | Highlight structures whose blueprint name contains `<name>`, on top of the [`Structure ESP`](configuration.md#admin-esp) list. |
| `!espHideEmpty` | Hide empty containers in structure ESP. |
| `!tracers` | Draw every nearby shot as a tracer line, coloured by which body part it hit. The single most useful tool for judging aim assistance by eye. |
| `!vanish` | Toggle your own invisibility. |
| `!spawn` | Respawn at your current view, then enable creative mode, invisibility to enemies, and fly. |
| `!cloud <steamid>` | Print a player's uploaded (tribute) items to yourself. |

`!esp` is the master toggle — `!espPlayers` and `!EspStruct` only draw while ESP
is on for you.

### Interaction

These act on a suspect directly. Use them deliberately: they are visible to the
player and can tip off a cheater you are still gathering evidence on.

| Command | Description |
| ------- | ----------- |
| `!unequip <steamid>` | Strip a player's equipped armour. |
| `!dropweapon <steamid>` | Force a player to drop their held weapon. |
| `!jump <steamid>` | Force a player to jump. |
| `!punch <steamid>` | Trigger a player's tek gauntlet rocket punch. |
| `!tekjump <steamid>` | Trigger a player's tek chestpiece boost. |
| `!requestjoin <steamid>` | Send the player a fake tribe invite. |
| `!outofrange <steamid>` | Show the player the "out of range" client notice. |
| `!playpoopsound <steamid>` | Play the poop sound on a player. |
| `!playdeathsound <steamid>` | Play the death sound on a player. |

> ℹ️ **Every admin action is logged.** Admin chat commands are recorded to a local
> log file and posted to
> [`AdminTrollingWebhook`](configuration.md#webhooks) with the acting admin, the
> target, and the location — so admin powers stay accountable.
