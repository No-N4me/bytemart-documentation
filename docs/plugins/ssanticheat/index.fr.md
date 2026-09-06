# 🛡️ ssAntiCheat

ssAntiCheat est un **anticheat côté serveur** pour ARK: Survival Evolved. Il
s'exécute entièrement à l'intérieur de votre serveur en tant que plugin ArkApi —
les joueurs n'installent rien, et il n'y a aucun client à contourner. Les
détections sont signalées à votre Discord et aux administrateurs en jeu, et les
contrevenants sont mis en file d'attente pour une **vague de bannissement**, afin
que les tricheurs n'apprennent pas quel contrôle les a repérés.

En plus de la détection, ssAntiCheat **bloque** également un grand nombre
d'exploits connus purement et simplement, et fournit des correctifs pour
plusieurs problèmes de serveur de longue date — y compris des **exploits de
crash** et de la **duplication d'objets**.

## Fonctionnalités

- **Modules de détection.** Des dizaines de détecteurs individuellement
  activables/désactivables, regroupés en quatre catégories : **Combat**,
  **Divers**, **Mod** et **Exploits**. Quelques exemples : détection d'aimbot et
  de silent-aim, auto-flak, auto-medbrew, no-overheat, auto-loot et auto-craft.
  Chacun peut être activé, désactivé et ajusté indépendamment.
- **Blocage des exploits, pas seulement leur signalement.** La plupart des
  modules d'exploits peuvent à la fois *empêcher* l'action et la signaler, de
  sorte que l'exploit échoue au lieu d'être simplement journalisé après coup.
- **Protection contre les crashs et la duplication.** Les vecteurs de crash
  serveur connus sont bloqués, et les correctifs de duplication stoppent les
  méthodes de dupe d'objets courantes (dupes de transfert, astuces de
  sac/transmetteur, et plus encore).
- **Correctifs de glitches et de lag.** Une section `Fixes` distincte couvre des
  glitches serveur bien connus (glitch du scout, glitch des menottes, « player
  already connected », le glitch de traction, la protection contre le lag et le
  correctif de dupe).
- **Système de bannissement intégré.** Les bannissements sont persistés dans
  MySQL et appliqués à la connexion, avec des bannissements optionnels par
  **association d'IP** et par **HWID**. Les vagues de bannissement sont
  regroupées de sorte que plusieurs tricheurs soient retirés d'un coup. Voir
  [Bannissements et détections](bans.md).
- **Alertes Discord.** Les détections, les bannissements, les journaux de
  connexion, les bannissements par association d'IP et les journaux d'actions
  d'administration partent chacun vers un webhook que vous configurez — ou tous
  vers un seul.
- **Outils d'administration.** Mettez un joueur signalé en mode spectateur en une
  commande, activez/désactivez l'ESP joueurs et structures pour vous-même, et
  disposez d'un ensemble de commandes de chat pour gérer les suspects en jeu.
  Chaque action d'administration est journalisée.
- **Passerelle de connexion.** Vérifications optionnelles via la Steam Web API à
  la connexion : temps de jeu minimum, âge minimum du compte et bannissements VAC
  récents — chacune peut simplement journaliser ou bloquer.
- **Tableau de bord (optionnel).** Télémétrie facultative vers le tableau de bord
  ssAnticheat pour un flux de détection en direct, l'état de santé du serveur et,
  en option, une carte des joueurs en direct. Désactivé par défaut.

## Comment une détection devient un bannissement

```
detector fires
   └─> detection recorded  ──> in-game admin alert
                            ──> Discord webhook
                            ──> dashboard (if enabled)
   └─> module's ban threshold reached?
          └─> player queued for the next ban wave
                 └─> ban wave runs: on a save cycle, when the player
                     disconnects, on an instant-ban module, or manually
```

Les seuils, le blocage et le comportement de bannissement instantané sont
propres à chaque module. Le flux complet — et chaque réglage qui le modifie —
se trouve sur la page [Bannissements et détections](bans.md).

## Prérequis

