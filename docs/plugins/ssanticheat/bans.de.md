# Bans & Erkennungen

ssAntiCheat trennt das **Erkennen** eines Cheaters vom **Entfernen**. Eine
Erkennung löst immer eine Benachrichtigung aus; ein Ban erfolgt erst, wenn
der Schwellenwert eines Moduls erreicht ist, und selbst dann wird er
normalerweise bis zur nächsten **Ban-Welle** zurückgehalten. Diese
Verzögerung ist beabsichtigt — sie verhindert, dass ein Cheater „Ich habe X
getan und wurde eine Sekunde später gebannt" verknüpft und herausfindet,
welche Prüfung ihn erwischt hat.

## Die Pipeline

```
1. ein Detektor löst aus
2. Erkennung wird aufgezeichnet  ──> In-Game-Admin-Alarm
                                  ──> Discord-Webhook
                                  ──> Dashboard (falls aktiviert)
3. Modul hat seine BanAfterDetections-Anzahl erreicht?   ── nein ──> fertig
                                  │ ja
4. Spieler wird für einen Ban eingereiht
5. die Warteschlange wird bei der nächsten Ban-Welle ausgeführt
6. Ausführung: AutoBan.ExecuteCommand wird ausgeführt, Admins werden
   benachrichtigt, und (falls IntegratedBanSystem aktiv ist) wird die
   Ban-Zeile geschrieben und gekickt
7. beim nächsten Beitrittsversuch wird der Ban beim Login durchgesetzt
```

