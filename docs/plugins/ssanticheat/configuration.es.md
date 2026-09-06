# Configuración

ssAntiCheat se configura mediante un único `config.json` en la carpeta del
plugin:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/ssAntiCheat/config.json
```

Un segundo archivo, `config_commented.json`, se incluye junto a él. Es **la
misma configuración con comentarios `//`** — léelo, pero no lo renombres para
sustituir a `config.json` (los comentarios no son JSON válido).

Las claves `LicenseKey`, `Verbose`, `LogToFile` y `Database` son compartidas por
todos los plugins de Bytemart y están documentadas en la página de
**[Configuración común](../index.md#common-configuration)**. Esta página cubre
solo las claves exclusivas de ssAntiCheat.

> 💡 **Valida antes de empezar.** Valida siempre tu JSON después de editarlo
> (por ejemplo, con [JSONLint](https://jsonlint.com/)). Un código de error de
> carga `1114` significa un error de sintaxis JSON.

> ⚠️ **Los nombres de las claves son estructurales — cópialos exactamente.**
> Varias claves contienen espacios (`"Join Tracker"`, `"SaveWorld Cycles"`,
> `"Block Dedi Fill"`) y algunas llevan un error ortográfico histórico
> (`Threshole`, `additionnalData`). Se comparan byte a byte. "Corregir" una
> ortografía desactiva la función en silencio.

## Configuración autorreparable

En cada carga, ssAntiCheat compara tu `config.json` con el esquema con el que
fue compilado:

- **Las claves que faltan** se añaden con sus valores predeterminados, y la
  consola imprime exactamente lo que se añadió. Tu archivo original se copia
  primero a `config.json.bak`.
- **Las discrepancias de tipo** (una cadena donde se espera un número, etc.)
  **abortan la carga** con un error que nombra la clave — el plugin no se
  ejecutará con una configuración en la que no puede confiar.

Esto significa que una actualización que introduzca claves nuevas no romperá tu
servidor, y siempre puedes recortar tu configuración para dejar solo las claves
que te interesan.

---

## Claves de nivel superior {#top-level-keys}

```json
"Debug": false,
"Use Discord": true,
"UseDiscordURL": true,
"SteamAPIKey": "",
"CommandPrefix": "!",
"Send Alert to Ingame Admins when someone is detected using a cheat": true
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Debug` | boolean | `false` | Indicador de depuración interno. Déjalo en `false` — usa [`Verbose`](../index.md#verbose) para obtener salida de solución de problemas. |
| `Use Discord` | boolean | `true` | Interruptor maestro para las alertas de Discord. Cuando es `false`, no se publica ningún embed de detección o baneo en ningún sitio. |
| `UseDiscordURL` | boolean | `true` | Si los embeds de Discord incluyen las imágenes de icono/miniatura de ssAntiCheat. Puramente estético. |
| `SteamAPIKey` | string | `""` | Una [clave de la Steam Web API](https://steamcommunity.com/dev/apikey). Solo la requiere el filtro de conexión (comprobaciones de tiempo de juego / antigüedad de cuenta / VAC). Déjala vacía si no la usas. |
| `CommandPrefix` | string | `"!"` | El prefijo de los comandos de chat de administración dentro del juego. Consulta [Comandos](commands.md#chat-commands). |
| `Send Alert to Ingame Admins when someone is detected using a cheat` | boolean | `true` | Difunde una alerta de detección coloreada a todos los administradores conectados. |

## Webhooks {#webhooks}

```json
"DefaultWebhookUrl": "",
"BanWebhookUrl": "",
"AssociationBans": "",
"AdminTrollingWebhook": ""
```

Los cuatro son URLs de webhook de Discord, y todos vienen **vacíos** de
fábrica. Un webhook vacío significa "no enviar nada" — nunca es un error.

| Campo | Descripción |
| ----- | ----------- |
| `DefaultWebhookUrl` | A dónde van las detecciones cuando el módulo no tiene su propio webhook. Este es el que debes rellenar primero. |
| `BanWebhookUrl` | A dónde van las alertas de **baneo**. Recurre a `DefaultWebhookUrl` cuando está vacío. |
| `AssociationBans` | A dónde van las alertas de baneo por **asociación de IP** — es decir, una cuenta nueva sorprendida conectándose desde la IP de un jugador baneado. Consulta [Baneos y detecciones](bans.md#ip-association-bans). |
| `AdminTrollingWebhook` | Registro de auditoría de los comandos de chat de administración dentro del juego: quién ejecutó qué, sobre quién y dónde. |

Cualquier módulo individual también puede tener su propia clave `WebhookUrl`,
que anula `DefaultWebhookUrl` solo para ese módulo.

> 🔒 **Una URL de webhook es una credencial.** Cualquiera que la tenga puede
> publicar en tu canal. Mantén `config.json` fuera de repositorios públicos y
> capturas de pantalla.

## `Dashboard`

```json
"Dashboard": {
  "Enabled": false,
  "LivePositions": false
}
```

Telemetría opcional hacia el panel de control de ssAnticheat: un feed de
detecciones y baneos en vivo, historial de baneos y estado básico del
servidor. **Ambas claves son `false` de forma predeterminada** — nada sale de
tu máquina hasta que las actives.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `false` | Interruptor maestro para la telemetría del panel de control. |
| `LivePositions` | boolean | `false` | Envía además las posiciones de los jugadores para que el panel de control pueda dibujar un mapa en vivo. Esto es, en la práctica, una vista en vivo de dónde está cada jugador — déjalo desactivado a menos que quieras eso. |

Usa [`ssac.status`](commands.md#ssacstatus) para comprobar si la telemetría
realmente está fluyendo, y [`ssac.testdetection`](commands.md#ssactestdetection)
para enviar una detección simulada a través del proceso.

## `Join Tracker`

```json
"Join Tracker": {
  "Enabled": true,
  "Include IP": true,
  "JoinLogs": ""
}
```

Publica un embed de Discord cada vez que un jugador se conecta, con su nombre,
Steam ID, tribu y ubicación de aparición.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Activa o desactiva el registro de conexiones. |
| `Include IP` | boolean | `true` | Incluye la dirección IP de conexión en el embed. |
| `JoinLogs` | string | `""` | URL de webhook para los registros de conexión. Vacío significa que los registros se recopilan pero no se publican. |

> ⚠️ **Las direcciones IP son datos personales.** Si activas `Include IP`,
> envía los registros de conexión a un canal privado solo para administradores,
> y comprueba qué exige tu normativa local antes de conservarlos.

## `Admin ESP`

Ajustes para la superposición de ESP de administración dentro del juego,
activada por cada administrador con la
[familia de comandos `!esp`](commands.md#chat-commands).

```json
"Admin ESP": {
  "Enabled": true,
  "RefreshTime": 0.1,
  "Range": 30000,
  "Structure ESP": ["Box"]
}
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Reservado. El acceso a los comandos de ESP está controlado por el estado de administrador de ARK, no por esta clave. |
| `RefreshTime` | number | `0.1` | Cuánto dura cada etiqueta/caja dibujada, en segundos. Menor = más fluido, más llamadas de dibujo del cliente. |
| `Range` | number | `30000` | Radio de escaneo (unidades de Unreal) alrededor del administrador. |
| `Structure ESP` | array | `["Box"]` | Subcadenas de nombres de blueprint de estructuras a resaltar cuando el ESP de estructuras está activado. `"Box"` coincide con las cajas de almacenamiento; añade por ejemplo `"Vault"` o `"Turret"`. |

## `ServerCrash`

```json
"ServerCrash": {
  "SaveWorld": true,
  "AutomaticRestart": true
}
```

Qué hacer cuando el proceso del servidor se cierra inesperadamente.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `SaveWorld` | boolean | `true` | Intenta guardar el mundo desde dentro del manejador de cierres inesperados, de modo que un cierre cueste minutos en lugar de todo el intervalo de guardado. |
| `AutomaticRestart` | boolean | `true` | Reinicia el servidor automáticamente tras un breve retraso después del cierre inesperado. **Desactiva** esto si tu gestor de servidor (ASM, ArkServerManager, un wrapper de servicio, …) ya reinicia al salir — de lo contrario tendrás dos reinicios compitiendo entre sí. |

## `Fixes`

Correcciones para glitches conocidos del servidor y rutas de exploits. No son
detectores — nadie es señalado ni baneado por ellos; el comportamiento
defectuoso simplemente se impide.

```json
"Fixes": {
  "Scout Glitch Fix":         { "Enabled": true },
  "Handcuff Glitch Fix":      { "Enabled": false },
  "Player Already Connected": { "Enabled": true },
  "Pull Fix":                 { "Enabled": true },
  "Lag Protector":            { "Enabled": true },
  "Dupe Fix":                 { "Enabled": true }
}
```

| Corrección | Predeterminado | Qué hace |
| --- | ------- | ------------ |
| `Scout Glitch Fix` | `true` | Corrige el comportamiento de transporte del Scout, cerrando el conocido glitch del Scout. |
| `Handcuff Glitch Fix` | `false` | Vuelve a equipar las esposas a un jugador que se reconecta después de haberse desconectado estando esposado — cerrando el truco de "desconectarse para escapar de las esposas". Desactivado de forma predeterminada; actívalo si las esposas forman parte de cómo operan tus administradores o jugadores. |
| `Player Already Connected` | `true` | Elimina la sesión atascada que produce el error "player already connected", para que los jugadores no tengan que esperar a que se resuelva sola. |
| `Pull Fix` | `true` | Bloquea el exploit de **server pull** de Structures Plus, en el que se usa un pull para arrastrar en bloque objetos restringidos (tributos de jefe y similares) fuera de un contenedor. Al jugador se le muestra "You can't pull this craft". |
| `Lag Protector` | `true` | Protección contra griefing dirigida a trucos deliberados de lag en el servidor. **Necesita claves adicionales — consulta más abajo.** |
| `Dupe Fix` | `true` | Destruye los alijos de objetos de muerte de S+ duplicados: un segundo alijo de muerte que aparece encima de uno ya existente se elimina en lugar de duplicar su contenido. |

Cada corrección tiene un indicador `Enabled`. `Lag Protector` tiene tres más.

### Protector de lag

`Lag Protector` viene solo con `Enabled`, y cada una de sus protecciones es
**opcional** — añade tú mismo las claves para activarlas:

```json
"Lag Protector": {
  "Enabled": true,
  "WhipProtection": true,
  "BlueprintProtection": true,
  "LagWebhook": ""
}
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `WhipProtection` | boolean | `false` | Expulsa a un jugador que dispara un arma dentro de un área con suficientes estructuras como para causar lag al servidor — el clásico grief de "látigo en una mega-base". |
| `BlueprintProtection` | boolean | `false` | Expulsa a un jugador que encola una ráfaga inverosímil de fabricaciones de blueprints en pocos segundos. |
| `LagWebhook` | string | `""` | Webhook para las expulsiones de la protección contra lag. Si está vacío, no se envía nada. |

Las expulsiones de esta corrección llevan un código de motivo deliberadamente
opaco, para que un griefer no aprenda nada de ello: `0x7E3` es la protección
contra el látigo, `0x4DE` la protección de blueprints.

> ℹ️ **Las claves que añades tú mismo se conservan.** La autorreparación de la
> configuración solo *añade* claves que faltan — nunca elimina claves que no
> reconoce, así que las tres anteriores sobreviven a las actualizaciones del
> plugin.

## `IntegratedBanSystem` y `AutoBan`

Estas dos secciones controlan el proceso de baneo y están documentadas en su
totalidad en la página de **[Baneos y detecciones](bans.md)**:

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
},
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

> ⚠️ **Cambia la URL de `BanMessage`.** Viene con un marcador de posición
> `example.com`. Apúntala a tu propia tienda o página de apelación.

---

## `Modules`

Cada detector vive bajo `Modules`, en una de cuatro categorías:

| Categoría | Qué cubre |
| -------- | -------------- |
| `CombatCheats` | Trampas durante el combate — asistencia de puntería, manipulación de cadencia de disparo y munición, automatización de consumibles. |
| `MiscCheats` | Automatización de cliente y herramientas del lado del cliente — auto-loot, auto-craft, spoofers, anomalías de temporización, además del filtro de conexión. |
| `Mod` | Comprobaciones que requieren el mod cliente complementario opcional (incluyendo la captura de ID de hardware y la detección de evasión de mods). Inerte a menos que ese mod esté desplegado — pregunta en el [Discord de Bytemart](https://bytemart.net/discord) si lo quieres. |
| `Exploits` | Exploits conocidos del juego y de mods: rutas de duplicación, vectores de cierre inesperado, unlockers, abuso de monturas y estructuras, protección de administradores, y más. |

La forma es siempre la misma:

```json
"Modules": {
  "CombatCheats": {
    "Enabled": true,
    "SubModules": {
      "AutoFlak":   { "Enabled": true, "Block": true, "TimesUntilDetect": 6 },
      "NoOverheat": { "Enabled": true, "Block": true, "BanAfterDetections": 2 },
      "...":        { "...": "..." }
    }
  },
  "MiscCheats": { "Enabled": true, "SubModules": { "...": "..." } },
  "Mod":        { "Enabled": true, "SubModules": { "...": "..." } },
  "Exploits":   { "Enabled": true, "SubModules": { "...": "..." } }
}
```

El `Enabled: false` de una categoría desactiva **todos** los módulos dentro de
ella, sea lo que digan los indicadores individuales. Tu `config.json` de
fábrica contiene la lista completa de submódulos con valores predeterminados
razonables — la referencia de abajo explica las claves que encontrarás en
ellos.

### Claves comunes de submódulo {#common-submodule-keys}

| Clave | Tipo | Significado |
| --- | ---- | ------- |
| `Enabled` | boolean | Activa o desactiva este detector específico. |
| `Block` | boolean | Impide la acción tramposa además de reportarla. Cuando es `false`, la acción se ejecuta y solo obtienes la alerta — útil mientras generas confianza en un módulo en tu propio servidor. |
| `BanAfterDetections` | number | Encola al jugador para un baneo después de esta cantidad de detecciones **de este módulo**. Ausente o `0` significa que este módulo nunca banea por sí solo. |
| `InstantBan` | boolean | Ejecuta ese baneo de inmediato en lugar de esperar a la próxima oleada de baneos. |
| `OnlyAnalysis` | boolean | Detecta y registra, pero no publica en tu webhook de Discord. Un modo silencioso para evaluar un módulo. |
| `WebhookUrl` | string | Envía las alertas de este módulo a un webhook específico en lugar de `DefaultWebhookUrl`. |
| `Threshole` / `*Threshold` | number | La sensibilidad del módulo. Más alto = se requiere más evidencia antes de activarse. La ortografía `Threshole` es intencional en las claves que la usan. |
| `BlockMovement` | boolean | Usado por algunos módulos de unlockers: inmoviliza al infractor en lugar de solo señalarlo. |

Algunos módulos añaden claves propias — por ejemplo, una lista de nombres de
blueprint a excluir de una comprobación, o un sub-indicador adicional para una
variante específica del exploit. Esas se describen en `config_commented.json`
donde no son evidentes por sí mismas.

> 💡 **Consejo de ajuste.** Empieza con los valores predeterminados de
> fábrica. Si un módulo produce falsos positivos en tu configuración, prefiere
> subir su umbral o su `BanAfterDetections` antes que desactivarlo por
> completo — y activa `OnlyAnalysis` mientras lo observas.

### El filtro de conexión

Un módulo dentro de `MiscCheats` merece mención aparte porque necesita
configuración externa: el **rastreador de sesión** comprueba a un jugador que
se conecta contra la Steam Web API y puede rechazar cuentas que parezcan
desechables.

```json
"SessionTracker": {
  "Enabled": true,
  "WebhookUrl": "",
  "Checks": {
    "AccountRestrictions": {
      "MinGameHours": 30,
      "BlockMinGameHours": false,
      "LogMinGameHours": true,
      "MinAccountAgeDays": 30,
      "BlockMinAccountAgeDays": false,
      "LogMinAccountAgeDays": true
    },
    "VacBanRestrictions": {
      "Block": false,
      "RecentDaysThreshole": 90,
      "Log": true
    }
  }
}
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `WebhookUrl` | string | `""` | Webhook para los resultados del filtro. Recurre a `DefaultWebhookUrl`. |
| `MinGameHours` | number | `30` | Tiempo mínimo de juego en ARK, en horas. |
| `BlockMinGameHours` | boolean | `false` | Expulsa a los jugadores por debajo de ese tiempo de juego. |
| `LogMinGameHours` | boolean | `true` | Reporta a los jugadores por debajo de ese tiempo de juego. |
| `MinAccountAgeDays` | number | `30` | Antigüedad mínima de la cuenta de Steam, en días. |
| `BlockMinAccountAgeDays` | boolean | `false` | Expulsa a las cuentas más nuevas que eso. |
| `LogMinAccountAgeDays` | boolean | `true` | Reporta a las cuentas más nuevas que eso. |
| `VacBanRestrictions.RecentDaysThreshole` | number | `90` | Qué tan reciente debe ser un baneo VAC para contar. |
| `VacBanRestrictions.Block` | boolean | `false` | Expulsa a los jugadores con un baneo VAC reciente. |
| `VacBanRestrictions.Log` | boolean | `true` | Reporta a los jugadores con un baneo VAC reciente. |

> ℹ️ **Requiere `SteamAPIKey`.** Sin una clave, estas comprobaciones no pueden
> ejecutarse. Ten en cuenta también que un jugador con un perfil de Steam
> **privado** oculta su tiempo de juego — decide deliberadamente si quieres
> activar `Block*`, ya que alejará a algunos jugadores legítimos.

---

**Próximos pasos:**

- [Comandos](commands.md) — comandos de consola/RCON y de administración
  dentro del juego.
- [Baneos y detecciones](bans.md) — umbrales, oleadas de baneos, baneos por
  IP/HWID, desbaneos.
- [Configuración común](../index.md#common-configuration) — `LicenseKey`,
  `Database`, `LogToFile`, `Verbose`.
