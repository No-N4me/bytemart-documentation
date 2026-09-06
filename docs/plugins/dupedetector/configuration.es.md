# Configuración

DupeDetector se configura mediante un único `config.json` en la carpeta del
plugin:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/DupeDetector/config.json
```

Un segundo archivo, `config_commented.json`, se incluye junto a él. Es **la
misma configuración con comentarios `//`** — léelo, pero no lo renombres para
sustituir a `config.json` (los comentarios no son JSON válido).

Las claves `LicenseKey`, `Verbose`, `LogToFile` y `Database` son compartidas
por todos los plugins de Bytemart y están documentadas en la página de
**[Configuración común](../index.md#common-configuration)**. Esta página
cubre solo el bloque `DupeDetection`, que es exclusivo de DupeDetector.

> 💡 **Valida antes de empezar.** Valida siempre tu JSON después de editarlo
> (por ejemplo, con [JSONLint](https://jsonlint.com/)). Un código de error de
> carga `1114` significa un error de sintaxis JSON.

## `DupeDetection`

```json
"DupeDetection": {
  "AlertWebhook": "",
  "Punishment": {
    "PunishmentWebhook": "",
    "Command": "",
    "ClearInventory": false,
    "After": {
      "Min": 1,
      "Max": 1
    }
  }
}
```

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `AlertWebhook` | string | `""` | Webhook de Discord para las **detecciones** — un mensaje por detección, nombrando al jugador implicado. Vacío significa que las detecciones se siguen contando, pero no se publica nada. |

### `Punishment`

Qué sucede una vez que un jugador ha acumulado suficientes detecciones. Todos
los campos son opcionales: deja `Command` vacío y `ClearInventory` en false, y
DupeDetector se vuelve solo informativo.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `PunishmentWebhook` | string | `""` | Webhook de Discord para los **castigos**. Se mantiene separado de `AlertWebhook` para que puedas dirigir los castigos (mucho más raros) a un canal solo para administradores. Vacío significa que no se publica nada. |
| `Command` | string | `""` | Un comando de consola del servidor para ejecutar contra el infractor cuando se alcanza el umbral — por ejemplo `banplayer {steamid}` o `kickplayer {steamid}`. Vacío significa que no se ejecuta ningún comando. |
| `ClearInventory` | boolean | `false` | Vacía el inventario del infractor como parte del castigo. |
| `After.Min` | number | `1` | Límite inferior del umbral de detección. |
| `After.Max` | number | `1` | Límite superior del umbral de detección. |

#### El umbral `After`

`Min` y `Max` acotan cuántas detecciones puede acumular un jugador antes de
que se dispare el castigo. Darles valores **diferentes** deja el umbral exacto
impredecible, que es la configuración recomendada — un número fijo y conocido
es algo que un infractor puede sortear.

- `"Min": 1, "Max": 1` — castiga en la primera detección (el valor
  predeterminado).
- `"Min": 2, "Max": 5` — castiga en algún punto de ese rango.

Los valores se comprueban dentro de un rango al cargar, así que no puedes
configurar accidentalmente un umbral que nunca se dispare.

> 💡 **Empieza en modo solo informativo.** Deja `Command` vacío y
> `ClearInventory` en false durante los primeros días, observa lo que llega a
> `AlertWebhook`, y solo entonces decide cómo debería ser un castigo.

## Webhooks

Ambos campos de webhook deben ser **URLs de webhook de Discord**. Se aceptan
estos prefijos:

```
https://discord.com/api/webhooks/...
https://discordapp.com/api/webhooks/...
https://ptb.discord.com/api/webhooks/...
https://canary.discord.com/api/webhooks/...
```

Cualquier otra cosa — incluyendo una cadena vacía — se descarta, con una línea
en el registro del plugin que lo indica. Un webhook vacío nunca es un error;
solo significa "no enviar nada".

> 🔒 **Una URL de webhook es una credencial.** Cualquiera que la tenga puede
> publicar en tu canal. Mantén `config.json` fuera de repositorios públicos y
> capturas de pantalla.

## Ejemplo completo

```json
{
  "LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE",
  "Verbose": false,
  "LogToFile": false,
  "Database": {
    "MysqlHost": "localhost",
    "MysqlPort": 3306,
    "MysqlUser": "username",
    "MysqlPass": "password",
    "MysqlDB": "database"
  },
  "DupeDetection": {
    "AlertWebhook": "https://discord.com/api/webhooks/...",
    "Punishment": {
      "PunishmentWebhook": "https://discord.com/api/webhooks/...",
      "Command": "banplayer {steamid}",
      "ClearInventory": true,
      "After": {
        "Min": 2,
        "Max": 4
      }
    }
  }
}
```

---

**Próximos pasos:**

- [Descripción general](index.md) — qué cubre el plugin, la instalación y los
  comandos.
- [Configuración común](../index.md#common-configuration) — `LicenseKey`,
  `Database`, `LogToFile`, `Verbose`.
