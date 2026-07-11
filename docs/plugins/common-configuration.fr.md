# Configuration commune

Chaque plugin Bytemart se configure via un fichier `config.json` situé dans le
dossier propre au plugin :

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/config.json
```

Les clés ci-dessous apparaissent au **premier niveau** de ce fichier et se comportent
de manière identique dans chaque plugin. Les pages individuelles des plugins ne
documentent que les clés qui leur sont propres et renvoient ici pour les clés
partagées.

> 💡 **Validez votre JSON.** Une simple virgule ou guillemet mal placé empêchera un
> plugin de se charger. Après chaque modification, passez votre configuration dans un
> validateur tel que [JSONLint](https://jsonlint.com/). Un code d'erreur de chargement
> `1114` signifie presque toujours une erreur de syntaxe JSON.

## `LicenseKey`

```json
"LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE"
```

Votre clé de licence Bytemart. **Obligatoire.** Le plugin authentifie cette clé
auprès du serveur de licences Bytemart au démarrage, et aucune de ses fonctionnalités
ne s'active tant que l'authentification n'a pas réussi. Retrouvez votre clé sur votre
[tableau de bord Bytemart](https://bytemart.net/).

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `LicenseKey` | string | — | La clé de licence délivrée pour votre plugin. Gardez-la confidentielle. |

## `Verbose`

```json
"Verbose": false
```

Active la journalisation détaillée du plugin. Lorsque la valeur est `true`, le plugin
affiche des informations de diagnostic supplémentaires dans la console du serveur —
utile pour le dépannage, mais bruyant sinon. Laissez la valeur à `false` en
fonctionnement normal.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Verbose` | boolean | `false` | Active la journalisation détaillée (niveau debug) dans la console. |

## `LogToFile`

```json
"LogToFile": false
```

Lorsque la valeur est `true`, le plugin recopie tout ce qu'il journalise dans un
fichier journal avec rotation, à l'intérieur de son propre dossier :

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/<PluginName>.log
```

Le fichier effectue une rotation automatique (environ 5 Mo par fichier, jusqu'à
3 fichiers conservés). Seule la sortie de ce plugin est écrite — le journal partagé
d'ArkApi/du serveur n'est jamais modifié. Cela permet d'isoler facilement l'activité
d'un seul plugin lors du diagnostic d'un problème.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `LogToFile` | boolean | `false` | Recopie les journaux de ce plugin dans son propre fichier `.log` avec rotation. |

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

Identifiants de connexion MySQL. Les plugins qui persistent des données (classements,
temps de recharge, transactions, …) se connectent à votre serveur MySQL/MariaDB à
l'aide de ces valeurs et créent les tables dont ils ont besoin au premier lancement.
Faites pointer tous les plugins vers la même base de données, sauf si vous avez une
raison précise de les séparer.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `MysqlHost` | string | `localhost` | Nom d'hôte ou IP de votre serveur MySQL/MariaDB. |
| `MysqlPort` | number | `3306` | Port du serveur. |
| `MysqlUser` | string | — | Nom d'utilisateur ayant accès à la base de données. |
| `MysqlPass` | string | — | Mot de passe de cet utilisateur. |
| `MysqlDB` | string | — | Nom de la base de données à utiliser. Elle doit déjà exister ; le plugin y crée ses propres tables. |

> ⚠️ **La base de données doit exister.** Les plugins créent automatiquement leurs
> **tables**, mais ils ne créent **pas** la base de données elle-même. Créez le schéma
> nommé dans `MysqlDB` et accordez à l'utilisateur les permissions `SELECT`, `INSERT`,
> `UPDATE`, `DELETE` et `CREATE` sur celui-ci avant de démarrer le serveur.
