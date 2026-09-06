# Befehle

ssAntiCheat hat zwei Arten von Befehlen: **Konsolen-/RCON**-Befehle mit dem
Präfix `ssac.` und **In-Game-Chat**-Befehle mit dem Präfix `!` (konfigurierbar
über [`CommandPrefix`](configuration.md#top-level-keys)).

Konsolen- und RCON-Zugriff ist per Definition Admin-Zugriff, sodass
`ssac.`-Befehle keine zusätzliche Berechtigung benötigen. Die Chatbefehle
prüfen, ob du ein **Server-Admin** bist (`enablecheats`), und tun andernfalls
stillschweigend nichts.

## Konsolen- / RCON-Befehle

| Befehl | Kanäle | Beschreibung |
| ------- | -------- | ----------- |
| `ssac.help [page]` | Konsole, RCON | Paginierte Liste aller registrierten Befehle. |
| `ssac.status` | Konsole, RCON | Lizenz-, Server-ID- und Dashboard-Telemetriestatus. |
| `ssac.detections` | Konsole, RCON | Listet aktuelle Erkennungen, gruppiert nach Steam-ID. |
| `ssac.pendingbans` | Konsole, RCON | Listet Spieler, die für die nächste Ban-Welle eingereiht sind. |
| `ssac.banwave` | Konsole, RCON | Führt die ausstehende Ban-Welle sofort aus. |
| `ssac.clearbanwave` | Konsole, RCON | Verwirft alle ausstehenden Bans, ohne jemanden zu bannen. |
| `ssac.ban <steamid> [r=<reason>] [d=<duration>]` | Konsole, RCON | Bannt einen Spieler. |
| `ssac.unban <ban-id>` | Konsole, RCON | Hebt einen Ban anhand seiner Ban-ID auf. |
| `ssac.testdetection [steamid] [module]` | Konsole, RCON | Schickt eine simulierte Erkennung an das Dashboard. |
| `ssac.go [steamid]` | Konsole | Beobachtet einen Spieler — den angegebenen oder den zuletzt erkannten. |
| `ssac.command <reason> <command...>` | Konsole | Führt einen Konsolenbefehl als du selbst aus, protokolliert. |

`ssac.go` und `ssac.command` wirken auf *deinen* Charakter, daher
funktionieren sie nur über die In-Game-Konsole — hinter einer RCON-Sitzung
steht kein Spieler.

### `ssac.status`

Das Erste, was du nach der Installation ausführen solltest, und das Erste,
wonach der Support fragen wird. Es gibt die Plugin-Version aus, ob die Lizenz
authentifiziert wurde, die ID dieses Servers, die Karte und den Servernamen
sowie — wenn die Dashboard-Telemetrie aktiv ist — den Endpunkt, ob sich der
Server registriert hat, das letzte Sendeergebnis und die
Warteschlangentiefe.

```bash
ssac.status
```

Eine Warteschlangentiefe ungleich null, die nie abnimmt, bedeutet, dass der
Dashboard-Endpunkt nicht erreichbar ist oder deine Events ablehnt.

### `ssac.detections`

Listet die im Speicher gehaltenen Erkennungen (in etwa die **letzte
Stunde**), gruppiert nach Steam-ID, mit dem Modul, das jeweils ausgelöst hat.

```bash
ssac.detections
```

> ℹ️ **Erkennungen existieren nur im Arbeitsspeicher.** Sie überstehen keinen
> Server-Neustart. Bans dagegen schon — sie werden in MySQL gespeichert.
> Nutze deine Discord-Webhooks als dauerhafte Aufzeichnung der Erkennungen.

### `ssac.ban` / `ssac.unban`

```
ssac.ban <steamid> [r=<reason>] [d=<duration>]
ssac.unban <ban-id>
```

| Argument | Beschreibung |
| -------- | ----------- |
| `<steamid>` | Die SteamID64 des Ziels (17 Ziffern). |
| `r=<reason>` | Ban-Grund. In Anführungszeichen setzen, wenn er Leerzeichen enthält. Standardmäßig `No reason provided`. |
| `d=<duration>` | Ban-Dauer, zusammengesetzt aus `d`-/`h`-/`m`-/`s`-Teilen — z. B. `7d`, `12h30m`, `1d6h`. Weglassen für einen **dauerhaften** Ban. |

```bash
ssac.ban 76561198000000000 r="Aimbot" d=7d
ssac.ban 76561198000000000                  # dauerhaft, kein Grund
ssac.unban 42                               # hebt Ban #42 auf
```

Der Ban wird zusammen mit der IP des Spielers (und seiner Hardware-ID, falls
eine erfasst wurde) in MySQL geschrieben, und der Spieler wird, falls online,
sofort mit deiner [`BanMessage`](bans.md#ban-message) gekickt. `ssac.unban`
erwartet die **Ban-ID**, nicht die Steam-ID — sowohl `ssac.detections` als
auch das Discord-Ban-Embed zeigen sie an, und sie ist auch der
`{ban_id}`-Wert in der Kick-Nachricht, die der Spieler sieht.

### `ssac.banwave` / `ssac.clearbanwave` / `ssac.pendingbans`

```bash
ssac.pendingbans     # wer eingereiht ist, und warum
ssac.banwave         # alle sofort bannen
ssac.clearbanwave    # alle laufen lassen
```

Ausstehende Bans werden von Erkennungsmodulen eingereiht und normalerweise
nach einem Zeitplan ausgeführt — siehe
[Bans & Erkennungen](bans.md#ban-waves). Mit diesen drei Befehlen kannst du
die Warteschlange prüfen, sie vorzeitig ausführen oder eine Warteschlange
leeren, die du für einen Fehlalarm hältst.

### `ssac.go`

Versetzt dich in den Zuschauermodus und bewegt dich zu einem Spieler.

```bash
ssac.go                       # der zuletzt erkannte Spieler
ssac.go 76561198000000000     # ein bestimmter Spieler
```

Ohne Argument folgt es der letzten Erkennung, was genau das ist, was du beim
Reagieren auf eine Benachrichtigung willst. Mit einer Steam-ID zielt es auf
diesen Spieler und gibt den aufgelösten Namen aus, sodass du bestätigen
kannst, dass du die richtige Person erwischt hast.

### `ssac.command`

Führt einen Konsolenbefehl als du selbst aus und protokolliert, dass
ssAntiCheat ihn autorisiert hat, damit das Admin-Schutzmodul dich nicht dafür
meldet.

```
ssac.command <reason> <command...>
```

```bash
ssac.command investigating_dupe giveitemnum 1 1 0 0
```

Das erste Argument ist ein Freitext-Grund für das Prüfprotokoll; alles
danach ist der auszuführende Befehl.

### `ssac.testdetection`

Erzeugt eine **simulierte** Erkennung, damit du deine Dashboard-Pipeline
überprüfen kannst, ohne auf einen echten Cheater warten zu müssen. Dafür muss
[`Dashboard.Enabled`](configuration.md#dashboard) auf `true` stehen.

```
ssac.testdetection [steamid] [module]
```

```bash
ssac.testdetection                              # eine Erkennung für dich selbst (über die In-Game-Konsole)
ssac.testdetection 76561198000000000 AutoLoot   # für einen bestimmten Spieler, mit der Bezeichnung AutoLoot
```

Ohne Argumente über die In-Game-Konsole ausgeführt, zielt es auf **dich**,
sodass die Dashboard-Zeile einen echten Namen, Stamm und Position zeigt.
Test-Events werden als simuliert gekennzeichnet und aus den echten
Erkennungsstatistiken ausgeschlossen. Sie werden nicht an Discord gesendet
und bannen niemals jemanden.

---

## Chatbefehle {#chat-commands}

Werden im In-Game-Chat eingegeben, nur für Admins, mit dem Präfix
[`CommandPrefix`](configuration.md#top-level-keys) (standardmäßig `!`). Wo
ein Befehl `<steamid>` erwartet, kannst du sie weglassen — er wirkt dann auf
**denjenigen, den du gerade ansiehst**.

Die Namen werden exakt so abgeglichen, wie sie unten geschrieben sind,
einschließlich Groß-/Kleinschreibung.

### Untersuchung

| Befehl | Beschreibung |
| ------- | ----------- |
| `!esp` | Schaltet ESP für dich selbst ein oder aus. |
| `!espPlayers` | Schaltet Spieler-ESP ein oder aus: Name, Gesundheit und aktuelle Waffe über jedem Spieler. |
| `!EspStruct` | Schaltet Struktur-ESP ein oder aus. |
| `!espset <name>` | Hebt Strukturen hervor, deren Blueprint-Name `<name>` enthält, zusätzlich zur Liste [`Structure ESP`](configuration.md#admin-esp). |
| `!espHideEmpty` | Verbirgt leere Container im Struktur-ESP. |
| `!tracers` | Zeichnet jeden nahen Schuss als Leuchtspurlinie, eingefärbt danach, welchen Körperteil er getroffen hat. Das mit Abstand nützlichste Werkzeug, um Zielhilfe mit bloßem Auge zu beurteilen. |
| `!vanish` | Schaltet deine eigene Unsichtbarkeit ein oder aus. |
| `!spawn` | Respawnt an deiner aktuellen Ansicht und aktiviert anschließend den Kreativmodus, Unsichtbarkeit gegenüber Feinden und Fliegen. |
| `!cloud <steamid>` | Gibt dir die hochgeladenen (Tribut-)Items eines Spielers aus. |

`!esp` ist der Hauptschalter — `!espPlayers` und `!EspStruct` zeichnen nur,
während ESP für dich aktiv ist.

### Interaktion

Diese wirken direkt auf einen Verdächtigen. Setze sie bewusst ein: Sie sind
für den Spieler sichtbar und können einen Cheater warnen, gegen den du noch
Beweise sammelst.

| Befehl | Beschreibung |
| ------- | ----------- |
| `!unequip <steamid>` | Entfernt die angelegte Rüstung eines Spielers. |
| `!dropweapon <steamid>` | Zwingt einen Spieler, seine gehaltene Waffe fallen zu lassen. |
| `!jump <steamid>` | Zwingt einen Spieler zu springen. |
| `!punch <steamid>` | Löst den Tek-Handschuh-Raketenschlag eines Spielers aus. |
| `!tekjump <steamid>` | Löst den Tek-Brustpanzer-Boost eines Spielers aus. |
| `!requestjoin <steamid>` | Sendet dem Spieler eine gefälschte Stammeseinladung. |
| `!outofrange <steamid>` | Zeigt dem Spieler den Client-Hinweis „out of range". |
| `!playpoopsound <steamid>` | Spielt bei einem Spieler das Kot-Geräusch ab. |
| `!playdeathsound <steamid>` | Spielt bei einem Spieler das Todesgeräusch ab. |

> ℹ️ **Jede Admin-Aktion wird protokolliert.** Admin-Chatbefehle werden in
> einer lokalen Protokolldatei erfasst und an
> [`AdminTrollingWebhook`](configuration.md#webhooks) gesendet, mit dem
> ausführenden Admin, dem Ziel und dem Ort — so bleiben Admin-Rechte
> nachvollziehbar.
