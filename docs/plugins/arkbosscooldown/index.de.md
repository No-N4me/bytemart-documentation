# ⏳ ArkBossCooldown

ArkBossCooldown führt eine **serverweite Abklingzeit zwischen Boss-Starts**
ein. Boss-Arenen werden durch das Craften eines Tribut-Items betreten, und
nichts hindert eine Gruppe daran, mehrere davon hintereinander zu craften —
die Teleports stapeln sich, und Spieler kommen tot in der Arena an. Dieses
Plugin sorgt dafür, dass der Server einen Boss-Start verweigert, bis die
Abklingzeit des letzten abgelaufen ist.

Es ist absichtlich klein gehalten: eine Abklingzeit, eine Nachricht, eine
Liste von Tribut-Items.

## Was es tut

- **Eine Abklingzeit für den gesamten Server.** Das erste Craften eines
  Boss-Tributs aktiviert sie; jedes weitere Craften eines Tributs wird
  verweigert, bis sie abgelaufen ist. Sie gilt *nicht* pro Spieler oder pro
  Stamm — startet eine Gruppe einen Boss, warten alle.
- **Das verweigerte Craften kostet nichts.** Das Tribut-Item wird nicht
  verbraucht, und es findet kein Teleport statt, sodass ein Spieler, der auf
  die Abklingzeit trifft, es einfach erneut versuchen kann, sobald sie
  vorüber ist.
- **Sagt dem Spieler warum.** Eine konfigurierbare Chat-, Benachrichtigungs-
  oder Broadcast-Nachricht zeigt die verbleibende Zeit an. Sie kann auch
  deaktiviert werden, um stillschweigend zu verweigern.
- **Funktioniert auf jeder Karte und mit Mods.** Die Tribut-Items, die die
  Abklingzeit aktivieren, sind einfach eine Liste von Blueprint-Pfaden in der
  Konfiguration, sodass du modifizierte Arenen hinzufügen oder Bosse
  entfernen kannst, die du nicht sperren möchtest.
- **Sonst nichts.** Items, die nicht in deiner Liste stehen, werden ganz
  normal gecraftet.

