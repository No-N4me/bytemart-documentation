# 🤖 Discord Bot

Tribescore comes with a companion **Discord bot** that brings your server's
competition into Discord — a live, auto-refreshing leaderboard, slash commands to
look up any tribe, and an automatic abuse-detection system that flags suspicious
scoring.

The bot connects **directly to the same MySQL/MariaDB database** the plugin uses.
It only ever *reads* the plugin's score tables — it never changes your scores — so
it is safe to run alongside a live server.

## Features

- **Live leaderboard** — posts and auto-refreshes the top tribes in a channel of
  your choice, with ▲/▼ movement arrows between scoring periods.
- **Image or embed rendering** — show the board as a classic Discord embed, or as a
  polished PNG rendered from one of seven built-in designs (`podium`, `spotlight`,
  `cards`, `bars`, `terminal`, `ark`, `dark`). Templates are plain HTML you can
  restyle and brand for your server.
- **Slash commands** — `/tribepoints` and `/getrank` let players look up any tribe's
  score and rank. Command names and messages are configurable.
- **Abuse detection** — three independent detectors post alerts when scoring looks
  suspicious, each with an *"Ignore this alert"* button to silence false positives.
- **Standalone executable** — distributed as a single self-contained Windows `.exe`.
  No browser and no extra installs are required, even for image rendering.

## Requirements

- The Tribescore plugin installed and writing to a MySQL/MariaDB database (see
  [Configuration](configuration.md) and
  [Common Configuration](../index.md#database)).
- A Discord application and bot token, created on the
  [Discord Developer Portal](https://discord.com/developers/applications).
- A Windows machine to run the bot — it can run anywhere that can reach the database.

## Installation

1. Download the bot from your **Bytemart Dashboard** and extract it.
2. Open `config.yml` and configure it (see below).
3. Set your bot token and database password — either directly in `config.yml`, or
   via the `LEADERBOARD_BOT_TOKEN` and `MYSQL_PASSWORD` environment variables
   (recommended, so secrets stay out of the config file).
4. Invite the bot to your server, giving it permission to send messages, embeds, and
   attachments in the leaderboard and alert channels.
5. Run the executable. On first launch it registers its slash commands and posts the
   leaderboard.

> 💡 If you rename a slash command in `config.yml`, Discord may need the bot to be
> kicked and re-invited before the change takes effect.

## Configuration (`config.yml`)

The bot is configured entirely through `config.yml`. Key settings:

| Setting | Description |
| ------- | ----------- |
| `bot-token` | Your Discord bot token. Leave blank and set `LEADERBOARD_BOT_TOKEN` instead. |
| `period-start` | Cron expression for when a new scoring period starts (the board snapshots movement then). See [crontab.guru](https://crontab.guru/). |
| `timezone` | Timezone for scheduling and transaction comparisons — must match your database's timezone. |
| `refresh-cooldown` | Seconds between in-period leaderboard refreshes. |
| `leaderboard-channel` | The channel ID where the leaderboard is posted. |
| `keep-leaderboard-history` | When `true`, posts a fresh leaderboard message each period instead of editing the existing one. |
| `leaderboard-render-mode` | `embed` (Discord embed) or `image` (rendered PNG). |
| `leaderboard-image` | Image-mode options: `template`, `title`, `lines`, `width`, `scale`. |
| `mysql` | Database connection: `host`, `port`, `user`, `password`, `database`, `leaderboard-table`, `transactions-table`, `timezone`. |
| `commands` | Command names, descriptions, and reply messages. |
| `abuse-detection` | Enable and tune the abuse-detection modules. |

> ⚠️ The `leaderboard-table` and `transactions-table` must match the plugin's tables
> — by default `ts_leaderboard` and `ts_transactions`. The bot reads these tables and
> never writes to them.

### Leaderboard display

Choose how the board is rendered with `leaderboard-render-mode`:

```yaml
leaderboard-render-mode: "image"   # or "embed"
leaderboard-image:
  template: "spotlight"   # podium | spotlight | cards | bars | terminal | ark | dark
  title: "Tribes Leaderboard"
  lines: 15               # number of tribes shown
  width: 820
  scale: 2                # 2 = crisp / retina output
```

In `embed` mode the board is a text embed built from `leaderboard_embed.json`. In
`image` mode it is rendered from an HTML template under
`templates/leaderboard/<name>/`. If image rendering ever fails, the bot
automatically falls back to the embed, so the leaderboard can never go offline.

### Slash commands

| Command (default) | Description |
| ----------------- | ----------- |
| `/tribepoints <tribe>` | Show a tribe's current points. |
| `/getrank <tribe>` | Show a tribe's rank and points. |

Both command names and their reply messages are configurable under `commands` in
`config.yml`, using the `{tribe}`, `{points}`, and `{rank}` placeholders.

### Abuse detection

When `abuse-detection.enabled` is `true`, the bot periodically scans the top tribes
and posts an alert to the configured `channel-id` when a module trips. Every alert
carries an **"Ignore this alert"** button that suppresses future repeats for that
tribe pair.

| Module | Detects |
| ------ | ------- |
| `rapid-increase` | A tribe gaining an unusually large number of points within one scoring period. |
| `massive-transaction` | A single transfer of points above a threshold from one tribe to another. |
| `prefered-source` | A tribe receiving a large share of its points from one single source tribe (with an optional reciprocity "mirror" check). |

Each module has its own `cooldown`, thresholds, and alert `title` / `message` — the
available placeholders are documented inline in `config.yml`.

> ℹ️ The bot creates one table of its own, `ts_ignored_alerts`, to remember which
> alerts you have dismissed. This is the only table it writes to; your score data is
> never modified.
