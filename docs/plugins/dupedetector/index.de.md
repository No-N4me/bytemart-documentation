# 🔍 DupeDetector

DupeDetector ist ein kleines, fokussiertes ArkApi-Plugin, das **über das
Tribut-Inventar durchgeführte Item-Duplizierung** erkennt — den Obelisken,
das Versorgungsabwurf-Terminal und den Transmitter-Upload-Store, die für
Cluster-Transfers verwendet werden.

Es tut eine Sache, und das leise: Duplizierungsversuche werden an deinen
Discord gemeldet, und Wiederholungstäter können automatisch behandelt
werden.

## Was es tut

- **Erkennt Duplizierung** über den Tribut-/Upload-Store, ohne Client-Mod und
  ohne dass deine Spieler etwas installieren müssen.
- **Benachrichtigt deinen Discord.** Jede Erkennung wird an den von dir
  konfigurierten Webhook gepostet.
- **Bestraft Wiederholungstäter.** Sobald ein Spieler oft genug erkannt
  wurde, kann DupeDetector einen Server-Befehl gegen ihn ausführen (Kick,
  Ban, was auch immer du wählst) und optional sein Inventar leeren.
  Bestrafungen gehen an einen eigenen Webhook, sodass du sie an einen nur für
  Admins zugänglichen Kanal weiterleiten kannst.
- **Nur Berichterstattung, wenn du das möchtest.** Lasse die
  Bestrafungsoptionen leer, und das Plugin informiert dich nur — es handelt
  niemals von selbst.

Wie viel Spielraum ein Spieler erhält, bevor eine Bestrafung ausgelöst wird,
ist konfigurierbar und absichtlich keine feste Zahl. Siehe
[`Punishment.After`](configuration.md#punishment).

> ℹ️ **Erkennungsdetails werden absichtlich nicht veröffentlicht.** Was eine
> Erkennung auslöst und wie viele Erkennungen einem bestimmten Spieler
> erlaubt sind, wird hier nicht dokumentiert — diese Informationen helfen nur
> denjenigen, die du zu fassen versuchst. Wenn du eine bestimmte
> Benachrichtigung verstehen musst, frage im
> [Bytemart-Discord](https://bytemart.net/discord).

## Anforderungen

| Anforderung | Hinweise |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** oder neuer | Das Plugin lädt nicht mit älteren API-Versionen. |
| MySQL / MariaDB | Das Plugin verbindet sich beim Start, daher sind gültige Zugangsdaten erforderlich. Siehe [Gemeinsame Konfiguration](../index.md#database). |
| Ein Bytemart-Lizenzschlüssel | Nichts wird aktiviert, bevor der Schlüssel authentifiziert ist. |
| Ausgehendes HTTPS | Wird für die Lizenzierung und für Discord-Webhooks benötigt. |

## Installation

1. Stelle sicher, dass ArkApi **3.51+** auf deinem Server installiert ist.
2. Richte eine MySQL-/MariaDB-Datenbank ein — siehe
   [Gemeinsame Konfiguration](../index.md#database). Die Datenbank muss
   bereits existieren.
3. Lade die `DupeDetector.zip` von deinem **Bytemart-Dashboard** herunter.
4. Stoppe den Server (führe zuerst `saveworld` aus) oder entlade jede
   vorherige Version mit `plugins.unload DupeDetector`.
5. Entpacke das Archiv in einen `DupeDetector`-Ordner innerhalb von
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Öffne die `config.json` und trage deinen `LicenseKey`, deine
   `Database`-Zugangsdaten und mindestens `DupeDetection.AlertWebhook` ein —
   siehe [Konfiguration](configuration.md).
7. Starte den Server und stelle sicher, dass während des Starts keine Fehler
   auftreten.

> ⚠️ **Richte `AlertWebhook` ein, bevor du live gehst.** Es ist
> standardmäßig leer, und ein leerer Webhook bedeutet, dass Erkennungen zwar
> aufgezeichnet, aber nirgendwo gepostet werden.

### Aktualisieren

- **Manuell:** `plugins.unload DupeDetector`, ersetze die Dateien und dann
  `plugins.load DupeDetector`.
- **Automatisch (Hot-Reload):** Benenne die neue `DupeDetector.dll` in
  `DupeDetector.dll.arkapi` um und lege sie in den Plugin-Ordner — ArkApi
  lädt die neue Version und entlädt die alte automatisch.

DupeDetector repariert seine eigene Konfiguration beim Laden: Fehlende
Schlüssel werden mit ihren Standardwerten ergänzt, und dein Original wird
vorher als `config.json.bak` gesichert. Ein Typkonflikt (eine Zeichenkette,
wo eine Zahl hingehört) bricht das Laden stattdessen ab, mit einem Fehler,
der den Schlüssel benennt.

## Befehle

Konsolen- und RCON-Zugriff ist per Definition Admin-Zugriff, sodass diese
keine zusätzliche Berechtigung benötigen.

| Befehl | Kanäle | Beschreibung |
| ------- | -------- | ----------- |
| `DupeDetector.help [page]` | Konsole, RCON | Paginierte Liste aller registrierten Befehle. |
| `DupeDetector.reload` | Konsole, RCON | Liest die `config.json` neu ein, ohne den Server neu zu starten. |

`DupeDetector.reload` tauscht die laufende Konfiguration direkt aus, sodass
Änderungen an Webhook und Bestrafung sofort wirksam werden. Es führt die
Konfigurationsreparatur **nicht** erneut aus, also validiere dein JSON,
bevor du neu lädst.

## Fehlerbehebung

- **Plugin lädt nicht, Fehlercode `1114`** — ein JSON-Syntaxfehler in der
  `config.json`. Prüfe sie mit [JSONLint](https://jsonlint.com/).
- **„License key is missing"** — `LicenseKey` enthält noch den
  Platzhalterwert.
- **Nichts kommt bei Discord an** — die URL muss ein echter
  Discord-Webhook-Endpunkt sein (`https://discord.com/api/webhooks/...`; die
  Formen `discordapp.com`, `ptb.` und `canary.` werden ebenfalls
  akzeptiert). Alles andere wird verworfen, mit einer entsprechenden Zeile
  im Log.
- **Alles andere** — setze `LogToFile` auf `true` und reproduziere das
  Problem; das Plugin schreibt seine eigene rotierende `DupeDetector.log`
  neben der `config.json`. Frage anschließend im
  [Bytemart-Discord](https://bytemart.net/discord).

---

**Nächste Schritte:**

- [Konfiguration](configuration.md) — der `DupeDetection`-Block.
- [Gemeinsame Konfiguration](../index.md#common-configuration) — die gemeinsamen Schlüssel `LicenseKey`,
  `Database`, `LogToFile` und `Verbose`.
