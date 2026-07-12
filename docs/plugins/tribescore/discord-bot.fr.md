# 🤖 Bot Discord

Tribescore est fourni avec un **bot Discord** compagnon qui amène la compétition de
votre serveur dans Discord — un classement en direct qui se rafraîchit
automatiquement, des commandes slash pour consulter n'importe quelle tribu, et un
système automatique de détection d'abus qui signale les scores suspects.

Le bot se connecte **directement à la même base de données MySQL/MariaDB** que celle
utilisée par le plugin. Il ne fait jamais que *lire* les tables de score du plugin — il
ne modifie jamais vos scores — il est donc sûr de l'exécuter en parallèle d'un serveur
en production.

## Fonctionnalités

- **Classement en direct** — publie et rafraîchit automatiquement les meilleures tribus
  dans un salon de votre choix, avec des flèches de mouvement ▲/▼ entre les périodes de
  scoring.
- **Rendu en image ou en embed** — affichez le classement sous forme d'embed Discord
  classique, ou sous forme de PNG soigné rendu à partir de l'un des sept designs
  intégrés (`podium`, `spotlight`, `cards`, `bars`, `terminal`, `ark`, `dark`). Les
  templates sont du simple HTML que vous pouvez restyler et personnaliser aux couleurs
  de votre serveur.
- **Commandes slash** — `/tribepoints` et `/getrank` permettent aux joueurs de consulter
  le score et le rang de n'importe quelle tribu. Les noms de commandes et les messages
  sont configurables.
- **Détection d'abus** — trois détecteurs indépendants publient des alertes lorsque le
  scoring paraît suspect, chacun accompagné d'un bouton *« Ignorer cette alerte »* pour
  faire taire les faux positifs.
- **Exécutable autonome** — distribué sous la forme d'un unique `.exe` Windows
  autonome. Aucun navigateur ni aucune installation supplémentaire n'est requis, même
  pour le rendu des images.

## Prérequis

- Le plugin Tribescore installé et écrivant dans une base de données MySQL/MariaDB (voir
  [Configuration](configuration.md) et
  [Configuration commune](../common-configuration.md#database)).
- Une application et un token de bot Discord, créés sur le
  [Portail développeur Discord](https://discord.com/developers/applications).
- Une machine Windows pour exécuter le bot — il peut fonctionner partout où la base de
  données est accessible.

## Installation

1. Téléchargez le bot depuis votre **tableau de bord Bytemart** et extrayez-le.
2. Ouvrez `config.yml` et configurez-le (voir ci-dessous).
3. Renseignez votre token de bot et le mot de passe de la base de données — soit
   directement dans `config.yml`, soit via les variables d'environnement
   `LEADERBOARD_BOT_TOKEN` et `MYSQL_PASSWORD` (recommandé, afin que les secrets restent
   hors du fichier de configuration).
4. Invitez le bot sur votre serveur, en lui accordant la permission d'envoyer des
   messages, des embeds et des pièces jointes dans les salons du classement et des
   alertes.
5. Lancez l'exécutable. Au premier démarrage, il enregistre ses commandes slash et
   publie le classement.

> 💡 Si vous renommez une commande slash dans `config.yml`, Discord peut avoir besoin
> que le bot soit expulsé puis réinvité avant que le changement ne prenne effet.

## Configuration (`config.yml`)

Le bot se configure entièrement via `config.yml`. Réglages principaux :

| Réglage | Description |
| ------- | ----------- |
| `bot-token` | Votre token de bot Discord. Laissez vide et définissez plutôt `LEADERBOARD_BOT_TOKEN`. |
| `period-start` | Expression cron indiquant le début d'une nouvelle période de scoring (le classement fige alors le mouvement). Voir [crontab.guru](https://crontab.guru/). |
| `timezone` | Fuseau horaire pour la planification et les comparaisons de transactions — doit correspondre au fuseau horaire de votre base de données. |
| `refresh-cooldown` | Nombre de secondes entre les rafraîchissements du classement au sein d'une période. |
| `leaderboard-channel` | L'identifiant du salon où le classement est publié. |
| `keep-leaderboard-history` | Lorsque `true`, publie un nouveau message de classement à chaque période au lieu de modifier le message existant. |
| `leaderboard-render-mode` | `embed` (embed Discord) ou `image` (PNG rendu). |
| `leaderboard-image` | Options du mode image : `template`, `title`, `lines`, `width`, `scale`. |
| `mysql` | Connexion à la base de données : `host`, `port`, `user`, `password`, `database`, `leaderboard-table`, `transactions-table`, `timezone`. |
| `commands` | Noms de commandes, descriptions et messages de réponse. |
| `abuse-detection` | Active et ajuste les modules de détection d'abus. |

> ⚠️ Les tables `leaderboard-table` et `transactions-table` doivent correspondre aux
> tables du plugin — par défaut `ts_leaderboard` et `ts_transactions`. Le bot lit ces
> tables et n'y écrit jamais.

### Affichage du classement

Choisissez le mode de rendu du classement avec `leaderboard-render-mode` :

```yaml
leaderboard-render-mode: "image"   # ou "embed"
leaderboard-image:
  template: "spotlight"   # podium | spotlight | cards | bars | terminal | ark | dark
  title: "Tribes Leaderboard"
  lines: 15               # nombre de tribus affichées
  width: 820
  scale: 2                # 2 = rendu net / retina
```

En mode `embed`, le classement est un embed textuel construit à partir de
`leaderboard_embed.json`. En mode `image`, il est rendu à partir d'un template HTML situé
sous `templates/leaderboard/<name>/`. Si le rendu de l'image échoue, le bot bascule
automatiquement sur l'embed, de sorte que le classement ne peut jamais être hors ligne.

### Commandes slash

| Commande (par défaut) | Description |
| ----------------- | ----------- |
| `/tribepoints <tribe>` | Affiche les points actuels d'une tribu. |
| `/getrank <tribe>` | Affiche le rang et les points d'une tribu. |

Les noms des deux commandes ainsi que leurs messages de réponse sont configurables sous
`commands` dans `config.yml`, à l'aide des placeholders `{tribe}`, `{points}` et
`{rank}`.

### Détection d'abus

Lorsque `abuse-detection.enabled` vaut `true`, le bot analyse périodiquement les
meilleures tribus et publie une alerte dans le `channel-id` configuré lorsqu'un module
se déclenche. Chaque alerte est accompagnée d'un bouton **« Ignorer cette alerte »** qui
supprime les répétitions futures pour cette paire de tribus.

| Module | Détecte |
| ------ | ------- |
| `rapid-increase` | Une tribu gagnant un nombre inhabituellement élevé de points au cours d'une même période de scoring. |
| `massive-transaction` | Un transfert unique de points au-dessus d'un seuil, d'une tribu vers une autre. |
| `prefered-source` | Une tribu recevant une grande part de ses points d'une seule tribu source (avec une vérification optionnelle de réciprocité « miroir »). |

Chaque module dispose de son propre `cooldown`, de ses seuils et de son `title` /
`message` d'alerte — les placeholders disponibles sont documentés directement dans
`config.yml`.

> ℹ️ Le bot crée une table qui lui est propre, `ts_ignored_alerts`, pour retenir les
> alertes que vous avez ignorées. C'est la seule table dans laquelle il écrit ; vos
> données de score ne sont jamais modifiées.
