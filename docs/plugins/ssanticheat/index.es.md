# 🛡️ ssAntiCheat

ssAntiCheat es un **anti-cheat del lado del servidor** para ARK: Survival Evolved.
Se ejecuta completamente dentro de tu servidor como un plugin de ArkApi — los
jugadores no instalan nada, y no hay ningún cliente que evadir. Las detecciones se
alertan a tu Discord y a los administradores dentro del juego, y los infractores se
encolan en una **oleada de baneos** para que los tramposos no averigüen qué
comprobación los detectó.

Además de la detección, ssAntiCheat también **bloquea** directamente un gran número
de exploits conocidos, e incluye correcciones para varios problemas de servidor de
larga data — incluyendo **exploits de cierre inesperado** y **duplicación de
objetos**.

## Funciones

- **Módulos de detección.** Docenas de detectores que se pueden activar o
  desactivar individualmente, agrupados en cuatro categorías: **Combate**,
  **Varios**, **Mod** y **Exploits**. Algunos ejemplos: detección de aimbot y
  silent-aim, auto-flak, auto-medbrew, no-overheat, auto-loot y auto-craft. Cada
  uno se puede activar, desactivar y ajustar por separado.
- **Bloqueo de exploits, no solo informes.** La mayoría de los módulos de exploits
  pueden *prevenir* la acción además de señalarla, de modo que el exploit falla en
  lugar de limitarse a quedar registrado después de los hechos.
- **Protección contra cierres inesperados y duplicación.** Se bloquean los
  vectores conocidos de cierre inesperado del servidor, y las correcciones de
  duplicación detienen las rutas habituales de dupeo de objetos (dupes por
  transferencia, trucos de bolsa/transmisor, y más).
- **Correcciones de glitches y lag.** Una sección `Fixes` independiente cubre
  glitches conocidos del servidor (el glitch del scout, el glitch de las esposas,
  "player already connected", el glitch del pull, la protección contra lag y la
  corrección de dupeo).
- **Sistema de baneos integrado.** Los baneos se persisten en MySQL y se aplican
  al iniciar sesión, con baneos opcionales por **asociación de IP** y **HWID**.
  Las oleadas de baneos se agrupan para eliminar a varios tramposos a la vez.
  Consulta [Baneos y detecciones](bans.md).
- **Alertas de Discord.** Las detecciones, los baneos, los registros de conexión,
  los baneos por asociación de IP y los registros de acciones de administración
  van cada uno a un webhook que configures — o todos al mismo.
- **Herramientas de administración.** Espía a un jugador señalado con un solo
  comando, activa o desactiva el ESP de jugadores y estructuras para ti mismo, y
  un conjunto de comandos de chat para gestionar sospechosos dentro del juego.
  Cada acción de administración queda registrada.
- **Filtro de conexión.** Comprobaciones opcionales de la Steam Web API al
  conectarse: tiempo de juego mínimo, antigüedad mínima de la cuenta y baneos VAC
  recientes — cada una puede solo registrar, o bloquear.
- **Panel de control (opcional).** Telemetría opcional hacia el panel de control
  de ssAnticheat para un feed de detecciones en vivo, el estado del servidor y un
  mapa opcional de jugadores en vivo. Desactivado de forma predeterminada.

## Cómo una detección se convierte en un baneo

```
el detector se activa
   └─> detección registrada  ──> alerta a los administradores en el juego
                              ──> webhook de Discord
                              ──> panel de control (si está activado)
   └─> ¿se alcanzó el umbral de baneo del módulo?
          └─> jugador encolado para la próxima oleada de baneos
                 └─> la oleada de baneos se ejecuta: en un ciclo de guardado,
                     cuando el jugador se desconecta, en un módulo de baneo
                     instantáneo, o manualmente
```

Los umbrales, el bloqueo y el comportamiento de baneo instantáneo son específicos
de cada módulo. El flujo completo — y cada ajuste que lo modifica — está en la
página de [Baneos y detecciones](bans.md).

