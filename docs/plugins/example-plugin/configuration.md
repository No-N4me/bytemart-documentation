# Configuration

The main configuration file is located at `ArkApi/Plugins/ArkKits/config.json`. Make sure to use a tool like [JSONLint](https://jsonlint.com/) to validate your config after making changes.

### Example `config.json`

```json
{
  "General": {
    "DatabaseType": "sqlite",
    "DiscordWebhook": "https://discord.com/api/webhooks/your-webhook-url"
  },
  "Kits": {
    "Starter": {
      "Description": "Basic tools and armor.",
      "CooldownInMinutes": 60,
      "MinLevel": 1,
      "Permissions": "ArkKits.Use.Starter",
      "Items": [
        {
          "BlueprintPath": "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponStonePick.PrimalItem_WeaponStonePick'",
          "Quality": 1,
          "Quantity": 1,
          "ForceBPO": false
        }
      ]
    }
  }
}
```