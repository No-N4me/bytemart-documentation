# Plugins

Los plugins de Bytemart amplían tu servidor de ARK con nuevas funciones. Cada plugin
se distribuye como un `.zip` que descargas desde tu **Panel de Bytemart** y colocas
en la carpeta de plugins de tu servidor.

## Configuración compartida

Todos los plugins de Bytemart leen un `config.json` de nivel superior que comparte un
pequeño conjunto de claves: tu clave de licencia, los interruptores de registro y las
credenciales de la base de datos MySQL. Estas se documentan una sola vez, en un único
lugar:

- **[Configuración común](common-configuration.md)** — `LicenseKey`, `Verbose`,
  `LogToFile` y `Database`, comunes a **todos** los plugins.

La página de configuración propia de cada plugin cubre solo las claves exclusivas de
ese plugin y enlaza de vuelta a la página anterior para las compartidas.

## Plugins disponibles

| Plugin | Descripción |
| ------ | ----------- |
| [Tribescore](tribescore/index.md) | Un sistema competitivo de puntuación de tribus: las tribus ganan puntos por destruir estructuras, dinos y jugadores enemigos en PvP, mostrado a través de una tabla de clasificación y hologramas en el mundo. |
