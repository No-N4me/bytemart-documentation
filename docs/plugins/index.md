# Plugins

Bytemart plugins extend your ARK server with new features. Each plugin ships as a
`.zip` you download from your **Bytemart Dashboard** and drop into your server's
plugin folder.

## Shared configuration

Every Bytemart plugin reads a top-level `config.json` that shares a small set of
keys — your license key, logging switches, and MySQL database credentials. These
are documented once, in a single place:

- **[Common Configuration](common-configuration.md)** — `LicenseKey`, `Verbose`,
  `LogToFile`, and `Database`, common to **all** plugins.

Each plugin's own configuration page covers only the keys unique to that plugin
and links back to the page above for the shared ones.

## Available plugins

| Plugin | Description |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | A competitive tribe scoring system: tribes earn score for destroying enemy structures, dinos, and players in PvP, surfaced through a leaderboard and in-world holograms. |
