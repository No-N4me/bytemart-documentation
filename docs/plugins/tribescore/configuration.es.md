# Configuración

Tribescore se configura mediante **tres** archivos en la carpeta del plugin
(`ShooterGame/Binaries/Win64/ArkApi/Plugins/Tribescore/`):

| Archivo | Propósito |
| ---- | ------- |
| `config.json` | Ajustes principales: licencia, base de datos, activación, elegibilidad, modificadores de puntuación, hologramas y comandos de chat. |
| `structures.json` | Valores de puntos para estructuras, por nivel de construcción y por blueprint. |
| `dinos.json` | Valores de puntos y reglas de conteo para dinos, por especie. |

> 💡 **Valida antes de empezar.** Valida siempre tu JSON después de editarlo (por
> ejemplo, con [JSONLint](https://jsonlint.com/)). Un código de error de carga `1114`
> significa un error de sintaxis JSON.

Las claves `LicenseKey`, `Verbose`, `LogToFile` y `Database` son compartidas por todos
los plugins de Bytemart y están documentadas en la página de
**[Configuración común](../index.md#common-configuration)**. Esta página cubre solo las
claves exclusivas de Tribescore.

---

## `config.json`

### `DebugMode`

```json
"DebugMode": false
```

Cuando es `true`, la consola se vuelve más detallada **y** se te permite ganar
tribescore de tu propia tribu — útil para probar la puntuación en un servidor de
desarrollo. Déjalo en `false` en un servidor en producción.

### `TribescoreActivation`

Retrasa la puntuación de forma global tras el inicio (wipe) de un servidor, para que
las tribus tengan tiempo de reestablecerse antes de que empiece la competición.

```json
"TribescoreActivation": {
  "Activation": {
    "Type": "delay",
    "Value": 7200
  },
  "Message": "Tribescore is globally enabled after 2 hours, please wait {cooldown}"
}
```

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Activation.Type` | string | `"delay"` — activa la puntuación `Value` segundos después del inicio del servidor. `"timestamp"` — activa la puntuación en una [marca de tiempo Unix](https://www.unixtimestamp.com/) fija. |
| `Activation.Value` | number | Segundos de retraso (para `delay`) o la marca de tiempo Unix (para `timestamp`). Ponlo en `0` para desactivar la función y activar la puntuación de inmediato. |
| `Message` | string | Se muestra a los jugadores que activan la puntuación mientras aún está en tiempo de espera. El marcador `{cooldown}` se reemplaza por el tiempo restante. |

### `TribescoreEligibility`

Restringe qué tribus pueden ganar puntos según el tamaño de la membresía.

```json
"TribescoreEligibility": {
  "MinPlayers": 1,
  "MinOnlinePlayers": 0
}
```

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `MinPlayers` | number | Número mínimo de miembros que una tribu debe tener (en total) para ganar puntos. |
| `MinOnlinePlayers` | number | Número mínimo de miembros que deben estar **conectados** para que la tribu gane puntos. `0` desactiva esta comprobación. |

### `Scoring`

El corazón del plugin. Los valores base residen aquí (y en `structures.json` /
`dinos.json`); la subsección `Modifiers` los multiplica.

```json
"Scoring": {
  "GainLossRatio": 0.75,
  "Structures": { "Enabled": true, "DefaultValue": 10.0 },
  "Dinos":      { "Enabled": true, "DefaultValue": 25.0 },
  "Players":    { "Enabled": true, "Value": 150.0 },
  "Modifiers": { "...": "..." }
}
```

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `GainLossRatio` | number | Cuando no se establece un `LossOverride` explícito (en `structures.json` / `dinos.json`), la pérdida de puntuación del **defensor** es `gain × GainLossRatio`. Con `0.75`, un defensor pierde el 75 % de lo que ganó el atacante. |
| `Structures.Enabled` | boolean | Activa la puntuación por estructuras destruidas. Configura los valores en [`structures.json`](#structuresjson). |
| `Structures.DefaultValue` | number | Puntos para una estructura sin coincidencia de nivel o blueprint. |
| `Dinos.Enabled` | boolean | Activa la puntuación por dinos matados. Configura los valores en [`dinos.json`](#dinosjson). |
| `Dinos.DefaultValue` | number | Puntos para un dino sin anulación por especie. |
| `Players.Enabled` | boolean | Activa la puntuación por jugadores enemigos matados. |
| `Players.Value` | number | Puntos fijos otorgados por cada muerte de jugador enemigo. |

#### `Modifiers.OfflineProtection`

Reduce (o aumenta) los puntos ganados contra una tribu que ha estado completamente
desconectada durante un tiempo — desalentando el raideo offline.

```json
"OfflineProtection": {
  "Enabled": true,
  "ActivatesAfter": 3600,
  "Modifier": 0.75
}
```

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Activa o desactiva la función. |
| `ActivatesAfter` | number | Segundos que una tribu debe estar completamente desconectada antes de que se active la protección. |
| `Modifier` | number | Multiplicador aplicado una vez activo. `< 1` reduce la ganancia del atacante (por ejemplo, `0.75` = −25 %). |

*Aplicado según el **defensor**.*

#### `Modifiers.PermissionModifiers`

Aumenta (o reduce) la puntuación según los **permisos** de ArkApi del atacante.
Requiere el plugin [Permissions](https://github.com/ServersHub/ServerAPI) de la
ArkServerAPI.

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

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Activa o desactiva la función. |
| `TribePermissionsOnly` | boolean | Cuando es `true`, solo comprueba los permisos a nivel de tribu (ignora los permisos individuales de los jugadores). |
| `OnlinePlayersOnly` | boolean | Cuando es `true`, solo considera los permisos de los miembros actualmente conectados; de lo contrario, se comprueban todos los miembros. |
| `Modifiers[]` | array | Pares permiso → multiplicador. **Solo se aplica un modificador a la vez**; si varios coinciden, se usa el **mayor**. |
| `Modifiers[].Permission` | string | El nodo de permiso que el jugador/tribu debe poseer. |
| `Modifiers[].Value` | number | Multiplicador aplicado (`> 1` aumenta la ganancia). |

*Aplicado según el **atacante**.*

#### `Modifiers.ScoreDifferenceRatio`

Equilibra tribus fuertes frente a débiles. El ratio comparado es la puntuación del
**defensor** dividida por la puntuación del **atacante**; el `Modifier` del intervalo
coincidente escala la ganancia del atacante — de modo que las tribus grandes que
cultivan puntos de las pequeñas se ven penalizadas, y los desfavorecidos que atacan a
gigantes se ven potenciados.

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

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Activa o desactiva la función. |
| `Intervals[]` | array | Bandas del ratio de puntuación defensor/atacante, cada una con un multiplicador. |
| `LowerBound` / `UpperBound` | number | La banda de ratio que cubre este modificador. Usa `-1` como `UpperBound` de la banda superior para indicar "sin límite superior". |
| `Modifier` | number | Multiplicador aplicado cuando el ratio cae dentro de esta banda. |

**Interpretación de los valores predeterminados:**

- Ratio `≥ 2` (el defensor tiene ≥ 2× la puntuación del atacante) → potenciador de
  **1.2×** para el atacante desfavorecido.
- Ratio entre `1.5` y `2` → potenciador de **1.1×**.
- Ratio entre `0.25` y `0.5` → penalización de **0.6×**.
- Ratio `< 0.25` (el defensor tiene menos de una cuarta parte de la puntuación del
  atacante) → **0.25×** — una fuerte penalización por cultivar puntos de tribus mucho
  más débiles.

*Usa **tanto** al atacante como al defensor.*

### `Holograms`

Controla los números de puntos flotantes que aparecen en el mundo cuando cambia la
puntuación. `Damager` es el texto `+points` mostrado al atacante; `Damagee` es el
texto `-points` mostrado al defensor.

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

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `DecimalPrecision` | number | Decimales mostrados en el valor `{points}`. |
| `LifeSpan` | number | Segundos que el holograma permanece visible. |
| `Scale.X` / `Scale.Y` | number | Tamaño del texto en cada eje. |
| `FadeTime.In` / `FadeTime.Out` | number | Duración de la aparición / desaparición gradual en segundos. |
| `Velocity.X/Y/Z` | number | Velocidad de desplazamiento del texto; el valor predeterminado lo hace flotar hacia arriba (`Z`). |
| `Damager` / `Damagee` | object | Los avisos emergentes de ganancia / pérdida. `Enabled` activa cada uno; `Text` usa el marcador `{points}`; `Color` es RGB (0–255). |

Los jugadores pueden activar o desactivar los hologramas para sí mismos con el comando
de chat `/holograms` (consulta [Comandos](commands.md)).

### `ChatCommands`

Activa, renombra y da estilo a los tres comandos de chat en el juego. Cada uno tiene un
interruptor `Enabled` y un activador `Command` personalizable; desactivar uno lo
elimina por completo del registro.

```json
"ChatCommands": {
  "Holograms":   { "Enabled": true, "Command": "/holograms", "On": { "...": "..." }, "Off": { "...": "..." } },
  "Leaderboard": { "Enabled": true, "Lines": 15, "Command": "/leaderboard", "Text": "#{rank} [{tribe}] : {score}", "PerRankColor": { "...": "..." } },
  "MyTribeRank": { "Enabled": true, "Command": "/triberank", "Text": "Your tribe ({tribe}) is ranked #{rank} with {score}" }
}
```

Campos comunes en cada comando: `TextSize` (número), `Color` (RGB `{R,G,B}`) y
`DisplayTime` (segundos que el mensaje permanece en pantalla).

**`Holograms`** — activa o desactiva la visualización de hologramas por jugador. `On` y
`Off` definen cada uno el mensaje de confirmación (`Text`, `TextSize`, `Color`,
`DisplayTime`) mostrado al alternar.

**`Leaderboard`** — imprime las mejores tribus.

| Campo | Descripción |
| ----- | ----------- |
| `Lines` | Cuántas tribus listar. |
| `Text` | Formato de línea. Marcadores: `{rank}`, `{tribe}`, `{score}`. |
| `PerRankColor` | Anulaciones de color opcionales por puesto, indexadas por rango (`"1"`, `"2"`, `"3"`, …), cada una un objeto RGB. |

**`MyTribeRank`** — imprime el rango de la propia tribu de quien lo ejecuta. `Text`
admite los mismos marcadores `{rank}`, `{tribe}`, `{score}`.

### `Messages`

Reservado para la personalización de mensajes; vacío (`{}`) de forma predeterminada.

---

## `structures.json`

Valores de puntos para estructuras, resueltos primero por **nivel** de construcción y
luego anulados por **blueprints** específicos. Una estructura que no coincide con nada
usa `DefaultValue`.

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

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Tiers` | object | Valores por nivel, indexados por material de construcción (`Thatch`, `Wood`, `Stone`, `Adobe`, `Metal`, `Tek`). |
| `Tiers.<tier>.Value` | number | Puntos que gana el atacante por destruir una estructura de este nivel. |
| `Tiers.<tier>.LossOverride` | number | *(opcional)* Puntos fijos que pierde el defensor. Si se omite, se usa `Value × GainLossRatio`. |
| `DefaultValue` | number | Valor de reserva cuando una estructura no coincide con ningún nivel ni entrada personalizada. |
| `Customs[]` | array | Anulaciones por blueprint que tienen prioridad sobre el valor de nivel. |
| `Customs[].BlueprintPath` | string | Ruta de blueprint completa de la estructura. Usa `ts.addstructure` para añadir automáticamente la estructura que estás mirando (consulta [Comandos](commands.md)). |
| `Customs[].Value` | number | Puntos para este blueprint específico. |
| `Customs[].LossOverride` | number | *(opcional)* Pérdida fija para este blueprint. |

---

## `dinos.json`

Valores de puntos y reglas de conteo por especie de dino. `Defaults` se aplica a todo
dino que no esté listado en `Customs`.

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

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Value` | number | Puntos que gana el atacante por matar a este dino. |
| `LossOverride` | number | *(opcional)* Puntos fijos que pierde el defensor. Si se omite, se usa `Value × GainLossRatio`. |
| `CountBabies` | boolean | Si matar dinos bebés/juveniles otorga puntos. |
| `CountWithoutSaddle` | boolean | Si un domesticado sin montura otorga puntos. |
| `CountNotMounted` | boolean | Si un dino que no está siendo montado en ese momento otorga puntos. |
| `ScoreFromWild` | boolean | Si matar a un dino **salvaje** (no domesticado) de esta especie otorga puntos. |
| `Customs[].BlueprintPath` | string | Ruta de blueprint completa de la especie a la que apunta esta anulación. |

Cada entrada de `Customs` puede establecer cualquier subconjunto de estos campos; los
campos no especificados recurren a `Defaults`.
