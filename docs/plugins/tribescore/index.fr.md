# 🏆 Tribescore

Tribescore est un **système compétitif de score de tribu** pour ARK: Survival Evolved.
Les tribus gagnent du *tribescore* en détruisant les structures, dinos et joueurs
ennemis en PvP. Les scores sont persistés dans MySQL et mis en avant via un système de
classement et de rangs, tandis que des nombres flottants « hologrammes » apparaissent
dans le monde à chaque fois que des points sont gagnés ou perdus.

L'attribution des points passe par un pipeline de modificateurs multiplicatifs et
configurable, afin de maintenir une compétition équitable : protection hors ligne,
équilibrage selon la différence de score entre tribus fortes et faibles, boosts basés
sur les permissions et boosts temporaires accordés par les administrateurs.

## Fonctionnalités

- **Scoring PvP :** Attribue des points pour la destruction de structures ennemies, la
  mort de dinos apprivoisés et la mort de joueurs ennemis. Chaque source est
  configurable individuellement et peut être désactivée.
- **Valeurs par palier et par blueprint :** Les structures sont notées par palier de
  construction (Chaume → Tek) avec des surcharges par blueprint ; les dinos sont notés
  par espèce avec des options fines (bébés, sans selle, sauvages, …).
- **Pipeline de modificateurs :** Équilibrez le jeu avec la protection hors ligne, un
  ratio de différence de score fort-contre-faible, des modificateurs de permission et
  des boosts temporaires.
- **Classement et rangs :** Commandes de chat en jeu `/leaderboard` et `/triberank`,
  adossées à un classement MySQL persistant.
- **Hologrammes dans le monde :** Texte flottant configurable `+points` / `-points` que
  les joueurs peuvent activer ou désactiver pour eux-mêmes.
- **Outils d'administration :** Ajoutez/retirez du score, accordez des boosts
  temporaires, auditez l'historique des transactions d'une tribu et estimez la valeur
  d'une base — le tout depuis la console/RCON.

## Fonctionnement du scoring

Lorsqu'une structure, un dino ou un joueur ennemi est détruit, la valeur de base des
points provient des tables de scoring (`structures.json`, `dinos.json`, ou la valeur
forfaitaire du joueur dans `config.json`). Cette valeur de base est ensuite multipliée
à travers le pipeline de modificateurs :

```
final score = base points
            × OfflineProtection(defender)
            × ScoreDifferenceRatio(attacker, defender)
            × PermissionModifier(attacker)
            × TimedBoost(attacker, type)
```

La tribu attaquante **gagne** le résultat ; la tribu défenseure **perd** un montant
(configurable séparément). Consultez la page [Configuration](configuration.md) pour
tous les réglages.

## Installation

1. Assurez-vous d'avoir une version prise en charge d'[ArkApi](https://arkserverapi.com/)
   installée sur votre serveur (Tribescore requiert ArkApi **3.51** ou plus récent).
2. Configurez une base de données MySQL/MariaDB — voir [Configuration commune](../common-configuration.md#database).
3. Téléchargez le `Tribescore.zip` depuis votre **tableau de bord Bytemart**.
4. Arrêtez le serveur (exécutez d'abord `saveworld`), ou déchargez toute version
   précédente avec `plugins.unload Tribescore`.
5. Extrayez l'archive dans un dossier `Tribescore` à l'intérieur de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Ouvrez `config.json` et renseignez votre `LicenseKey` et vos identifiants
   `Database` (voir [Configuration](configuration.md)).
7. Démarrez le serveur et confirmez qu'aucune erreur n'apparaît pendant le démarrage.

### Mise à jour

- **Manuelle :** `plugins.unload Tribescore`, remplacez les fichiers, puis
  `plugins.load Tribescore`.
- **Automatique (rechargement à chaud) :** renommez le nouveau `Tribescore.dll` en
  `Tribescore.dll.arkapi` et déposez-le dans le dossier du plugin — ArkApi charge la
  nouvelle version et décharge automatiquement l'ancienne.

Vérifiez toujours le changelog pour les modifications de configuration lors d'une mise
à jour ; un outil comme [Diffchecker](https://www.diffchecker.com/) aide à repérer les
clés nouvelles ou renommées.

---

**Étapes suivantes :**

- [Configuration](configuration.md) — le `config.json` complet, ainsi que `structures.json` et `dinos.json`.
- [Commandes](commands.md) — les commandes d'administration console/RCON et les commandes de chat en jeu.
- [Configuration commune](../common-configuration.md) — les clés partagées `LicenseKey`, `Database`, `LogToFile` et `Verbose`.
