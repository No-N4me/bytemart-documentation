# Commandes

ssAntiCheat propose deux types de commandes : les commandes **console/RCON**
préfixées par `ssac.`, et les commandes de **chat en jeu** préfixées par `!`
(configurable via [`CommandPrefix`](configuration.md#top-level-keys)).

L'accès console et RCON est un accès administrateur par définition, donc les
commandes `ssac.` ne nécessitent aucune permission supplémentaire. Les
commandes de chat vérifient que vous êtes un **administrateur du serveur**
(`enablecheats`) et ne font silencieusement rien sinon.

## Commandes console / RCON

| Commande | Canaux | Description |
| ------- | -------- | ----------- |
| `ssac.help [page]` | Console, RCON | Liste paginée de chaque commande enregistrée. |
| `ssac.status` | Console, RCON | Licence, ID du serveur, et statut de la télémétrie du tableau de bord. |
| `ssac.detections` | Console, RCON | Liste les détections récentes, regroupées par Steam ID. |
| `ssac.pendingbans` | Console, RCON | Liste les joueurs en file d'attente pour la prochaine vague de bannissement. |
| `ssac.banwave` | Console, RCON | Exécute immédiatement la vague de bannissement en attente. |
| `ssac.clearbanwave` | Console, RCON | Abandonne tous les bannissements en attente sans bannir personne. |
| `ssac.ban <steamid> [r=<reason>] [d=<duration>]` | Console, RCON | Bannit un joueur. |
| `ssac.unban <ban-id>` | Console, RCON | Annule un bannissement par son ID de bannissement. |
| `ssac.testdetection [steamid] [module]` | Console, RCON | Envoie une détection simulée au tableau de bord. |
| `ssac.go [steamid]` | Console | Passe en spectateur sur un joueur — celui indiqué, ou le dernier détecté. |
| `ssac.command <reason> <command...>` | Console | Exécute une commande console en votre nom, en le consignant. |

`ssac.go` et `ssac.command` agissent sur *votre* personnage, elles ne
fonctionnent donc que depuis la console en jeu — il n'y a pas de personnage
derrière une session RCON.

### `ssac.status`

La première chose à exécuter après l'installation, et la première chose que
le support vous demandera. Elle affiche la version du plugin, si la licence
s'est authentifiée, l'ID de ce serveur, la carte et le nom du serveur, et —
lorsque la télémétrie du tableau de bord est active — le point de
terminaison, si le serveur s'est enregistré, le résultat du dernier envoi et
la profondeur de la file d'attente.

```bash
ssac.status
```

Une profondeur de file non nulle qui ne se résorbe jamais signifie que le
point de terminaison du tableau de bord est inaccessible ou rejette vos
événements.

### `ssac.detections`

Liste les détections conservées en mémoire (environ la **dernière heure**),
regroupées par Steam ID, avec le module qui s'est déclenché pour chacune.

```bash
ssac.detections
```

> ℹ️ **Les détections ne sont qu'en mémoire.** Elles ne survivent pas à un
> redémarrage du serveur. Les bannissements, si — ils sont stockés dans
> MySQL. Utilisez vos webhooks Discord comme trace permanente des
> détections.

### `ssac.ban` / `ssac.unban`

```
ssac.ban <steamid> [r=<reason>] [d=<duration>]
ssac.unban <ban-id>
```

| Argument | Description |
| -------- | ----------- |
| `<steamid>` | Le SteamID64 de la cible (17 chiffres). |
| `r=<reason>` | Raison du bannissement. Entourez-la de guillemets si elle contient des espaces. Par défaut, `No reason provided`. |
| `d=<duration>` | Durée du bannissement, composée de parties `d` / `h` / `m` / `s` — p. ex. `7d`, `12h30m`, `1d6h`. Omettez-la pour un bannissement **permanent**. |

```bash
ssac.ban 76561198000000000 r="Aimbot" d=7d
ssac.ban 76561198000000000                  # permanent, sans raison
ssac.unban 42                               # lève le bannissement n°42
```

Le bannissement est écrit dans MySQL avec l'IP du joueur (et son ID matériel
s'il en a été capturé un), et le joueur est immédiatement expulsé s'il est
en ligne avec votre [`BanMessage`](bans.md#ban-message). `ssac.unban`
prend l'**ID de bannissement**, pas le Steam ID — `ssac.detections` et
l'embed Discord de bannissement l'affichent tous les deux, et c'est
également le `{ban_id}` dans le message d'expulsion que voit le joueur.

### `ssac.banwave` / `ssac.clearbanwave` / `ssac.pendingbans`

```bash
ssac.pendingbans     # qui est en file d'attente, et pourquoi
ssac.banwave         # bannit tout le monde maintenant
ssac.clearbanwave    # laisse-les tous tranquilles
```

Les bannissements en attente sont mis en file par les modules de détection
et s'exécutent normalement selon un planning — voir
[Bannissements et détections](bans.md#ban-waves). Ces trois commandes vous
permettent d'examiner la file, de la vider par anticipation, ou de vider une
file que vous pensez être un faux positif.

### `ssac.go`

Vous place en mode spectateur et vous déplace vers un joueur.

```bash
ssac.go                       # le joueur détecté le plus récemment
ssac.go 76561198000000000     # un joueur spécifique
```

Sans argument, elle suit la dernière détection, ce qui est ce que vous
voulez en réaction à une alerte. Avec un Steam ID, elle cible ce joueur et
affiche le nom résolu, afin que vous puissiez confirmer avoir attrapé la
bonne personne.

### `ssac.command`

Exécute une commande console en votre nom et enregistre que ssAntiCheat l'a
sanctionnée, afin que le module de protection des administrateurs ne vous
signale pas pour l'avoir utilisée.

```
ssac.command <reason> <command...>
```

```bash
ssac.command investigating_dupe giveitemnum 1 1 0 0
```

Le premier argument est une raison en texte libre pour la trace d'audit ;
tout ce qui suit est la commande à exécuter.

### `ssac.testdetection`

Émet une détection **simulée** afin que vous puissiez vérifier votre
pipeline de tableau de bord sans attendre un vrai tricheur. Elle nécessite
que [`Dashboard.Enabled`](configuration.md#dashboard) soit à `true`.

```
ssac.testdetection [steamid] [module]
```

```bash
ssac.testdetection                              # une détection pour vous-même (depuis la console en jeu)
ssac.testdetection 76561198000000000 AutoLoot   # pour un joueur spécifique, libellée AutoLoot
```

Exécutée sans arguments depuis la console en jeu, elle vous cible **vous**,
de sorte que la ligne du tableau de bord affiche un vrai nom, une vraie
tribu et une vraie position. Les événements de test sont marqués comme
simulés et sont exclus des statistiques de détection réelles. Ils ne sont
pas envoyés à Discord et ne bannissent jamais personne.

---

## Commandes de chat {#chat-commands}

Saisies dans le chat en jeu, réservées aux administrateurs, préfixées par
[`CommandPrefix`](configuration.md#top-level-keys) (`!` par défaut).
Lorsqu'une commande prend `<steamid>`, vous pouvez l'omettre et elle agit sur
**celui que vous regardez**.

Les noms sont reconnus exactement tels qu'écrits ci-dessous, y compris la
casse.

### Investigation

| Commande | Description |
| ------- | ----------- |
| `!esp` | Active/désactive l'ESP pour vous-même. |
| `!espPlayers` | Active/désactive l'ESP joueurs : nom, santé et arme actuelle au-dessus de chaque joueur. |
| `!EspStruct` | Active/désactive l'ESP structures. |
| `!espset <name>` | Surligne les structures dont le nom de blueprint contient `<name>`, en plus de la liste [`Structure ESP`](configuration.md#admin-esp). |
| `!espHideEmpty` | Masque les conteneurs vides dans l'ESP structures. |
| `!tracers` | Dessine chaque tir à proximité sous forme de ligne de tracé, colorée selon la partie du corps touchée. L'outil le plus utile pour juger d'une assistance de visée à l'œil nu. |
| `!vanish` | Active/désactive votre propre invisibilité. |
| `!spawn` | Réapparaît à votre vue actuelle, puis active le mode créatif, l'invisibilité face aux ennemis et le vol. |
| `!cloud <steamid>` | Affiche les objets envoyés (tribut) d'un joueur, pour vous seul. |

`!esp` est le commutateur principal — `!espPlayers` et `!EspStruct` ne
s'affichent que lorsque l'ESP est activé pour vous.

### Interaction

Celles-ci agissent directement sur un suspect. Utilisez-les délibérément :
elles sont visibles par le joueur et peuvent alerter un tricheur sur lequel
vous êtes encore en train de rassembler des preuves.

| Commande | Description |
| ------- | ----------- |
| `!unequip <steamid>` | Retire l'armure équipée d'un joueur. |
| `!dropweapon <steamid>` | Force un joueur à lâcher son arme tenue. |
| `!jump <steamid>` | Force un joueur à sauter. |
| `!punch <steamid>` | Déclenche le coup de poing propulsé du gantelet tek d'un joueur. |
| `!tekjump <steamid>` | Déclenche le boost du plastron tek d'un joueur. |
| `!requestjoin <steamid>` | Envoie au joueur une fausse invitation de tribu. |
| `!outofrange <steamid>` | Affiche au joueur la notification client « out of range ». |
| `!playpoopsound <steamid>` | Joue le son de crotte sur un joueur. |
| `!playdeathsound <steamid>` | Joue le son de mort sur un joueur. |

> ℹ️ **Chaque action d'administration est journalisée.** Les commandes de
> chat d'administration sont enregistrées dans un fichier journal local et
> publiées sur [`AdminTrollingWebhook`](configuration.md#webhooks) avec
> l'administrateur agissant, la cible et l'emplacement — afin que les
> pouvoirs d'administration restent responsables.
