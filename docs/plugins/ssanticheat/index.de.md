# 🛡️ ssAntiCheat

ssAntiCheat ist ein **serverseitiger Anti-Cheat** für ARK: Survival Evolved. Er
läuft vollständig innerhalb deines Servers als ArkApi-Plugin — Spieler
installieren nichts, und es gibt keinen Client, den man umgehen könnte.
Erkennungen werden an deinen Discord und an In-Game-Admins gemeldet, und
Übeltäter werden in eine **Ban-Welle** eingereiht, damit Cheater nicht
herausfinden, welche Prüfung sie erwischt hat.

Neben der Erkennung **blockiert** ssAntiCheat außerdem eine große Anzahl
bekannter Exploits direkt und liefert Fixes für mehrere seit Langem bestehende
Serverprobleme — darunter **Crash-Exploits** und **Item-Duplizierung**.

## Funktionen

- **Erkennungsmodule.** Dutzende einzeln umschaltbare Detektoren, gruppiert in
  vier Kategorien: **Combat**, **Misc**, **Mod** und **Exploits**. Ein paar
  Beispiele: Aimbot- und Silent-Aim-Erkennung, Auto-Flak, Auto-Medbrew,
  No-Overheat, Auto-Loot und Auto-Craft. Jedes kann einzeln aktiviert,
  deaktiviert und angepasst werden.
- **Exploit-Blockierung, nicht nur Meldung.** Die meisten Exploit-Module können
  die Aktion nicht nur melden, sondern auch *verhindern*, sodass der Exploit
  fehlschlägt, anstatt nur im Nachhinein protokolliert zu werden.
- **Crash- & Duplizierungsschutz.** Bekannte Server-Crash-Vektoren werden
  blockiert, und die Duplizierungs-Fixes stoppen die gängigen Item-Dupe-Methoden
  (Transfer-Dupes, Bag-/Transmitter-Tricks und mehr).
