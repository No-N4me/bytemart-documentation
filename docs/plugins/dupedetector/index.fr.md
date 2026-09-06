# 🔍 DupeDetector

DupeDetector est un plugin ArkApi petit et ciblé qui repère la **duplication
d'objets réalisée via l'inventaire de tribut** — l'obélisque, le terminal de
supply drop et la boutique d'upload du transmetteur utilisés pour les
transferts de cluster.

Il fait une seule chose et la fait discrètement : les tentatives de
duplication sont signalées à votre Discord, et les récidivistes peuvent être
traités automatiquement.

## Ce qu'il fait

- **Détecte la duplication** via l'inventaire de tribut/upload, sans mod
  client et sans rien à installer pour vos joueurs.
- **Alerte votre Discord.** Chaque détection est publiée sur le webhook que
  vous configurez.
- **Punit les récidivistes.** Une fois qu'un joueur a été détecté
  suffisamment de fois, DupeDetector peut exécuter une commande serveur
  contre lui (expulsion, bannissement, ce que vous choisissez) et, en
  option, vider son inventaire. Les punitions partent vers leur propre
  webhook afin que vous puissiez les diriger vers un canal réservé aux
  administrateurs.
- **Signalement seul si vous le souhaitez.** Laissez les options de
  punition vides et le plugin ne fait plus que vous informer — il n'agit
  jamais de lui-même.

La marge de manœuvre accordée à un joueur avant qu'une punition ne se
déclenche est configurable, et volontairement pas un nombre fixe. Voir
[`Punishment.After`](configuration.md#punishment).

> ℹ️ **Les détails de détection ne sont volontairement pas publiés.** Ce qui
> déclenche une détection, et combien de détections sont tolérées pour un
> joueur donné, ne sont pas documentés ici — cette information n'aide que
> les personnes que vous essayez d'attraper. Si vous avez besoin de
> comprendre une alerte spécifique, demandez sur le
> [Discord Bytemart](https://bytemart.net/discord).

## Prérequis

| Prérequis | Remarques |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** ou plus récent | Le plugin ne se chargera pas sur des versions d'API antérieures. |
| MySQL / MariaDB | Le plugin se connecte au démarrage, des identifiants valides sont donc requis. Voir [Configuration commune](../index.md#database). |
| Une clé de licence Bytemart | Rien ne s'active tant que la clé n'a pas été authentifiée. |
| HTTPS sortant | Nécessaire pour la licence et pour les webhooks Discord. |

## Installation

1. Assurez-vous d'avoir ArkApi **3.51+** installé sur votre serveur.
2. Configurez une base de données MySQL/MariaDB — voir
   [Configuration commune](../index.md#database). La base de données doit
   déjà exister.
3. Téléchargez `DupeDetector.zip` depuis votre **tableau de bord Bytemart**.
4. Arrêtez le serveur (exécutez d'abord `saveworld`), ou déchargez toute
   version précédente avec `plugins.unload DupeDetector`.
5. Extrayez l'archive dans un dossier `DupeDetector` à l'intérieur de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Ouvrez `config.json` et renseignez votre `LicenseKey`, vos identifiants
   `Database`, et au minimum `DupeDetection.AlertWebhook` — voir
   [Configuration](configuration.md).
7. Démarrez le serveur et confirmez qu'aucune erreur n'apparaît pendant le
   démarrage.

> ⚠️ **Configurez `AlertWebhook` avant la mise en production.** Il est livré
> vide, et un webhook vide signifie que les détections sont enregistrées
> mais jamais publiées nulle part.

### Mise à jour

- **Manuelle :** `plugins.unload DupeDetector`, remplacez les fichiers, puis
  `plugins.load DupeDetector`.
- **Automatique (rechargement à chaud) :** renommez le nouveau
  `DupeDetector.dll` en `DupeDetector.dll.arkapi` et déposez-le dans le
  dossier du plugin — ArkApi charge la nouvelle version et décharge
  automatiquement l'ancienne.

DupeDetector répare automatiquement sa propre configuration au chargement :
les clés manquantes sont ajoutées avec leurs valeurs par défaut et votre
original est d'abord sauvegardé dans `config.json.bak`. Une incompatibilité
de type (une chaîne là où un nombre est attendu) interrompt le chargement à
la place, avec une erreur nommant la clé.

## Commandes

L'accès console et RCON est un accès administrateur par définition, donc
celles-ci ne nécessitent aucune permission supplémentaire.

| Commande | Canaux | Description |
| ------- | -------- | ----------- |
| `DupeDetector.help [page]` | Console, RCON | Liste paginée de chaque commande enregistrée. |
| `DupeDetector.reload` | Console, RCON | Relit `config.json` sans redémarrer le serveur. |

`DupeDetector.reload` remplace la configuration active sur-le-champ, de
sorte que les modifications de webhook et de punition prennent effet
immédiatement. Elle **ne** relance **pas** la passe de réparation de
configuration, validez donc votre JSON avant de recharger.

## Dépannage

- **Le plugin ne se charge pas, code d'erreur `1114`** — une erreur de
  syntaxe JSON dans `config.json`. Passez-le dans
  [JSONLint](https://jsonlint.com/).
- **« License key is missing »** — `LicenseKey` contient encore la valeur
  d'espace réservé.
- **Rien n'arrive sur Discord** — l'URL doit être un véritable point de
  terminaison de webhook Discord (`https://discord.com/api/webhooks/...` ;
  les formes `discordapp.com`, `ptb.` et `canary.` sont également
  acceptées). Toute autre valeur est abandonnée avec une ligne dans le
  journal.
- **Tout autre problème** — passez `LogToFile` à `true` et reproduisez le
  problème ; le plugin écrit son propre fichier `DupeDetector.log` à
  rotation, à côté de `config.json`. Puis demandez sur le
  [Discord Bytemart](https://bytemart.net/discord).

---

**Étapes suivantes :**

- [Configuration](configuration.md) — le bloc `DupeDetection`.
- [Configuration commune](../index.md#common-configuration) — les clés partagées `LicenseKey`,
  `Database`, `LogToFile` et `Verbose`.
