# Configuration

ArkBossCooldown se configure via un unique fichier `config.json` dans le
dossier du plugin :

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ArkBossCooldown/config.json
```

Un second fichier, `config_commented.json`, est fourni à côté. Il s'agit de
la **même configuration avec des commentaires `//`** — lisez-le, mais ne le
renommez pas à la place de `config.json` (les commentaires ne sont pas du
JSON valide).

Les clés `LicenseKey`, `Verbose`, `LogToFile` et `Database` sont partagées
par chaque plugin Bytemart et sont documentées sur la page
**[Configuration commune](../index.md#common-configuration)**. Cette page
couvre les clés propres à ArkBossCooldown.

> 💡 **Validez avant de démarrer.** Validez toujours votre JSON après
> édition (par exemple avec [JSONLint](https://jsonlint.com/)). Un code
> d'erreur de chargement `1114` signifie une erreur de syntaxe JSON —
> facile à provoquer dans le long tableau `Bosses`.

## `TestMode`

```json
"TestMode": false
```

Lorsque la valeur est `true`, le plugin journalise dans la console du
serveur le **chemin de blueprint de chaque objet fabriqué par n'importe quel
joueur**. C'est ainsi que vous trouvez le chemin exact d'un objet de tribut
à mettre dans [`Bosses`](#bosses) :

1. Réglez `TestMode` sur `true` et rechargez (`ArkBossCooldown.reload`).
2. Fabriquez le tribut que vous voulez soumettre à la restriction.
3. Copiez le chemin depuis la ligne de la console — elle ressemble à
   `[TestMode] Crafted item blueprint: Blueprint'/Game/...'`.
4. Collez-le dans `Bosses`, remettez `TestMode` à `false`, et rechargez à
   nouveau.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `TestMode` | boolean | `false` | Journalise le chemin de blueprint de chaque objet fabriqué. |

> ⚠️ **Désactivez-le à nouveau.** Avec `TestMode` activé, un serveur très
> fréquenté écrit une ligne de console pour *chaque fabricage de chaque
> joueur*. C'est un outil de recherche, pas un réglage à laisser activé.

## `BossStartCooldown`

```json
"BossStartCooldown": 5
```

Le nombre de **secondes** que tout le serveur doit attendre entre deux
débuts de combat de boss. Le premier fabricage de tribut arme le temps de
recharge ; tout autre fabricage de tribut est refusé tant qu'il n'a pas
expiré.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `BossStartCooldown` | number | `5` | Secondes entre les débuts de combat de boss, à l'échelle du serveur. |

La valeur par défaut de `5` est un **anti-rebond** — elle absorbe une rafale
de clics répétés et est invisible en jeu normal. Des valeurs plus grandes
transforment le plugin en véritable limite de fréquence, ce qui fonctionne,
mais soyez conscient de deux choses :

- **C'est à l'échelle du serveur.** Un temps de recharge de 30 minutes
  signifie qu'une tribu démarrant un boss bloque toutes les autres tribus
  pendant 30 minutes. C'est une décision de conception pour votre serveur,
  pas un bug.
- **Cela ne survit pas à un redémarrage.** Le temps de recharge armé vit en
  mémoire, donc un redémarrage du serveur (ou un déchargement/rechargement
  du plugin) le réinitialise. Sans conséquence pour quelques secondes ; à
  garder à l'esprit si vous le réglez sur des heures.

`ArkBossCooldown.reload` prend en compte immédiatement une nouvelle valeur,
mais laisse délibérément tourner un temps de recharge déjà armé.

## `CooldownMessage`

```json
"CooldownMessage": {
  "Enabled": true,
  "Channel": "Notification",
  "Message": "Boss is on cooldown, please wait %delay%.",
  "Color": { "R": 255, "G": 0, "B": 0, "A": 255 },
  "Scale": 1.0,
  "Time": 5.0
}
```

Ce que voit le joueur dont le fabricage a été refusé. Seul ce joueur est
notifié — rien n'est diffusé au reste du serveur.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Mettez à `false` pour refuser le début de combat de boss silencieusement. |
| `Channel` | string | `"Notification"` | `"Chat"`, `"Notification"`, ou `"Broadcast"`. Une valeur non reconnue retombe sur `"Chat"`. |
| `Message` | string | voir ci-dessus | Le texte. Prend en charge les espaces réservés ci-dessous. |
| `Color` | object | rouge | `R`, `G`, `B`, `A`, chacun de `0` à `255`. `A` est l'opacité. |
| `Scale` | number | `1.0` | Taille du texte. **Canal `Notification` uniquement** — ignoré sur les autres. |
| `Time` | number | `5.0` | Secondes pendant lesquelles le message reste à l'écran. **`Notification` et `Broadcast` uniquement** — une ligne de chat reste dans le journal de chat quoi qu'il arrive. |

### Espaces réservés

| Espace réservé | Se développe en | Exemple |
| ----------- | ---------- | ------- |
| `%delay%` | Le temps restant, en toutes lettres | `1 Minute, 5 Seconds` |
| `%seconds%` | Le temps restant en simple nombre de secondes | `65` |

Utilisez `%delay%` pour un message lu par des joueurs, et `%seconds%`
lorsque vous voulez quelque chose de compact :

```json
"Message": "Boss on cooldown - %seconds%s remaining."
```

> 💡 **`Notification` accepte aussi une `Icon`.** Ajoutez une clé `"Icon"`
> avec un chemin de texture pour afficher une image à côté de la
> notification. Elle n'est pas dans la configuration livrée ; ajoutez-la
> vous-même si vous en voulez une — la réparation de configuration ne fait
> qu'*ajouter* les clés manquantes, elle survivra donc aux mises à jour.

## `Bosses`

```json
"Bosses": [
  "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'",
  "Blueprint'/Game/Fjordur/Boss/Arena/PrimalItem_BossTribute_FenrirBoss_Hard.PrimalItem_BossTribute_FenrirBoss_Hard'"
]
```

Les chemins de blueprint de chaque objet de tribut qui arme le temps de
recharge. **Tout ce qui n'est pas dans cette liste se fabrique tout à fait
normalement** — le plugin l'ignore.

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Bosses` | array of strings | Chemins de blueprint complets, incluant l'enveloppe `Blueprint'...'` et le nom d'asset dupliqué après le dernier `.`. Comparé exactement. |

La liste livrée couvre les objets de tribut pour **The Island**, **The
Center**, **Scorched Earth**, **Ragnarok**, **Aberration**, **Valguero**,
**Fjordur**, **Lost Island**, et **Crystal Isles**, à chaque niveau de
difficulté.

Pour soumettre autre chose à la restriction — une autre carte, une arène
moddée, ou un tribut personnalisé — utilisez [`TestMode`](#testmode) pour
capturer le chemin et l'ajouter ici. Pour *cesser* de restreindre un boss,
supprimez sa ligne.

> ⚠️ **Copiez les chemins exactement.** La correspondance est exacte
> caractère pour caractère sur le chemin complet. Une apostrophe finale
> manquante, un chemin raccourci, ou le nom d'asset écrit une seule fois au
> lieu de deux, tout cela signifie « aucune correspondance », et le tribut
> se fabriquera sans aucun temps de recharge. Il n'y a pas d'erreur pour un
> chemin non reconnu, vérifiez donc votre modification avec un vrai
> fabricage.

## Exemple complet

Une limite de 15 minutes annoncée dans le chat :

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "TestMode": false,
  "BossStartCooldown": 900,
  "CooldownMessage": {
    "Enabled": true,
    "Channel": "Chat",
    "Message": "A boss fight has already started. Next one available in %delay%.",
    "Color": { "R": 255, "G": 180, "B": 0, "A": 255 },
    "Scale": 1.0,
    "Time": 8.0
  },
  "Bosses": [
    "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'"
  ],
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  }
}
```

> ℹ️ **`Database` est requis mais inutilisé.** ArkBossCooldown se connecte
> au démarrage comme tout plugin Bytemart, mais n'y stocke rien de son
> propre chef. Faites-le pointer vers n'importe quelle base de données que
> le serveur peut atteindre.

---

**Étapes suivantes :**

- [Vue d'ensemble](index.md) — ce que fait le plugin, l'installation et les commandes.
- [Configuration commune](../index.md#common-configuration) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
