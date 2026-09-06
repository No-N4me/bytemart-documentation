# 🔍 DupeDetector

DupeDetector es un plugin de ArkApi pequeño y enfocado que detecta la
**duplicación de objetos realizada a través del inventario de tributo** — el
obelisco, la terminal de suministro y la tienda de subida del transmisor usada
para las transferencias entre clústeres.

Hace una sola cosa, y la hace discretamente: los intentos de duplicación se
reportan a tu Discord, y los infractores reincidentes se pueden gestionar
automáticamente.

## Qué hace

- **Detecta la duplicación** a través de la tienda de tributo/subida, sin mod
  de cliente y sin nada que tus jugadores deban instalar.
- **Alerta a tu Discord.** Cada detección se publica en el webhook que
  configures.
- **Castiga a los infractores reincidentes.** Una vez que un jugador ha sido
  detectado suficientes veces, DupeDetector puede ejecutar un comando de
  servidor contra él (expulsión, baneo, lo que elijas) y opcionalmente vaciar
  su inventario. Los castigos van a su propio webhook para que puedas
  dirigirlos a un canal solo para administradores.
- **Solo informativo si lo prefieres.** Deja vacías las opciones de castigo y
  el plugin solo te avisa — nunca actúa por sí solo.

Cuánto margen se le da a un jugador antes de que se dispare un castigo es
configurable, y deliberadamente no es un número fijo. Consulta
[`Punishment.After`](configuration.md#punishment).

> ℹ️ **Los detalles de detección no se publican intencionalmente.** Qué
> desencadena una detección, y cuántas detecciones se le permiten a un jugador
> determinado, no están documentados aquí — esa información solo ayuda a las
> personas que estás intentando atrapar. Si necesitas entender una alerta
> específica, pregunta en el [Discord de Bytemart](https://bytemart.net/discord).

## Requisitos

| Requisito | Notas |
| ----------- | ----- |
| [ArkApi](https://arkserverapi.com/) **3.51** o más reciente | El plugin no se cargará en versiones anteriores de la API. |
| MySQL / MariaDB | El plugin se conecta al arrancar, por lo que se requieren credenciales válidas. Consulta [Configuración común](../index.md#database). |
| Una clave de licencia de Bytemart | Nada se activa hasta que la clave se autentica. |
| HTTPS saliente | Necesario para la licencia y para los webhooks de Discord. |

## Instalación

1. Asegúrate de tener ArkApi **3.51+** instalado en tu servidor.
2. Configura una base de datos MySQL/MariaDB — consulta
   [Configuración común](../index.md#database). La base de datos ya debe
   existir.
3. Descarga `DupeDetector.zip` desde tu **Panel de Bytemart**.
4. Detén el servidor (ejecuta `saveworld` primero), o descarga cualquier
   versión anterior con `plugins.unload DupeDetector`.
5. Extrae el archivo en una carpeta `DupeDetector` dentro de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Abre `config.json` y rellena tus credenciales de `LicenseKey`, `Database`, y
   al menos `DupeDetection.AlertWebhook` — consulta
   [Configuración](configuration.md).
7. Inicia el servidor y confirma que no hay errores durante el arranque.

> ⚠️ **Configura `AlertWebhook` antes de salir en producción.** Viene vacío de
> fábrica, y un webhook vacío significa que las detecciones se registran pero
> nunca se publican en ningún sitio.

### Actualización

- **Manual:** `plugins.unload DupeDetector`, reemplaza los archivos y luego
  `plugins.load DupeDetector`.
- **Automática (recarga en caliente):** renombra el nuevo `DupeDetector.dll` a
  `DupeDetector.dll.arkapi` y colócalo en la carpeta del plugin — ArkApi carga
  la nueva versión y descarga la antigua automáticamente.

DupeDetector repara su propia configuración al cargar: las claves que faltan
se añaden con sus valores predeterminados y tu original se respalda primero en
`config.json.bak`. Una discrepancia de tipo (una cadena donde corresponde un
número) aborta la carga en su lugar, con un error que nombra la clave.

## Comandos

El acceso a la consola y RCON es acceso de administrador por definición, por
lo que estos no necesitan permisos adicionales.

| Comando | Canales | Descripción |
| ------- | -------- | ----------- |
| `DupeDetector.help [page]` | Consola, RCON | Lista paginada de todos los comandos registrados. |
| `DupeDetector.reload` | Consola, RCON | Vuelve a leer `config.json` sin reiniciar el servidor. |

`DupeDetector.reload` reemplaza la configuración en vivo en su lugar, por lo
que los cambios de webhook y castigo tienen efecto de inmediato. **No** vuelve
a ejecutar el proceso de reparación de la configuración, así que valida tu
JSON antes de recargar.

## Solución de problemas

- **El plugin no se carga, código de error `1114`** — un error de sintaxis
  JSON en `config.json`. Pásalo por [JSONLint](https://jsonlint.com/).
- **"License key is missing"** — `LicenseKey` todavía tiene el valor de
  marcador de posición.
- **Nada llega a Discord** — la URL debe ser un endpoint de webhook de Discord
  real (`https://discord.com/api/webhooks/...`; las formas `discordapp.com`,
  `ptb.` y `canary.` también se aceptan). Cualquier otra cosa se descarta con
  una línea en el registro.
- **Cualquier otra cosa** — pon `LogToFile` en `true` y reproduce el problema;
  el plugin escribe su propio archivo rotativo `DupeDetector.log` junto a
  `config.json`. Luego pregunta en el
  [Discord de Bytemart](https://bytemart.net/discord).

---

**Próximos pasos:**

- [Configuración](configuration.md) — el bloque `DupeDetection`.
- [Configuración común](../index.md#common-configuration) — las claves
  compartidas `LicenseKey`, `Database`, `LogToFile` y `Verbose`.
