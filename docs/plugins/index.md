# Plugins

Bytemart plugins extend your ARK server with new features. Each plugin ships as a
`.zip` you download from your **Bytemart Dashboard** and drop into your server's
plugin folder.

## Available plugins

| Plugin | Description |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | A competitive tribe scoring system: tribes earn score for destroying enemy structures, dinos, and players in PvP, surfaced through a leaderboard and in-world holograms. |
| [ssAntiCheat](ssanticheat/index.md) | Server-side anti-cheat: detection modules for combat cheats and exploits, an integrated ban system with ban waves, Discord alerting, and fixes for known crash and duplication exploits. |
| [DupeDetector](dupedetector/index.md) | A focused dupe detector for the tribute/upload store: catches item duplication, alerts your Discord, and optionally punishes repeat offenders automatically. |
| [ArkBossCooldown](arkbosscooldown/index.md) | A server-wide cooldown between boss starts, so spammed boss tributes stop stacking teleports and killing players on arrival. |

## Common Configuration

Every Bytemart plugin is configured through a `config.json` file located in the
plugin's own folder:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/config.json
```

The keys below appear at the **top level** of that file and behave identically in
every plugin. Individual plugin pages document only the keys that are unique to
them and link back here for these shared ones.

> 💡 **Validate your JSON.** A single misplaced comma or quote will stop a plugin
> from loading. After every edit, run your config through a validator such as
> [JSONLint](https://jsonlint.com/). A load error code of `1114` almost always
> means a JSON syntax error.

### `LicenseKey`

```json
"LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE"
```

Your Bytemart license key. **Required.** The plugin authenticates this key against
the Bytemart licensing server on startup, and none of its features activate until
authentication succeeds. Find your key on your
[Bytemart Dashboard](https://bytemart.net/).

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `LicenseKey` | string | — | The license key issued for your plugin. Keep it private. |

### `Verbose`

```json
"Verbose": false
```

Enables verbose plugin logging. When `true`, the plugin prints extra diagnostic
output to the server console — useful when troubleshooting, noisy otherwise. Leave
it `false` in normal operation.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `Verbose` | boolean | `false` | Enable verbose (debug-level) console logging. |

### `LogToFile`

```json
"LogToFile": false
```

When `true`, the plugin mirrors everything it logs to a rotating log file inside
its own folder:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/<PluginName>.log
```

The file rotates automatically (roughly 5 MB per file, up to 3 files kept). Only
that one plugin's output is written — the shared ArkApi/server log is never
modified. This makes it easy to isolate a single plugin's activity when diagnosing
an issue.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `LogToFile` | boolean | `false` | Mirror this plugin's logs to its own rotating `.log` file. |

### `Database`

```json
"Database": {
  "MysqlHost": "localhost",
  "MysqlPort": 3306,
  "MysqlUser": "username",
  "MysqlPass": "password",
  "MysqlDB": "database"
}
```

MySQL connection credentials. Plugins that persist data (leaderboards, cooldowns,
transactions, …) connect to your MySQL/MariaDB server using these values and
create the tables they need on first run. Point every plugin at the same database
unless you have a specific reason to separate them.

| Field | Type | Default | Description |
| ----- | ---- | ------- | ----------- |
| `MysqlHost` | string | `localhost` | Hostname or IP of your MySQL/MariaDB server. |
| `MysqlPort` | number | `3306` | Server port. |
| `MysqlUser` | string | — | Username with access to the database. |
| `MysqlPass` | string | — | Password for that user. |
| `MysqlDB` | string | — | Name of the database to use. It must already exist; the plugin creates its own tables inside it. |

> ⚠️ **The database must exist.** Plugins create their **tables** automatically,
> but they do **not** create the database itself. Create the schema named in
> `MysqlDB` and grant the user `SELECT`, `INSERT`, `UPDATE`, `DELETE`, and `CREATE`
> permissions on it before starting the server.
