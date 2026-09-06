# Plugins

Los plugins de Bytemart amplían tu servidor de ARK con nuevas funciones. Cada plugin
se distribuye como un `.zip` que descargas desde tu **Panel de Bytemart** y colocas
en la carpeta de plugins de tu servidor.

## Plugins disponibles

| Plugin | Descripción |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | Un sistema competitivo de puntuación de tribus: las tribus ganan puntos por destruir estructuras, dinos y jugadores enemigos en PvP, mostrado a través de una tabla de clasificación y hologramas en el mundo. |
| [ssAntiCheat](ssanticheat/index.md) | Anti-cheat del lado del servidor: módulos de detección para trampas de combate y exploits, un sistema de baneos integrado con oleadas de baneos, alertas de Discord y correcciones para exploits conocidos de cierre inesperado y duplicación. |
| [DupeDetector](dupedetector/index.md) | Un detector de dupeo enfocado en la tienda de tributo/subida: detecta la duplicación de objetos, alerta a tu Discord y, opcionalmente, castiga automáticamente a los infractores reincidentes. |
| [ArkBossCooldown](arkbosscooldown/index.md) | Un tiempo de espera a nivel de servidor entre inicios de jefe, para que los tributos de jefe repetidos dejen de acumular teletransportes y matar a los jugadores al llegar. |

## Configuración común {#common-configuration}

Todos los plugins de Bytemart se configuran mediante un archivo `config.json`
ubicado en la propia carpeta del plugin:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/config.json
```

Las claves siguientes aparecen en el **nivel superior** de ese archivo y se comportan
de forma idéntica en todos los plugins. Las páginas de cada plugin documentan solo las
claves que les son exclusivas y enlazan de vuelta aquí para las compartidas.

> 💡 **Valida tu JSON.** Una sola coma o comilla mal colocada impedirá que un plugin
> se cargue. Después de cada edición, pasa tu configuración por un validador como
> [JSONLint](https://jsonlint.com/). Un código de error de carga `1114` casi siempre
> significa un error de sintaxis JSON.

### `LicenseKey`

```json
"LicenseKey": "PLACE_YOUR_LICENSEKEY_HERE"
```

Tu clave de licencia de Bytemart. **Obligatoria.** El plugin autentica esta clave
contra el servidor de licencias de Bytemart al arrancar, y ninguna de sus funciones se
activa hasta que la autenticación tenga éxito. Encuentra tu clave en tu
[Panel de Bytemart](https://bytemart.net/).

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `LicenseKey` | string | — | La clave de licencia emitida para tu plugin. Manténla privada. |

### `Verbose`

```json
"Verbose": false
```

Activa el registro detallado del plugin. Cuando es `true`, el plugin imprime salida
de diagnóstico adicional en la consola del servidor: útil para solucionar problemas,
pero ruidosa en caso contrario. Déjalo en `false` durante el funcionamiento normal.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `Verbose` | boolean | `false` | Activa el registro detallado (nivel de depuración) en la consola. |

### `LogToFile`

```json
"LogToFile": false
```

Cuando es `true`, el plugin refleja todo lo que registra en un archivo de registro
rotativo dentro de su propia carpeta:

```
ShooterGame/Binaries/Win64/ArkApi/Plugins/<PluginName>/<PluginName>.log
```

El archivo rota automáticamente (aproximadamente 5 MB por archivo, hasta 3 archivos
conservados). Solo se escribe la salida de ese plugin: el registro compartido de
ArkApi/servidor nunca se modifica. Esto facilita aislar la actividad de un solo plugin
al diagnosticar un problema.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `LogToFile` | boolean | `false` | Refleja los registros de este plugin en su propio archivo `.log` rotativo. |

### `Database`

```json
"Database": {
  "MysqlHost": "localhost",
  "MysqlPort": 3306,
  "MysqlUser": "username",
  "MysqlPass": "password",
  "MysqlDB": "database"
}
```

Credenciales de conexión a MySQL. Los plugins que persisten datos (tablas de
clasificación, tiempos de espera, transacciones, …) se conectan a tu servidor
MySQL/MariaDB usando estos valores y crean las tablas que necesitan en la primera
ejecución. Apunta todos los plugins a la misma base de datos a menos que tengas una
razón específica para separarlos.

| Campo | Tipo | Predeterminado | Descripción |
| ----- | ---- | ------- | ----------- |
| `MysqlHost` | string | `localhost` | Nombre de host o IP de tu servidor MySQL/MariaDB. |
| `MysqlPort` | number | `3306` | Puerto del servidor. |
| `MysqlUser` | string | — | Nombre de usuario con acceso a la base de datos. |
| `MysqlPass` | string | — | Contraseña de ese usuario. |
| `MysqlDB` | string | — | Nombre de la base de datos a utilizar. Debe existir previamente; el plugin crea sus propias tablas dentro de ella. |

> ⚠️ **La base de datos debe existir.** Los plugins crean sus **tablas**
> automáticamente, pero **no** crean la base de datos en sí. Crea el esquema con el
> nombre indicado en `MysqlDB` y otorga al usuario los permisos `SELECT`, `INSERT`,
> `UPDATE`, `DELETE` y `CREATE` sobre ella antes de iniciar el servidor.