- **Glitch- & Lag-Fixes.** Ein eigener `Fixes`-Abschnitt deckt bekannte
  Server-Glitches ab (Scout-Glitch, Handcuff-Glitch, „player already
  connected", der Pull-Glitch, Lag-Schutz und der Dupe-Fix).
- **Integriertes Bansystem.** Bans werden in MySQL gespeichert und beim Login
  durchgesetzt, mit optionalen **IP-Zuordnungs**- und **HWID**-Bans. Ban-Wellen
  werden gebündelt, sodass mehrere Cheater auf einmal entfernt werden. Siehe
  [Bans & Erkennungen](bans.md).
- **Discord-Benachrichtigungen.** Erkennungen, Bans, Join-Logs,
  IP-Zuordnungs-Bans und Admin-Aktionsprotokolle gehen jeweils an einen von dir
  konfigurierten Webhook — oder alle an denselben.
- **Admin-Werkzeuge.** Beobachte einen gemeldeten Spieler mit einem einzigen
  Befehl, schalte Spieler- und Struktur-ESP für dich selbst ein oder aus, und
  nutze eine Reihe von Chatbefehlen zum Umgang mit Verdächtigen im Spiel. Jede
  Admin-Aktion wird protokolliert.
- **Verbindungs-Gate.** Optionale Steam-Web-API-Prüfungen beim Beitritt:
  Mindestspielzeit, Mindestkontoalter und kürzliche VAC-Bans — jede kann nur
  protokollieren oder blockieren.
- **Dashboard (optional).** Opt-in-Telemetrie an das ssAnticheat-Dashboard für
  einen Live-Erkennungsfeed, den Serverstatus und eine optionale
  Live-Spielerkarte. Standardmäßig deaktiviert.

## Wie aus einer Erkennung ein Bann wird

```
Detektor löst aus
   └─> Erkennung aufgezeichnet  ──> In-Game-Admin-Alarm
                                ──> Discord-Webhook
                                ──> Dashboard (falls aktiviert)
   └─> Ban-Schwelle des Moduls erreicht?
          └─> Spieler wird für die nächste Ban-Welle eingereiht
                 └─> Ban-Welle läuft: bei einem Speicherzyklus, wenn der
                     Spieler die Verbindung trennt, bei einem
                     Instant-Ban-Modul oder manuell
```

Schwellenwerte, Blockierung und Instant-Ban-Verhalten sind pro Modul
festgelegt. Der vollständige Ablauf — und jede Stellschraube, die ihn
verändert — findest du auf der Seite [Bans & Erkennungen](bans.md).

## Anforderungen

| Anforderung | Hinweise |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** oder neuer | Das Plugin lädt nicht mit älteren API-Versionen. |
| MySQL / MariaDB | Erforderlich. Bans werden dort gespeichert. Siehe [Gemeinsame Konfiguration](../index.md#database). |
| Ein Bytemart-Lizenzschlüssel | Nichts wird aktiviert, bevor der Schlüssel authentifiziert ist. |
| Ausgehendes HTTPS | Wird für die Lizenzierung, Discord-Webhooks und (falls verwendet) die Steam-Web-API sowie das Dashboard benötigt. |

## Installation

1. Stelle sicher, dass ArkApi **3.51+** auf deinem Server installiert ist.
2. Richte eine MySQL-/MariaDB-Datenbank ein — siehe
   [Gemeinsame Konfiguration](../index.md#database). Die Datenbank muss
   bereits existieren; das Plugin erstellt seine eigenen Tabellen darin.
3. Lade die `ssAntiCheat.zip` von deinem **Bytemart-Dashboard** herunter.
4. Stoppe den Server (führe zuerst `saveworld` aus) oder entlade jede vorherige
   Version mit `plugins.unload ssAntiCheat`.
5. Entpacke das Archiv in einen `ssAntiCheat`-Ordner innerhalb von
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Öffne die `config.json` und trage deinen `LicenseKey` sowie deine
   `Database`-Zugangsdaten ein (siehe [Konfiguration](configuration.md)).
7. Starte den Server und stelle sicher, dass während des Starts keine Fehler
   auftreten.
8. Führe `ssac.status` über die Konsole oder RCON aus, um zu bestätigen, dass
   die Lizenz authentifiziert wurde.

> ⚠️ **Richte deine Webhooks ein, bevor du live gehst.** Jedes Webhook-Feld ist
> standardmäßig leer. Bis du mindestens `DefaultWebhookUrl` ausfüllst, sind
> Erkennungen nur für In-Game-Admins und im Server-Log sichtbar.

### Aktualisieren

- **Manuell:** `plugins.unload ssAntiCheat`, ersetze die Dateien und dann
  `plugins.load ssAntiCheat`.
- **Automatisch (Hot-Reload):** Benenne die neue `ssAntiCheat.dll` in
  `ssAntiCheat.dll.arkapi` um und lege sie in den Plugin-Ordner — ArkApi lädt
  die neue Version und entlädt die alte automatisch.

Prüfe beim Aktualisieren immer das Changelog auf Konfigurationsänderungen.
ssAntiCheat repariert seine eigene Konfiguration automatisch (fehlende
Schlüssel werden mit ihren Standardwerten ergänzt und das Original wird als
`config.json.bak` gesichert), aber ein Werkzeug wie
[Diffchecker](https://www.diffchecker.com/) hilft trotzdem dabei, neue
Schlüssel zu erkennen, die eine Anpassung wert sind.

## Fehlerbehebung

- **Plugin lädt nicht, Fehlercode `1114`** — ein JSON-Syntaxfehler in der
  `config.json`. Prüfe sie mit [JSONLint](https://jsonlint.com/).
- **„License key is missing"** — `LicenseKey` enthält noch den
  Platzhalterwert.
- **Nichts kommt bei Discord an** — prüfe, ob `Use Discord` auf `true` steht
  und die passende Webhook-URL ausgefüllt ist. Webhooks sind zweckgebunden;
  siehe [Konfiguration](configuration.md#webhooks).
- **Alles andere** — setze `LogToFile` auf `true` und reproduziere das
  Problem; das Plugin schreibt seine eigene rotierende `ssAntiCheat.log` neben
  der `config.json`, sodass du dich nicht durch das gemeinsame Server-Log
  wühlen musst. Frage anschließend im
  [Bytemart-Discord](https://bytemart.net/discord).

---

**Nächste Schritte:**

- [Konfiguration](configuration.md) — jeder Schlüssel in der `config.json`.
- [Befehle](commands.md) — Konsolen-/RCON-Befehle und In-Game-Admin-Chatbefehle.
- [Bans & Erkennungen](bans.md) — Schwellenwerte, Ban-Wellen, IP-/HWID-Bans und Entbannen.
- [Gemeinsame Konfiguration](../index.md#common-configuration) — die gemeinsamen Schlüssel `LicenseKey`, `Database`, `LogToFile` und `Verbose`.
