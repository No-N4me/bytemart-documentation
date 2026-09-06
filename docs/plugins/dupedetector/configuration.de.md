# Konfiguration

DupeDetector wird über eine einzelne `config.json` im Plugin-Ordner
konfiguriert:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/DupeDetector/config.json
```

Eine zweite Datei, `config_commented.json`, wird mitgeliefert. Sie enthält
**dieselbe Konfiguration mit `//`-Kommentaren** — lies sie, aber benenne sie
nicht in `config.json` um (Kommentare sind kein gültiges JSON).

Die Schlüssel `LicenseKey`, `Verbose`, `LogToFile` und `Database` werden von
jedem Bytemart-Plugin gemeinsam genutzt und sind auf der Seite
**[Gemeinsame Konfiguration](../index.md#common-configuration)** dokumentiert. Diese Seite
behandelt nur den `DupeDetection`-Block, der für DupeDetector spezifisch ist.

> 💡 **Vor dem Start validieren.** Validiere dein JSON nach jeder Änderung
> stets (z. B. mit [JSONLint](https://jsonlint.com/)). Ein Ladefehler mit dem
> Code `1114` bedeutet einen JSON-Syntaxfehler.

## `DupeDetection`

```json
"DupeDetection": {
  "AlertWebhook": "",
  "Punishment": {
    "PunishmentWebhook": "",
    "Command": "",
    "ClearInventory": false,
    "After": {
      "Min": 1,
      "Max": 1
    }
  }
}
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `AlertWebhook` | string | `""` | Discord-Webhook für **Erkennungen** — eine Nachricht pro Erkennung, die den beteiligten Spieler nennt. Leer bedeutet, dass Erkennungen weiterhin gezählt, aber nichts gepostet wird. |

### `Punishment`

Was passiert, sobald ein Spieler genug Erkennungen angesammelt hat. Jedes
Feld ist optional: Lasse `Command` leer und `ClearInventory` auf false, und
DupeDetector wird zu einem reinen Berichterstattungs-Tool.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `PunishmentWebhook` | string | `""` | Discord-Webhook für **Bestrafungen**. Getrennt von `AlertWebhook` gehalten, damit du die (deutlich selteneren) Bestrafungen an einen nur für Admins zugänglichen Kanal weiterleiten kannst. Leer bedeutet, dass nichts gepostet wird. |
| `Command` | string | `""` | Ein Server-Konsolenbefehl, der gegen den Übeltäter ausgeführt wird, wenn der Schwellenwert erreicht ist — zum Beispiel `banplayer {steamid}` oder `kickplayer {steamid}`. Leer bedeutet, dass kein Befehl ausgeführt wird. |
| `ClearInventory` | boolean | `false` | Leert das Inventar des Übeltäters als Teil der Bestrafung. |
| `After.Min` | number | `1` | Untergrenze des Erkennungsschwellenwerts. |
| `After.Max` | number | `1` | Obergrenze des Erkennungsschwellenwerts. |

#### Der `After`-Schwellenwert

`Min` und `Max` begrenzen, wie viele Erkennungen ein Spieler ansammeln darf,
bevor die Bestrafung ausgelöst wird. Wenn du ihnen **unterschiedliche** Werte
gibst, bleibt der genaue Schwellenwert unvorhersehbar, was die empfohlene
Einstellung ist — eine feste, bekannte Zahl ist etwas, das ein Übeltäter
umgehen kann.

- `"Min": 1, "Max": 1` — bestraft bei der ersten Erkennung (Standard).
- `"Min": 2, "Max": 5` — bestraft irgendwo in diesem Bereich.

Die Werte werden beim Laden auf ihren Bereich geprüft, sodass du versehentlich
keinen Schwellenwert konfigurieren kannst, der nie auslöst.

> 💡 **Beginne nur mit Berichterstattung.** Lasse `Command` für die ersten
> Tage leer und `ClearInventory` auf false, beobachte, was in
> `AlertWebhook` landet, und entscheide erst dann, wie eine Bestrafung
> aussehen soll.

## Webhooks

Beide Webhook-Felder müssen **Discord-Webhook-URLs** sein. Diese Präfixe
werden akzeptiert:

```
https://discord.com/api/webhooks/...
https://discordapp.com/api/webhooks/...
https://ptb.discord.com/api/webhooks/...
https://canary.discord.com/api/webhooks/...
```

Alles andere — einschließlich eines leeren Strings — wird verworfen, mit
einer entsprechenden Zeile im Plugin-Log. Ein leerer Webhook ist niemals ein
Fehler; er bedeutet lediglich „nichts senden".

> 🔒 **Eine Webhook-URL ist ein Berechtigungsnachweis.** Jeder, der sie
> besitzt, kann in deinem Kanal posten. Halte die `config.json` von
> öffentlichen Repositories und Screenshots fern.

## Vollständiges Beispiel

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  },
  "DupeDetection": {
    "AlertWebhook": "https://discord.com/api/webhooks/...",
    "Punishment": {
      "PunishmentWebhook": "https://discord.com/api/webhooks/...",
      "Command": "banplayer {steamid}",
      "ClearInventory": true,
      "After": {
        "Min": 2,
        "Max": 4
      }
    }
  }
}
```

---

**Nächste Schritte:**

- [Übersicht](index.md) — was das Plugin abdeckt, Installation und Befehle.
- [Gemeinsame Konfiguration](../index.md#common-configuration) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
