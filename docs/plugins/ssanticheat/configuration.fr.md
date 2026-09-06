# Configuration

ssAntiCheat se configure via un unique fichier `config.json` dans le dossier du
plugin :

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ssAntiCheat/config.json
```

Un second fichier, `config_commented.json`, est fourni à côté. Il s'agit de la
**même configuration avec des commentaires `//`** — lisez-le, mais ne le
renommez pas à la place de `config.json` (les commentaires ne sont pas du JSON
valide).

Les clés `LicenseKey`, `Verbose`, `LogToFile` et `Database` sont partagées par
chaque plugin Bytemart et sont documentées sur la page
**[Configuration commune](../index.md#common-configuration)**. Cette page ne
couvre que les clés propres à ssAntiCheat.

> 💡 **Validez avant de démarrer.** Validez toujours votre JSON après édition
> (par exemple avec [JSONLint](https://jsonlint.com/)). Un code d'erreur de
> chargement `1114` signifie une erreur de syntaxe JSON.

> ⚠️ **Les noms de clés sont critiques — copiez-les exactement.** Plusieurs
> clés contiennent des espaces (`"Join Tracker"`, `"SaveWorld Cycles"`,
> `"Block Dedi Fill"`) et certaines portent une faute d'orthographe historique
> (`Threshole`, `additionnalData`). Elles sont comparées caractère pour
> caractère. « Corriger » une orthographe désactive silencieusement la
> fonctionnalité.

## Configuration auto-réparatrice

À chaque chargement, ssAntiCheat compare votre `config.json` au schéma avec
lequel il a été construit :

- **Les clés manquantes** sont ajoutées avec leurs valeurs par défaut, et la
  console affiche exactement ce qui a été ajouté. Votre fichier original est
  d'abord copié dans `config.json.bak`.
- **Les incompatibilités de type** (une chaîne là où un nombre est attendu, et
  ainsi de suite) **interrompent le chargement** avec une erreur nommant la
  clé — le plugin ne s'exécute pas sur une configuration à laquelle il ne peut
  pas faire confiance.

Cela signifie qu'une mise à jour introduisant de nouvelles clés ne cassera pas
votre serveur, et que vous pouvez toujours réduire votre configuration aux
seules clés qui vous intéressent.

---

## Clés de premier niveau {#top-level-keys}

```json
"Debug": false,
"Use Discord": true,
"UseDiscordURL": true,
"SteamAPIKey": "",
"CommandPrefix": "!",
"Send Alert to Ingame Admins when someone is detected using a cheat": true
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Debug` | boolean | `false` | Indicateur de débogage interne. Laissez-le à `false` — utilisez [`Verbose`](../index.md#verbose) pour les sorties de dépannage. |
| `Use Discord` | boolean | `true` | Commutateur principal des alertes Discord. Si `false`, aucun embed de détection ou de bannissement n'est publié où que ce soit. |
| `UseDiscordURL` | boolean | `true` | Indique si les embeds Discord incluent les images d'icône/miniature de ssAntiCheat. Purement esthétique. |
| `SteamAPIKey` | string | `""` | Une [clé Steam Web API](https://steamcommunity.com/dev/apikey). Requise uniquement par la passerelle de connexion (vérifications de temps de jeu / âge du compte / VAC). Laissez vide si vous ne l'utilisez pas. |
| `CommandPrefix` | string | `"!"` | Le préfixe des commandes de chat d'administration en jeu. Voir [Commandes](commands.md#chat-commands). |
| `Send Alert to Ingame Admins when someone is detected using a cheat` | boolean | `true` | Diffuse une alerte de détection colorée à chaque administrateur en ligne. |

## Webhooks {#webhooks}

```json
"DefaultWebhookUrl": "",
"BanWebhookUrl": "",
"AssociationBans": "",
"AdminTrollingWebhook": ""
```

Les quatre sont des URL de webhook Discord, et toutes sont livrées **vides**.
Un webhook vide signifie « n'envoyer rien » — ce n'est jamais une erreur.

| Champ | Description |
| ----- | ----------- |
| `DefaultWebhookUrl` | Où vont les détections lorsque le module n'a pas son propre webhook. C'est celui à renseigner en premier. |
| `BanWebhookUrl` | Où vont les alertes de **bannissement**. Retombe sur `DefaultWebhookUrl` si vide. |
| `AssociationBans` | Où vont les alertes de bannissement par **association d'IP** — c'est-à-dire un nouveau compte surpris en train de se connecter depuis l'IP d'un joueur banni. Voir [Bannissements et détections](bans.md#ip-association-bans). |
| `AdminTrollingWebhook` | Journal d'audit des commandes de chat d'administration en jeu : qui a exécuté quoi, sur qui, et où. |

N'importe quel module individuel peut également avoir sa propre clé
`WebhookUrl`, qui remplace `DefaultWebhookUrl` pour ce module uniquement.

> 🔒 **Une URL de webhook est un identifiant.** Quiconque la possède peut
> publier dans votre canal. Gardez `config.json` hors des dépôts publics et
> des captures d'écran.

## `Dashboard`

```json
"Dashboard": {
  "Enabled": false,
  "LivePositions": false
}
```

Télémétrie facultative vers le tableau de bord ssAnticheat : un flux de
détections et de bannissements en direct, un historique des bannissements et
un état de santé de base du serveur. **Les deux clés sont à `false` par
défaut** — rien ne quitte votre machine tant que vous ne les activez pas.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `false` | Commutateur principal de la télémétrie du tableau de bord. |
| `LivePositions` | boolean | `false` | Envoie en plus les positions des joueurs pour que le tableau de bord puisse afficher une carte en direct. C'est en pratique une vue en direct de l'emplacement de chaque joueur — laissez-la désactivée sauf si c'est ce que vous voulez. |

Utilisez [`ssac.status`](commands.md#ssacstatus) pour vérifier si la
télémétrie circule réellement, et
[`ssac.testdetection`](commands.md#ssactestdetection) pour envoyer une
détection simulée dans le pipeline.

## `Join Tracker`

```json
"Join Tracker": {
  "Enabled": true,
  "Include IP": true,
  "JoinLogs": ""
}
```

Publie un embed Discord à chaque connexion d'un joueur, avec son nom, son
Steam ID, sa tribu et son lieu d'apparition.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Active/désactive la journalisation des connexions. |
| `Include IP` | boolean | `true` | Inclut l'adresse IP de connexion dans l'embed. |
| `JoinLogs` | string | `""` | URL de webhook pour les journaux de connexion. Vide signifie que les journaux de connexion sont collectés mais non publiés. |

> ⚠️ **Les adresses IP sont des données personnelles.** Si vous activez
> `Include IP`, envoyez les journaux de connexion vers un canal privé,
> réservé aux administrateurs, et vérifiez ce que vos règles locales exigent
> avant de les conserver.

## `Admin ESP`

Réglages de la surcouche ESP d'administration en jeu, activée par
administrateur avec la [famille de commandes `!esp`](commands.md#chat-commands).

```json
"Admin ESP": {
  "Enabled": true,
  "RefreshTime": 0.1,
  "Range": 30000,
  "Structure ESP": ["Box"]
}
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Réservé. L'accès aux commandes ESP est conditionné par le statut d'administrateur ARK, pas par cette clé. |
| `RefreshTime` | number | `0.1` | Durée de vie de chaque étiquette/boîte affichée, en secondes. Plus bas = plus fluide, plus d'appels de rendu côté client. |
| `Range` | number | `30000` | Rayon de scan (unités Unreal) autour de l'administrateur. |
| `Structure ESP` | array | `["Box"]` | Sous-chaînes des noms de blueprint de structures à surligner lorsque l'ESP structures est actif. `"Box"` correspond aux coffres de stockage ; ajoutez par exemple `"Vault"` ou `"Turret"`. |

## `ServerCrash`

```json
"ServerCrash": {
  "SaveWorld": true,
  "AutomaticRestart": true
}
```

Que faire lorsque le processus du serveur plante.

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `SaveWorld` | boolean | `true` | Tente une sauvegarde du monde depuis le gestionnaire de crash, afin qu'un crash ne coûte que quelques minutes au lieu de tout l'intervalle de sauvegarde. |
| `AutomaticRestart` | boolean | `true` | Redémarre automatiquement le serveur après un court délai suivant le crash. Désactivez ceci si votre gestionnaire de serveur (ASM, ArkServerManager, un wrapper de service, …) redémarre déjà à la sortie du processus — sinon vous obtenez deux redémarrages en compétition l'un avec l'autre. |

## `Fixes`

Correctifs pour des glitches serveur bien connus et des méthodes d'exploit.
Ce ne sont pas des détecteurs — personne n'est signalé ni banni par eux ; le
comportement défectueux est simplement empêché.

```json
"Fixes": {
  "Scout Glitch Fix":         { "Enabled": true },
  "Handcuff Glitch Fix":      { "Enabled": false },
  "Player Already Connected": { "Enabled": true },
  "Pull Fix":                 { "Enabled": true },
  "Lag Protector":            { "Enabled": true },
  "Dupe Fix":                 { "Enabled": true }
}
```

| Correctif | Défaut | Ce qu'il fait |
| --- | ------- | ------------ |
| `Scout Glitch Fix` | `true` | Corrige le comportement de portage du Scout, fermant le glitch bien connu du Scout. |
| `Handcuff Glitch Fix` | `false` | Rééquipe les menottes sur un joueur qui se reconnecte après s'être déconnecté alors qu'il était menotté — fermant l'astuce « se déconnecter pour échapper aux menottes ». Désactivé par défaut ; activez-le si les menottes font partie de la façon dont vos administrateurs ou joueurs opèrent. |
| `Player Already Connected` | `true` | Efface la session bloquée qui produit l'erreur « player already connected », afin que les joueurs n'aient pas à attendre qu'elle se résorbe. |
| `Pull Fix` | `true` | Bloque l'exploit de **traction serveur** (server pull) de Structures Plus, où une traction est utilisée pour extraire en masse des objets restreints (tributs de boss et similaires) d'un conteneur. Le message « You can't pull this craft » est affiché au joueur. |
| `Lag Protector` | `true` | Protection anti-griefing contre les astuces de lag délibéré du serveur. **Nécessite des clés supplémentaires — voir ci-dessous.** |
| `Dupe Fix` | `true` | Détruit les caches d'objets de mort S+ dupliquées : un second cache de mort apparaissant par-dessus un cache existant est supprimé au lieu de doubler son contenu. |

Chaque correctif prend un indicateur `Enabled`. `Lag Protector` en prend trois
de plus.

### Lag Protector

`Lag Protector` est livré avec `Enabled` uniquement, et chacune de ses
protections est **optionnelle** — ajoutez les clés vous-même pour les
activer :

```json
"Lag Protector": {
  "Enabled": true,
  "WhipProtection": true,
  "BlueprintProtection": true,
  "LagWebhook": ""
}
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `WhipProtection` | boolean | `false` | Expulse un joueur qui tire une arme dans une zone suffisamment remplie de structures pour faire ramer le serveur — le classique griefing « fouet dans une méga-base ». |
| `BlueprintProtection` | boolean | `false` | Expulse un joueur qui met en file une rafale invraisemblable de crafts de blueprint en quelques secondes. |
| `LagWebhook` | string | `""` | Webhook pour les expulsions liées à la protection contre le lag. Retombe sur l'envoi de rien si vide. |

Les expulsions issues de ce correctif portent un code de raison
délibérément opaque, afin qu'un griefer n'en apprenne rien : `0x7E3` pour la
protection contre le fouet, `0x4DE` pour la protection contre les blueprints.

> ℹ️ **Les clés que vous ajoutez vous-même sont conservées.** L'auto-réparation
> de la configuration ne fait *qu'ajouter* les clés manquantes — elle ne
> supprime jamais les clés qu'elle ne reconnaît pas, de sorte que les trois
> ci-dessus survivent aux mises à jour du plugin.

## `IntegratedBanSystem` et `AutoBan`

Ces deux sections pilotent le pipeline de bannissement et sont documentées
en détail sur la page **[Bannissements et détections](bans.md)** :

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
},
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

> ⚠️ **Changez l'URL du `BanMessage`.** Elle est livrée avec un espace
> réservé `example.com`. Faites-la pointer vers votre propre boutique ou
> page d'appel.

---

## `Modules`

Chaque détecteur se trouve sous `Modules`, dans l'une des quatre catégories :

| Catégorie | Ce qu'elle couvre |
| -------- | -------------- |
| `CombatCheats` | Triches en combat — assistance de visée, manipulation de cadence de tir et de munitions, automatisation de consommables. |
| `MiscCheats` | Automatisation client et outillage côté client — auto-loot, auto-craft, spoofers, anomalies de timing, plus la passerelle de connexion. |
| `Mod` | Vérifications nécessitant le mod client compagnon optionnel (y compris la capture d'ID matériel et la détection de contournement de mod). Inerte tant que ce mod n'est pas déployé — demandez sur le [Discord Bytemart](https://bytemart.net/discord) si vous le souhaitez. |
| `Exploits` | Exploits de jeu et de mods connus : méthodes de duplication, vecteurs de crash, déblocages, abus de montures et de structures, protection des administrateurs, et plus. |

La forme est toujours la même :

```json
"Modules": {
  "CombatCheats": {
    "Enabled": true,
    "SubModules": {
      "AutoFlak":   { "Enabled": true, "Block": true, "TimesUntilDetect": 6 },
      "NoOverheat": { "Enabled": true, "Block": true, "BanAfterDetections": 2 },
      "...":        { "...": "..." }
    }
  },
  "MiscCheats": { "Enabled": true, "SubModules": { "...": "..." } },
  "Mod":        { "Enabled": true, "SubModules": { "...": "..." } },
  "Exploits":   { "Enabled": true, "SubModules": { "...": "..." } }
}
```

Un `Enabled: false` sur une catégorie désactive **tous** les modules qu'elle
contient, quoi que disent les indicateurs individuels. Votre `config.json`
livré contient la liste complète des sous-modules avec des valeurs par
défaut raisonnables — la référence ci-dessous explique les clés que vous y
trouverez.

### Clés communes des sous-modules {#common-submodule-keys}

| Clé | Type | Signification |
| --- | ---- | ------- |
| `Enabled` | boolean | Active ou désactive ce détecteur spécifique. |
| `Block` | boolean | Empêche l'action trichée en plus de la signaler. Si `false`, l'action passe et vous n'obtenez que l'alerte — utile pendant que vous gagnez confiance en un module sur votre propre serveur. |
| `BanAfterDetections` | number | Met le joueur en file pour un bannissement après ce nombre de détections **par ce module**. Absent ou `0` signifie que ce module ne bannit jamais de lui-même. |
| `InstantBan` | boolean | Exécute ce bannissement immédiatement au lieu d'attendre la prochaine vague de bannissement. |
| `OnlyAnalysis` | boolean | Détecte et enregistre, mais ne publie pas sur votre webhook Discord. Un mode discret pour évaluer un module. |
| `WebhookUrl` | string | Envoie les alertes de ce module vers un webhook spécifique au lieu de `DefaultWebhookUrl`. |
| `Threshole` / `*Threshold` | number | La sensibilité du module. Plus élevé = plus de preuves requises avant qu'il ne se déclenche. L'orthographe `Threshole` est intentionnelle dans les clés qui l'utilisent. |
| `BlockMovement` | boolean | Utilisé par quelques modules de déblocage : fige le contrevenant sur place plutôt que de simplement le signaler. |

Certains modules ajoutent leurs propres clés — par exemple une liste de noms
de blueprint à exclure d'une vérification, ou un indicateur supplémentaire
pour une variante spécifique de l'exploit. Elles sont décrites dans
`config_commented.json` lorsqu'elles ne sont pas évidentes.

> 💡 **Conseils de réglage.** Commencez avec les valeurs par défaut livrées.
> Si un module produit des faux positifs sur votre configuration, préférez
> augmenter son seuil ou son `BanAfterDetections` plutôt que de le
> désactiver purement et simplement — et activez `OnlyAnalysis` pendant que
> vous l'observez.

### La passerelle de connexion

Un module de `MiscCheats` mérite d'être mentionné à part car il nécessite
une configuration externe : le **traqueur de session** vérifie un joueur qui
se connecte via la Steam Web API et peut rejeter les comptes qui semblent
jetables.

```json
"SessionTracker": {
  "Enabled": true,
  "WebhookUrl": "",
  "Checks": {
    "AccountRestrictions": {
      "MinGameHours": 30,
      "BlockMinGameHours": false,
      "LogMinGameHours": true,
      "MinAccountAgeDays": 30,
      "BlockMinAccountAgeDays": false,
      "LogMinAccountAgeDays": true
    },
    "VacBanRestrictions": {
      "Block": false,
      "RecentDaysThreshole": 90,
      "Log": true
    }
  }
}
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `WebhookUrl` | string | `""` | Webhook pour les résultats de la passerelle. Retombe sur `DefaultWebhookUrl`. |
| `MinGameHours` | number | `30` | Temps de jeu ARK minimum, en heures. |
| `BlockMinGameHours` | boolean | `false` | Expulse les joueurs en dessous de ce temps de jeu. |
| `LogMinGameHours` | boolean | `true` | Signale les joueurs en dessous de ce temps de jeu. |
| `MinAccountAgeDays` | number | `30` | Âge minimum du compte Steam, en jours. |
| `BlockMinAccountAgeDays` | boolean | `false` | Expulse les comptes plus jeunes que cela. |
| `LogMinAccountAgeDays` | boolean | `true` | Signale les comptes plus jeunes que cela. |
| `VacBanRestrictions.RecentDaysThreshole` | number | `90` | À quel point un bannissement VAC doit être récent pour compter. |
| `VacBanRestrictions.Block` | boolean | `false` | Expulse les joueurs ayant un bannissement VAC récent. |
| `VacBanRestrictions.Log` | boolean | `true` | Signale les joueurs ayant un bannissement VAC récent. |

> ℹ️ **Nécessite `SteamAPIKey`.** Sans clé, ces vérifications ne peuvent pas
> s'exécuter. Notez également qu'un joueur avec un profil Steam **privé**
> masque son temps de jeu — décidez délibérément si vous voulez activer
> `Block*`, car cela écartera certains joueurs légitimes.

---

**Étapes suivantes :**

- [Commandes](commands.md) — les commandes console/RCON et d'administration en jeu.
- [Bannissements et détections](bans.md) — seuils, vagues de bannissement, bannissements IP/HWID, débannissement.
- [Configuration commune](../index.md#common-configuration) — `LicenseKey`, `Database`,
  `LogToFile`, `Verbose`.
