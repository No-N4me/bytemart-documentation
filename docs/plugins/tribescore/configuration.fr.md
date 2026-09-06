# Configuration

Tribescore se configure via **trois** fichiers dans le dossier du plugin
(`ShooterGame/Binaries/Win64/ArkApi/Plugins/Tribescore/`) :

| Fichier | Rôle |
| ---- | ------- |
| `config.json` | Réglages principaux : licence, base de données, activation, éligibilité, modificateurs de scoring, hologrammes et commandes de chat. |
| `structures.json` | Valeurs en points des structures, par palier de construction et par blueprint. |
| `dinos.json` | Valeurs en points et règles de comptage des dinos, par espèce. |

> 💡 **Validez avant de démarrer.** Validez toujours votre JSON après édition (par
> exemple avec [JSONLint](https://jsonlint.com/)). Un code d'erreur de chargement
> `1114` signifie une erreur de syntaxe JSON.

Les clés `LicenseKey`, `Verbose`, `LogToFile` et `Database` sont partagées par chaque
plugin Bytemart et sont documentées sur la page
**[Configuration commune](../index.md#common-configuration)**. Cette page ne couvre que les
clés propres à Tribescore.

---

## `config.json`

### `DebugMode`

```json
"DebugMode": false
```

Lorsque la valeur est `true`, la console devient plus détaillée **et** vous êtes
autorisé à gagner du tribescore contre votre propre tribu — utile pour tester le
scoring sur un serveur de développement. Laissez la valeur à `false` sur un serveur en
production.

### `TribescoreActivation`

Retarde le scoring de manière globale après le démarrage d'un serveur (wipe), afin que
les tribus aient le temps de se réétablir avant le début de la compétition.

```json
"TribescoreActivation": {
  "Activation": {
    "Type": "delay",
    "Value": 7200
  },
  "Message": "Tribescore is globally enabled after 2 hours, please wait {cooldown}"
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Activation.Type` | string | `"delay"` — active le scoring `Value` secondes après le démarrage du serveur. `"timestamp"` — active le scoring à un [horodatage Unix](https://www.unixtimestamp.com/) fixe. |
| `Activation.Value` | number | Secondes de délai (pour `delay`) ou l'horodatage Unix (pour `timestamp`). Mettez `0` pour désactiver la fonctionnalité et activer le scoring immédiatement. |
| `Message` | string | Affiché aux joueurs qui déclenchent le scoring alors qu'il est encore en temps de recharge. L'espace réservé `{cooldown}` est remplacé par le temps restant. |

### `TribescoreEligibility`

Détermine quelles tribus peuvent gagner du score en fonction du nombre de membres.

```json
"TribescoreEligibility": {
  "MinPlayers": 1,
  "MinOnlinePlayers": 0
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `MinPlayers` | number | Nombre minimum de membres qu'une tribu doit avoir (au total) pour gagner du score. |
| `MinOnlinePlayers` | number | Nombre minimum de membres devant être **en ligne** pour que la tribu gagne du score. `0` désactive cette vérification. |

### `Scoring`

Le cœur du plugin. Les valeurs de base résident ici (et dans `structures.json` /
`dinos.json`) ; la sous-section `Modifiers` les multiplie.

```json
"Scoring": {
  "GainLossRatio": 0.75,
  "Structures": { "Enabled": true, "DefaultValue": 10.0 },
  "Dinos":      { "Enabled": true, "DefaultValue": 25.0 },
  "Players":    { "Enabled": true, "Value": 150.0 },
  "Modifiers": { "...": "..." }
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `GainLossRatio` | number | Lorsqu'aucun `LossOverride` explicite n'est défini (dans `structures.json` / `dinos.json`), la perte de score du **défenseur** vaut `gain × GainLossRatio`. À `0.75`, un défenseur perd 75 % de ce que l'attaquant a gagné. |
| `Structures.Enabled` | boolean | Active le scoring lié aux structures détruites. Configurez les valeurs dans [`structures.json`](#structuresjson). |
| `Structures.DefaultValue` | number | Points pour une structure sans correspondance de palier ni de blueprint. |
| `Dinos.Enabled` | boolean | Active le scoring lié aux dinos tués. Configurez les valeurs dans [`dinos.json`](#dinosjson). |
| `Dinos.DefaultValue` | number | Points pour un dino sans surcharge par espèce. |
| `Players.Enabled` | boolean | Active le scoring lié aux joueurs ennemis tués. |
| `Players.Value` | number | Points forfaitaires attribués par mort de joueur ennemi. |

#### `Modifiers.OfflineProtection`

Réduit (ou augmente) le score gagné contre une tribu qui est entièrement hors ligne
depuis un moment — dissuadant le raid hors ligne.

```json
"OfflineProtection": {
  "Enabled": true,
  "ActivatesAfter": 3600,
  "Modifier": 0.75
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Active/désactive la fonctionnalité. |
| `ActivatesAfter` | number | Secondes pendant lesquelles une tribu doit être entièrement hors ligne avant que la protection ne s'enclenche. |
| `Modifier` | number | Multiplicateur appliqué une fois actif. `< 1` réduit le gain de l'attaquant (p. ex. `0.75` = −25 %). |

*Appliqué en fonction du **défenseur**.*

#### `Modifiers.PermissionModifiers`

Augmente (ou réduit) le score en fonction des **permissions** ArkApi de l'attaquant.
Nécessite le plugin [Permissions](https://github.com/ServersHub/ServerAPI) de
l'ArkServerAPI.

```json
"PermissionModifiers": {
  "Enabled": true,
  "TribePermissionsOnly": false,
  "OnlinePlayersOnly": true,
  "Modifiers": [
    { "Permission": "ts.boost.10", "Value": 1.1 },
    { "Permission": "ts.boost.15", "Value": 1.15 },
    { "Permission": "ts.boost.25", "Value": 1.25 }
  ]
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Active/désactive la fonctionnalité. |
| `TribePermissionsOnly` | boolean | Lorsque la valeur est `true`, ne vérifie que les permissions au niveau de la tribu (ignore les permissions individuelles des joueurs). |
| `OnlinePlayersOnly` | boolean | Lorsque la valeur est `true`, ne prend en compte que les permissions des membres actuellement en ligne ; sinon, tous les membres sont vérifiés. |
| `Modifiers[]` | array | Paires permission → multiplicateur. **Un seul modificateur s'applique à la fois** ; si plusieurs correspondent, le **plus grand** est utilisé. |
| `Modifiers[].Permission` | string | Le nœud de permission que le joueur/la tribu doit posséder. |
| `Modifiers[].Value` | number | Multiplicateur appliqué (`> 1` augmente le gain). |

*Appliqué en fonction de l'**attaquant**.*

#### `Modifiers.ScoreDifferenceRatio`

Équilibre les tribus fortes contre les faibles. Le ratio comparé est le score du
**défenseur** divisé par le score de l'**attaquant** ; le `Modifier` de l'intervalle
correspondant met à l'échelle le gain de l'attaquant — ainsi les grandes tribus qui
farment les petites sont pénalisées, et les outsiders qui attaquent des géants sont
boostés.

```json
"ScoreDifferenceRatio": {
  "Enabled": true,
  "Intervals": [
    { "UpperBound": -1,   "LowerBound": 2,    "Modifier": 1.2 },
    { "UpperBound": 2,    "LowerBound": 1.5,  "Modifier": 1.1 },
    { "UpperBound": 1.5,  "LowerBound": 1,    "Modifier": 1 },
    { "UpperBound": 1,    "LowerBound": 0.5,  "Modifier": 0.8 },
    { "UpperBound": 0.5,  "LowerBound": 0.25, "Modifier": 0.6 },
    { "UpperBound": 0.25, "LowerBound": 0,    "Modifier": 0.25 }
  ]
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Active/désactive la fonctionnalité. |
| `Intervals[]` | array | Tranches du ratio de score défenseur/attaquant, chacune avec un multiplicateur. |
| `LowerBound` / `UpperBound` | number | La tranche de ratio couverte par ce modificateur. Utilisez `-1` comme `UpperBound` de la tranche supérieure pour signifier « aucune limite supérieure ». |
| `Modifier` | number | Multiplicateur appliqué lorsque le ratio tombe dans cette tranche. |

**Lecture des valeurs par défaut :**

- Ratio `≥ 2` (le défenseur a ≥ 2× le score de l'attaquant) → boost de **1.2×** pour
  l'attaquant outsider.
- Ratio entre `1.5` et `2` → boost de **1.1×**.
- Ratio entre `0.25` et `0.5` → pénalité de **0.6×**.
- Ratio `< 0.25` (le défenseur a moins d'un quart du score de l'attaquant) →
  **0.25×** — une forte pénalité pour le farm de tribus bien plus faibles.

*Utilise **à la fois** l'attaquant et le défenseur.*

### `Holograms`

Contrôle les nombres de points flottants qui apparaissent dans le monde lorsque le
score change. `Damager` est le texte `+points` affiché à l'attaquant ; `Damagee` est le
texte `-points` affiché au défenseur.

```json
"Holograms": {
  "DecimalPrecision": 1,
  "LifeSpan": 6.0,
  "Scale":    { "X": 0.5, "Y": 0.5 },
  "FadeTime": { "In": 2.0, "Out": 3.0 },
  "Velocity": { "X": 0, "Y": 0, "Z": 10.0 },
  "Damager": { "Enabled": true, "Text": "+ {points} points", "Color": { "R": 0,   "G": 255, "B": 0 } },
  "Damagee": { "Enabled": true, "Text": "- {points} points", "Color": { "R": 255, "G": 0,   "B": 0 } }
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `DecimalPrecision` | number | Nombre de décimales affichées dans la valeur `{points}`. |
| `LifeSpan` | number | Secondes pendant lesquelles l'hologramme reste visible. |
| `Scale.X` / `Scale.Y` | number | Taille du texte sur chaque axe. |
| `FadeTime.In` / `FadeTime.Out` | number | Durée d'apparition / de disparition en fondu, en secondes. |
| `Velocity.X/Y/Z` | number | Vitesse de dérive du texte ; par défaut, il flotte vers le haut (`Z`). |
| `Damager` / `Damagee` | object | Les fenêtres de gain / de perte. `Enabled` active/désactive chacune ; `Text` utilise l'espace réservé `{points}` ; `Color` est en RVB (0–255). |

Les joueurs peuvent activer ou désactiver les hologrammes pour eux-mêmes avec la
commande de chat `/holograms` (voir [Commandes](commands.md)).

### `ChatCommands`

Active, renomme et met en forme les trois commandes de chat en jeu. Chacune dispose
d'un commutateur `Enabled` et d'un déclencheur `Command` personnalisable ; désactiver
l'une d'elles la désenregistre entièrement.

```json
"ChatCommands": {
  "Holograms":   { "Enabled": true, "Command": "/holograms", "On": { "...": "..." }, "Off": { "...": "..." } },
  "Leaderboard": { "Enabled": true, "Lines": 15, "Command": "/leaderboard", "Text": "#{rank} [{tribe}] : {score}", "PerRankColor": { "...": "..." } },
  "MyTribeRank": { "Enabled": true, "Command": "/triberank", "Text": "Your tribe ({tribe}) is ranked #{rank} with {score}" }
}
```

Champs communs à chaque commande : `TextSize` (nombre), `Color` (RVB `{R,G,B}`) et
`DisplayTime` (secondes pendant lesquelles le message reste à l'écran).

**`Holograms`** — active/désactive l'affichage des hologrammes par joueur. `On` et
`Off` définissent chacun le message de confirmation (`Text`, `TextSize`, `Color`,
`DisplayTime`) affiché lors du basculement.

**`Leaderboard`** — affiche les meilleures tribus.

| Champ | Description |
| ----- | ----------- |
| `Lines` | Nombre de tribus à lister. |
| `Text` | Format de ligne. Espaces réservés : `{rank}`, `{tribe}`, `{score}`. |
| `PerRankColor` | Surcharges de couleur facultatives par place, indexées par rang (`"1"`, `"2"`, `"3"`, …), chacune étant un objet RVB. |

**`MyTribeRank`** — affiche le rang de la propre tribu de l'appelant. `Text` prend en
charge les mêmes espaces réservés `{rank}`, `{tribe}`, `{score}`.

### `Messages`

Réservé à la personnalisation des messages ; vide (`{}`) par défaut.

---

## `structures.json`

Valeurs en points des structures, résolues d'abord par **palier** de construction, puis
surchargées par des **blueprints** spécifiques. Une structure qui ne correspond à rien
utilise `DefaultValue`.

```json
{
  "Tiers": {
    "Thatch": { "Value": 1.0,  "LossOverride": 0.5 },
    "Wood":   { "Value": 2.0,  "LossOverride": 1.25 },
    "Stone":  { "Value": 3.0,  "LossOverride": 2.0 },
    "Adobe":  { "Value": 5.0,  "LossOverride": 4.0 },
    "Metal":  { "Value": 10.0, "LossOverride": 7.0 },
    "Tek":    { "Value": 15.0, "LossOverride": 12.5 }
  },
  "DefaultValue": 10.0,
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Structures/Misc/PrimalItemStructure_HeavyTurret.PrimalItemStructure_HeavyTurret'",
      "Value": 25.0
    },
    {
      "BlueprintPath": "Blueprint'/Game/.../PrimalItemStructure_TurretTek.PrimalItemStructure_TurretTek'",
      "Value": 25.0,
      "LossOverride": 25.0
    }
  ]
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Tiers` | object | Valeurs par palier, indexées par matériau de construction (`Thatch`, `Wood`, `Stone`, `Adobe`, `Metal`, `Tek`). |
| `Tiers.<tier>.Value` | number | Points que l'attaquant gagne en détruisant une structure de ce palier. |
| `Tiers.<tier>.LossOverride` | number | *(facultatif)* Points fixes que le défenseur perd. Si omis, `Value × GainLossRatio` est utilisé. |
| `DefaultValue` | number | Valeur de repli lorsqu'une structure ne correspond à aucun palier ni entrée personnalisée. |
| `Customs[]` | array | Surcharges par blueprint qui priment sur la valeur du palier. |
| `Customs[].BlueprintPath` | string | Chemin complet du blueprint de la structure. Utilisez `ts.addstructure` pour ajouter automatiquement la structure que vous regardez (voir [Commandes](commands.md)). |
| `Customs[].Value` | number | Points pour ce blueprint spécifique. |
| `Customs[].LossOverride` | number | *(facultatif)* Perte fixe pour ce blueprint. |

---

## `dinos.json`

Valeurs en points et règles de comptage par espèce de dino. `Defaults` s'applique à
chaque dino non listé dans `Customs`.

```json
{
  "Defaults": {
    "Value": 25.0,
    "LossOverride": 20.0,
    "CountBabies": true,
    "CountWithoutSaddle": true,
    "CountNotMounted": true,
    "ScoreFromWild": true
  },
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/Dinos/Giganotosaurus/Gigant_Character_BP.Gigant_Character_BP'",
      "Value": 50.0,
      "LossOverride": 45.0,
      "CountBabies": false
    }
  ]
}
```

| Champ | Type | Description |
| ----- | ---- | ----------- |
| `Value` | number | Points que l'attaquant gagne en tuant ce dino. |
| `LossOverride` | number | *(facultatif)* Points fixes que le défenseur perd. Si omis, `Value × GainLossRatio` est utilisé. |
| `CountBabies` | boolean | Indique si tuer des dinos bébés/juvéniles rapporte des points. |
| `CountWithoutSaddle` | boolean | Indique si un apprivoisé sans selle rapporte des points. |
| `CountNotMounted` | boolean | Indique si un dino qui n'est pas actuellement chevauché rapporte des points. |
| `ScoreFromWild` | boolean | Indique si tuer un dino **sauvage** (non apprivoisé) de cette espèce rapporte des points. |
| `Customs[].BlueprintPath` | string | Chemin complet du blueprint de l'espèce visée par cette surcharge. |

Chaque entrée `Customs` peut définir n'importe quel sous-ensemble de ces champs ; les
champs non spécifiés reviennent aux valeurs de `Defaults`.
