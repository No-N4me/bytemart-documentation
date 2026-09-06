# Baneos y detecciones

ssAntiCheat separa **detectar** a un tramposo de **eliminarlo**. Una detección
siempre alerta; un baneo solo ocurre una vez que se alcanza el umbral de un
módulo, e incluso entonces normalmente se retiene hasta la próxima **oleada de
baneos**. Ese retraso es deliberado — evita que un tramposo correlacione "hice
X, y me banearon un segundo después" y averigüe qué comprobación lo detectó.

## El proceso

```
1. un detector se activa
2. la detección se registra  ──> alerta a los administradores en el juego
                              ──> webhook de Discord
                              ──> panel de control (si está activado)
3. ¿el módulo alcanzó su contador de BanAfterDetections?   ── no ──> terminado
                              │ sí
4. el jugador se encola para un baneo
5. la cola se ejecuta en la próxima oleada de baneos
6. ejecución: se ejecuta AutoBan.ExecuteCommand, se alerta a los administradores,
   y (si IntegratedBanSystem está activo) se escribe la fila de baneo y se expulsa
7. en su próximo intento de conexión, el baneo se aplica al iniciar sesión
```

Los pasos 3 y 4 son específicos de cada módulo — consulta
[`BanAfterDetections`](configuration.md#common-submodule-keys). Un módulo sin
esa clave detecta y alerta, pero nunca banea por sí solo.

## Oleadas de baneos {#ban-waves}

Un baneo encolado se ejecuta cuando ocurre **cualquiera** de lo siguiente:

| Disparador | Notas |
| ------- | ----- |
| Cada *N* guardados del mundo | *N* es [`AutoBan."SaveWorld Cycles"`](#autoban) — `2` de forma predeterminada. Esta es la vía normal. |
| El jugador encolado se desconecta | Se le banea al salir, en lugar de dejarlo libre hasta la próxima oleada. |
| El módulo tiene `InstantBan: true` | Reservado para detecciones sin falso positivo plausible. |
| Un administrador ejecuta `ssac.banwave` | Vacía toda la cola ahora. |

Entre el encolado y la ejecución puedes inspeccionar la cola con
`ssac.pendingbans` y vaciarla con `ssac.clearbanwave`. Consulta
[Comandos](commands.md#ssacbanwave-ssacclearbanwave-ssacpendingbans).

### `AutoBan`

```json
"AutoBan": {
  "SaveWorld Cycles": 2,
  "ExecuteCommand": "banplayer {steamid} "
}
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `SaveWorld Cycles` | number | `2` | Ejecuta una oleada de baneos cada esta cantidad de guardados del mundo. Con un intervalo de guardado de 15 minutos, `2` significa un retraso máximo de 30 minutos. |
| `ExecuteCommand` | string | `"banplayer {steamid} "` | Un comando de consola que se ejecuta para cada jugador baneado. `{steamid}` se reemplaza por su SteamID64. Déjalo vacío para depender únicamente del sistema de baneos integrado. |

`ExecuteCommand` es la forma de enganchar ssAntiCheat a lo que ya uses. El
valor predeterminado añade al jugador a la lista de baneos propia de ARK; en su
lugar podrías llamar al comando de baneo de otro plugin, o a uno a nivel de
clúster.

> 💡 **Consejo para clústeres.** El `banplayer` de ARK es por servidor. Si
> administras un clúster, apunta `ExecuteCommand` a un comando de baneo
> compatible con clústeres, o usa el sistema de baneos integrado con una
> **base de datos MySQL compartida** entre todos tus servidores — así cada
> servidor aplicará cada baneo al iniciar sesión.

## `IntegratedBanSystem`

El almacén de baneos integrado: los baneos se escriben en tu base de datos
MySQL y se aplican cuando el jugador intenta conectarse.

```json
"IntegratedBanSystem": {
  "Enabled": true,
  "UseIPBans": true,
  "UseHWIDBans": false,
  "Exclude IPS": [],
  "BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nUnban at: https://store.example.com"
}
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Enabled` | boolean | `true` | Almacena y aplica los baneos en MySQL. Cuando es `false`, solo se ejecuta `AutoBan.ExecuteCommand`. |
| `UseIPBans` | boolean | `true` | También rechaza las conexiones desde la dirección IP de un jugador baneado. Consulta más abajo. |
| `UseHWIDBans` | boolean | `false` | También rechaza las conexiones desde el ID de hardware de un jugador baneado. Requiere el mod cliente complementario opcional para capturarlo — sin él, esto no hace nada. |
| `Exclude IPS` | array | `[]` | Direcciones IP que nunca se tratan como una asociación. Pon aquí direcciones compartidas/NAT. |
| `BanMessage` | string | ver arriba | El mensaje que ve el jugador. |

Los baneos viven en una única tabla (`ssAntiCheat_bans`) que contiene el Steam
ID, la IP, el ID de hardware, el motivo, la fecha del baneo y su expiración.
Apunta varios servidores a la misma base de datos y un baneo se aplicará en
todos ellos.

### Mensaje de baneo {#ban-message}

`BanMessage` admite dos marcadores:

| Marcador | Se reemplaza por |
| ----------- | ------------- |
| `{reason}` | El motivo del baneo. |
| `{ban_id}` | El ID numérico del baneo — el valor que necesita un administrador para `ssac.unban`. |

```json
"BanMessage": "You are banned from our server\nReason: {reason}\nBan id: {ban_id}\nAppeal at: https://yourserver.example/appeal"
```

> ⚠️ **Reemplaza la URL de marcador de posición.** El mensaje de fábrica
> apunta a `store.example.com`. Incluye siempre `{ban_id}` — sin él, un
> jugador que apele un baneo no tiene nada que citar y tendrás que buscar en
> la base de datos a mano.

### Baneos por asociación de IP {#ip-association-bans}

Con `UseIPBans` activado, se rechaza a un jugador que se conecta desde una
dirección que pertenece a un baneo activo **y se registra como su propio
baneo**, de modo que la cuenta alternativa queda baneada por Steam ID a partir
de ese momento. Se envía una alerta a
[`AssociationBans`](configuration.md#webhooks) nombrando ambas cuentas.

La comprobación es deliberadamente conservadora — solo se activa cuando la IP
coincide genuinamente, no está en `Exclude IPS`, y pertenece a una cuenta de
Steam *diferente*.

> ⚠️ **Los baneos por IP atrapan hogares y conexiones compartidas.** Hermanos,
> compañeros de piso, un cibercafé o una salida de VPN compartida parecerán
> todos el mismo jugador. Observa el canal de asociación durante un tiempo
> antes de confiar en él, y añade direcciones compartidas legítimas a
> `Exclude IPS`.

## Duraciones de los baneos

| Cómo se hizo el baneo | Duración |
| -------------------- | -------- |
| `ssac.ban` con `d=…` | Expira después de ese período. |
| `ssac.ban` sin `d=…` | Permanente. |
| Automático (el `BanAfterDetections` de un módulo) | Permanente. |

Para levantar cualquier baneo, usa su ID de baneo:

```bash
ssac.unban 42
```

## Revisar una detección antes de que se convierta en un baneo

El intervalo entre la detección y la oleada de baneos es tu ventana de
revisión. Un flujo de trabajo que funciona bien:

1. La alerta de Discord (o la alerta de administrador en el juego) nombra al
   jugador y al módulo.
2. `ssac.go` — espíalo de inmediato, sin argumentos para saltar a la última
   detección.
3. `!tracers` — observa sus disparos; la asistencia de puntería es evidente a
   simple vista de esta forma.
4. `ssac.pendingbans` — comprueba si ya está encolado y por qué.
5. Decide: dejar que la oleada corra, `ssac.banwave` para actuar ahora, o
   `ssac.clearbanwave` si crees que es un falso positivo.

Si un módulo produce falsos positivos repetidos en tu configuración, sube su
umbral o activa `OnlyAnalysis` en lugar de desactivarlo — consulta
[Consejo de ajuste](configuration.md#common-submodule-keys).

---

**Próximos pasos:**

- [Configuración](configuration.md) — todas las claves de `config.json`.
- [Comandos](commands.md) — la referencia completa de comandos.