> ℹ️ **Dies ist ein Entprellen, keine Boss-Sperre.** `BossStartCooldown` ist
> standardmäßig auf **5 Sekunden** gesetzt — lang genug, um eine Serie von
> Spam-Klicks abzufangen, kurz genug, dass es niemand bemerkt. Wenn du ein
> echtes „ein Boss pro Stunde"-Limit möchtest, setze einen deutlich größeren
> Wert und lies zuerst den Hinweis zu
> [Neustarts und Reloads](configuration.md#bossstartcooldown).

## Anforderungen

| Anforderung | Hinweise |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** oder neuer | Das Plugin lädt nicht mit älteren API-Versionen. |
| MySQL / MariaDB | Das Plugin verbindet sich beim Start, daher sind gültige Zugangsdaten erforderlich — ArkBossCooldown selbst speichert dort jedoch nichts. Siehe [Gemeinsame Konfiguration](../index.md#database). |
| Ein Bytemart-Lizenzschlüssel | Nichts wird aktiviert, bevor der Schlüssel authentifiziert ist. |
| Ausgehendes HTTPS | Wird für die Lizenzierung benötigt. |

## Installation

1. Stelle sicher, dass ArkApi **3.51+** auf deinem Server installiert ist.
2. Richte eine MySQL-/MariaDB-Datenbank ein — siehe
   [Gemeinsame Konfiguration](../index.md#database). Die Datenbank muss
   bereits existieren.
3. Lade die `ArkBossCooldown.zip` von deinem **Bytemart-Dashboard** herunter.
4. Stoppe den Server (führe zuerst `saveworld` aus) oder entlade jede
   vorherige Version mit `plugins.unload ArkBossCooldown`.
5. Entpacke das Archiv in einen `ArkBossCooldown`-Ordner innerhalb von
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Öffne die `config.json` und trage deinen `LicenseKey` sowie deine
   `Database`-Zugangsdaten ein. Die Standardwerte für alles andere sind so,
   wie sie ausgeliefert werden, verwendbar — siehe
   [Konfiguration](configuration.md).
7. Starte den Server und stelle sicher, dass während des Starts keine Fehler
   auftreten.
8. Crafte ein Boss-Tribut zweimal hintereinander, um zu prüfen, dass der
   zweite Versuch verweigert wird und die Nachricht erscheint.

> 💡 **Spielst du auf einer Karte oder mit einer Mod, die nicht in der
> Standardliste enthalten ist?** Aktiviere
> [`TestMode`](configuration.md#testmode), crafte das Tribut einmal, und
> kopiere den von der Konsole ausgegebenen Blueprint-Pfad in `Bosses`.
> Schalte `TestMode` anschließend wieder aus.

### Aktualisieren

- **Manuell:** `plugins.unload ArkBossCooldown`, ersetze die Dateien und
  dann `plugins.load ArkBossCooldown`.
- **Automatisch (Hot-Reload):** Benenne die neue `ArkBossCooldown.dll` in
  `ArkBossCooldown.dll.arkapi` um und lege sie in den Plugin-Ordner —
  ArkApi lädt die neue Version und entlädt die alte automatisch.

ArkBossCooldown repariert seine eigene Konfiguration beim Laden: Fehlende
Schlüssel werden mit ihren Standardwerten ergänzt, und dein Original wird
vorher als `config.json.bak` gesichert. Ein Typkonflikt (eine Zeichenkette,
wo eine Zahl hingehört) bricht das Laden stattdessen ab, mit einem Fehler,
der den Schlüssel benennt.

## Befehle

Konsolen- und RCON-Zugriff ist per Definition Admin-Zugriff, sodass diese
keine zusätzliche Berechtigung benötigen.

| Befehl | Kanäle | Beschreibung |
| ------- | -------- | ----------- |
| `ArkBossCooldown.help [page]` | Konsole, RCON | Paginierte Liste aller registrierten Befehle. |
| `ArkBossCooldown.reload` | Konsole, RCON | Liest die `config.json` neu ein, ohne den Server neu zu starten. |

`ArkBossCooldown.reload` baut die Boss-Liste, die Länge der Abklingzeit,
`TestMode` und die Nachrichteneinstellungen von der Festplatte neu auf. Es
löscht **keine** bereits laufende Abklingzeit — ein Reload ist kein
kostenloser Boss-Start. Um eine zu löschen, entlade und lade das Plugin neu.
Es führt außerdem die Konfigurationsreparatur nicht erneut aus, also
validiere dein JSON, bevor du neu lädst.

## Fehlerbehebung

- **Die Abklingzeit wird nie ausgelöst** — das Tribut, das du craftest,
  steht wahrscheinlich nicht in der `Bosses`-Liste. Aktiviere `TestMode`,
  crafte es, und lies den Pfad aus der Konsole ab.
- **Plugin lädt nicht, Fehlercode `1114`** — ein JSON-Syntaxfehler in der
  `config.json`. Prüfe sie mit [JSONLint](https://jsonlint.com/). Bei dem
  langen `Bosses`-Array übersieht man ein überzähliges Komma leicht.
- **„License key is missing"** — `LicenseKey` enthält noch den
  Platzhalterwert.
- **Die Nachricht erscheint nicht** — prüfe, ob `CooldownMessage.Enabled`
  auf `true` steht, und beachte, dass `Scale` nur für den Kanal
  `Notification` gilt.
- **Alles andere** — setze `LogToFile` auf `true` und reproduziere das
  Problem; das Plugin schreibt seine eigene rotierende
  `ArkBossCooldown.log` neben der `config.json`. Frage anschließend im
  [Bytemart-Discord](https://bytemart.net/discord).

---

**Nächste Schritte:**

- [Konfiguration](configuration.md) — die Abklingzeit, die Nachricht und die Boss-Liste.
- [Gemeinsame Konfiguration](../index.md#common-configuration) — die gemeinsamen Schlüssel `LicenseKey`,
  `Database`, `LogToFile` und `Verbose`.
