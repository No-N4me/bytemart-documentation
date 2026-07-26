# Plugins

Les plugins Bytemart étendent votre serveur ARK avec de nouvelles fonctionnalités.
Chaque plugin est distribué sous forme d'un `.zip` que vous téléchargez depuis votre
**tableau de bord Bytemart** et déposez dans le dossier de plugins de votre serveur.

## Configuration partagée

Chaque plugin Bytemart lit un `config.json` de premier niveau qui partage un petit
ensemble de clés — votre clé de licence, les commutateurs de journalisation et les
identifiants de la base de données MySQL. Elles sont documentées une seule fois, à un
seul endroit :

- **[Configuration commune](common-configuration.md)** — `LicenseKey`, `Verbose`,
  `LogToFile` et `Database`, communes à **tous** les plugins.

La page de configuration propre à chaque plugin ne couvre que les clés spécifiques à
ce plugin et renvoie à la page ci-dessus pour les clés partagées.

## Plugins disponibles

| Plugin | Description |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | Un système compétitif de score de tribu : les tribus gagnent des points en détruisant les structures, dinos et joueurs ennemis en PvP, le tout mis en avant via un classement et des hologrammes affichés dans le monde. |
