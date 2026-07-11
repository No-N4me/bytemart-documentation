# Befehle

Tribescore hat zwei Arten von Befehlen: **Admin**-Befehle, die über die Serverkonsole
oder RCON ausgeführt werden, und **Spieler**-Chatbefehle, die im Spiel eingegeben werden.
Admin-Befehle sind mit `ts.` vorangestellt und nur über die Konsole/RCON erreichbar, sodass
kein separates Berechtigungssystem sie absichert — der Zugriff ergibt sich aus dem Kanal.
Chatbefehle sind konfigurierbar und optional (siehe [`ChatCommands`](configuration.md#chatcommands)).

## Konsolen- / RCON-Befehle

| Befehl | Kanäle | Beschreibung |
| ------- | -------- | ----------- |
| `ts.help [page]` | Konsole, RCON | Zeigt das paginierte Tribescore-Hilfemenü. |
| `ts.give <tribe-id> <score>` | Konsole | Fügt einem Stamm Tribescore hinzu. Protokolliert eine `system`-Transaktion. |
| `ts.take <tribe-id> <score>` | Konsole | Entfernt Tribescore von einem Stamm. Protokolliert eine `system`-Transaktion. |
| `ts.boost <tribe-id> <type> <value> <duration>` | Konsole, RCON | Gewährt einem Stamm einen zeitlich begrenzten Punkte-Boost. |
| `ts.boost <tribe-id> clear` | Konsole, RCON | Löscht den aktiven zeitlich begrenzten Boost eines Stammes. |
| `ts.audit <tribe-id> [options]` | Konsole | Prüft die Punktetransaktionen eines Stammes und lädt einen Bericht hoch. |
| `ts.estimate <recipient-tribe-id> [options]` | Konsole | Schätzt den Tribescore der Strukturen um dich herum. |
| `ts.addstructure` | Konsole | Hängt die Struktur, die du gerade ansiehst, an `structures.json` an. |

### `ts.give` / `ts.take`

```bash
ts.give 1234567890 500      # 500 Punkte zu Stamm 1234567890 hinzufügen
ts.take 1234567890 250      # 250 Punkte von Stamm 1234567890 entfernen
```

Beide schreiben einen Eintrag vom Typ `system` in die Transaktionshistorie, sodass
manuelle Anpassungen nachvollziehbar sind.

### `ts.boost`

Gewährt einen temporären Punkte-Multiplikator, der sich für eine festgelegte Dauer in die
Modifikator-Pipeline einreiht.

```
ts.boost <tribe-id> <type> <value> <duration>
ts.boost <tribe-id> clear
```

| Argument | Beschreibung |
| -------- | ----------- |
| `<tribe-id>` | Die ID des Zielstammes. |
| `<type>` | Worauf der Boost angewendet wird: `structures`, `dinos`, `players`, `all` oder eine mit `+` verbundene Kombination (z. B. `structures+dinos`). |
| `<value>` | Der Multiplikator (z. B. `1.5` für +50 %). |
| `<duration>` | Lebensdauer des Boosts, in **Sekunden**. |

```bash
ts.boost 1234567890 structures+dinos 1.5 3600   # +50% auf Strukturen & Dinos für 1 Std.
ts.boost 1234567890 all 2 600                   # alle Punkte für 10 Minuten verdoppeln
ts.boost 1234567890 clear                        # den aktiven Boost entfernen
```

> ℹ️ **Auch für andere Plugins verfügbar.** Zeitlich begrenzte Boosts sind Teil der
> öffentlichen API von Tribescore (`SetTimedBoost` / `ClearTimedBoost` / `GetTimedBoost`),
> die das begleitende **Koth**-Plugin nutzt, um Event-Gewinner automatisch zu belohnen.

### `ts.audit`

Erstellt einen asynchronen Bericht über die Transaktionen eines Stammes (von wem sie
Punkte verdient haben, wer ihnen Punkte gestohlen hat, Aufschlüsselungen pro Cluster) und
lädt ihn hoch, wobei eine URL zurückgegeben wird.

```
ts.audit <tribe-id> [clusters_amount=X] [givers_amount=X] [stealers_amount=X] [start_date=YYYY-MM-DD] [end_date=YYYY-MM-DD]
```

| Option | Beschreibung |
| ------ | ----------- |
| `clusters_amount=X` | Anzahl der einzubeziehenden Top-Cluster. |
| `givers_amount=X` | Anzahl der Top-Stämme, von denen dieser Stamm Punkte verdient hat. |
| `stealers_amount=X` | Anzahl der Top-Stämme, die diesem Stamm Punkte weggenommen haben. |
| `start_date` / `end_date` | Beschränkt die Prüfung auf einen Datumsbereich (`YYYY-MM-DD`). |

```bash
ts.audit 1234567890 givers_amount=10 start_date=2026-07-01 end_date=2026-07-12
```

### `ts.estimate`

Scannt die Strukturen in Reichweite deines Charakters (mittels eines Octree-Scans, über
mehrere Ticks aufgeteilt) und schätzt, wie viele Punkte sie einem bestimmten Stamm wert
wären. Nützlich zum Feinabstimmen der Werte in `structures.json`.

```
ts.estimate <recipient-tribe-id> [modifiers=on|off] [range=X]
```

| Option | Beschreibung |
| ------ | ----------- |
| `modifiers=on\|off` | Ob die Modifikator-Pipeline auf die Schätzung angewendet wird. |
| `range=X` | Scan-Radius um deinen Charakter. |

### `ts.addstructure`

Führt einen Line-Trace auf die Struktur aus, die du gerade ansiehst, hängt sie als
benutzerdefinierten Eintrag an `structures.json` an und lädt die Datei per Hot-Reload neu
— eine schnelle Möglichkeit, Werte pro Blueprint hinzuzufügen, ohne Blueprint-Pfade von
Hand zu suchen.

---

## Chatbefehle

Diese werden im In-Game-Chat eingegeben. Die Namen sind konfigurierbar — die folgenden
Standardwerte stammen aus der ausgelieferten
[`ChatCommands`](configuration.md#chatcommands)-Konfiguration, und jeder Befehl kann
vollständig deaktiviert werden.

| Befehl (Standard) | Beschreibung |
| ----------------- | ----------- |
| `/leaderboard` | Zeigt die besten Stämme nach Punktzahl. |
| `/triberank` | Zeigt den Rang und die Punktzahl deines eigenen Stammes. |
| `/holograms` | Schaltet die schwebenden `+/- points`-Hologramme für dich selbst ein oder aus. |

Die Formulierung, Farben, Größe, Anzeigedauer auf dem Bildschirm und (für die Bestenliste)
die Anzahl der Zeilen sowie die Farben pro Rang werden allesamt in
[`ChatCommands`](configuration.md#chatcommands) festgelegt.

---

## Berechtigungsknoten

Tribescore verwendet keine Berechtigungen, um seine Befehle abzusichern, aber die Funktion
[`PermissionModifiers`](configuration.md#modifierspermissionmodifiers) liest
Berechtigungsknoten, um die Punktzahl eines Stammes zu erhöhen oder zu senken. Vergib sie
über das [Permissions](https://github.com/ServersHub/ServerAPI)-Plugin. Mit der
Standardkonfiguration:

```bash
Permissions.AddGroup VIP
Permissions.Grant VIP ts.boost.15
```

Hier würde ein Mitglied der Gruppe `VIP` seinem Stamm einen **1.15×**-Punktemultiplikator
verleihen, gemäß dem Eintrag `ts.boost.15` in `PermissionModifiers.Modifiers`. Die
Knotennamen sind frei wählbar — sie müssen lediglich mit dem übereinstimmen, was du
konfigurierst.
