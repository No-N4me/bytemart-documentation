# ⏳ ArkBossCooldown

ArkBossCooldown impone un **tiempo de espera a nivel de servidor entre inicios
de jefe**. Se entra a las arenas de jefe fabricando un objeto de tributo, y
nada impide que un grupo fabrique varios seguidos — los teletransportes se
acumulan y los jugadores llegan muertos a la arena. Este plugin hace que el
servidor rechace un inicio de jefe hasta que haya expirado el tiempo de espera
del anterior.

Es deliberadamente pequeño: un tiempo de espera, un mensaje, una lista de
objetos de tributo.

## Qué hace

- **Un único tiempo de espera para todo el servidor.** La primera fabricación
  de tributo de jefe lo activa; cualquier otra fabricación de tributo se
  rechaza hasta que expire. *No* es por jugador ni por tribu — si un grupo
  inicia un jefe, todos esperan.
- **La fabricación rechazada no cuesta nada.** El objeto de tributo no se
  consume y no ocurre ningún teletransporte, así que un jugador que se topa
  con el tiempo de espera simplemente puede volver a intentarlo una vez que
  haya pasado.
- **Le dice al jugador por qué.** Un mensaje configurable de chat,
  notificación o difusión muestra el tiempo restante. También se puede
  desactivar para rechazar en silencio.
- **Funciona en cualquier mapa, y con mods.** Los objetos de tributo que
  activan el tiempo de espera son solo una lista de rutas de blueprint en la
  configuración, así que puedes añadir arenas modificadas o quitar jefes que
  no quieras restringir.
- **Nada más.** Los objetos que no estén en tu lista se fabrican con total
  normalidad.

> ℹ️ **Esto es un debounce, no un bloqueo de jefes.** `BossStartCooldown` es
> de **5 segundos** de forma predeterminada — suficiente para absorber una
> ráfaga de clics repetidos, lo bastante corto para que nadie lo note. Si
> quieres un límite real de "un jefe por hora", ponlo en un número mucho más
> grande y lee antes la nota sobre
> [reinicios y recargas](configuration.md#bossstartcooldown).

## Requisitos

| Requisito | Notas |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** o más reciente | El plugin no se cargará en versiones anteriores de la API. |
| MySQL / MariaDB | El plugin se conecta al arrancar, por lo que se requieren credenciales válidas — pero ArkBossCooldown en sí no almacena nada ahí. Consulta [Configuración común](../index.md#database). |
| Una clave de licencia de Bytemart | Nada se activa hasta que la clave se autentica. |
| HTTPS saliente | Necesario para la licencia. |

## Instalación

1. Asegúrate de tener ArkApi **3.51+** instalado en tu servidor.
2. Configura una base de datos MySQL/MariaDB — consulta
   [Configuración común](../index.md#database). La base de datos ya debe
   existir.
3. Descarga `ArkBossCooldown.zip` desde tu **Panel de Bytemart**.
4. Detén el servidor (ejecuta `saveworld` primero), o descarga cualquier
   versión anterior con `plugins.unload ArkBossCooldown`.
5. Extrae el archivo en una carpeta `ArkBossCooldown` dentro de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Abre `config.json` y rellena tus credenciales de `LicenseKey` y `Database`.
   Los valores predeterminados de todo lo demás son utilizables tal como
   vienen — consulta [Configuración](configuration.md).
7. Inicia el servidor y confirma que no hay errores durante el arranque.
8. Fabrica un tributo de jefe dos veces seguidas para comprobar que el segundo
   intento se rechaza y aparece el mensaje.

> 💡 **¿Juegas en un mapa o mod que no está en la lista predeterminada?**
> Activa [`TestMode`](configuration.md#testmode), fabrica el tributo una vez,
> y copia en `Bosses` la ruta de blueprint que imprime la consola. Luego
> vuelve a desactivar `TestMode`.

### Actualización

- **Manual:** `plugins.unload ArkBossCooldown`, reemplaza los archivos y
  luego `plugins.load ArkBossCooldown`.
- **Automática (recarga en caliente):** renombra el nuevo
  `ArkBossCooldown.dll` a `ArkBossCooldown.dll.arkapi` y colócalo en la
  carpeta del plugin — ArkApi carga la nueva versión y descarga la antigua
  automáticamente.

ArkBossCooldown repara su propia configuración al cargar: las claves que
faltan se añaden con sus valores predeterminados y tu original se respalda
primero en `config.json.bak`. Una discrepancia de tipo (una cadena donde
corresponde un número) aborta la carga en su lugar, con un error que nombra
la clave.

## Comandos

El acceso a la consola y RCON es acceso de administrador por definición, por
lo que estos no necesitan permisos adicionales.

| Comando | Canales | Descripción |
| ------- | -------- | ----------- |
| `ArkBossCooldown.help [page]` | Consola, RCON | Lista paginada de todos los comandos registrados. |
| `ArkBossCooldown.reload` | Consola, RCON | Vuelve a leer `config.json` sin reiniciar el servidor. |

`ArkBossCooldown.reload` reconstruye desde el disco la lista de jefes, la
duración del tiempo de espera, `TestMode` y los ajustes del mensaje. **No**
despeja un tiempo de espera que ya esté en curso — recargar no es un inicio de
jefe gratis. Para despejar uno, descarga y vuelve a cargar el plugin. Tampoco
vuelve a ejecutar el proceso de reparación de la configuración, así que valida
tu JSON antes de recargar.

## Solución de problemas

- **El tiempo de espera nunca se activa** — el tributo que estás fabricando
  probablemente no está en la lista `Bosses`. Activa `TestMode`, fabrícalo, y
  lee la ruta desde la consola.
- **El plugin no se carga, código de error `1114`** — un error de sintaxis
  JSON en `config.json`. Pásalo por [JSONLint](https://jsonlint.com/). El
  extenso array `Bosses` hace fácil pasar por alto una coma suelta.
- **"License key is missing"** — `LicenseKey` todavía tiene el valor de
  marcador de posición.
- **El mensaje no aparece** — comprueba que `CooldownMessage.Enabled` sea
  `true`, y ten en cuenta que `Scale` solo se aplica al canal `Notification`.
- **Cualquier otra cosa** — pon `LogToFile` en `true` y reproduce el
  problema; el plugin escribe su propio archivo rotativo
  `ArkBossCooldown.log` junto a `config.json`. Luego pregunta en el
  [Discord de Bytemart](https://bytemart.net/discord).

---

**Próximos pasos:**

- [Configuración](configuration.md) — el tiempo de espera, el mensaje y la
  lista de jefes.
- [Configuración común](../index.md#common-configuration) — las claves
  compartidas `LicenseKey`, `Database`, `LogToFile` y `Verbose`.
