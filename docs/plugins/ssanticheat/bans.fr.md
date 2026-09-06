# Bannissements et détections

ssAntiCheat sépare la **détection** d'un tricheur de son **retrait**. Une
détection alerte toujours ; un bannissement ne survient qu'une fois le seuil
d'un module atteint, et même alors il est normalement retenu jusqu'à la
prochaine **vague de bannissement**. Ce délai est délibéré — il empêche un
tricheur de faire le lien « j'ai fait X, et j'ai été banni une seconde plus
tard » et de deviner quel contrôle l'a repéré.

## Le pipeline

```
1. a detector fires
2. detection is recorded  ──> in-game admin alert
                          ──> Discord webhook
                          ──> dashboard (if enabled)
3. module reached its BanAfterDetections count?   ── no ──> done
                          │ yes
4. player is queued for a ban
5. the queue is executed on the next ban wave
6. execution: run AutoBan.ExecuteCommand, alert admins,
   and (if IntegratedBanSystem is on) write the ban row and kick
7. on their next join attempt, the ban is enforced at login
```

Les étapes 3 à 4 sont propres à chaque module — voir
[`BanAfterDetections`](configuration.md#common-submodule-keys). Un module
sans cette clé détecte et alerte, mais ne bannit jamais de lui-même.

## Vagues de bannissement {#ban-waves}

Un bannissement en attente est exécuté lorsque **l'un** des événements
suivants se produit :

| Déclencheur | Remarques |
| ------- | ----- |
| Toutes les *N* sauvegardes du monde | *N* est [`AutoBan."SaveWorld Cycles"`](#autoban) — `2` par défaut. C'est le chemin normal. |
| Le joueur en file d'attente se déconnecte | Il est banni en sortant, plutôt que d'être laissé libre jusqu'à la prochaine vague. |
| Le module a `InstantBan: true` | Réservé aux détections sans faux positif plausible. |
| Un administrateur exécute `ssac.banwave` | Vide toute la file d'attente immédiatement. |

Entre la mise en file et l'exécution, vous pouvez inspecter la file avec
`ssac.pendingbans` et la vider avec `ssac.clearbanwave`. Voir
[Commandes](commands.md#ssacbanwave-ssacclearbanwave-ssacpendingbans).

### `AutoBan`

```json
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `SaveWorld Cycles` | number | `2` | Exécute une vague de bannissement toutes ces sauvegardes du monde. Avec un intervalle de sauvegarde de 15 minutes, `2` signifie un délai maximal de 30 minutes. |
| `ExecuteCommand` | string | `"banplayer {steamid} "` | Une commande console exécutée pour chaque joueur banni. `{steamid}` est remplacé par son SteamID64. Laissez vide pour vous appuyer uniquement sur le système de bannissement intégré. |

`ExecuteCommand` est la façon de connecter ssAntiCheat à ce que vous
utilisez déjà. La valeur par défaut ajoute le joueur à la propre liste de
bannissement d'ARK ; vous pourriez à la place appeler la commande de
bannissement d'un autre plugin, ou une commande valable pour tout un
cluster.

> 💡 **Astuce cluster.** Le `banplayer` d'ARK est propre à chaque serveur.
> Si vous exploitez un cluster, faites pointer `ExecuteCommand` vers une
> commande de bannissement compatible cluster, ou utilisez le système de
> bannissement intégré avec une **base de données MySQL partagée** entre
> tous vos serveurs — chaque serveur applique alors chaque bannissement à
> la connexion.

## `IntegratedBanSystem`

Le stockage de bannissement intégré : les bannissements sont écrits dans
votre base de données MySQL et appliqués lorsque le joueur tente de se
connecter.

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
}
```

| Champ | Type | Défaut | Description |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Stocke et applique les bannissements dans MySQL. Si `false`, seul `AutoBan.ExecuteCommand` s'exécute. |
| `UseIPBans` | boolean | `true` | Refuse également les connexions depuis l'adresse IP d'un joueur banni. Voir ci-dessous. |
| `UseHWIDBans` | boolean | `false` | Refuse également les connexions depuis l'ID matériel d'un joueur banni. Nécessite le mod client compagnon optionnel pour en capturer un — sans lui, ceci ne fait rien. |
| `Exclude IPS` | array | `[]` | Adresses IP jamais traitées comme une association. Placez-y les adresses partagées/NAT. |
| `BanMessage` | string | voir ci-dessus | Le message que voit le joueur. |

Les bannissements résident dans une table unique (`ssAntiCheat_bans`)
contenant le Steam ID, l'IP, l'ID matériel, la raison, la date de
bannissement et son expiration. Faites pointer plusieurs serveurs vers la
même base de données et un bannissement s'applique sur tous.

### Message de bannissement {#ban-message}

`BanMessage` prend en charge deux espaces réservés :

| Espace réservé | Remplacé par |
| ----------- | ------------- |
| `{reason}` | La raison du bannissement. |
| `{ban_id}` | L'ID numérique du bannissement — la valeur dont un administrateur a besoin pour `ssac.unban`. |

```json
"BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nAppeal at: https://yourserver.example/appeal"
```

> ⚠️ **Remplacez l'URL de l'espace réservé.** Le message livré pointe vers
> `store.example.com`. Incluez toujours `{ban_id}` — sans lui, un joueur qui
> fait appel d'un bannissement n'a rien à citer et vous devez chercher dans
> la base de données à la main.

### Bannissements par association d'IP {#ip-association-bans}

Avec `UseIPBans` activé, un joueur se connectant depuis une adresse
appartenant à un bannissement actif est refusé **et enregistré comme son
propre bannissement**, de sorte que le compte alternatif est ensuite banni
par Steam ID. Une alerte part vers
[`AssociationBans`](configuration.md#webhooks) nommant les deux comptes.

La vérification est délibérément prudente — elle ne se déclenche que
lorsque l'IP correspond véritablement, n'est pas dans `Exclude IPS`, et
appartient à un compte Steam *différent*.

> ⚠️ **Les bannissements IP touchent les foyers et les connexions
> partagées.** Des frères et sœurs, des colocataires, un cybercafé, ou une
> sortie VPN partagée ressembleront tous au même joueur. Surveillez le canal
> d'association pendant un moment avant de lui faire confiance, et ajoutez
> les adresses partagées légitimes à `Exclude IPS`.

## Durées de bannissement

| Comment le bannissement a été créé | Durée |
| -------------------- | -------- |
| `ssac.ban` avec `d=…` | Expire après cette période. |
| `ssac.ban` sans `d=…` | Permanent. |
| Automatique (le `BanAfterDetections` d'un module) | Permanent. |

Pour lever n'importe quel bannissement, utilisez son ID de bannissement :

```bash
ssac.unban 42
```

## Examiner une détection avant qu'elle ne devienne un bannissement

L'intervalle entre la détection et la vague de bannissement est votre
fenêtre d'examen. Un flux de travail qui fonctionne bien :

1. L'alerte Discord (ou l'alerte d'administrateur en jeu) nomme le joueur
   et le module.
2. `ssac.go` — mettez-vous en spectateur immédiatement, sans argument pour
   sauter à la dernière détection.
3. `!tracers` — observez ses tirs ; une assistance de visée est évidente à
   l'œil nu de cette façon.
4. `ssac.pendingbans` — voyez s'il est déjà en file d'attente et pour quoi.
5. Décidez : laisser la vague se dérouler, `ssac.banwave` pour agir
   maintenant, ou `ssac.clearbanwave` si vous pensez qu'il s'agit d'un faux
   positif.

Si un module produit des faux positifs répétés sur votre configuration,
augmentez son seuil ou activez `OnlyAnalysis` dessus plutôt que de le
désactiver — voir
[Conseils de réglage](configuration.md#common-submodule-keys).

---

**Étapes suivantes :**

- [Configuration](configuration.md) — toutes les clés de `config.json`.
- [Commandes](commands.md) — la référence complète des commandes.
