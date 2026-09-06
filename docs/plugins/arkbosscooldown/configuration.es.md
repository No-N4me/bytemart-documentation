# Configuración

ArkBossCooldown se configura mediante un único `config.json` en la carpeta del
plugin:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ArkBossCooldown/config.json
```

Un segundo archivo, `config_commented.json`, se incluye junto a él. Es **la
misma configuración con comentarios `//`** — léelo, pero no lo renombres para
sustituir a `config.json` (los comentarios no son JSON válido).

Las claves `LicenseKey`, `Verbose`, `LogToFile` y `Database` son compartidas
por todos los plugins de Bytemart y están documentadas en la página de
**[Configuración común](../index.md#common-configuration)**. Esta página cubre
las claves exclusivas de ArkBossCooldown.

> 💡 **Valida antes de empezar.** Valida siempre tu JSON después de editarlo
> (por ejemplo, con [JSONLint](https://jsonlint.com/)). Un código de error de
> carga `1114` significa un error de sintaxis JSON — fácil de causar en el
> extenso array `Bosses`.

## `TestMode`

```json
"TestMode": false
```

Cuando es `true`, el plugin registra en la consola del servidor la **ruta de
blueprint de cada objeto que fabrique cualquier jugador**. Así es como
encuentras la ruta exacta de un objeto de tributo para ponerlo en
[`Bosses`](#bosses):

1. Pon `TestMode` en `true` y recarga (`ArkBossCooldown.reload`).
2. Fabrica el tributo que quieres restringir.
3. Copia la ruta de la línea de consola — se ve así:
   `[TestMode] Crafted item blueprint: Blueprint'/Game/...'`.
4. Pégala en `Bosses`, vuelve a poner `TestMode` en `false`, y recarga de
   nuevo.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `TestMode` | boolean | `false` | Registra la ruta de blueprint de cada objeto fabricado. |

> ⚠️ **Vuelve a desactivarlo.** Con `TestMode` activado, un servidor
> concurrido escribe una línea de consola por *cada fabricación de cada
> jugador*. Es una herramienta de consulta, no un ajuste para dejar activado.

## `BossStartCooldown`

```json
"BossStartCooldown": 5
```

Cuántos **segundos** debe esperar todo el servidor entre dos inicios de jefe.
La primera fabricación de tributo activa el tiempo de espera; cualquier otra
fabricación de tributo se rechaza hasta que expire.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `BossStartCooldown` | number | `5` | Segundos entre inicios de jefe, a nivel de servidor. |

El valor predeterminado de `5` es un **debounce** — absorbe una ráfaga de
clics repetidos y es invisible en el juego normal. Valores más grandes
convierten al plugin en un límite de frecuencia real, lo cual funciona, pero
ten en cuenta dos cosas:

- **Es a nivel de servidor.** Un tiempo de espera de 30 minutos significa que
  una tribu que inicia un jefe bloquea a todas las demás tribus durante 30
  minutos. Eso es una decisión de diseño para tu servidor, no un error.
- **No sobrevive a un reinicio.** El tiempo de espera activado vive en
  memoria, así que un reinicio del servidor (o una descarga/carga del plugin)
  lo despeja. Está bien para unos pocos segundos; vale la pena saberlo si lo
  pones en horas.

`ArkBossCooldown.reload` toma un valor nuevo de inmediato, pero deja
deliberadamente en marcha un tiempo de espera ya activado.

## `CooldownMessage`

```json
"CooldownMessage": {
  "Enabled": true,
  "Channel": "Notification",
  "Message": "Boss is on cooldown, please wait %delay%.",
  "Color": { "R": 255, "G": 0, "B": 0, "A": 255 },
  "Scale": 1.0,
  "Time": 5.0
}
```

Lo que ve el jugador al que se le rechazó. Solo se notifica a ese jugador — no
se difunde nada al resto del servidor.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Ponlo en `false` para rechazar el inicio de jefe en silencio. |
| `Channel` | string | `"Notification"` | `"Chat"`, `"Notification"`, o `"Broadcast"`. Un valor no reconocido recurre a `"Chat"`. |
| `Message` | string | ver arriba | El texto. Admite los marcadores de abajo. |
| `Color` | object | rojo | `R`, `G`, `B`, `A`, cada uno `0`–`255`. `A` es la opacidad. |
| `Scale` | number | `1.0` | Tamaño del texto. **Solo en el canal `Notification`** — se ignora en los demás. |
| `Time` | number | `5.0` | Segundos que el mensaje permanece en pantalla. **Solo `Notification` y `Broadcast`** — una línea de chat permanece en el registro de chat de todas formas. |

### Marcadores

| Marcador | Se expande a | Ejemplo |
| ----------- | ---------- | ------- |
| `%delay%` | El tiempo restante, escrito con palabras | `1 Minute, 5 Seconds` |
| `%seconds%` | El tiempo restante como un simple número de segundos | `65` |

Usa `%delay%` para un mensaje que los jugadores lean, y `%seconds%` cuando
quieras algo compacto:

```json
"Message": "Boss on cooldown - %seconds%s remaining."
```

> 💡 **`Notification` también acepta un `Icon`.** Añade una clave `"Icon"`
> con una ruta de textura para mostrar una imagen junto a la notificación. No
> está en la configuración de fábrica; añádela tú mismo si quieres una — la
> reparación de la configuración solo *añade* claves que faltan, así que
> sobrevivirá a las actualizaciones.

## `Bosses`

```json
"Bosses": [
  "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'",
  "Blueprint'/Game/Fjordur/Boss/Arena/PrimalItem_BossTribute_FenrirBoss_Hard.PrimalItem_BossTribute_FenrirBoss_Hard'"
]
```

Las rutas de blueprint de cada objeto de tributo que activa el tiempo de
espera. **Cualquier cosa que no esté en esta lista se fabrica con total
normalidad** — el plugin la ignora.

| Campo | Tipo | Descripción |
| ----- | ---- | ----------- |
| `Bosses` | array of strings | Rutas de blueprint completas, incluyendo el envoltorio `Blueprint'...'` y el nombre de activo duplicado después del `.` final. Se comparan exactamente. |

La lista de fábrica cubre los objetos de tributo de **The Island**,
**The Center**, **Scorched Earth**, **Ragnarok**, **Aberration**,
**Valguero**, **Fjordur**, **Lost Island**, y **Crystal Isles**, en todas las
dificultades.

Para restringir cualquier otra cosa — otro mapa, una arena modificada, o un
tributo personalizado — usa [`TestMode`](#testmode) para capturar la ruta y
añadirla aquí. Para *dejar* de restringir un jefe, elimina su línea.

> ⚠️ **Copia las rutas exactamente.** La coincidencia es byte a byte sobre la
> ruta completa. Una `'` final que falte, una ruta acortada, o el nombre de
> activo escrito una vez en lugar de dos veces, todo significa "sin
> coincidencia", y el tributo se fabricará sin ningún tiempo de espera. No hay
> ningún error para una ruta no reconocida, así que comprueba tu cambio con
> una fabricación real.

## Ejemplo completo

Un límite de 15 minutos anunciado en el chat:

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "TestMode": false,
  "BossStartCooldown": 900,
  "CooldownMessage": {
    "Enabled": true,
    "Channel": "Chat",
    "Message": "A boss fight has already started. Next one available in %delay%.",
    "Color": { "R": 255, "G": 180, "B": 0, "A": 255 },
    "Scale": 1.0,
    "Time": 8.0
  },
  "Bosses": [
    "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Cloth/PrimalItem_BossTribute_Spider_Easy.PrimalItem_BossTribute_Spider_Easy'"
  ],
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  }
}
```

> ℹ️ **`Database` es obligatorio pero no se usa.** ArkBossCooldown se conecta
> al arrancar como todos los plugins de Bytemart, pero no almacena nada
> propio. Apúntalo a cualquier base de datos que el servidor pueda alcanzar.

---

**Próximos pasos:**

- [Descripción general](index.md) — qué hace el plugin, la instalación y los
  comandos.
- [Configuración común](../index.md#common-configuration) — `LicenseKey`,
  `Database`, `LogToFile`, `Verbose`.