| Prérequis | Remarques |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** ou plus récent | Le plugin ne se chargera pas sur des versions d'API antérieures. |
| MySQL / MariaDB | Requis. Les bannissements y sont persistés. Voir [Configuration commune](../index.md#database). |
| Une clé de licence Bytemart | Rien ne s'active tant que la clé n'a pas été authentifiée. |
| HTTPS sortant | Nécessaire pour la licence, les webhooks Discord et (si utilisée) la Steam Web API ainsi que le tableau de bord. |

## Installation

1. Assurez-vous d'avoir ArkApi **3.51+** installé sur votre serveur.
2. Configurez une base de données MySQL/MariaDB — voir
   [Configuration commune](../index.md#database). La base de données doit déjà
   exister ; le plugin y crée ses propres tables.
3. Téléchargez `ssAntiCheat.zip` depuis votre **tableau de bord Bytemart**.
4. Arrêtez le serveur (exécutez d'abord `saveworld`), ou déchargez toute version
   précédente avec `plugins.unload ssAntiCheat`.
5. Extrayez l'archive dans un dossier `ssAntiCheat` à l'intérieur de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Ouvrez `config.json` et renseignez votre `LicenseKey` et vos identifiants
   `Database` (voir [Configuration](configuration.md)).
7. Démarrez le serveur et confirmez qu'aucune erreur n'apparaît pendant le
   démarrage.
8. Exécutez `ssac.status` depuis la console ou RCON pour confirmer que la
   licence s'est bien authentifiée.

> ⚠️ **Configurez vos webhooks avant la mise en production.** Chaque champ de
> webhook est livré vide. Tant que vous n'avez pas renseigné au moins
> `DefaultWebhookUrl`, les détections ne sont visibles que par les
> administrateurs en jeu et dans le journal du serveur.

### Mise à jour

- **Manuelle :** `plugins.unload ssAntiCheat`, remplacez les fichiers, puis
  `plugins.load ssAntiCheat`.
- **Automatique (rechargement à chaud) :** renommez le nouveau `ssAntiCheat.dll`
  en `ssAntiCheat.dll.arkapi` et déposez-le dans le dossier du plugin — ArkApi
  charge la nouvelle version et décharge automatiquement l'ancienne.

Vérifiez toujours le changelog pour les modifications de configuration lors
d'une mise à jour. ssAntiCheat répare automatiquement sa propre configuration
(les clés manquantes sont ajoutées avec leurs valeurs par défaut et l'original
est sauvegardé dans `config.json.bak`), mais un outil comme
[Diffchecker](https://www.diffchecker.com/) aide tout de même à repérer les
nouvelles clés à ajuster.

## Dépannage

- **Le plugin ne se charge pas, code d'erreur `1114`** — une erreur de syntaxe
  JSON dans `config.json`. Passez-le dans [JSONLint](https://jsonlint.com/).
- **« License key is missing »** — `LicenseKey` contient encore la valeur
  d'espace réservé.
- **Rien n'arrive sur Discord** — vérifiez que `Use Discord` est à `true` et que
  l'URL du webhook concerné est bien renseignée. Les webhooks sont propres à
  chaque usage ; voir [Configuration](configuration.md#webhooks).
- **Tout autre problème** — passez `LogToFile` à `true` et reproduisez le
  problème ; le plugin écrit son propre fichier `ssAntiCheat.log` à rotation, à
  côté de `config.json`, pour vous éviter de fouiller dans le journal partagé du
  serveur. Puis demandez sur le
  [Discord Bytemart](https://bytemart.net/discord).

---

**Étapes suivantes :**

- [Configuration](configuration.md) — toutes les clés de `config.json`.
- [Commandes](commands.md) — les commandes console/RCON et les commandes de chat d'administration en jeu.
- [Bannissements et détections](bans.md) — seuils, vagues de bannissement, bannissements IP/HWID et débannissement.
- [Configuration commune](../index.md#common-configuration) — les clés partagées `LicenseKey`,
  `Database`, `LogToFile` et `Verbose`.
