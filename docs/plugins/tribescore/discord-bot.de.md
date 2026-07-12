# 🤖 Discord-Bot

Tribescore wird mit einem begleitenden **Discord-Bot** ausgeliefert, der den
Wettbewerb deines Servers nach Discord bringt — eine live aktualisierte Bestenliste,
Slash-Befehle zum Nachschlagen jedes Stammes und ein automatisches
Missbrauchserkennungssystem, das verdächtige Punktevergaben meldet.

Der Bot verbindet sich **direkt mit derselben MySQL-/MariaDB-Datenbank**, die auch das
Plugin verwendet. Er *liest* dabei ausschließlich die Punktetabellen des Plugins — er
ändert deine Punkte niemals — und lässt sich daher gefahrlos parallel zu einem laufenden
Server betreiben.

## Funktionen

- **Live-Bestenliste** — postet die besten Stämme in einem Kanal deiner Wahl und
  aktualisiert sie automatisch, mit ▲/▼-Bewegungspfeilen zwischen den Wertungsperioden.
- **Darstellung als Bild oder Embed** — zeige die Liste als klassisches Discord-Embed
  oder als hochwertiges PNG, gerendert aus einem von sieben eingebauten Designs
  (`podium`, `spotlight`, `cards`, `bars`, `terminal`, `ark`, `dark`). Die Vorlagen sind
  reines HTML, das du für deinen Server umgestalten und mit deinem Branding versehen
  kannst.
- **Slash-Befehle** — mit `/tribepoints` und `/getrank` können Spieler Punktzahl und
  Rang jedes Stammes nachschlagen. Befehlsnamen und Nachrichten sind konfigurierbar.
- **Missbrauchserkennung** — drei unabhängige Detektoren posten Warnungen, wenn eine
  Punktevergabe verdächtig aussieht, jeweils mit einer *„Diese Warnung ignorieren"*-
  Schaltfläche, um Fehlalarme stummzuschalten.
- **Eigenständige ausführbare Datei** — wird als einzelne, in sich geschlossene
  Windows-`.exe` verteilt. Es sind weder ein Browser noch zusätzliche Installationen
  erforderlich, selbst für das Rendern von Bildern.

## Voraussetzungen

