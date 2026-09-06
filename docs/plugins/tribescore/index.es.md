# 🏆 Tribescore

Tribescore es un **sistema competitivo de puntuación de tribus** para ARK: Survival
Evolved. Las tribus ganan *tribescore* destruyendo estructuras, dinos y jugadores
enemigos en PvP. Las puntuaciones se persisten en MySQL y se muestran a través de una
tabla de clasificación y un sistema de rangos, mientras que números "holograma"
flotantes aparecen en el mundo cada vez que se ganan o se pierden puntos.

Las concesiones de puntos pasan por una cadena de modificadores multiplicativa y
configurable para que puedas mantener la competición justa: protección offline,
equilibrio por diferencia de puntuación entre tribus fuertes y débiles, potenciadores
basados en permisos y potenciadores temporizados otorgados por administradores.

## Funciones

- **Puntuación PvP:** Otorga puntos por destruir estructuras enemigas, matar dinos
  domesticados y matar jugadores enemigos. Cada fuente es configurable de forma
  individual y puede desactivarse.
- **Valores por nivel y por blueprint:** Las estructuras se puntúan por nivel de
  construcción (Paja → Tek) con anulaciones por blueprint; los dinos se puntúan por
  especie con indicadores detallados (crías, sin montura, salvajes, …).
- **Cadena de modificadores:** Equilibra el juego con protección offline, un ratio de
  diferencia de puntuación fuerte-contra-débil, modificadores de permisos y
  potenciadores temporizados.
- **Tabla de clasificación y rangos:** Comandos de chat `/leaderboard` y `/triberank`
  en el juego, respaldados por una tabla de clasificación persistente en MySQL.
- **Hologramas en el mundo:** Texto flotante configurable `+points` / `-points` que
  los jugadores pueden activar o desactivar para sí mismos.
- **Herramientas de administración:** Dar/quitar puntos, otorgar potenciadores
  temporizados, auditar el historial de transacciones de una tribu y estimar el valor
  de una base, todo desde la consola/RCON.
- **Bot de Discord complementario:** Un bot incluido publica una tabla de clasificación
  en vivo en Discord, añade comandos de barra para consultar tribus y señala
  puntuaciones sospechosas. Consulta [Bot de Discord](discord-bot.md).

## Cómo funciona la puntuación

Cuando se destruye una estructura, un dino o un jugador enemigo, el valor de puntos
base proviene de las tablas de puntuación (`structures.json`, `dinos.json` o el valor
fijo de jugador en `config.json`). Ese valor base se multiplica luego a través de la
cadena de modificadores:

```
final score = base points
            × OfflineProtection(defender)
            × ScoreDifferenceRatio(attacker, defender)
            × PermissionModifier(attacker)
            × TimedBoost(attacker, type)
```

La tribu atacante **gana** el resultado; la tribu defensora **pierde** una cantidad
(configurable por separado). Consulta la página de
[Configuración](configuration.md) para conocer todos los ajustes.

## Instalación

1. Asegúrate de tener una versión compatible de [ArkApi](https://arkserverapi.com/)
   instalada en tu servidor (Tribescore requiere ArkApi **3.51** o más reciente).
2. Configura una base de datos MySQL/MariaDB — consulta [Configuración común](../index.md#database).
3. Descarga el `Tribescore.zip` desde tu **Panel de Bytemart**.
4. Detén el servidor (ejecuta `saveworld` primero) o descarga cualquier versión
   anterior con `plugins.unload Tribescore`.
5. Extrae el archivo en una carpeta `Tribescore` dentro de
   `ShooterGame/Binaries/Win64/ArkApi/Plugins/`.
6. Abre `config.json` y rellena tus credenciales de `LicenseKey` y `Database`
   (consulta [Configuración](configuration.md)).
7. Inicia el servidor y confirma que no hay errores durante el arranque.

### Actualización

- **Manual:** `plugins.unload Tribescore`, reemplaza los archivos y luego
  `plugins.load Tribescore`.
- **Automática (recarga en caliente):** renombra el nuevo `Tribescore.dll` a
  `Tribescore.dll.arkapi` y colócalo en la carpeta del plugin — ArkApi carga la nueva
  versión y descarga la antigua automáticamente.

Comprueba siempre el registro de cambios en busca de cambios de configuración al
actualizar; una herramienta como [Diffchecker](https://www.diffchecker.com/) ayuda a
detectar claves nuevas o renombradas.

---

**Próximos pasos:**

- [Configuración](configuration.md) — el `config.json` completo, más `structures.json` y `dinos.json`.
- [Comandos](commands.md) — comandos de administración de consola/RCON y comandos de chat en el juego.
- [Bot de Discord](discord-bot.md) — el bot complementario: tabla de clasificación en vivo, comandos de barra y detección de abusos.
- [Configuración común](../index.md#common-configuration) — las claves compartidas `LicenseKey`, `Database`, `LogToFile` y `Verbose`.
