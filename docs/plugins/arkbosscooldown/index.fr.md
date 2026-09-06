# ⏳ ArkBossCooldown

ArkBossCooldown instaure un **temps de recharge à l'échelle du serveur entre
les débuts de combat de boss**. Les arènes de boss se rejoignent en
fabriquant un objet de tribut, et rien n'empêche un groupe d'en fabriquer
plusieurs à la suite — les téléportations s'empilent et les joueurs arrivent
dans l'arène déjà morts. Ce plugin fait en sorte que le serveur refuse un
début de combat de boss tant que le temps de recharge du précédent n'a pas
expiré.

Il est délibérément minimaliste : un temps de recharge, un message, une
liste d'objets de tribut.

## Ce qu'il fait

- **Un seul temps de recharge pour tout le serveur.** Le premier
  fabricage de tribut de boss l'arme ; tout autre fabricage de tribut est
  refusé tant qu'il n'a pas expiré. Ce n'est *pas* par joueur ni par tribu —
  si un groupe démarre un boss, tout le monde attend.
- **Le fabricage refusé ne coûte rien.** L'objet de tribut n'est pas
  consommé et aucune téléportation n'a lieu, de sorte qu'un joueur qui
  tombe sur le temps de recharge peut simplement réessayer une fois celui-ci
  écoulé.
- **Informe le joueur pourquoi.** Un message configurable de chat, de
  notification ou de diffusion affiche le temps restant. Il peut aussi être
  désactivé pour refuser silencieusement.
- **Fonctionne sur n'importe quelle carte, et avec des mods.** Les objets de
  tribut qui arment le temps de recharge ne sont qu'une liste de chemins de
  blueprint dans la configuration, vous pouvez donc ajouter des arènes
  moddées ou retirer des boss que vous ne voulez pas soumettre à la
  restriction.
- **Rien d'autre.** Les objets autres que ceux que vous listez se fabriquent
  tout à fait normalement.

> ℹ️ **Ceci est un anti-rebond, pas un verrouillage de boss.**
> `BossStartCooldown` vaut par défaut **5 secondes** — assez long pour
> absorber une rafale de clics répétés, assez court pour que personne ne le
> remarque. Si vous voulez une véritable limite « un boss par heure »,
> réglez-le sur un nombre bien plus grand et lisez d'abord la remarque sur
> les [redémarrages et rechargements](configuration.md#bossstartcooldown).

## Prérequis

| Prérequis | Remarques |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** ou plus récent | Le plugin ne se chargera pas sur des versions d'API antérieures. |
| MySQL / MariaDB | Le plugin se connecte au démarrage, des identifiants valides sont donc requis — mais ArkBossCooldown lui-même n'y stocke rien. Voir [Configuration commune](../index.md#database). |
| Une clé de licence Bytemart | Rien ne s'active tant que la clé n'a pas été authentifiée. |
| HTTPS sortant | Nécessaire pour la licence. |

## Installation

1. Assurez-vous d'avoir ArkApi **3.51+** installé sur votre serveur.
2. Configurez une base de données MySQL/MariaDB — voir
   [Configuration commune](../index.md#database). La base de données doit
   déjà exister.
3. Téléchargez `ArkBossCooldown.zip` depuis votre **tableau de bord
   Bytemart**.
4. Arrêtez le serveur (exécutez d'abord `saveworld`), ou déchargez toute
   version précédente avec `plugins.unload ArkBossCooldown`.
5. Extrayez l'archive dans un dossier `ArkBossCooldown` à l'intérieur de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Ouvrez `config.json` et renseignez votre `LicenseKey` et vos identifiants
   `Database`. Les valeurs par défaut pour tout le reste sont utilisables
   telles que livrées — voir [Configuration](configuration.md).
7. Démarrez le serveur et confirmez qu'aucune erreur n'apparaît pendant le
   démarrage.
8. Fabriquez deux fois de suite un tribut de boss pour vérifier que la
   seconde tentative est refusée et que le message apparaît.

> 💡 **Vous jouez sur une carte ou un mod absent de la liste par défaut ?**
> Activez [`TestMode`](configuration.md#testmode), fabriquez le tribut une
> fois, et copiez le chemin de blueprint que la console affiche dans
> `Bosses`. Puis désactivez à nouveau `TestMode`.

### Mise à jour

- **Manuelle :** `plugins.unload ArkBossCooldown`, remplacez les fichiers,
  puis `plugins.load ArkBossCooldown`.
- **Automatique (rechargement à chaud) :** renommez le nouveau
  `ArkBossCooldown.dll` en `ArkBossCooldown.dll.arkapi` et déposez-le dans
  le dossier du plugin — ArkApi charge la nouvelle version et décharge
  automatiquement l'ancienne.

ArkBossCooldown répare automatiquement sa propre configuration au
chargement : les clés manquantes sont ajoutées avec leurs valeurs par
défaut et votre original est d'abord sauvegardé dans `config.json.bak`. Une
incompatibilité de type (une chaîne là où un nombre est attendu) interrompt
le chargement à la place, avec une erreur nommant la clé.

## Commandes

L'accès console et RCON est un accès administrateur par définition, donc
celles-ci ne nécessitent aucune permission supplémentaire.

| Commande | Canaux | Description |
| ------- | -------- | ----------- |
| `ArkBossCooldown.help [page]` | Console, RCON | Liste paginée de chaque commande enregistrée. |
| `ArkBossCooldown.reload` | Console, RCON | Relit `config.json` sans redémarrer le serveur. |

`ArkBossCooldown.reload` reconstruit la liste des boss, la durée du temps de
recharge, `TestMode`, et les réglages de message à partir du disque. Elle ne
**réinitialise pas** un temps de recharge déjà en cours — recharger n'offre
pas un début de boss gratuit. Pour en réinitialiser un, déchargez puis
rechargez le plugin. Elle ne relance pas non plus la passe de réparation de
configuration, validez donc votre JSON avant de recharger.

## Dépannage

- **Le temps de recharge ne se déclenche jamais** — le tribut que vous
  fabriquez n'est probablement pas dans la liste `Bosses`. Activez
  `TestMode`, fabriquez-le, et lisez le chemin dans la console.
- **Le plugin ne se charge pas, code d'erreur `1114`** — une erreur de
  syntaxe JSON dans `config.json`. Passez-le dans
  [JSONLint](https://jsonlint.com/). Le long tableau `Bosses` rend une
  virgule égarée facile à manquer.
- **« License key is missing »** — `LicenseKey` contient encore la valeur
  d'espace réservé.
- **Le message n'apparaît pas** — vérifiez que `CooldownMessage.Enabled` est
  à `true`, et notez que `Scale` ne s'applique qu'au canal `Notification`.
- **Tout autre problème** — passez `LogToFile` à `true` et reproduisez le
  problème ; le plugin écrit son propre fichier `ArkBossCooldown.log` à
  rotation, à côté de `config.json`. Puis demandez sur le
  [Discord Bytemart](https://bytemart.net/discord).

---

**Étapes suivantes :**

- [Configuration](configuration.md) — le temps de recharge, le message, et la liste des boss.
- [Configuration commune](../index.md#common-configuration) — les clés partagées `LicenseKey`,
  `Database`, `LogToFile` et `Verbose`.