- Das Tribescore-Plugin ist installiert und schreibt in eine MySQL-/MariaDB-Datenbank
  (siehe [Konfiguration](configuration.md) und
  [Gemeinsame Konfiguration](../common-configuration.md#database)).
- Eine Discord-Anwendung und ein Bot-Token, erstellt im
  [Discord Developer Portal](https://discord.com/developers/applications).
- Ein Windows-Rechner, auf dem der Bot läuft — er kann überall laufen, wo die Datenbank
  erreichbar ist.

## Installation

1. Lade den Bot aus deinem **Bytemart-Dashboard** herunter und entpacke ihn.
2. Öffne die `config.yml` und konfiguriere sie (siehe unten).
3. Trage deinen Bot-Token und dein Datenbank-Passwort ein — entweder direkt in der
   `config.yml` oder über die Umgebungsvariablen `LEADERBOARD_BOT_TOKEN` und
   `MYSQL_PASSWORD` (empfohlen, damit Geheimnisse aus der Konfigurationsdatei
   herausgehalten werden).
4. Lade den Bot auf deinen Server ein und gib ihm die Berechtigung, in den Bestenlisten-
   und Warnkanälen Nachrichten, Embeds und Anhänge zu senden.
5. Führe die ausführbare Datei aus. Beim ersten Start registriert er seine Slash-Befehle
   und postet die Bestenliste.

> 💡 Wenn du einen Slash-Befehl in der `config.yml` umbenennst, muss der Bot unter
> Umständen aus dem Server entfernt und erneut eingeladen werden, bevor die Änderung
> wirksam wird.

## Konfiguration (`config.yml`)

Der Bot wird vollständig über die `config.yml` konfiguriert. Die wichtigsten
Einstellungen:

| Einstellung | Beschreibung |
| ------- | ----------- |
| `bot-token` | Dein Discord-Bot-Token. Lasse es leer und setze stattdessen `LEADERBOARD_BOT_TOKEN`. |
| `period-start` | Cron-Ausdruck dafür, wann eine neue Wertungsperiode beginnt (dann erfasst die Liste die Bewegungen als Snapshot). Siehe [crontab.guru](https://crontab.guru/). |
| `timezone` | Zeitzone für die Zeitplanung und den Vergleich von Transaktionen — muss mit der Zeitzone deiner Datenbank übereinstimmen. |
| `refresh-cooldown` | Sekunden zwischen den Bestenlisten-Aktualisierungen innerhalb einer Periode. |
| `leaderboard-channel` | Die Kanal-ID, in der die Bestenliste gepostet wird. |
| `keep-leaderboard-history` | Bei `true` wird pro Periode eine frische Bestenlisten-Nachricht gepostet, anstatt die vorhandene zu bearbeiten. |
| `leaderboard-render-mode` | `embed` (Discord-Embed) oder `image` (gerendertes PNG). |
| `leaderboard-image` | Optionen für den Bildmodus: `template`, `title`, `lines`, `width`, `scale`. |
| `mysql` | Datenbankverbindung: `host`, `port`, `user`, `password`, `database`, `leaderboard-table`, `transactions-table`, `timezone`. |
| `commands` | Befehlsnamen, Beschreibungen und Antwortnachrichten. |
| `abuse-detection` | Aktivieren und Feinabstimmung der Missbrauchserkennungs-Module. |

> ⚠️ Die `leaderboard-table` und die `transactions-table` müssen mit den Tabellen des
> Plugins übereinstimmen — standardmäßig `ts_leaderboard` und `ts_transactions`. Der Bot
> liest diese Tabellen und schreibt niemals in sie.

### Darstellung der Bestenliste

Wähle mit `leaderboard-render-mode`, wie die Liste gerendert wird:

```yaml
leaderboard-render-mode: "image"   # oder "embed"
leaderboard-image:
  template: "spotlight"   # podium | spotlight | cards | bars | terminal | ark | dark
  title: "Tribes Leaderboard"
  lines: 15               # Anzahl der angezeigten Stämme
  width: 820
  scale: 2                # 2 = gestochen scharf / Retina-Ausgabe
```

Im `embed`-Modus ist die Liste ein Text-Embed, das aus der `leaderboard_embed.json`
erstellt wird. Im `image`-Modus wird sie aus einer HTML-Vorlage unter
`templates/leaderboard/<name>/` gerendert. Sollte das Rendern eines Bildes einmal
fehlschlagen, greift der Bot automatisch auf das Embed zurück, sodass die Bestenliste
niemals offline gehen kann.

### Slash-Befehle

| Befehl (Standard) | Beschreibung |
| ----------------- | ----------- |
| `/tribepoints <tribe>` | Zeigt die aktuellen Punkte eines Stammes an. |
| `/getrank <tribe>` | Zeigt Rang und Punkte eines Stammes an. |

Sowohl die Befehlsnamen als auch ihre Antwortnachrichten sind unter `commands` in der
`config.yml` konfigurierbar, unter Verwendung der Platzhalter `{tribe}`, `{points}` und
`{rank}`.

### Missbrauchserkennung

Wenn `abuse-detection.enabled` auf `true` steht, scannt der Bot regelmäßig die besten
Stämme und postet eine Warnung an die konfigurierte `channel-id`, sobald ein Modul
anschlägt. Jede Warnung trägt eine **„Diese Warnung ignorieren"**-Schaltfläche, die
künftige Wiederholungen für dieses Stämme-Paar unterdrückt.

| Modul | Erkennt |
| ------ | ------- |
| `rapid-increase` | Ein Stamm, der innerhalb einer Wertungsperiode eine ungewöhnlich große Anzahl an Punkten gewinnt. |
| `massive-transaction` | Eine einzelne Punkteübertragung oberhalb eines Schwellenwerts von einem Stamm zu einem anderen. |
| `prefered-source` | Ein Stamm, der einen großen Anteil seiner Punkte von einem einzigen Quell-Stamm erhält (mit optionaler „Spiegel"-Prüfung auf Gegenseitigkeit). |

Jedes Modul hat seinen eigenen `cooldown`, eigene Schwellenwerte und einen eigenen
Warn-`title` / eine eigene `message` — die verfügbaren Platzhalter sind direkt in der
`config.yml` dokumentiert.

> ℹ️ Der Bot erstellt eine eigene Tabelle, `ts_ignored_alerts`, um sich zu merken, welche
> Warnungen du verworfen hast. Dies ist die einzige Tabelle, in die er schreibt; deine
> Punktedaten werden niemals verändert.
