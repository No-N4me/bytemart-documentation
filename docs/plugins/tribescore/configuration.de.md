# Konfiguration

Tribescore wird über **drei** Dateien im Plugin-Ordner konfiguriert
(`ShooterGame/Binaries/Win64/ArkApi/Plugins/Tribescore/`):

| Datei | Zweck |
| ---- | ------- |
| `config.json` | Haupteinstellungen: Lizenz, Datenbank, Aktivierung, Berechtigung, Punkte-Modifikatoren, Hologramme und Chatbefehle. |
| `structures.json` | Punktwerte für Strukturen, nach Baustufe und pro Blueprint. |
| `dinos.json` | Punktwerte und Zählregeln für Dinos, pro Spezies. |

> 💡 **Vor dem Start validieren.** Validiere dein JSON nach jeder Änderung stets (z. B.
> mit [JSONLint](https://jsonlint.com/)). Ein Ladefehler mit dem Code `1114` bedeutet
> einen JSON-Syntaxfehler.

Die Schlüssel `LicenseKey`, `Verbose`, `LogToFile` und `Database` werden von jedem
Bytemart-Plugin gemeinsam genutzt und sind auf der Seite
**[Gemeinsame Konfiguration](../index.md)** dokumentiert. Diese Seite
behandelt nur die Schlüssel, die für Tribescore spezifisch sind.

---

## `config.json`

### `DebugMode`

```json
"DebugMode": false
```

Wenn `true`, wird die Konsole ausführlicher **und** du darfst Tribescore vom eigenen
Stamm verdienen — nützlich, um die Punktevergabe auf einem Entwicklungsserver zu testen.
Lasse diesen Wert auf einem Live-Server auf `false`.

### `TribescoreActivation`

Verzögert die Punktevergabe global nach einem Serverstart (Wipe), damit Stämme Zeit
haben, sich neu zu etablieren, bevor der Wettbewerb beginnt.

```json
"TribescoreActivation": {
  "Activation": {
    "Type": "delay",
    "Value": 7200
  },
  "Message": "Tribescore is globally enabled after 2 hours, please wait {cooldown}"
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Activation.Type` | string | `"delay"` — aktiviert die Punktevergabe `Value` Sekunden nach dem Serverstart. `"timestamp"` — aktiviert die Punktevergabe zu einem festen [Unix-Zeitstempel](https://www.unixtimestamp.com/). |
| `Activation.Value` | number | Verzögerung in Sekunden (bei `delay`) oder der Unix-Zeitstempel (bei `timestamp`). Setze auf `0`, um die Funktion zu deaktivieren und die Punktevergabe sofort zu aktivieren. |
| `Message` | string | Wird Spielern angezeigt, die die Punktevergabe auslösen, während sie noch in der Abklingzeit ist. Der Platzhalter `{cooldown}` wird durch die verbleibende Zeit ersetzt. |

### `TribescoreEligibility`

Steuert, welche Stämme abhängig von ihrer Mitgliederzahl Punkte verdienen können.

```json
"TribescoreEligibility": {
  "MinPlayers": 1,
  "MinOnlinePlayers": 0
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `MinPlayers` | number | Mindestanzahl an Mitgliedern (insgesamt), die ein Stamm haben muss, um Punkte zu verdienen. |
| `MinOnlinePlayers` | number | Mindestanzahl an Mitgliedern, die **online** sein müssen, damit der Stamm Punkte verdient. `0` deaktiviert diese Prüfung. |

### `Scoring`

Das Herzstück des Plugins. Basiswerte befinden sich hier (sowie in `structures.json` /
`dinos.json`); der Unterabschnitt `Modifiers` multipliziert sie.

```json
"Scoring": {
  "GainLossRatio": 0.75,
  "Structures": { "Enabled": true, "DefaultValue": 10.0 },
  "Dinos":      { "Enabled": true, "DefaultValue": 25.0 },
  "Players":    { "Enabled": true, "Value": 150.0 },
  "Modifiers": { "...": "..." }
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `GainLossRatio` | number | Wenn kein expliziter `LossOverride` gesetzt ist (in `structures.json` / `dinos.json`), beträgt der Punktverlust des **Verteidigers** `gain × GainLossRatio`. Bei `0.75` verliert ein Verteidiger 75 % dessen, was der Angreifer gewonnen hat. |
| `Structures.Enabled` | boolean | Aktiviert die Punktevergabe für zerstörte Strukturen. Werte werden in [`structures.json`](#structuresjson) konfiguriert. |
| `Structures.DefaultValue` | number | Punkte für eine Struktur ohne Übereinstimmung bei Stufe oder Blueprint. |
| `Dinos.Enabled` | boolean | Aktiviert die Punktevergabe für getötete Dinos. Werte werden in [`dinos.json`](#dinosjson) konfiguriert. |
| `Dinos.DefaultValue` | number | Punkte für einen Dino ohne speziesspezifische Überschreibung. |
| `Players.Enabled` | boolean | Aktiviert die Punktevergabe für getötete feindliche Spieler. |
| `Players.Value` | number | Feste Punkte, die pro getötetem feindlichen Spieler vergeben werden. |

#### `Modifiers.OfflineProtection`

Verringert (oder erhöht) die gegen einen Stamm verdienten Punkte, der bereits eine Weile
vollständig offline ist — um Offline-Raiding zu unterbinden.

```json
"OfflineProtection": {
  "Enabled": true,
  "ActivatesAfter": 3600,
  "Modifier": 0.75
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Schaltet die Funktion ein oder aus. |
| `ActivatesAfter` | number | Sekunden, die ein Stamm vollständig offline sein muss, bevor der Schutz greift. |
| `Modifier` | number | Multiplikator, der bei Aktivierung angewendet wird. `< 1` verringert den Gewinn des Angreifers (z. B. `0.75` = −25 %). |

*Wird basierend auf dem **Verteidiger** angewendet.*

#### `Modifiers.PermissionModifiers`

Erhöht (oder senkt) die Punkte basierend auf den ArkApi-**Berechtigungen** des Angreifers.
Erfordert das [Permissions](https://github.com/ServersHub/ServerAPI)-Plugin aus der
ArkServerAPI.

```json
"PermissionModifiers": {
  "Enabled": true,
  "TribePermissionsOnly": false,
  "OnlinePlayersOnly": true,
  "Modifiers": [
    { "Permission": "ts.boost.10", "Value": 1.1 },
    { "Permission": "ts.boost.15", "Value": 1.15 },
    { "Permission": "ts.boost.25", "Value": 1.25 }
  ]
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Schaltet die Funktion ein oder aus. |
| `TribePermissionsOnly` | boolean | Wenn `true`, werden nur Berechtigungen auf Stammesebene geprüft (individuelle Spielerberechtigungen werden ignoriert). |
| `OnlinePlayersOnly` | boolean | Wenn `true`, werden nur die Berechtigungen der aktuell online befindlichen Mitglieder berücksichtigt; andernfalls werden alle Mitglieder geprüft. |
| `Modifiers[]` | array | Paare aus Berechtigung → Multiplikator. **Es gilt jeweils nur ein Modifikator**; wenn mehrere zutreffen, wird der **größte** verwendet. |
| `Modifiers[].Permission` | string | Der Berechtigungsknoten, den der Spieler/Stamm besitzen muss. |
| `Modifiers[].Value` | number | Angewendeter Multiplikator (`> 1` erhöht den Gewinn). |

*Wird basierend auf dem **Angreifer** angewendet.*

#### `Modifiers.ScoreDifferenceRatio`

Balanciert starke gegen schwache Stämme. Das verglichene Verhältnis ist die Punktzahl des
**Verteidigers** geteilt durch die Punktzahl des **Angreifers**; der `Modifier` des
passenden Intervalls skaliert den Gewinn des Angreifers — so werden große Stämme, die
kleine abfarmen, geschwächt, und Außenseiter, die Giganten angreifen, gestärkt.

```json
"ScoreDifferenceRatio": {
  "Enabled": true,
  "Intervals": [
    { "UpperBound": -1,   "LowerBound": 2,    "Modifier": 1.2 },
    { "UpperBound": 2,    "LowerBound": 1.5,  "Modifier": 1.1 },
    { "UpperBound": 1.5,  "LowerBound": 1,    "Modifier": 1 },
    { "UpperBound": 1,    "LowerBound": 0.5,  "Modifier": 0.8 },
    { "UpperBound": 0.5,  "LowerBound": 0.25, "Modifier": 0.6 },
    { "UpperBound": 0.25, "LowerBound": 0,    "Modifier": 0.25 }
  ]
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Schaltet die Funktion ein oder aus. |
| `Intervals[]` | array | Bänder des Verhältnisses Verteidiger-/Angreiferpunktzahl, jeweils mit einem Multiplikator. |
| `LowerBound` / `UpperBound` | number | Das Verhältnisband, das dieser Modifikator abdeckt. Verwende `-1` als `UpperBound` des obersten Bandes, um „keine obere Grenze" auszudrücken. |
| `Modifier` | number | Multiplikator, der angewendet wird, wenn das Verhältnis in dieses Band fällt. |

**Die Standardwerte gelesen:**

- Verhältnis `≥ 2` (Verteidiger hat ≥ 2× die Punktzahl des Angreifers) → **1.2×**-Boost
  für den angreifenden Außenseiter.
- Verhältnis zwischen `1.5` und `2` → **1.1×**-Boost.
- Verhältnis zwischen `0.25` und `0.5` → **0.6×**-Abschwächung.
- Verhältnis `< 0.25` (Verteidiger hat weniger als ein Viertel der Punktzahl des
  Angreifers) → **0.25×** — eine harte Abschwächung beim Abfarmen deutlich schwächerer
  Stämme.

*Nutzt **sowohl** den Angreifer als auch den Verteidiger.*

### `Holograms`

Steuert die schwebenden Punktzahlen, die in der Spielwelt erscheinen, wenn sich die
Punkte ändern. `Damager` ist der `+points`-Text, der dem Angreifer angezeigt wird;
`Damagee` ist der `-points`-Text, der dem Verteidiger angezeigt wird.

```json
"Holograms": {
  "DecimalPrecision": 1,
  "LifeSpan": 6.0,
  "Scale":    { "X": 0.5, "Y": 0.5 },
  "FadeTime": { "In": 2.0, "Out": 3.0 },
  "Velocity": { "X": 0, "Y": 0, "Z": 10.0 },
  "Damager": { "Enabled": true, "Text": "+ {points} points", "Color": { "R": 0,   "G": 255, "B": 0 } },
  "Damagee": { "Enabled": true, "Text": "- {points} points", "Color": { "R": 255, "G": 0,   "B": 0 } }
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `DecimalPrecision` | number | Anzahl der Nachkommastellen, die im `{points}`-Wert angezeigt werden. |
| `LifeSpan` | number | Sekunden, die das Hologramm sichtbar bleibt. |
| `Scale.X` / `Scale.Y` | number | Textgröße auf der jeweiligen Achse. |
| `FadeTime.In` / `FadeTime.Out` | number | Ein- / Ausblenddauer in Sekunden. |
| `Velocity.X/Y/Z` | number | Driftgeschwindigkeit des Textes; der Standardwert lässt ihn nach oben schweben (`Z`). |
| `Damager` / `Damagee` | object | Die Gewinn- / Verlust-Einblendungen. `Enabled` schaltet jede einzeln ein oder aus; `Text` verwendet den Platzhalter `{points}`; `Color` ist RGB (0–255). |

Spieler können Hologramme für sich selbst mit dem Chatbefehl `/holograms` ein- oder
ausschalten (siehe [Befehle](commands.md)).

### `ChatCommands`

Aktiviert, benennt um und gestaltet die drei In-Game-Chatbefehle. Jeder hat einen
`Enabled`-Schalter und einen anpassbaren `Command`-Auslöser; das Deaktivieren eines
Befehls hebt seine Registrierung vollständig auf.

```json
"ChatCommands": {
  "Holograms":   { "Enabled": true, "Command": "/holograms", "On": { "...": "..." }, "Off": { "...": "..." } },
  "Leaderboard": { "Enabled": true, "Lines": 15, "Command": "/leaderboard", "Text": "#{rank} [{tribe}] : {score}", "PerRankColor": { "...": "..." } },
  "MyTribeRank": { "Enabled": true, "Command": "/triberank", "Text": "Your tribe ({tribe}) is ranked #{rank} with {score}" }
}
```

Gemeinsame Felder bei jedem Befehl: `TextSize` (number), `Color` (RGB `{R,G,B}`) und
`DisplayTime` (Sekunden, die die Nachricht auf dem Bildschirm bleibt).

**`Holograms`** — schaltet die spielerbezogene Hologrammanzeige um. `On` und `Off`
definieren jeweils die Bestätigungsnachricht (`Text`, `TextSize`, `Color`,
`DisplayTime`), die beim Umschalten angezeigt wird.

**`Leaderboard`** — gibt die besten Stämme aus.

| Feld | Beschreibung |
| ----- | ----------- |
| `Lines` | Wie viele Stämme aufgelistet werden. |
| `Text` | Zeilenformat. Platzhalter: `{rank}`, `{tribe}`, `{score}`. |
| `PerRankColor` | Optionale Farbüberschreibungen pro Platzierung, indexiert nach Rang (`"1"`, `"2"`, `"3"`, …), jeweils ein RGB-Objekt. |

**`MyTribeRank`** — gibt den Rang des eigenen Stammes des Aufrufers aus. `Text`
unterstützt dieselben Platzhalter `{rank}`, `{tribe}`, `{score}`.

### `Messages`

Reserviert für die Anpassung von Nachrichten; standardmäßig leer (`{}`).

---

## `structures.json`

Punktwerte für Strukturen, zuerst nach Bau**stufe** aufgelöst und dann durch spezifische
**Blueprints** überschrieben. Eine Struktur, die auf nichts passt, verwendet
`DefaultValue`.

```json
{
  "Tiers": {
    "Thatch": { "Value": 1.0,  "LossOverride": 0.5 },
    "Wood":   { "Value": 2.0,  "LossOverride": 1.25 },
    "Stone":  { "Value": 3.0,  "LossOverride": 2.0 },
    "Adobe":  { "Value": 5.0,  "LossOverride": 4.0 },
    "Metal":  { "Value": 10.0, "LossOverride": 7.0 },
    "Tek":    { "Value": 15.0, "LossOverride": 12.5 }
  },
  "DefaultValue": 10.0,
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Structures/Misc/PrimalItemStructure_HeavyTurret.PrimalItemStructure_HeavyTurret'",
      "Value": 25.0
    },
    {
      "BlueprintPath": "Blueprint'/Game/.../PrimalItemStructure_TurretTek.PrimalItemStructure_TurretTek'",
      "Value": 25.0,
      "LossOverride": 25.0
    }
  ]
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Tiers` | object | Werte pro Stufe, indexiert nach Baumaterial (`Thatch`, `Wood`, `Stone`, `Adobe`, `Metal`, `Tek`). |
| `Tiers.<tier>.Value` | number | Punkte, die der Angreifer für das Zerstören einer Struktur dieser Stufe gewinnt. |
| `Tiers.<tier>.LossOverride` | number | *(optional)* Feste Punkte, die der Verteidiger verliert. Wenn ausgelassen, wird `Value × GainLossRatio` verwendet. |
| `DefaultValue` | number | Ausweichwert, wenn eine Struktur auf keine Stufe oder keinen benutzerdefinierten Eintrag passt. |
| `Customs[]` | array | Überschreibungen pro Blueprint, die Vorrang vor dem Stufenwert haben. |
| `Customs[].BlueprintPath` | string | Vollständiger Blueprint-Pfad der Struktur. Verwende `ts.addstructure`, um die Struktur, die du gerade ansiehst, automatisch anzuhängen (siehe [Befehle](commands.md)). |
| `Customs[].Value` | number | Punkte für diesen spezifischen Blueprint. |
| `Customs[].LossOverride` | number | *(optional)* Fester Verlust für diesen Blueprint. |

---

## `dinos.json`

Punktwerte und Zählregeln pro Dino-Spezies. `Defaults` gilt für jeden Dino, der nicht in
`Customs` aufgeführt ist.

```json
{
  "Defaults": {
    "Value": 25.0,
    "LossOverride": 20.0,
    "CountBabies": true,
    "CountWithoutSaddle": true,
    "CountNotMounted": true,
    "ScoreFromWild": true
  },
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/Dinos/Giganotosaurus/Gigant_Character_BP.Gigant_Character_BP'",
      "Value": 50.0,
      "LossOverride": 45.0,
      "CountBabies": false
    }
  ]
}
```

| Feld | Typ | Beschreibung |
| ----- | ---- | ----------- |
| `Value` | number | Punkte, die der Angreifer für das Töten dieses Dinos gewinnt. |
| `LossOverride` | number | *(optional)* Feste Punkte, die der Verteidiger verliert. Wenn ausgelassen, wird `Value × GainLossRatio` verwendet. |
| `CountBabies` | boolean | Ob das Töten von Baby-/Jungdinos Punkte bringt. |
| `CountWithoutSaddle` | boolean | Ob ein gezähmtes Tier ohne Sattel Punkte bringt. |
| `CountNotMounted` | boolean | Ob ein Dino, der gerade nicht geritten wird, Punkte bringt. |
| `ScoreFromWild` | boolean | Ob das Töten eines **wilden** (ungezähmten) Dinos dieser Spezies Punkte bringt. |
| `Customs[].BlueprintPath` | string | Vollständiger Blueprint-Pfad der Spezies, auf die diese Überschreibung abzielt. |

Jeder `Customs`-Eintrag kann eine beliebige Teilmenge dieser Felder setzen; nicht
angegebene Felder greifen auf `Defaults` zurück.
