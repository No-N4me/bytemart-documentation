# Comandos

Tribescore tiene dos tipos de comandos: los comandos de **administración** que se
ejecutan desde la consola del servidor o RCON, y los comandos de **chat** de jugador
que se escriben en el juego. Los comandos de administración llevan el prefijo `ts.` y
solo son accesibles a través de la consola/RCON, por lo que ningún sistema de permisos
independiente los restringe — el acceso está implícito por el canal. Los comandos de
chat son configurables y opcionales (consulta [`ChatCommands`](configuration.md#chatcommands)).

## Comandos de consola / RCON

| Comando | Canales | Descripción |
| ------- | -------- | ----------- |
| `ts.help [page]` | Consola, RCON | Muestra el menú de ayuda paginado de Tribescore. |
| `ts.give <tribe-id> <score>` | Consola | Añade tribescore a una tribu. Registra una transacción `system`. |
| `ts.take <tribe-id> <score>` | Consola | Quita tribescore de una tribu. Registra una transacción `system`. |
| `ts.boost <tribe-id> <type> <value> <duration>` | Consola, RCON | Otorga un potenciador de puntuación temporizado a una tribu. |
| `ts.boost <tribe-id> clear` | Consola, RCON | Elimina el potenciador temporizado activo de una tribu. |
| `ts.audit <tribe-id> [options]` | Consola | Audita las transacciones de puntuación de una tribu y sube un informe. |
| `ts.estimate <recipient-tribe-id> [options]` | Consola | Estima el tribescore de las estructuras a tu alrededor. |
| `ts.addstructure` | Consola | Añade la estructura que estás mirando a `structures.json`. |

### `ts.give` / `ts.take`

```bash
ts.give 1234567890 500      # añade 500 puntos a la tribu 1234567890
ts.take 1234567890 250      # quita 250 puntos de la tribu 1234567890
```

Ambos escriben una entrada de tipo `system` en el historial de transacciones para que
los ajustes manuales sean auditables.

### `ts.boost`

Otorga un multiplicador de puntuación temporal que se integra en la cadena de
modificadores durante una duración determinada.

```
ts.boost <tribe-id> <type> <value> <duration>
ts.boost <tribe-id> clear
```

| Argumento | Descripción |
| -------- | ----------- |
| `<tribe-id>` | El ID de la tribu objetivo. |
| `<type>` | A qué se aplica el potenciador: `structures`, `dinos`, `players`, `all`, o una combinación unida con `+` (por ejemplo, `structures+dinos`). |
| `<value>` | El multiplicador (por ejemplo, `1.5` para +50 %). |
| `<duration>` | Duración del potenciador, en **segundos**. |

```bash
ts.boost 1234567890 structures+dinos 1.5 3600   # +50% en estructuras y dinos durante 1h
ts.boost 1234567890 all 2 600                   # duplica toda la puntuación durante 10 minutos
ts.boost 1234567890 clear                        # elimina el potenciador activo
```

> ℹ️ **También expuesto a otros plugins.** Los potenciadores temporizados forman parte
> de la API pública de Tribescore (`SetTimedBoost` / `ClearTimedBoost` /
> `GetTimedBoost`), que el plugin complementario **Koth** utiliza para recompensar
> automáticamente a los ganadores de eventos.

### `ts.audit`

Crea un informe asíncrono de las transacciones de una tribu (de quién ganó puntos,
quién le robó, desgloses por clúster) y lo sube, devolviendo una URL.

```
ts.audit <tribe-id> [clusters_amount=X] [givers_amount=X] [stealers_amount=X] [start_date=YYYY-MM-DD] [end_date=YYYY-MM-DD]
```

| Opción | Descripción |
| ------ | ----------- |
| `clusters_amount=X` | Número de clústeres principales a incluir. |
| `givers_amount=X` | Número de tribus principales de las que esta tribu ganó puntos. |
| `stealers_amount=X` | Número de tribus principales que le quitaron puntos a esta tribu. |
| `start_date` / `end_date` | Restringe la auditoría a un rango de fechas (`YYYY-MM-DD`). |

```bash
ts.audit 1234567890 givers_amount=10 start_date=2026-07-01 end_date=2026-07-12
```

### `ts.estimate`

Escanea las estructuras dentro del alcance de tu personaje (mediante un escaneo de
octree, fragmentado a lo largo de varios ticks) y estima cuántos puntos valdrían para
una tribu determinada. Útil para ajustar los valores de `structures.json`.

```
ts.estimate <recipient-tribe-id> [modifiers=on|off] [range=X]
```

| Opción | Descripción |
| ------ | ----------- |
| `modifiers=on\|off` | Si aplicar la cadena de modificadores a la estimación. |
| `range=X` | Radio de escaneo alrededor de tu personaje. |

### `ts.addstructure`

Traza una línea hacia la estructura que estás mirando, la añade a `structures.json`
como una entrada personalizada y recarga el archivo en caliente — una forma rápida de
añadir valores por blueprint sin tener que buscar las rutas de blueprint a mano.

---

## Comandos de chat

Estos se escriben en el chat del juego. Los nombres son configurables — los valores
predeterminados de abajo provienen de la configuración de
[`ChatCommands`](configuration.md#chatcommands) incluida, y cada comando puede
desactivarse por completo.

| Comando (predeterminado) | Descripción |
| ----------------- | ----------- |
| `/leaderboard` | Muestra las mejores tribus por puntuación. |
| `/triberank` | Muestra el rango y la puntuación de tu propia tribu. |
| `/holograms` | Activa o desactiva para ti los hologramas flotantes de `+/- points`. |

El texto, los colores, el tamaño, la duración en pantalla y (para la tabla de
clasificación) el número de líneas y los colores por rango se configuran todos en
[`ChatCommands`](configuration.md#chatcommands).

---

## Nodos de permiso

Tribescore no usa permisos para restringir sus comandos, pero la función
[`PermissionModifiers`](configuration.md#modifierspermissionmodifiers) lee nodos de
permiso para aumentar o reducir la puntuación de una tribu. Otórgalos mediante el
plugin [Permissions](https://github.com/ServersHub/ServerAPI). Con la configuración
predeterminada:

```bash
Permissions.AddGroup VIP
Permissions.Grant VIP ts.boost.15
```

Aquí, un miembro del grupo `VIP` daría a su tribu un multiplicador de puntuación de
**1.15×**, según la entrada `ts.boost.15` en `PermissionModifiers.Modifiers`. Los
nombres de los nodos son arbitrarios — solo tienen que coincidir con lo que
configures.
