# Konfiguration

ssAntiCheat wird über eine einzelne `config.json` im Plugin-Ordner
konfiguriert:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ssAntiCheat/config.json
```

Eine zweite Datei, `config_commented.json`, wird mitgeliefert. Sie enthält
**dieselbe Konfiguration mit `//`-Kommentaren** — lies sie, aber benenne sie
nicht in `config.json` um (Kommentare sind kein gültiges JSON).

Die Schlüssel `LicenseKey`, `Verbose`, `LogToFile` und `Database` werden von
jedem Bytemart-Plugin gemeinsam genutzt und sind auf der Seite
**[Gemeinsame Konfiguration](../index.md#common-configuration)** dokumentiert. Diese Seite
behandelt nur die Schlüssel, die für ssAntiCheat spezifisch sind.

> 💡 **Vor dem Start validieren.** Validiere dein JSON nach jeder Änderung
> stets (z. B. mit [JSONLint](https://jsonlint.com/)). Ein Ladefehler mit dem
> Code `1114` bedeutet einen JSON-Syntaxfehler.

> ⚠️ **Schlüsselnamen sind entscheidend — kopiere sie exakt.** Mehrere
> Schlüssel enthalten Leerzeichen (`"Join Tracker"`, `"SaveWorld Cycles"`,
> `"Block Dedi Fill"`), und einige tragen eine historische Falschschreibung
> (`Threshole`, `additionnalData`). Sie werden byte-genau abgeglichen. Eine
> „korrigierte" Schreibweise deaktiviert die Funktion stillschweigend.

## Selbstreparierende Konfiguration

Bei jedem Laden vergleicht ssAntiCheat deine `config.json` mit dem Schema, mit
dem es gebaut wurde:

- **Fehlende Schlüssel** werden mit ihren Standardwerten ergänzt, und die
  Konsole gibt genau aus, was hinzugefügt wurde. Deine Originaldatei wird
  vorher nach `config.json.bak` kopiert.
- **Typkonflikte** (z. B. eine Zeichenkette, wo eine Zahl erwartet wird)
  **brechen das Laden ab** mit einem Fehler, der den Schlüssel benennt — das
  Plugin läuft nicht mit einer Konfiguration, der es nicht vertrauen kann.

Das bedeutet, dass ein Update, das neue Schlüssel einführt, deinen Server
nicht beschädigt, und du kannst deine Konfiguration jederzeit auf nur die
Schlüssel reduzieren, die dir wichtig sind.

---

## Grundlegende Schlüssel {#top-level-keys}

```json
"Debug": false,
"Use Discord": true,
"UseDiscordURL": true,
"SteamAPIKey": "",
"CommandPrefix": "!",
"Send Alert to Ingame Admins when someone is detected using a cheat": true
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Debug` | boolean | `false` | Interne Debug-Kennzeichnung. Lasse sie auf `false` — verwende [`Verbose`](../index.md#verbose) für Diagnoseausgaben. |
| `Use Discord` | boolean | `true` | Hauptschalter für Discord-Benachrichtigungen. Wenn `false`, werden nirgendwo Erkennungs- oder Ban-Embeds gepostet. |
| `UseDiscordURL` | boolean | `true` | Ob Discord-Embeds die ssAntiCheat-Symbol-/Vorschaubilder enthalten. Rein kosmetisch. |
| `SteamAPIKey` | string | `""` | Ein [Steam-Web-API-Schlüssel](https://steamcommunity.com/dev/apikey). Nur für das Verbindungs-Gate erforderlich (Spielzeit-/Kontoalter-/VAC-Prüfungen). Leer lassen, wenn du es nicht nutzt. |
| `CommandPrefix` | string | `"!"` | Das Präfix für die In-Game-Admin-Chatbefehle. Siehe [Befehle](commands.md#chat-commands). |
| `Send Alert to Ingame Admins when someone is detected using a cheat` | boolean | `true` | Sendet eine farbige Erkennungsmeldung an jeden online befindlichen Admin. |

## Webhooks {#webhooks}

```json
"DefaultWebhookUrl": "",
"BanWebhookUrl": "",
"AssociationBans": "",
"AdminTrollingWebhook": ""
```

Alle vier sind Discord-Webhook-URLs und werden allesamt **leer** ausgeliefert.
Ein leerer Webhook bedeutet „nichts senden" — das ist niemals ein Fehler.

| Feld | Beschreibung |
| ----- | ----------- |
| `DefaultWebhookUrl` | Wohin Erkennungen gehen, wenn das Modul keinen eigenen Webhook hat. Dieser sollte zuerst ausgefüllt werden. |
| `BanWebhookUrl` | Wohin **Ban**-Benachrichtigungen gehen. Fällt bei Leere auf `DefaultWebhookUrl` zurück. |
| `AssociationBans` | Wohin Bans wegen **IP-Zuordnung** gehen — d. h. wenn ein neuer Account beim Verbinden von der IP eines gebannten Spielers erwischt wird. Siehe [Bans & Erkennungen](bans.md#ip-association-bans). |
| `AdminTrollingWebhook` | Prüfprotokoll für die In-Game-Admin-Chatbefehle: wer hat was, an wem und wo ausgeführt. |

Jedes einzelne Modul kann außerdem einen eigenen `WebhookUrl`-Schlüssel
besitzen, der `DefaultWebhookUrl` nur für dieses Modul überschreibt.

> 🔒 **Eine Webhook-URL ist ein Berechtigungsnachweis.** Jeder, der sie
> besitzt, kann in deinem Kanal posten. Halte die `config.json` von
> öffentlichen Repositories und Screenshots fern.

## `Dashboard`

```json
"Dashboard": {
  "Enabled": false,
  "LivePositions": false
}
```

Opt-in-Telemetrie an das ssAnticheat-Dashboard: ein Live-Feed für Erkennungen
und Bans, eine Ban-Historie und grundlegender Serverstatus. **Beide Schlüssel
sind standardmäßig `false`** — nichts verlässt deinen Server, bevor du sie
aktivierst.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `false` | Hauptschalter für die Dashboard-Telemetrie. |
| `LivePositions` | boolean | `false` | Sendet zusätzlich Spielerpositionen, damit das Dashboard eine Live-Karte zeichnen kann. Das ist praktisch eine Live-Ansicht davon, wo sich jeder Spieler befindet — lasse es deaktiviert, sofern du das nicht willst. |

Verwende [`ssac.status`](commands.md#ssacstatus), um zu prüfen, ob tatsächlich
Telemetrie übertragen wird, und
[`ssac.testdetection`](commands.md#ssactestdetection), um eine simulierte
Erkennung durch die Pipeline zu schicken.

## `Join Tracker`

```json
"Join Tracker": {
  "Enabled": true,
  "Include IP": true,
  "JoinLogs": ""
}
```

Postet bei jedem Spielerbeitritt ein Discord-Embed mit Name, Steam-ID, Stamm
und Spawn-Ort.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Schaltet die Join-Protokollierung ein oder aus. |
| `Include IP` | boolean | `true` | Bezieht die verbindende IP-Adresse in das Embed mit ein. |
| `JoinLogs` | string | `""` | Webhook-URL für Join-Logs. Leer bedeutet, dass Join-Logs gesammelt, aber nicht gepostet werden. |

> ⚠️ **IP-Adressen sind personenbezogene Daten.** Wenn du `Include IP`
> aktivierst, sende Join-Logs an einen privaten, nur für Admins zugänglichen
> Kanal, und prüfe vorher, was deine lokalen Vorschriften von dir verlangen,
> bevor du sie aufbewahrst.

## `Admin ESP`

Einstellungen für das In-Game-Admin-ESP-Overlay, das pro Admin mit der
[`!esp`-Familie](commands.md#chat-commands) von Chatbefehlen umgeschaltet
wird.

```json
"Admin ESP": {
  "Enabled": true,
  "RefreshTime": 0.1,
  "Range": 30000,
  "Structure ESP": ["Box"]
}
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Reserviert. Der Zugriff auf die ESP-Befehle wird durch den ARK-Admin-Status geregelt, nicht durch diesen Schlüssel. |
| `RefreshTime` | number | `0.1` | Wie lange jedes gezeichnete Label/jede Box bestehen bleibt, in Sekunden. Niedriger = flüssiger, mehr Client-Zeichenaufrufe. |
| `Range` | number | `30000` | Scan-Radius (Unreal-Einheiten) um den Admin. |
| `Structure ESP` | array | `["Box"]` | Teilzeichenketten von Struktur-Blueprint-Namen, die hervorgehoben werden, wenn Struktur-ESP aktiv ist. `"Box"` erfasst Lagerkisten; füge z. B. `"Vault"` oder `"Turret"` hinzu. |

## `ServerCrash`

```json
"ServerCrash": {
  "SaveWorld": true,
  "AutomaticRestart": true
}
```

Was zu tun ist, wenn der Serverprozess abstürzt.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `SaveWorld` | boolean | `true` | Versucht einen Weltspeichervorgang aus dem Crash-Handler heraus, sodass ein Absturz Minuten statt das gesamte Speicherintervall kostet. |
| `AutomaticRestart` | boolean | `true` | Startet den Server nach einer kurzen Verzögerung automatisch neu. Schalte dies **aus**, wenn dein Server-Manager (ASM, ArkServerManager, ein Service-Wrapper, …) beim Beenden bereits neu startet — sonst laufen zwei Neustarts gegeneinander. |

## `Fixes`

Fixes für bekannte Server-Glitches und Exploit-Methoden. Das sind keine
Detektoren — niemand wird dadurch gemeldet oder gebannt; das fehlerhafte
Verhalten wird einfach verhindert.

```json
"Fixes": {
  "Scout Glitch Fix":         { "Enabled": true },
  "Handcuff Glitch Fix":      { "Enabled": false },
  "Player Already Connected": { "Enabled": true },
  "Pull Fix":                 { "Enabled": true },
  "Lag Protector":            { "Enabled": true },
  "Dupe Fix":                 { "Enabled": true }
}
```

| Fix | Standard | Was er bewirkt |
| --- | ------- | ------------ |
| `Scout Glitch Fix` | `true` | Korrigiert das Trageverhalten des Scouts und schließt den bekannten Scout-Glitch. |
| `Handcuff Glitch Fix` | `false` | Legt einem Spieler, der sich nach dem Ausloggen in Handschellen wieder einloggt, die Handschellen erneut an — schließt den Trick „Ausloggen, um den Handschellen zu entkommen". Standardmäßig deaktiviert; aktiviere ihn, wenn Handschellen Teil der Arbeitsweise deiner Admins oder Spieler sind. |
| `Player Already Connected` | `true` | Löscht die feststeckende Sitzung, die den Fehler „player already connected" verursacht, sodass Spieler nicht warten müssen, bis er von selbst verschwindet. |
| `Pull Fix` | `true` | Blockiert den Structures-Plus-**Server-Pull**-Exploit, bei dem ein Pull genutzt wird, um eingeschränkte Items (Boss-Tribute und Ähnliches) massenhaft aus einem Container zu ziehen. Der Spieler erhält die Meldung „You can't pull this craft". |
| `Lag Protector` | `true` | Anti-Griefing-Schutz gegen absichtliche Server-Lag-Tricks. **Benötigt zusätzliche Schlüssel — siehe unten.** |
| `Dupe Fix` | `true` | Zerstört duplizierte S+-Todes-Item-Caches: Ein zweiter Todes-Cache, der über einem bestehenden spawnt, wird entfernt, anstatt dessen Inhalt zu verdoppeln. |

Jeder Fix hat eine `Enabled`-Kennzeichnung. `Lag Protector` hat drei weitere.

### Lag Protector

`Lag Protector` wird nur mit `Enabled` ausgeliefert, und jeder seiner
Schutzmechanismen ist **opt-in** — füge die Schlüssel selbst hinzu, um sie
einzuschalten:

```json
"Lag Protector": {
  "Enabled": true,
  "WhipProtection": true,
  "BlueprintProtection": true,
  "LagWebhook": ""
}
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `WhipProtection` | boolean | `false` | Kickt einen Spieler, der eine Waffe innerhalb eines mit genügend Strukturen vollgepackten Bereichs abfeuert, um den Server zum Laggen zu bringen — das klassische „Whip in einer Mega-Base"-Griefing. |
| `BlueprintProtection` | boolean | `false` | Kickt einen Spieler, der innerhalb weniger Sekunden eine unplausible Flut von Blueprint-Craftings in die Warteschlange stellt. |
| `LagWebhook` | string | `""` | Webhook für Lag-Schutz-Kicks. Sendet bei Leere nichts. |

Kicks durch diesen Fix tragen absichtlich einen nichtssagenden Grundcode,
damit ein Griefer nichts daraus lernt: `0x7E3` steht für den Whip-Schutz,
`0x4DE` für den Blueprint-Schutz.

> ℹ️ **Selbst hinzugefügte Schlüssel bleiben erhalten.** Die
> Selbstreparatur der Konfiguration *fügt* fehlende Schlüssel nur hinzu — sie
> löscht niemals Schlüssel, die sie nicht erkennt, sodass die drei oben
> Plugin-Updates überstehen.

## `IntegratedBanSystem` und `AutoBan`

Diese beiden Abschnitte steuern die Ban-Pipeline und werden vollständig auf
der Seite **[Bans & Erkennungen](bans.md)** dokumentiert:

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
},
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

> ⚠️ **Ändere die URL in `BanMessage`.** Sie wird mit einem
> `example.com`-Platzhalter ausgeliefert. Verweise stattdessen auf deinen
> eigenen Store oder deine Einspruchsseite.

---

## `Modules`

Jeder Detektor befindet sich unter `Modules`, in einer von vier Kategorien:

| Kategorie | Was sie abdeckt |
| -------- | -------------- |
| `CombatCheats` | Cheats während des Kampfes — Zielhilfen, Manipulation von Feuerrate und Munition, Verbrauchsgüter-Automatisierung. |
| `MiscCheats` | Client-Automatisierung und clientseitige Werkzeuge — Auto-Loot, Auto-Craft, Spoofer, Timing-Anomalien, sowie das Verbindungs-Gate. |
| `Mod` | Prüfungen, die die optionale begleitende Client-Mod erfordern (einschließlich Hardware-ID-Erfassung und Mod-Bypass-Erkennung). Wirkungslos, solange diese Mod nicht bereitgestellt ist — frage im [Bytemart-Discord](https://bytemart.net/discord), wenn du sie haben möchtest. |
| `Exploits` | Bekannte Spiel- und Mod-Exploits: Duplizierungsmethoden, Crash-Vektoren, Unlocker, Missbrauch von Reittieren und Strukturen, Admin-Schutz und mehr. |

Die Struktur ist immer gleich:

```json
"Modules": {
  "CombatCheats": {
    "Enabled": true,
    "SubModules": {
      "AutoFlak":   { "Enabled": true, "Block": true, "TimesUntilDetect": 6 },
      "NoOverheat": { "Enabled": true, "Block": true, "BanAfterDetections": 2 },
      "...":        { "...": "..." }
    }
  },
  "MiscCheats": { "Enabled": true, "SubModules": { "...": "..." } },
  "Mod":        { "Enabled": true, "SubModules": { "...": "..." } },
  "Exploits":   { "Enabled": true, "SubModules": { "...": "..." } }
}
```

Das `Enabled: false` einer Kategorie schaltet **jedes** Modul darin ab,
unabhängig davon, was die einzelnen Kennzeichnungen sagen. Deine
mitgelieferte `config.json` enthält die vollständige Liste der Submodule mit
sinnvollen Standardwerten — die Referenz unten erklärt die Schlüssel, die du
bei ihnen findest.

### Gemeinsame Submodul-Schlüssel {#common-submodule-keys}

| Feld | Typ | Beschreibung |
| --- | ---- | ------- |
| `Enabled` | boolean | Schaltet diesen bestimmten Detektor ein oder aus. |
| `Block` | boolean | Verhindert die betrogene Aktion zusätzlich zur Meldung. Wenn `false`, wird die Aktion durchgeführt und du erhältst nur die Benachrichtigung — nützlich, während du Vertrauen in ein Modul auf deinem eigenen Server aufbaust. |
| `BanAfterDetections` | number | Reiht den Spieler nach so vielen Erkennungen **durch dieses Modul** für einen Ban ein. Fehlt der Wert oder ist er `0`, bannt dieses Modul nie von selbst. |
| `InstantBan` | boolean | Führt diesen Ban sofort aus, statt auf die nächste Ban-Welle zu warten. |
| `OnlyAnalysis` | boolean | Erkennt und protokolliert, postet aber nicht an deinen Discord-Webhook. Ein stiller Modus zum Bewerten eines Moduls. |
| `WebhookUrl` | string | Sendet die Benachrichtigungen dieses Moduls an einen bestimmten Webhook anstelle von `DefaultWebhookUrl`. |
| `Threshole` / `*Threshold` | number | Die Empfindlichkeit des Moduls. Höher = mehr Beweise erforderlich, bevor es auslöst. Die Schreibweise `Threshole` ist bei den Schlüsseln, die sie verwenden, beabsichtigt. |
| `BlockMovement` | boolean | Wird von einigen Unlocker-Modulen verwendet: friert den Übeltäter an Ort und Stelle ein, anstatt ihn nur zu melden. |

Einige Module fügen eigene Schlüssel hinzu — zum Beispiel eine Liste von
Blueprint-Namen, die von einer Prüfung ausgeschlossen werden sollen, oder eine
zusätzliche Unter-Kennzeichnung für eine bestimmte Variante des Exploits.
Diese werden in der `config_commented.json` beschrieben, wo sie nicht
selbsterklärend sind.

> 💡 **Tipp zur Feinabstimmung.** Beginne mit den mitgelieferten
> Standardwerten. Wenn ein Modul auf deinem Setup Fehlalarme erzeugt, erhöhe
> bevorzugt seinen Schwellenwert oder sein `BanAfterDetections`, anstatt es
> komplett zu deaktivieren — und setze `OnlyAnalysis`, während du es
> beobachtest.

### Das Verbindungs-Gate

Ein Modul in `MiscCheats` verdient besondere Erwähnung, weil es externe
Einrichtung benötigt: Der **Session-Tracker** prüft einen beitretenden
Spieler gegen die Steam-Web-API und kann Accounts ablehnen, die wie
Wegwerf-Accounts wirken.

```json
"SessionTracker": {
  "Enabled": true,
  "WebhookUrl": "",
  "Checks": {
    "AccountRestrictions": {
      "MinGameHours": 30,
      "BlockMinGameHours": false,
      "LogMinGameHours": true,
      "MinAccountAgeDays": 30,
      "BlockMinAccountAgeDays": false,
      "LogMinAccountAgeDays": true
    },
    "VacBanRestrictions": {
      "Block": false,
      "RecentDaysThreshole": 90,
      "Log": true
    }
  }
}
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `WebhookUrl` | string | `""` | Webhook für die Ergebnisse des Gates. Fällt auf `DefaultWebhookUrl` zurück. |
| `MinGameHours` | number | `30` | Mindestspielzeit in ARK, in Stunden. |
| `BlockMinGameHours` | boolean | `false` | Kickt Spieler unterhalb dieser Spielzeit. |
| `LogMinGameHours` | boolean | `true` | Meldet Spieler unterhalb dieser Spielzeit. |
| `MinAccountAgeDays` | number | `30` | Mindestalter des Steam-Accounts, in Tagen. |
| `BlockMinAccountAgeDays` | boolean | `false` | Kickt Accounts, die jünger sind. |
| `LogMinAccountAgeDays` | boolean | `true` | Meldet Accounts, die jünger sind. |
| `VacBanRestrictions.RecentDaysThreshole` | number | `90` | Wie kürzlich ein VAC-Ban sein muss, um zu zählen. |
| `VacBanRestrictions.Block` | boolean | `false` | Kickt Spieler mit einem kürzlichen VAC-Ban. |
| `VacBanRestrictions.Log` | boolean | `true` | Meldet Spieler mit einem kürzlichen VAC-Ban. |

> ℹ️ **Erfordert `SteamAPIKey`.** Ohne einen Schlüssel können diese Prüfungen
> nicht laufen. Beachte außerdem, dass ein Spieler mit einem **privaten**
> Steam-Profil seine Spielzeit verbirgt — entscheide bewusst, ob du `Block*`
> aktivieren willst, da es auch einige legitime Spieler abweisen wird.

---

**Nächste Schritte:**

- [Befehle](commands.md) — Konsolen-/RCON- und In-Game-Admin-Befehle.
- [Bans & Erkennungen](bans.md) — Schwellenwerte, Ban-Wellen, IP-/HWID-Bans, Entbannen.
- [Gemeinsame Konfiguration](../index.md#common-configuration) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
