# Bans & Detections

ssAntiCheat separates **detecting** a cheater from **removing** them. A detection
always alerts; a ban only happens once a module's threshold is met, and even then
it is normally held back until the next **ban wave**. That delay is deliberate —
it stops a cheater from correlating "I did X, and was banned one second later"
and working out which check caught them.

## The pipeline

```
1. a detector fires
2. detection is recorded  ──> in-game admin alert
                          ──> Discord webhook
                          ──> dashboard (if enabled)
3. module reached its BanAfterDetections count?   ── no ──> done
                          │ yes
4. player is queued for a ban
5. the queue is executed on the next ban wave
6. execution: run AutoBan.ExecuteCommand, alert admins,
   and (if IntegratedBanSystem is on) write the ban row and kick
7. on their next join attempt, the ban is enforced at login
```

Steps 3–4 are per module — see
[`BanAfterDetections`](configuration.md#common-submodule-keys). A module without
that key detects and alerts, but never bans on its own.

## Ban waves

A queued ban is executed when **any** of the following happens:

| Trigger | Notes |
| ------- | ----- |
| Every *N* world saves | *N* is [`AutoBan."SaveWorld Cycles"`](#autoban) — `2` by default. This is the normal path. |
| The queued player disconnects | They are banned on the way out, rather than being left free until the next wave. |
| The module has `InstantBan: true` | Reserved for detections with no plausible false positive. |
| An admin runs `ssac.banwave` | Flush the whole queue now. |

Between queueing and execution you can inspect the queue with `ssac.pendingbans`
and empty it with `ssac.clearbanwave`. See
[Commands](commands.md#ssacbanwave-ssacclearbanwave-ssacpendingbans).

### `AutoBan`

```json
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `SaveWorld Cycles` | number | `2` | Run a ban wave every this many world saves. With a 15-minute save interval, `2` means at most a 30-minute delay. |
| `ExecuteCommand` | string | `"banplayer {steamid} "` | A console command run for each banned player. `{steamid}` is replaced with their SteamID64. Leave it empty to rely solely on the integrated ban system. |

`ExecuteCommand` is how you hook ssAntiCheat into whatever you already use. The
default adds the player to ARK's own ban list; you could instead call another
plugin's ban command, or a cluster-wide one.

> 💡 **Cluster tip.** ARK's `banplayer` is per-server. If you run a cluster,
> either point `ExecuteCommand` at a cluster-aware ban command, or use the
> integrated ban system with a **shared MySQL database** across all your servers
> — every server then enforces every ban at login.

## `IntegratedBanSystem`

The built-in ban store: bans are written to your MySQL database and enforced when
the player tries to connect.

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
}
```

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Store and enforce bans in MySQL. When `false`, only `AutoBan.ExecuteCommand` runs. |
| `UseIPBans` | boolean | `true` | Also refuse connections from a banned player's IP address. See below. |
| `UseHWIDBans` | boolean | `false` | Also refuse connections from a banned player's hardware ID. Requires the optional companion client mod to capture one — without it this does nothing. |
| `Exclude IPS` | array | `[]` | IP addresses never treated as an association. Put shared/NAT addresses here. |
| `BanMessage` | string | see above | The message the player sees. |

Bans live in a single table (`ssAntiCheat_bans`) holding the Steam ID, IP,
hardware ID, reason, ban date, and expiry. Point several servers at the same
database and a ban applies across all of them.

### Ban message

`BanMessage` supports two placeholders:

| Placeholder | Replaced with |
| ----------- | ------------- |
| `{reason}` | The ban reason. |
| `{ban_id}` | The numeric ban ID — the value an admin needs for `ssac.unban`. |

```json
"BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nAppeal at: https://yourserver.example/appeal"
```

> ⚠️ **Replace the placeholder URL.** The shipped message points at
> `store.example.com`. Always include `{ban_id}` — without it, a player appealing
> a ban has nothing to quote and you have to search the database by hand.

### IP-association bans

With `UseIPBans` on, a player connecting from an address that belongs to an
active ban is refused **and recorded as their own ban**, so the alt account is
banned by Steam ID from then on. An alert goes to
[`AssociationBans`](configuration.md#webhooks) naming both accounts.

The check is deliberately conservative — it only fires when the IP genuinely
matches, is not in `Exclude IPS`, and belongs to a *different* Steam account.

> ⚠️ **IP bans catch households and shared connections.** Siblings, roommates, an
> internet café, or a shared VPN exit will all look like the same player. Watch
> the association channel for a while before you trust it, and add legitimate
> shared addresses to `Exclude IPS`.

## Ban durations

| How the ban was made | Duration |
| -------------------- | -------- |
| `ssac.ban` with `d=…` | Expires after that period. |
| `ssac.ban` without `d=…` | Permanent. |
| Automatic (a module's `BanAfterDetections`) | Permanent. |

To lift any ban, use its ban ID:

```bash
ssac.unban 42
```

## Reviewing a detection before it becomes a ban

The gap between detection and ban wave is your review window. A workflow that
works well:

1. The Discord alert (or in-game admin alert) names the player and the module.
2. `ssac.go` — spectate them immediately, with no argument to jump to the last
   detection.
3. `!tracers` — watch their shots; aim assistance is obvious to the naked eye
   this way.
4. `ssac.pendingbans` — see whether they are already queued and for what.
5. Decide: let the wave run, `ssac.banwave` to act now, or `ssac.clearbanwave` if
   you believe it is a false positive.

If a module produces repeated false positives on your setup, raise its threshold
or set `OnlyAnalysis` on it rather than turning it off — see
[Tuning advice](configuration.md#common-submodule-keys).

---

**Next steps:**

- [Configuration](configuration.md) — every key in `config.json`.
- [Commands](commands.md) — the full command reference.
