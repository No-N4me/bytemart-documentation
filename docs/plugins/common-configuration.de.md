# Gemeinsame Konfiguration

Jedes Bytemart-Plugin wird über eine `config.json`-Datei konfiguriert, die sich im
eigenen Ordner des Plugins befindet:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/config.json
```

Die folgenden Schlüssel erscheinen auf der **obersten Ebene** dieser Datei und
verhalten sich in jedem Plugin identisch. Die einzelnen Plugin-Seiten dokumentieren
nur die Schlüssel, die für sie spezifisch sind, und verweisen für diese gemeinsamen
Schlüssel hierher zurück.

> 💡 **Validiere dein JSON.** Ein einziges falsch platziertes Komma oder
> Anführungszeichen verhindert, dass ein Plugin lädt. Prüfe deine Konfiguration nach
> jeder Änderung mit einem Validator wie
> [JSONLint](https://jsonlint.com/). Ein Ladefehler mit dem Code `1114` bedeutet fast
> immer einen JSON-Syntaxfehler.

## `LicenseKey`

```json
"LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE"
```

Dein Bytemart-Lizenzschlüssel. **Erforderlich.** Das Plugin authentifiziert diesen
Schlüssel beim Start gegen den Bytemart-Lizenzserver, und keine seiner Funktionen wird
aktiviert, bevor die Authentifizierung erfolgreich ist. Deinen Schlüssel findest du in
deinem [Bytemart-Dashboard](https://bytemart.net/).

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `LicenseKey` | string | — | Der für dein Plugin ausgestellte Lizenzschlüssel. Halte ihn geheim. |

## `Verbose`

```json
"Verbose": false
```

Aktiviert ausführliche Plugin-Protokollierung. Wenn `true`, gibt das Plugin zusätzliche
Diagnoseausgaben in der Serverkonsole aus — nützlich bei der Fehlersuche, ansonsten
störend. Lasse diesen Wert im Normalbetrieb auf `false`.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `Verbose` | boolean | `false` | Aktiviert ausführliche Konsolenprotokollierung (Debug-Ebene). |

## `LogToFile`

```json
"LogToFile": false
```

Wenn `true`, spiegelt das Plugin alles, was es protokolliert, in eine rotierende
Protokolldatei innerhalb seines eigenen Ordners:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/<PluginName>.log
```

Die Datei rotiert automatisch (etwa 5 MB pro Datei, bis zu 3 Dateien werden behalten).
Es wird nur die Ausgabe dieses einen Plugins geschrieben — das gemeinsame
ArkApi-/Server-Protokoll wird nie verändert. Dadurch lässt sich die Aktivität eines
einzelnen Plugins bei der Fehlerdiagnose leicht isolieren.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `LogToFile` | boolean | `false` | Spiegelt die Protokolle dieses Plugins in seine eigene rotierende `.log`-Datei. |

## `Database`

```json
"Database": {
  "MysqlHost": "localhost",
  "MysqlPort": 3306,
  "MysqlUser": "username",
  "MysqlPass": "password",
  "MysqlDB": "database"
}
```

MySQL-Verbindungs-Zugangsdaten. Plugins, die Daten dauerhaft speichern (Bestenlisten,
Abklingzeiten, Transaktionen, …), verbinden sich mit diesen Werten zu deinem
MySQL-/MariaDB-Server und erstellen die benötigten Tabellen beim ersten Start. Richte
jedes Plugin auf dieselbe Datenbank aus, sofern du keinen bestimmten Grund hast, sie zu
trennen.

| Feld | Typ | Standard | Beschreibung |
| ----- | ---- | ------- | ----------- |
| `MysqlHost` | string | `localhost` | Hostname oder IP deines MySQL-/MariaDB-Servers. |
| `MysqlPort` | number | `3306` | Serverport. |
| `MysqlUser` | string | — | Benutzername mit Zugriff auf die Datenbank. |
| `MysqlPass` | string | — | Passwort für diesen Benutzer. |
| `MysqlDB` | string | — | Name der zu verwendenden Datenbank. Sie muss bereits existieren; das Plugin erstellt seine eigenen Tabellen darin. |

> ⚠️ **Die Datenbank muss existieren.** Plugins erstellen ihre **Tabellen**
> automatisch, jedoch erstellen sie **nicht** die Datenbank selbst. Lege das in
> `MysqlDB` genannte Schema an und erteile dem Benutzer die Berechtigungen `SELECT`,
> `INSERT`, `UPDATE`, `DELETE` und `CREATE` darauf, bevor du den Server startest.
