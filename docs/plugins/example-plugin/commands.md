# Commands & Permissions

This plugin features both in-game chat commands for players and remote RCON commands for server owners.

## Player Chat Commands

| Command | Description | Required Permission |
| ------- | ----------- | ------------------- |
| `/kits` | Opens the UI to list all available kits. | `ArkKits.Use` |
| `/kit <name>` | Immediately claims a specific kit. | `ArkKits.Use.<name>` |

### Example Usage:

`❯ /kit Starter` - Gives the player the Starter kit if it is off cooldown.

## RCON / Console Commands

| Command | Description |
| ------- | ----------- |
| `Kits.Reload` | Reloads the `config.json` file on the fly without restarting the server. |
| `Kits.ResetCooldown <SteamID> <KitName>` | Resets the cooldown timer for specific player's kit. |

---

## 🔐 Permissions System

ArkKits relies heavily on ArkApi's built-in permissions system. You must grant the exact permissions matching your `config.json`.
**To grant a VIP group permission to the "AlphaKit":**
```bash
Permissions.AddGroup VIP
Permissions.Grant VIP ArkKits.Use.AlphaKit
```