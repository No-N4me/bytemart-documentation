# 🤖 Bot de Discord

Tribescore incluye un **bot de Discord** complementario que lleva la competición de
tu servidor a Discord: una tabla de clasificación en vivo con actualización
automática, comandos de barra para consultar cualquier tribu y un sistema automático
de detección de abusos que señala puntuaciones sospechosas.

El bot se conecta **directamente a la misma base de datos MySQL/MariaDB** que utiliza
el plugin. Solo *lee* las tablas de puntuación del plugin — nunca modifica tus
puntuaciones — por lo que es seguro ejecutarlo junto a un servidor en vivo.

## Funciones

- **Tabla de clasificación en vivo** — publica y actualiza automáticamente las
  mejores tribus en un canal de tu elección, con flechas de movimiento ▲/▼ entre
  periodos de puntuación.
- **Renderizado como imagen o embed** — muestra la tabla como un embed clásico de
  Discord, o como un PNG pulido renderizado a partir de uno de los siete diseños
  integrados (`podium`, `spotlight`, `cards`, `bars`, `terminal`, `ark`, `dark`). Las
  plantillas son HTML sencillo que puedes reestilizar y personalizar con la marca de
  tu servidor.
- **Comandos de barra** — `/tribepoints` y `/getrank` permiten a los jugadores
  consultar la puntuación y el rango de cualquier tribu. Los nombres de los comandos y
  los mensajes son configurables.
- **Detección de abusos** — tres detectores independientes publican alertas cuando la
  puntuación parece sospechosa, cada una con un botón *"Ignorar esta alerta"* para
  silenciar los falsos positivos.
- **Ejecutable independiente** — distribuido como un único `.exe` de Windows
  autocontenido. No se necesita navegador ni instalaciones adicionales, ni siquiera
  para el renderizado de imágenes.

## Requisitos

- El plugin Tribescore instalado y escribiendo en una base de datos MySQL/MariaDB
  (consulta [Configuración](configuration.md) y
  [Configuración común](../common-configuration.md#database)).
- Una aplicación de Discord y un token de bot, creados en el
  [Portal de desarrolladores de Discord](https://discord.com/developers/applications).
- Una máquina Windows para ejecutar el bot — puede ejecutarse en cualquier lugar que
  pueda acceder a la base de datos.

## Instalación

1. Descarga el bot desde tu **Panel de Bytemart** y extráelo.
2. Abre `config.yml` y configúralo (ver más abajo).
3. Establece tu token de bot y la contraseña de la base de datos — ya sea
   directamente en `config.yml`, o mediante las variables de entorno
   `LEADERBOARD_BOT_TOKEN` y `MYSQL_PASSWORD` (recomendado, para que los secretos se
   mantengan fuera del archivo de configuración).
4. Invita al bot a tu servidor, otorgándole permiso para enviar mensajes, embeds y
   archivos adjuntos en los canales de la tabla de clasificación y de alertas.
5. Ejecuta el ejecutable. En el primer arranque registra sus comandos de barra y
   publica la tabla de clasificación.

> 💡 Si renombras un comando de barra en `config.yml`, es posible que Discord necesite
> que se expulse y se vuelva a invitar al bot antes de que el cambio surta efecto.

## Configuración (`config.yml`)

El bot se configura por completo a través de `config.yml`. Ajustes principales:

| Ajuste | Descripción |
| ------- | ----------- |
| `bot-token` | Tu token de bot de Discord. Déjalo en blanco y establece `LEADERBOARD_BOT_TOKEN` en su lugar. |
| `period-start` | Expresión cron para cuándo comienza un nuevo periodo de puntuación (la tabla toma una instantánea del movimiento en ese momento). Consulta [crontab.guru](https://crontab.guru/). |
| `timezone` | Zona horaria para la programación y las comparaciones de transacciones — debe coincidir con la zona horaria de tu base de datos. |
| `refresh-cooldown` | Segundos entre actualizaciones de la tabla de clasificación dentro de un periodo. |
| `leaderboard-channel` | El ID del canal donde se publica la tabla de clasificación. |
| `keep-leaderboard-history` | Cuando es `true`, publica un mensaje de tabla de clasificación nuevo cada periodo en lugar de editar el existente. |
| `leaderboard-render-mode` | `embed` (embed de Discord) o `image` (PNG renderizado). |
| `leaderboard-image` | Opciones del modo imagen: `template`, `title`, `lines`, `width`, `scale`. |
| `mysql` | Conexión a la base de datos: `host`, `port`, `user`, `password`, `database`, `leaderboard-table`, `transactions-table`, `timezone`. |
| `commands` | Nombres de comandos, descripciones y mensajes de respuesta. |
| `abuse-detection` | Activa y ajusta los módulos de detección de abusos. |

> ⚠️ Las tablas `leaderboard-table` y `transactions-table` deben coincidir con las
> tablas del plugin — por defecto `ts_leaderboard` y `ts_transactions`. El bot lee
> estas tablas y nunca escribe en ellas.

### Visualización de la tabla de clasificación

Elige cómo se renderiza la tabla con `leaderboard-render-mode`:

```yaml
leaderboard-render-mode: "image"   # o "embed"
leaderboard-image:
  template: "spotlight"   # podium | spotlight | cards | bars | terminal | ark | dark
  title: "Tribes Leaderboard"
  lines: 15               # número de tribus mostradas
  width: 820
  scale: 2                # 2 = salida nítida / retina
```

En el modo `embed`, la tabla es un embed de texto construido a partir de
`leaderboard_embed.json`. En el modo `image` se renderiza a partir de una plantilla
HTML ubicada en `templates/leaderboard/<name>/`. Si el renderizado de imágenes llegara
a fallar, el bot recurre automáticamente al embed, de modo que la tabla de
clasificación nunca puede quedar fuera de línea.

### Comandos de barra

| Comando (predeterminado) | Descripción |
| ----------------- | ----------- |
| `/tribepoints <tribe>` | Muestra los puntos actuales de una tribu. |
| `/getrank <tribe>` | Muestra el rango y los puntos de una tribu. |

Tanto los nombres de los comandos como sus mensajes de respuesta son configurables
bajo `commands` en `config.yml`, usando los marcadores `{tribe}`, `{points}` y
`{rank}`.

### Detección de abusos

Cuando `abuse-detection.enabled` es `true`, el bot escanea periódicamente las mejores
tribus y publica una alerta en el `channel-id` configurado cuando se activa un módulo.
Cada alerta incluye un botón **"Ignorar esta alerta"** que suprime futuras
repeticiones para ese par de tribus.

| Módulo | Detecta |
| ------ | ------- |
| `rapid-increase` | Una tribu que gana una cantidad inusualmente grande de puntos dentro de un mismo periodo de puntuación. |
| `massive-transaction` | Una única transferencia de puntos por encima de un umbral de una tribu a otra. |
| `prefered-source` | Una tribu que recibe una gran parte de sus puntos de una sola tribu de origen (con una comprobación opcional de reciprocidad "mirror"). |

Cada módulo tiene su propio `cooldown`, umbrales y `title` / `message` de alerta — los
marcadores disponibles están documentados en línea dentro de `config.yml`.

> ℹ️ El bot crea una tabla propia, `ts_ignored_alerts`, para recordar qué alertas has
> descartado. Esta es la única tabla en la que escribe; los datos de tu puntuación
> nunca se modifican.