## Requisitos

| Requisito | Notas |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** o más reciente | El plugin no se cargará en versiones anteriores de la API. |
| MySQL / MariaDB | Obligatorio. Los baneos se persisten ahí. Consulta [Configuración común](../index.md#database). |
| Una clave de licencia de Bytemart | Nada se activa hasta que la clave se autentica. |
| HTTPS saliente | Necesario para la licencia, los webhooks de Discord y (si se usa) la Steam Web API y el panel de control. |

## Instalación

1. Asegúrate de tener ArkApi **3.51+** instalado en tu servidor.
2. Configura una base de datos MySQL/MariaDB — consulta
   [Configuración común](../index.md#database). La base de datos ya debe existir;
   el plugin crea sus propias tablas dentro de ella.
3. Descarga `ssAntiCheat.zip` desde tu **Panel de Bytemart**.
4. Detén el servidor (ejecuta `saveworld` primero), o descarga cualquier versión
   anterior con `plugins.unload ssAntiCheat`.
5. Extrae el archivo en una carpeta `ssAntiCheat` dentro de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Abre `config.json` y rellena tus credenciales de `LicenseKey` y `Database`
   (consulta [Configuración](configuration.md)).
7. Inicia el servidor y confirma que no hay errores durante el arranque.
8. Ejecuta `ssac.status` desde la consola o RCON para confirmar que la licencia se
   autenticó.

> ⚠️ **Configura tus webhooks antes de salir en producción.** Todos los campos de
> webhook vienen vacíos de fábrica. Hasta que rellenes al menos
> `DefaultWebhookUrl`, las detecciones solo son visibles para los administradores
> dentro del juego y en el registro del servidor.

### Actualización

- **Manual:** `plugins.unload ssAntiCheat`, reemplaza los archivos y luego
  `plugins.load ssAntiCheat`.
- **Automática (recarga en caliente):** renombra el nuevo `ssAntiCheat.dll` a
  `ssAntiCheat.dll.arkapi` y colócalo en la carpeta del plugin — ArkApi carga la
  nueva versión y descarga la antigua automáticamente.

Comprueba siempre el registro de cambios en busca de cambios de configuración al
actualizar. ssAntiCheat repara automáticamente su propia configuración (las claves
que faltan se añaden con sus valores predeterminados y el original se respalda en
`config.json.bak`), pero una herramienta como
[Diffchecker](https://www.diffchecker.com/) sigue siendo útil para detectar claves
nuevas que merezca la pena ajustar.

## Solución de problemas

- **El plugin no se carga, código de error `1114`** — un error de sintaxis JSON en
  `config.json`. Pásalo por [JSONLint](https://jsonlint.com/).
- **"License key is missing"** — `LicenseKey` todavía tiene el valor de marcador
  de posición.
- **Nada llega a Discord** — comprueba que `Use Discord` sea `true` y que la URL
  de webhook correspondiente esté rellenada. Los webhooks son específicos por
  propósito; consulta [Configuración](configuration.md#webhooks).
- **Cualquier otra cosa** — pon `LogToFile` en `true` y reproduce el problema; el
  plugin escribe su propio archivo rotativo `ssAntiCheat.log` junto a
  `config.json`, para que no tengas que rebuscar en el registro compartido del
  servidor. Luego pregunta en el
  [Discord de Bytemart](https://bytemart.net/discord).

---

**Próximos pasos:**

- [Configuración](configuration.md) — todas las claves de `config.json`.
- [Comandos](commands.md) — comandos de consola/RCON y comandos de chat de
  administración dentro del juego.
- [Baneos y detecciones](bans.md) — umbrales, oleadas de baneos, baneos por
  IP/HWID y desbaneos.
- [Configuración común](../index.md#common-configuration) — las claves
  compartidas `LicenseKey`, `Database`, `LogToFile` y `Verbose`.
