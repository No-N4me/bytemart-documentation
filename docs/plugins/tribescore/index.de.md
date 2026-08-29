# 🏆 Tribescore

Tribescore ist ein kompetitives **Punktesystem für Stämme** für ARK: Survival Evolved.
Stämme verdienen *Tribescore*, indem sie feindliche Strukturen, Dinos und Spieler im
PvP zerstören. Die Punkte werden in MySQL gespeichert und über eine Bestenliste sowie
ein Rangsystem dargestellt, während bei jedem Punktgewinn oder -verlust schwebende
„Hologramm"-Zahlen in der Spielwelt auftauchen.

Die Punktevergabe läuft durch eine konfigurierbare, multiplikative Modifikator-Pipeline,
damit du den Wettbewerb fair halten kannst: Offline-Schutz, Ausgleich anhand der
Punktedifferenz zwischen starken und schwachen Stämmen, berechtigungsbasierte Boosts und
von Admins vergebene zeitlich begrenzte Boosts.

## Funktionen

- **PvP-Punkte:** Vergib Punkte für das Zerstören feindlicher Strukturen, das Töten
  gezähmter Dinos und das Töten feindlicher Spieler. Jede Quelle ist einzeln
  konfigurierbar und kann abgeschaltet werden.
- **Werte pro Stufe & pro Blueprint:** Strukturen werden nach Baustufe bewertet
  (Stroh → Tek) mit Überschreibungen pro Blueprint; Dinos werden pro Spezies bewertet
  mit feingranularen Flags (Babys, ohne Sattel, wild, …).
- **Modifikator-Pipeline:** Balanciere das Spiel mit Offline-Schutz, einem
  Punktedifferenz-Verhältnis „stark gegen schwach", Berechtigungs-Modifikatoren und
  zeitlich begrenzten Boosts.
- **Bestenliste & Ränge:** In-Game-Chatbefehle `/leaderboard` und `/triberank`,
  gestützt auf eine persistente MySQL-Bestenliste.
- **Hologramme in der Spielwelt:** Konfigurierbarer schwebender `+points`- /
  `-points`-Text, den Spieler für sich selbst ein- oder ausschalten können.
- **Admin-Werkzeuge:** Punkte geben/nehmen, zeitlich begrenzte Boosts vergeben, die
  Transaktionshistorie eines Stammes prüfen und den Wert einer Basis schätzen — alles
  über die Konsole/RCON.
- **Begleitender Discord-Bot:** Ein mitgelieferter Bot postet eine Live-Bestenliste nach
  Discord, ergänzt Slash-Befehle zum Nachschlagen von Stämmen und meldet verdächtige
  Punktevergaben. Siehe [Discord-Bot](discord-bot.md).

## Wie die Punktevergabe funktioniert

Wenn eine feindliche Struktur, ein Dino oder ein Spieler zerstört wird, stammt der
Basispunktwert aus den Punktetabellen (`structures.json`, `dinos.json` oder dem festen
Spielerwert in `config.json`). Dieser Basiswert wird anschließend durch die
Modifikator-Pipeline multipliziert:

```
final score = base points
            × OfflineProtection(defender)
            × ScoreDifferenceRatio(attacker, defender)
            × PermissionModifier(attacker)
            × TimedBoost(attacker, type)
```

Der angreifende Stamm **gewinnt** das Ergebnis; der verteidigende Stamm **verliert** einen
(separat konfigurierbaren) Betrag. Auf der Seite
[Konfiguration](configuration.md) findest du jede Stellschraube.

## Installation

1. Stelle sicher, dass eine unterstützte Version von [ArkApi](https://arkserverapi.com/)
   auf deinem Server installiert ist (Tribescore benötigt ArkApi **3.51** oder neuer).
2. Richte eine MySQL-/MariaDB-Datenbank ein — siehe [Gemeinsame Konfiguration](../index.md#database).
3. Lade die `Tribescore.zip` von deinem **Bytemart-Dashboard** herunter.
4. Stoppe den Server (führe zuerst `saveworld` aus) oder entlade jede vorherige Version
   mit `plugins.unload Tribescore`.
5. Entpacke das Archiv in einen `Tribescore`-Ordner innerhalb von
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Öffne die `config.json` und trage deinen `LicenseKey` sowie deine
   `Database`-Zugangsdaten ein
   (siehe [Konfiguration](configuration.md)).
7. Starte den Server und stelle sicher, dass während des Starts keine Fehler auftreten.

### Aktualisieren

- **Manuell:** `plugins.unload Tribescore`, ersetze die Dateien und dann
  `plugins.load Tribescore`.
- **Automatisch (Hot-Reload):** Benenne die neue `Tribescore.dll` in
  `Tribescore.dll.arkapi` um und lege sie in den Plugin-Ordner — ArkApi lädt die
  neue Version und entlädt die alte automatisch.

Prüfe beim Aktualisieren immer das Changelog auf Konfigurationsänderungen; ein Werkzeug
wie [Diffchecker](https://www.diffchecker.com/) hilft, neue oder umbenannte Schlüssel zu
erkennen.

---

**Nächste Schritte:**

- [Konfiguration](configuration.md) — die vollständige `config.json` sowie `structures.json` und `dinos.json`.
- [Befehle](commands.md) — Admin-Befehle über Konsole/RCON und In-Game-Chatbefehle.
- [Discord-Bot](discord-bot.md) — der begleitende Bot: Live-Bestenliste, Slash-Befehle und Missbrauchserkennung.
- [Gemeinsame Konfiguration](../index.md) — die gemeinsamen Schlüssel `LicenseKey`, `Database`, `LogToFile` und `Verbose`.