Die Schritte 3–4 sind pro Modul festgelegt — siehe
[`BanAfterDetections`](configuration.md#common-submodule-keys). Ein Modul
ohne diesen Schlüssel erkennt und benachrichtigt, bannt aber nie von selbst.

## Ban-Wellen {#ban-waves}

Ein eingereihter Ban wird ausgeführt, sobald **eines** der Folgenden
eintritt:

| Auslöser | Hinweise |
| ------- | ----- |
| Alle *N* Weltspeicherungen | *N* ist [`AutoBan."SaveWorld Cycles"`](#autoban) — standardmäßig `2`. Dies ist der normale Weg. |
| Der eingereihte Spieler trennt die Verbindung | Er wird beim Verlassen gebannt, statt bis zur nächsten Welle frei zu bleiben. |
| Das Modul hat `InstantBan: true` | Reserviert für Erkennungen ohne plausiblen Fehlalarm. |
| Ein Admin führt `ssac.banwave` aus | Leert die gesamte Warteschlange sofort. |

Zwischen dem Einreihen und der Ausführung kannst du die Warteschlange mit
`ssac.pendingbans` einsehen und sie mit `ssac.clearbanwave` leeren. Siehe
[Befehle](commands.md#ssacbanwave-ssacclearbanwave-ssacpendingbans).

### `AutoBan`

```json
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `SaveWorld Cycles` | number | `2` | Führt alle so viele Weltspeicherungen eine Ban-Welle aus. Bei einem 15-Minuten-Speicherintervall bedeutet `2` eine Verzögerung von höchstens 30 Minuten. |
| `ExecuteCommand` | string | `"banplayer {steamid} "` | Ein Konsolenbefehl, der für jeden gebannten Spieler ausgeführt wird. `{steamid}` wird durch dessen SteamID64 ersetzt. Leer lassen, um dich ausschließlich auf das integrierte Bansystem zu verlassen. |

Über `ExecuteCommand` bindest du ssAntiCheat in das ein, was du bereits
nutzt. Der Standardwert fügt den Spieler zu ARKs eigener Bannliste hinzu; du
könntest stattdessen den Ban-Befehl eines anderen Plugins aufrufen, oder
einen clusterweiten.

> 💡 **Tipp für Cluster.** ARKs `banplayer` gilt pro Server. Wenn du einen
> Cluster betreibst, richte `ExecuteCommand` entweder auf einen
> clusterfähigen Ban-Befehl aus, oder nutze das integrierte Bansystem mit
> einer **gemeinsam genutzten MySQL-Datenbank** über alle deine Server
> hinweg — dann setzt jeder Server jeden Ban beim Login durch.

## `IntegratedBanSystem`

Der eingebaute Ban-Speicher: Bans werden in deine MySQL-Datenbank
geschrieben und durchgesetzt, wenn der Spieler versucht, sich zu verbinden.

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
}
```

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Speichert und setzt Bans in MySQL durch. Wenn `false`, wird nur `AutoBan.ExecuteCommand` ausgeführt. |
| `UseIPBans` | boolean | `true` | Verweigert außerdem Verbindungen von der IP-Adresse eines gebannten Spielers. Siehe unten. |
| `UseHWIDBans` | boolean | `false` | Verweigert außerdem Verbindungen von der Hardware-ID eines gebannten Spielers. Erfordert die optionale begleitende Client-Mod, um eine zu erfassen — ohne sie bewirkt dies nichts. |
| `Exclude IPS` | array | `[]` | IP-Adressen, die nie als Zuordnung behandelt werden. Trage hier gemeinsam genutzte/NAT-Adressen ein. |
| `BanMessage` | string | siehe oben | Die Nachricht, die der Spieler sieht. |

Bans befinden sich in einer einzigen Tabelle (`ssAntiCheat_bans`), die
Steam-ID, IP, Hardware-ID, Grund, Bandatum und Ablauf enthält. Richtest du
mehrere Server auf dieselbe Datenbank aus, gilt ein Ban für alle.

### Ban-Nachricht {#ban-message}

`BanMessage` unterstützt zwei Platzhalter:

| Platzhalter | Wird ersetzt durch |
| ----------- | ------------- |
| `{reason}` | Den Ban-Grund. |
| `{ban_id}` | Die numerische Ban-ID — der Wert, den ein Admin für `ssac.unban` benötigt. |

```json
"BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nAppeal at: https://yourserver.example/appeal"
```

> ⚠️ **Ersetze die Platzhalter-URL.** Die mitgelieferte Nachricht verweist
> auf `store.example.com`. Füge immer `{ban_id}` ein — ohne sie hat ein
> Spieler, der gegen einen Ban Einspruch einlegt, nichts, worauf er sich
> beziehen kann, und du musst die Datenbank von Hand durchsuchen.

### IP-Zuordnungs-Bans {#ip-association-bans}

Ist `UseIPBans` aktiv, wird ein Spieler, der sich von einer Adresse aus
verbindet, die zu einem aktiven Ban gehört, abgewiesen **und als eigener Ban
erfasst**, sodass der Alt-Account von da an per Steam-ID gebannt ist. Eine
Benachrichtigung geht an [`AssociationBans`](configuration.md#webhooks), die
beide Accounts nennt.

Die Prüfung ist absichtlich konservativ — sie greift nur, wenn die IP
wirklich übereinstimmt, nicht in `Exclude IPS` steht und zu einem *anderen*
Steam-Account gehört.

> ⚠️ **IP-Bans erfassen auch Haushalte und gemeinsam genutzte
> Verbindungen.** Geschwister, Mitbewohner, ein Internetcafé oder ein
> gemeinsam genutzter VPN-Ausgang sehen alle wie derselbe Spieler aus.
> Beobachte den Zuordnungskanal eine Weile, bevor du ihm vertraust, und trage
> legitime gemeinsam genutzte Adressen in `Exclude IPS` ein.

## Ban-Dauern

| Wie der Ban erstellt wurde | Dauer |
| -------------------- | -------- |
| `ssac.ban` mit `d=…` | Läuft nach diesem Zeitraum ab. |
| `ssac.ban` ohne `d=…` | Dauerhaft. |
| Automatisch (das `BanAfterDetections` eines Moduls) | Dauerhaft. |

Um einen Ban aufzuheben, verwende seine Ban-ID:

```bash
ssac.unban 42
```

## Eine Erkennung prüfen, bevor sie zu einem Ban wird

Die Lücke zwischen Erkennung und Ban-Welle ist dein Prüffenster. Ein
Arbeitsablauf, der sich bewährt hat:

1. Die Discord-Benachrichtigung (oder der In-Game-Admin-Alarm) nennt den
   Spieler und das Modul.
2. `ssac.go` — beobachte ihn sofort, ohne Argument, um zur letzten
   Erkennung zu springen.
3. `!tracers` — beobachte seine Schüsse; Zielhilfe ist auf diese Weise mit
   bloßem Auge offensichtlich.
4. `ssac.pendingbans` — prüfe, ob er bereits eingereiht ist und wofür.
5. Entscheide: die Welle laufen lassen, `ssac.banwave`, um sofort zu
   handeln, oder `ssac.clearbanwave`, wenn du einen Fehlalarm vermutest.

Wenn ein Modul auf deinem Setup wiederholt Fehlalarme erzeugt, erhöhe seinen
Schwellenwert oder setze `OnlyAnalysis` dafür, statt es abzuschalten — siehe
[Tipp zur Feinabstimmung](configuration.md#common-submodule-keys).

---

**Nächste Schritte:**

- [Konfiguration](configuration.md) — jeder Schlüssel in der `config.json`.
- [Befehle](commands.md) — die vollständige Befehlsreferenz.
