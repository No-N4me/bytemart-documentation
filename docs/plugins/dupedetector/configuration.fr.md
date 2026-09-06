# Configuration

DupeDetector se configure via un unique fichier `config.json` dans le dossier
du plugin :

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/DupeDetector/config.json
```

Un second fichier, `config_commented.json`, est fourni à côté. Il s'agit de
la **même configuration avec des commentaires `//`** — lisez-le, mais ne le
renommez pas à la place de `config.json` (les commentaires ne sont pas du
JSON valide).

Les clés `LicenseKey`, `Verbose`, `LogToFile` et `Database` sont partagées
par chaque plugin Bytemart et sont documentées sur la page
**[Configuration commune](../index.md#common-configuration)**. Cette page ne
couvre que le bloc `DupeDetection`, propre à DupeDetector.

> 💡 **Validez avant de démarrer.** Validez toujours votre JSON après
> édition (par exemple avec [JSONLint](https://jsonlint.com/)). Un code
> d'erreur de chargement `1114` signifie une erreur de syntaxe JSON.

## `DupeDetection`

```json
"DupeDetection": {
  "AlertWebhook": "",
  "Punishment": {
    "PunishmentWebhook": "",
    "Command": "",
    "ClearInventory": false,
    "After": {
      "Min": 1,
      "Max": 1
    }
  }
}
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `AlertWebhook` | string | `""` | Webhook Discord pour les **détections** — un message par détection, nommant le joueur concerné. Vide signifie que les détections sont tout de même comptabilisées, mais que rien n'est publié. |

### `Punishment`

Ce qui se passe une fois qu'un joueur a accumulé suffisamment de détections.
Chaque champ est facultatif : laissez `Command` vide et `ClearInventory` à
false et DupeDetector devient purement un outil de signalement.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `PunishmentWebhook` | string | `""` | Webhook Discord pour les **punitions**. Séparé de `AlertWebhook` afin que vous puissiez diriger les punitions (bien plus rares) vers un canal réservé aux administrateurs. Vide signifie que rien n'est publié. |
| `Command` | string | `""` | Une commande console serveur exécutée contre le contrevenant lorsque le seuil est atteint — par exemple `banplayer {steamid}` ou `kickplayer {steamid}`. Vide signifie qu'aucune commande n'est exécutée. |
| `ClearInventory` | boolean | `false` | Vide l'inventaire du contrevenant dans le cadre de la punition. |
| `After.Min` | number | `1` | Limite inférieure du seuil de détection. |
| `After.Max` | number | `1` | Limite supérieure du seuil de détection. |

#### Le seuil `After`

`Min` et `Max` délimitent le nombre de détections qu'un joueur peut
accumuler avant que la punition ne se déclenche. Leur donner des valeurs
**différentes** rend le seuil exact imprévisible, ce qui est le réglage
recommandé — un nombre fixe et connu est quelque chose qu'un contrevenant
peut contourner.

- `"Min": 1, "Max": 1` — punit dès la première détection (par défaut).
- `"Min": 2, "Max": 5` — punit quelque part dans cette plage.

Les valeurs sont vérifiées lors du chargement, vous ne pouvez donc pas
configurer accidentellement un seuil qui ne se déclenche jamais.

> 💡 **Commencez en mode signalement seul.** Laissez `Command` vide et
> `ClearInventory` à false pendant les premiers jours, observez ce qui
> arrive dans `AlertWebhook`, et ce n'est qu'ensuite que vous déciderez de
> ce que doit être une punition.

## Webhooks

Les deux champs de webhook doivent être des **URL de webhook Discord**. Ces
préfixes sont acceptés :

```
https://discord.com/api/webhooks/...
https://discordapp.com/api/webhooks/...
https://ptb.discord.com/api/webhooks/...
https://canary.discord.com/api/webhooks/...
```

Toute autre valeur — y compris une chaîne vide — est abandonnée, avec une
ligne dans le journal du plugin le signalant. Un webhook vide n'est jamais
une erreur ; cela signifie simplement « n'envoyer rien ».

> 🔒 **Une URL de webhook est un identifiant.** Quiconque la possède peut
> publier dans votre canal. Gardez `config.json` hors des dépôts publics et
> des captures d'écran.

## Exemple complet

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  },
  "DupeDetection": {
    "AlertWebhook": "https://discord.com/api/webhooks/...",
    "Punishment": {
      "PunishmentWebhook": "https://discord.com/api/webhooks/...",
      "Command": "banplayer {steamid}",
      "ClearInventory": true,
      "After": {
        "Min": 2,
        "Max": 4
      }
    }
  }
}
```

---

**Étapes suivantes :**

- [Vue d'ensemble](index.md) — ce que couvre le plugin, l'installation et les commandes.
- [Configuration commune](../index.md#common-configuration) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
