# Commandes

Tribescore propose deux types de commandes : les commandes d'**administration**
exécutées depuis la console du serveur ou RCON, et les commandes de chat des
**joueurs** saisies en jeu. Les commandes d'administration sont préfixées par `ts.` et
ne sont accessibles que via la console/RCON, de sorte qu'aucun système de permission
distinct ne les protège — l'accès est implicite par le canal. Les commandes de chat
sont configurables et facultatives (voir [`ChatCommands`](configuration.md#chatcommands)).

## Commandes console / RCON

| Commande | Canaux | Description |
| ------- | -------- | ----------- |
| `ts.help [page]` | Console, RCON | Affiche le menu d'aide paginé de Tribescore. |
| `ts.give <tribe-id> <score>` | Console | Ajoute du tribescore à une tribu. Enregistre une transaction `system`. |
| `ts.take <tribe-id> <score>` | Console | Retire du tribescore à une tribu. Enregistre une transaction `system`. |
| `ts.boost <tribe-id> <type> <value> <duration>` | Console, RCON | Accorde un boost de score temporaire à une tribu. |
| `ts.boost <tribe-id> clear` | Console, RCON | Efface le boost temporaire actif d'une tribu. |
| `ts.audit <tribe-id> [options]` | Console | Audite les transactions de score d'une tribu et téléverse un rapport. |
| `ts.estimate <recipient-tribe-id> [options]` | Console | Estime le tribescore des structures autour de vous. |
| `ts.addstructure` | Console | Ajoute la structure que vous regardez à `structures.json`. |

### `ts.give` / `ts.take`

```bash
ts.give 1234567890 500      # ajoute 500 points à la tribu 1234567890
ts.take 1234567890 250      # retire 250 points à la tribu 1234567890
```

Les deux écrivent une entrée de type `system` dans l'historique des transactions, afin
que les ajustements manuels soient auditables.

### `ts.boost`

Accorde un multiplicateur de score temporaire qui s'intègre au pipeline de
modificateurs pendant une durée définie.

```
ts.boost <tribe-id> <type> <value> <duration>
ts.boost <tribe-id> clear
```

| Argument | Description |
| -------- | ----------- |
| `<tribe-id>` | L'ID de la tribu cible. |
| `<type>` | Ce à quoi le boost s'applique : `structures`, `dinos`, `players`, `all`, ou une combinaison jointe par `+` (p. ex. `structures+dinos`). |
| `<value>` | Le multiplicateur (p. ex. `1.5` pour +50 %). |
| `<duration>` | Durée de vie du boost, en **secondes**. |

```bash
ts.boost 1234567890 structures+dinos 1.5 3600   # +50% sur les structures et dinos pendant 1 h
ts.boost 1234567890 all 2 600                   # double tout le score pendant 10 minutes
ts.boost 1234567890 clear                        # retire le boost actif
```

> ℹ️ **Également exposé aux autres plugins.** Les boosts temporaires font partie de
> l'API publique de Tribescore (`SetTimedBoost` / `ClearTimedBoost` / `GetTimedBoost`),
> que le plugin compagnon **Koth** utilise pour récompenser automatiquement les
> vainqueurs d'événements.

### `ts.audit`

Construit un rapport asynchrone des transactions d'une tribu (de qui elle a gagné des
points, qui lui en a volé, ventilations par cluster) et le téléverse, en renvoyant une
URL.

```
ts.audit <tribe-id> [clusters_amount=X] [givers_amount=X] [stealers_amount=X] [start_date=YYYY-MM-DD] [end_date=YYYY-MM-DD]
```

| Option | Description |
| ------ | ----------- |
| `clusters_amount=X` | Nombre de meilleurs clusters à inclure. |
| `givers_amount=X` | Nombre de meilleures tribus dont cette tribu a gagné des points. |
| `stealers_amount=X` | Nombre de meilleures tribus qui ont pris des points à cette tribu. |
| `start_date` / `end_date` | Restreint l'audit à une plage de dates (`YYYY-MM-DD`). |

```bash
ts.audit 1234567890 givers_amount=10 start_date=2026-07-01 end_date=2026-07-12
```

### `ts.estimate`

Scanne les structures à portée de votre personnage (via un scan par octree, découpé sur
plusieurs ticks) et estime la quantité de score qu'elles vaudraient pour une tribu
donnée. Utile pour ajuster les valeurs de `structures.json`.

```
ts.estimate <recipient-tribe-id> [modifiers=on|off] [range=X]
```

| Option | Description |
| ------ | ----------- |
| `modifiers=on\|off` | Indique s'il faut appliquer le pipeline de modificateurs à l'estimation. |
| `range=X` | Rayon de scan autour de votre personnage. |

### `ts.addstructure`

Effectue un tracé linéaire sur la structure que vous regardez, l'ajoute à
`structures.json` en tant qu'entrée personnalisée et recharge le fichier à chaud — un
moyen rapide d'ajouter des valeurs par blueprint sans chercher les chemins de blueprint
à la main.

---

## Commandes de chat

Celles-ci sont saisies dans le chat en jeu. Les noms sont configurables — les valeurs
par défaut ci-dessous proviennent de la configuration [`ChatCommands`](configuration.md#chatcommands)
livrée, et chaque commande peut être entièrement désactivée.

| Commande (par défaut) | Description |
| ----------------- | ----------- |
| `/leaderboard` | Affiche les meilleures tribus par score. |
| `/triberank` | Affiche le rang et le score de votre propre tribu. |
| `/holograms` | Active ou désactive pour vous-même les hologrammes flottants `+/- points`. |

Le libellé, les couleurs, la taille, la durée d'affichage à l'écran et (pour le
classement) le nombre de lignes et les couleurs par rang se règlent tous dans
[`ChatCommands`](configuration.md#chatcommands).

---

## Nœuds de permission

Tribescore n'utilise pas de permissions pour protéger ses commandes, mais la
fonctionnalité [`PermissionModifiers`](configuration.md#modifierspermissionmodifiers)
lit des nœuds de permission pour augmenter ou réduire le score d'une tribu. Accordez-les
via le plugin [Permissions](https://github.com/ServersHub/ServerAPI). Avec la
configuration par défaut :

```bash
Permissions.AddGroup VIP
Permissions.Grant VIP ts.boost.15
```

Ici, un membre du groupe `VIP` accorderait à sa tribu un multiplicateur de score de
**1.15×**, conformément à l'entrée `ts.boost.15` de `PermissionModifiers.Modifiers`.
Les noms des nœuds sont arbitraires — ils doivent simplement correspondre à ce que vous
configurez.
