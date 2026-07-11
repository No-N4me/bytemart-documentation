# Plugins

Bytemart-Plugins erweitern deinen ARK-Server um neue Funktionen. Jedes Plugin wird
als `.zip`-Datei ausgeliefert, die du von deinem **Bytemart-Dashboard** herunterlädst
und in den Plugin-Ordner deines Servers ablegst.

## Gemeinsame Konfiguration

Jedes Bytemart-Plugin liest eine übergeordnete `config.json`, die sich einen kleinen
Satz an Schlüsseln teilt — deinen Lizenzschlüssel, Protokollierungs-Schalter und die
MySQL-Datenbank-Zugangsdaten. Diese werden nur einmal, an einer zentralen Stelle,
dokumentiert:

- **[Gemeinsame Konfiguration](common-configuration.md)** — `LicenseKey`, `Verbose`,
  `LogToFile` und `Database`, gemeinsam für **alle** Plugins.

Die Konfigurationsseite jedes Plugins behandelt nur die Schlüssel, die für dieses
Plugin spezifisch sind, und verweist für die gemeinsamen Schlüssel zurück auf die
obige Seite.

## Verfügbare Plugins

| Plugin | Beschreibung |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | Ein kompetitives Punktesystem für Stämme: Stämme verdienen Punkte für das Zerstören feindlicher Strukturen, Dinos und Spieler im PvP, dargestellt über eine Bestenliste und Hologramme in der Spielwelt. |
| [ArkKits (Beispiel)](example-plugin/index.md) | Verteile anpassbare Startgegenstände, Dinos und Buffs an Spieler basierend auf Berechtigungen. |
