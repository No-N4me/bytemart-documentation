# Comandos

ssAntiCheat tiene dos tipos de comandos: los comandos de **consola/RCON** con el
prefijo `ssac.`, y los comandos de **chat dentro del juego** con el prefijo `!`
(configurable mediante [`CommandPrefix`](configuration.md#top-level-keys)).

El acceso a la consola y RCON es acceso de administrador por definición, por lo
que los comandos `ssac.` no necesitan permisos adicionales. Los comandos de chat
comprueban que seas **administrador del servidor** (`enablecheats`) y, si no, no
hacen nada silenciosamente.

## Comandos de consola / RCON

| Comando | Canales | Descripción |
| ------- | -------- | ----------- |
| `ssac.help [page]` | Consola, RCON | Lista paginada de todos los comandos registrados. |
| `ssac.status` | Consola, RCON | Licencia, ID del servidor y estado de la telemetría del panel de control. |
| `ssac.detections` | Consola, RCON | Lista las detecciones recientes, agrupadas por Steam ID. |
| `ssac.pendingbans` | Consola, RCON | Lista los jugadores encolados para la próxima oleada de baneos. |
| `ssac.banwave` | Consola, RCON | Ejecuta de inmediato la oleada de baneos pendiente. |
| `ssac.clearbanwave` | Consola, RCON | Descarta todos los baneos pendientes sin banear a nadie. |
| `ssac.ban <steamid> [r=<reason>] [d=<duration>]` | Consola, RCON | Banea a un jugador. |
| `ssac.unban <ban-id>` | Consola, RCON | Cancela un baneo por su ID de baneo. |
| `ssac.testdetection [steamid] [module]` | Consola, RCON | Envía una detección simulada al panel de control. |
| `ssac.go [steamid]` | Consola | Espía a un jugador — el indicado, o el último detectado. |
| `ssac.command <reason> <command...>` | Consola | Ejecuta un comando de consola como tú mismo, dejando constancia. |

`ssac.go` y `ssac.command` actúan sobre *tu* personaje, así que solo funcionan
desde la consola dentro del juego — no hay ningún jugador detrás de una sesión
de RCON.

### `ssac.status`

Lo primero que debes ejecutar tras instalar, y lo primero que te pedirá el
soporte. Imprime la versión del plugin, si la licencia se autenticó, el ID de
este servidor, el mapa y el nombre del servidor, y — cuando la telemetría del
panel de control está activada — el endpoint, si el servidor se ha registrado,
el resultado del último envío y la profundidad de la cola.

```bash
ssac.status
```

Una profundidad de cola distinta de cero que nunca se vacía significa que el
endpoint del panel de control es inalcanzable o está rechazando tus eventos.

### `ssac.detections`

Lista las detecciones que están en memoria (aproximadamente de la **última
hora**), agrupadas por Steam ID, con el módulo que se activó en cada una.

```bash
ssac.detections
```

> ℹ️ **Las detecciones solo están en memoria.** No sobreviven a un reinicio del
> servidor. Los baneos sí — se almacenan en MySQL. Usa tus webhooks de Discord
> como el registro permanente de las detecciones.

### `ssac.ban` / `ssac.unban`

```
ssac.ban <steamid> [r=<reason>] [d=<duration>]
ssac.unban <ban-id>
```

| Argumento | Descripción |
| -------- | ----------- |
| `<steamid>` | El SteamID64 del objetivo (17 dígitos). |
| `r=<reason>` | Motivo del baneo. Enciérralo entre comillas si contiene espacios. Por defecto es `No reason provided`. |
| `d=<duration>` | Duración del baneo, formada por partes `d` / `h` / `m` / `s` — por ejemplo, `7d`, `12h30m`, `1d6h`. Omítelo para un baneo **permanente**. |

```bash
ssac.ban 76561198000000000 r="Aimbot" d=7d
ssac.ban 76561198000000000                  # permanente, sin motivo
ssac.unban 42                               # levanta el baneo #42
```

El baneo se escribe en MySQL junto con la IP del jugador (y su ID de hardware
si se capturó uno), y el jugador es expulsado de inmediato si está conectado,
con tu [`BanMessage`](bans.md#ban-message). `ssac.unban` toma el **ID de
baneo**, no el Steam ID — tanto `ssac.detections` como el embed de baneo de
Discord lo muestran, y también es el `{ban_id}` en el mensaje de expulsión que
ve el jugador.

### `ssac.banwave` / `ssac.clearbanwave` / `ssac.pendingbans`

```bash
ssac.pendingbans     # quién está encolado, y por qué
ssac.banwave         # banéalos a todos ahora
ssac.clearbanwave    # déjalos a todos libres
```

Los baneos pendientes son encolados por los módulos de detección y normalmente
se ejecutan según un horario — consulta
[Baneos y detecciones](bans.md#ban-waves). Estos tres comandos te permiten
revisar la cola, vaciarla antes de tiempo, o limpiar una cola que crees que es
un falso positivo.

### `ssac.go`

Te pone en modo espectador y te mueve hacia un jugador.

```bash
ssac.go                       # el jugador detectado más recientemente
ssac.go 76561198000000000     # un jugador específico
```

Sin argumentos sigue la última detección, que es lo que quieres al reaccionar a
una alerta. Con un Steam ID apunta a ese jugador y muestra el nombre que
resolvió, para que puedas confirmar que agarraste a la persona correcta.

### `ssac.command`

Ejecuta un comando de consola como tú mismo y registra que ssAntiCheat lo
sancionó, para que el módulo de protección de administradores no te señale por
usarlo.

```
ssac.command <reason> <command...>
```

```bash
ssac.command investigating_dupe giveitemnum 1 1 0 0
```

El primer argumento es un motivo de texto libre para el registro de auditoría;
todo lo que sigue es el comando a ejecutar.

### `ssac.testdetection`

Emite una detección **simulada** para que puedas verificar el proceso de tu
panel de control sin esperar a un tramposo real. Requiere que
[`Dashboard.Enabled`](configuration.md#dashboard) sea `true`.

```
ssac.testdetection [steamid] [module]
```

```bash
ssac.testdetection                              # una detección para ti mismo (desde la consola del juego)
ssac.testdetection 76561198000000000 AutoLoot   # para un jugador específico, etiquetada como AutoLoot
```

Ejecutado sin argumentos desde la consola del juego, apunta hacia **ti**, así
que la fila del panel de control muestra un nombre, tribu y posición reales.
Los eventos de prueba se marcan como simulados y se excluyen de las
estadísticas reales de detección. No se envían a Discord y nunca banean a
nadie.

---

## Comandos de chat {#chat-commands}

Se escriben en el chat dentro del juego, solo para administradores, con el
prefijo [`CommandPrefix`](configuration.md#top-level-keys) (`!` de forma
predeterminada). Cuando un comando toma `<steamid>`, puedes omitirlo y actuará
sobre **quien estés mirando**.

Los nombres se comparan exactamente como se escriben a continuación, incluyendo
mayúsculas y minúsculas.

### Investigación

| Comando | Descripción |
| ------- | ----------- |
| `!esp` | Activa o desactiva el ESP para ti mismo. |
| `!espPlayers` | Activa o desactiva el ESP de jugadores: nombre, vida y arma actual sobre cada jugador. |
| `!EspStruct` | Activa o desactiva el ESP de estructuras. |
| `!espset <name>` | Resalta las estructuras cuyo nombre de blueprint contenga `<name>`, además de la lista [`Structure ESP`](configuration.md#admin-esp). |
| `!espHideEmpty` | Oculta los contenedores vacíos en el ESP de estructuras. |
| `!tracers` | Dibuja cada disparo cercano como una línea trazadora, coloreada según la parte del cuerpo que impactó. La herramienta más útil para juzgar a simple vista la asistencia de puntería. |
| `!vanish` | Activa o desactiva tu propia invisibilidad. |
| `!spawn` | Reaparece en tu vista actual, y luego activa el modo creativo, la invisibilidad ante enemigos y el vuelo. |
| `!cloud <steamid>` | Te imprime los objetos subidos (tributo) de un jugador. |

`!esp` es el interruptor maestro — `!espPlayers` y `!EspStruct` solo dibujan
mientras el ESP está activado para ti.

### Interacción

Estos actúan directamente sobre un sospechoso. Úsalos con cautela: son
visibles para el jugador y pueden alertar a un tramposo sobre el que todavía
estás reuniendo pruebas.

| Comando | Descripción |
| ------- | ----------- |
| `!unequip <steamid>` | Despoja a un jugador de su armadura equipada. |
| `!dropweapon <steamid>` | Obliga a un jugador a soltar el arma que lleva. |
| `!jump <steamid>` | Obliga a un jugador a saltar. |
| `!punch <steamid>` | Activa el puñetazo cohete del guantelete tek de un jugador. |
| `!tekjump <steamid>` | Activa el impulso de la coraza tek de un jugador. |
| `!requestjoin <steamid>` | Envía al jugador una invitación de tribu falsa. |
| `!outofrange <steamid>` | Muestra al jugador el aviso de cliente "out of range". |
| `!playpoopsound <steamid>` | Reproduce el sonido de caca sobre un jugador. |
| `!playdeathsound <steamid>` | Reproduce el sonido de muerte sobre un jugador. |

> ℹ️ **Cada acción de administración queda registrada.** Los comandos de chat
> de administración se registran en un archivo de registro local y se publican
> en [`AdminTrollingWebhook`](configuration.md#webhooks) con el administrador
> que actuó, el objetivo y la ubicación — para que los poderes de administrador
> sigan siendo responsables.
