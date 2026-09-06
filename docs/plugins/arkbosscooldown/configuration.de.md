# Konfiguration

ArkBossCooldown wird über eine einzelne `config.json` im Plugin-Ordner
konfiguriert:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ArkBossCooldown/config.json
```

Eine zweite Datei, `config_commented.json`, wird mitgeliefert. Sie enthält
**dieselbe Konfiguration mit `//`-Kommentaren** — lies sie, aber benenne sie
nicht in `config.json` um (Kommentare sind kein gültiges JSON).

Die Schlüssel `LicenseKey`, `Verbose`, `LogToFile` und `Database` werden von
jedem Bytemart-Plugin gemeinsam genutzt und sind auf der Seite
**[Gemeinsame Konfiguration](../index.md#common-configuration)** dokumentiert. Diese Seite
behandelt die Schlüssel, die für ArkBossCooldown spezifisch sind.

> 💡 **Vor dem Start validieren.** Validiere dein JSON nach jeder Änderung
> stets (z. B. mit [JSONLint](https://jsonlint.com/)). Ein Ladefehler mit dem
> Code `1114` bedeutet einen JSON-Syntaxfehler — im langen `Bosses`-Array
> leicht verursacht.

## `TestMode`

```json
"TestMode": false
```

Wenn `true`, protokolliert das Plugin den **Blueprint-Pfad jedes Items, das
ein Spieler craftet**, in der Serverkonsole. So findest du den genauen Pfad
eines Tribut-Items, um ihn in [`Bosses`](#bosses) einzutragen:

1. Setze `TestMode` auf `true` und lade neu (`ArkBossCooldown.reload`).
2. Crafte das Tribut, das du sperren möchtest.
3. Kopiere den Pfad aus der Konsolenzeile — sie sieht so aus:
   `[TestMode] Crafted item blueprint: Blueprint'/Game/...'`.
4. Füge ihn in `Bosses` ein, setze `TestMode` wieder auf `false`, und lade
   erneut neu.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `TestMode` | boolean | `false` | Protokolliert den Blueprint-Pfad jedes gecrafteten Items. |

> ⚠️ **Schalte es wieder aus.** Mit aktivem `TestMode` schreibt ein
> ausgelasteter Server eine Konsolenzeile für *jedes Craften jedes
> Spielers*. Es ist ein Nachschlage-Werkzeug, keine Einstellung, die
> dauerhaft aktiviert bleiben sollte.

## `BossStartCooldown`

```json
"BossStartCooldown": 5
```

Wie viele **Sekunden** der gesamte Server zwischen zwei Boss-Starts warten
muss. Das erste Craften eines Tributs aktiviert die Abklingzeit; jedes
weitere Craften eines Tributs wird verweigert, bis sie abgelaufen ist.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `BossStartCooldown` | number | `5` | Sekunden zwischen Boss-Starts, serverweit. |

Der Standardwert `5` ist ein **Entprellen** — er fängt eine Serie von
Spam-Klicks ab und ist im normalen Spielbetrieb unsichtbar. Größere Werte
verwandeln das Plugin in eine echte Ratenbegrenzung, was funktioniert, aber
beachte zwei Dinge:

- **Sie gilt serverweit.** Eine 30-minütige Abklingzeit bedeutet, dass ein
  Stamm, der einen Boss startet, jeden anderen Stamm für 30 Minuten
  blockiert. Das ist eine Design-Entscheidung für deinen Server, kein Bug.
- **Sie übersteht keinen Neustart.** Die aktivierte Abklingzeit lebt im
  Arbeitsspeicher, sodass ein Server-Neustart (oder ein Entladen/Laden des
  Plugins) sie löscht. Bei ein paar Sekunden unerheblich; wichtig zu
  wissen, wenn du sie auf Stunden setzt.

`ArkBossCooldown.reload` übernimmt einen neuen Wert sofort, lässt aber eine
bereits aktivierte Abklingzeit absichtlich weiterlaufen.

## `CooldownMessage`

```json
"CooldownMessage": {
  "Enabled": true,
  "Channel": "Notification",
  "Message": "Boss is on cooldown, please wait %delay%.",
  "Color": { "R": 255, "G": 0, "B": 0, "A": 255 },
  "Scale": 1.0,
  "Time": 5.0
}
```

Was der abgewiesene Spieler sieht. Nur dieser Spieler wird benachrichtigt —
es wird nichts an den Rest des Servers gesendet.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Auf `false` setzen, um den Boss-Start stillschweigend zu verweigern. |
| `Channel` | string | `"Notification"` | `"Chat"`, `"Notification"` oder `"Broadcast"`. Ein nicht erkannter Wert fällt auf `"Chat"` zurück. |
| `Message` | string | siehe oben | Der Text. Unterstützt die untenstehenden Platzhalter. |
| `Color` | object | rot | `R`, `G`, `B`, `A`, jeweils `0`–`255`. `A` ist die Deckkraft. |
| `Scale` | number | `1.0` | Textgröße. **Nur beim Kanal `Notification`** — wird bei den anderen ignoriert. |
| `Time` | number | `5.0` | Sekunden, die die Nachricht auf dem Bildschirm bleibt. **Nur bei `Notification` und `Broadcast`** — eine Chat-Zeile bleibt unabhängig davon im Chat-Log. |

### Platzhalter

| Platzhalter | Wird zu | Beispiel |
| ----------- | ---------- | ------- |
| `%delay%` | Die verbleibende Zeit, ausgeschrieben | `1 Minute, 5 Seconds` |
| `%seconds%` | Die verbleibende Zeit als einfache Anzahl von Sekunden | `65` |

Verwende `%delay%` für eine Nachricht, die Spieler lesen, und `%seconds%`,
wenn du etwas Kompakteres möchtest:

```json
"Message": "Boss on cooldown - %seconds%s remaining."
```

> 💡 **`Notification` akzeptiert außerdem ein `Icon`.** Füge einen
> `"Icon"`-Schlüssel mit einem Texturpfad hinzu, um ein Bild neben der
> Benachrichtigung anzuzeigen. Er ist nicht in der mitgelieferten
> Konfiguration enthalten; füge ihn selbst hinzu, wenn du einen möchtest —
> die Konfigurationsreparatur *fügt* fehlende Schlüssel nur hinzu, so
> übersteht er Updates.

## `Bosses`

```json
"Bosses": [
  "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'",
  "Blueprint'/Game/Fjordur/Boss/Arena/PrimalItem_BossTribute_FenrirBoss_Hard.PrimalItem_BossTribute_FenrirBoss_Hard'"
]
```

Die Blueprint-Pfade jedes Tribut-Items, das die Abklingzeit aktiviert.
**Alles, was nicht in dieser Liste steht, wird ganz normal gecraftet** —
das Plugin ignoriert es.

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Bosses` | array of strings | Vollständige Blueprint-Pfade, einschließlich der `Blueprint'...'`-Umschließung und des doppelten Asset-Namens nach dem letzten `.`. Wird exakt abgeglichen. |

Die mitgelieferte Liste deckt die Tribut-Items für **The Island**, **The
Center**, **Scorched Earth**, **Ragnarok**, **Aberration**, **Valguero**,
**Fjordur**, **Lost Island** und **Crystal Isles** ab, für jede
Schwierigkeitsstufe.

Um etwas anderes zu sperren — eine andere Karte, eine modifizierte Arena
oder ein individuelles Tribut — verwende [`TestMode`](#testmode), um den
Pfad zu erfassen, und füge ihn hier hinzu. Um die Sperrung eines Bosses zu
*beenden*, lösche seine Zeile.

> ⚠️ **Kopiere Pfade exakt.** Der Abgleich erfolgt byte-genau auf dem
> vollständigen Pfad. Ein fehlendes abschließendes `'`, ein verkürzter Pfad
> oder ein nur einmal statt zweimal eingetragener Asset-Name bedeuten alle
> „keine Übereinstimmung", und das Tribut wird ohne jede Abklingzeit
> gecraftet. Es gibt keinen Fehler für einen nicht erkannten Pfad, also
> prüfe deine Änderung mit einem echten Craft.

## Vollständiges Beispiel

Ein 15-Minuten-Limit, im Chat angekündigt:

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "TestMode": false,
  "BossStartCooldown": 900,
  "CooldownMessage": {
    "Enabled": true,
    "Channel": "Chat",
    "Message": "A boss fight has already started. Next one available in %delay%.",
    "Color": { "R": 255, "G": 180, "B": 0, "A": 255 },
    "Scale": 1.0,
    "Time": 8.0
  },
  "Bosses": [
    "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'"
  ],
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  }
}
```

> ℹ️ **`Database` ist erforderlich, wird aber nicht genutzt.**
> ArkBossCooldown verbindet sich beim Start wie jedes Bytemart-Plugin,
> speichert aber nichts Eigenes. Richte es auf eine beliebige Datenbank, die
> der Server erreichen kann.

---

**Nächste Schritte:**

- [Übersicht](index.md) — was das Plugin tut, Installation und Befehle.
- [Gemeinsame Konfiguration](../index.md#common-configuration) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
