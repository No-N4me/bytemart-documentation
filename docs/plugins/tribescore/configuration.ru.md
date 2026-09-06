# Конфигурация

Tribescore настраивается через **три** файла в папке плагина
(`ShooterGame/Binaries/Win64/ArkApi/Plugins/Tribescore/`):

| Файл | Назначение |
| ---- | ------- |
| `config.json` | Основные настройки: лицензия, база данных, активация, право участия, модификаторы начисления очков, голограммы и чат-команды. |
| `structures.json` | Значения очков для построек, по тиру постройки и по конкретным чертежам. |
| `dinos.json` | Значения очков и правила подсчёта для динозавров, по видам. |

> 💡 **Проверяйте перед запуском.** Всегда проверяйте ваш JSON после
> редактирования (например,
> через [JSONLint](https://jsonlint.com/)). Код ошибки загрузки `1114` означает
> синтаксическую ошибку JSON.

Ключи `LicenseKey`, `Verbose`, `LogToFile` и `Database` являются общими для каждого
плагина Bytemart и задокументированы на странице
**[Общая конфигурация](../index.md#common-configuration)**. Эта страница описывает только
ключи, уникальные для Tribescore.

---

## `config.json`

### `DebugMode`

```json
"DebugMode": false
```

Когда установлено `true`, консоль становится более подробной, **и** вам разрешается
зарабатывать tribescore со своего собственного племени — полезно для тестирования
начисления очков на dev-сервере. На боевом сервере оставьте `false`.

### `TribescoreActivation`

Глобально задерживает начисление очков после запуска сервера (вайпа), чтобы у племён
было время восстановиться до начала соревнования.

```json
"TribescoreActivation": {
  "Activation": {
    "Type": "delay",
    "Value": 7200
  },
  "Message": "Tribescore is globally enabled after 2 hours, please wait {cooldown}"
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `Activation.Type` | string | `"delay"` — включить начисление очков через `Value` секунд после запуска сервера. `"timestamp"` — включить начисление очков в фиксированный [Unix timestamp](https://www.unixtimestamp.com/). |
| `Activation.Value` | number | Задержка в секундах (для `delay`) или Unix timestamp (для `timestamp`). Установите `0`, чтобы отключить функцию и включить начисление очков немедленно. |
| `Message` | string | Показывается игрокам, которые запускают начисление очков, пока оно ещё на кулдауне. Плейсхолдер `{cooldown}` заменяется на оставшееся время. |

### `TribescoreEligibility`

Определяет, какие племена могут зарабатывать очки, в зависимости от размера состава.

```json
"TribescoreEligibility": {
  "MinPlayers": 1,
  "MinOnlinePlayers": 0
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `MinPlayers` | number | Минимальное количество участников (всего), которое должно быть у племени, чтобы зарабатывать очки. |
| `MinOnlinePlayers` | number | Минимальное количество участников, которые должны быть **онлайн**, чтобы племя зарабатывало очки. `0` отключает эту проверку. |

### `Scoring`

Сердце плагина. Здесь находятся базовые значения (а также в `structures.json` /
`dinos.json`); подраздел `Modifiers` умножает их.

```json
"Scoring": {
  "GainLossRatio": 0.75,
  "Structures": { "Enabled": true, "DefaultValue": 10.0 },
  "Dinos":      { "Enabled": true, "DefaultValue": 25.0 },
  "Players":    { "Enabled": true, "Value": 150.0 },
  "Modifiers": { "...": "..." }
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `GainLossRatio` | number | Когда явный `LossOverride` не задан (в `structures.json` / `dinos.json`), потеря очков **обороняющегося** составляет `gain × GainLossRatio`. При `0.75` обороняющийся теряет 75% от того, что получил атакующий. |
| `Structures.Enabled` | boolean | Включить начисление очков за уничтоженные постройки. Настройте значения в [`structures.json`](#structuresjson). |
| `Structures.DefaultValue` | number | Очки за постройку без совпадения по тиру или чертежу. |
| `Dinos.Enabled` | boolean | Включить начисление очков за убитых динозавров. Настройте значения в [`dinos.json`](#dinosjson). |
| `Dinos.DefaultValue` | number | Очки за динозавра без переопределения по конкретному виду. |
| `Players.Enabled` | boolean | Включить начисление очков за убитых вражеских игроков. |
| `Players.Value` | number | Фиксированное количество очков, начисляемое за убийство вражеского игрока. |

#### `Modifiers.OfflineProtection`

Уменьшает (или увеличивает) очки, заработанные против племени, которое полностью
находилось офлайн какое-то время — препятствуя офлайн-рейдам.

```json
"OfflineProtection": {
  "Enabled": true,
  "ActivatesAfter": 3600,
  "Modifier": 0.75
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Переключатель функции. |
| `ActivatesAfter` | number | Количество секунд, которое племя должно быть полностью офлайн, прежде чем защита вступит в силу. |
| `Modifier` | number | Множитель, применяемый после активации. `< 1` уменьшает выигрыш атакующего (например, `0.75` = −25%). |

*Применяется на основе **обороняющегося**.*

#### `Modifiers.PermissionModifiers`

Усиливает (или ослабляет) очки на основе **прав доступа** ArkApi атакующего.
Требует плагин
[Permissions](https://github.com/ServersHub/ServerAPI) из ArkServerAPI.

```json
"PermissionModifiers": {
  "Enabled": true,
  "TribePermissionsOnly": false,
  "OnlinePlayersOnly": true,
  "Modifiers": [
    { "Permission": "ts.boost.10", "Value": 1.1 },
    { "Permission": "ts.boost.15", "Value": 1.15 },
    { "Permission": "ts.boost.25", "Value": 1.25 }
  ]
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Переключатель функции. |
| `TribePermissionsOnly` | boolean | Когда установлено `true`, проверять только права уровня племени (игнорировать индивидуальные права игроков). |
| `OnlinePlayersOnly` | boolean | Когда установлено `true`, учитывать только права участников, находящихся в данный момент онлайн; иначе проверяются все участники. |
| `Modifiers[]` | array | Пары право → множитель. **Одновременно применяется только один модификатор**; если совпадают несколько, используется **наибольший**. |
| `Modifiers[].Permission` | string | Узел права доступа, которым должен обладать игрок/племя. |
| `Modifiers[].Value` | number | Применяемый множитель (`> 1` увеличивает выигрыш). |

*Применяется на основе **атакующего**.*

#### `Modifiers.ScoreDifferenceRatio`

Балансирует сильные и слабые племена. Сравниваемое отношение — это очки
**обороняющегося**, делённые на очки **атакующего**; `Modifier` совпадающего
интервала масштабирует выигрыш атакующего — так что большие племена, фармящие
маленькие, ослабляются, а аутсайдеры, атакующие гигантов, усиливаются.

```json
"ScoreDifferenceRatio": {
  "Enabled": true,
  "Intervals": [
    { "UpperBound": -1,   "LowerBound": 2,    "Modifier": 1.2 },
    { "UpperBound": 2,    "LowerBound": 1.5,  "Modifier": 1.1 },
    { "UpperBound": 1.5,  "LowerBound": 1,    "Modifier": 1 },
    { "UpperBound": 1,    "LowerBound": 0.5,  "Modifier": 0.8 },
    { "UpperBound": 0.5,  "LowerBound": 0.25, "Modifier": 0.6 },
    { "UpperBound": 0.25, "LowerBound": 0,    "Modifier": 0.25 }
  ]
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `Enabled` | boolean | Переключатель функции. |
| `Intervals[]` | array | Диапазоны отношения очков обороняющегося/атакующего, каждый со своим множителем. |
| `LowerBound` / `UpperBound` | number | Диапазон отношения, который покрывает этот модификатор. Используйте `-1` в качестве `UpperBound` верхнего диапазона, чтобы обозначить «без верхнего предела». |
| `Modifier` | number | Множитель, применяемый, когда отношение попадает в этот диапазон. |

**Как читать значения по умолчанию:**

- Отношение `≥ 2` (у обороняющегося ≥ 2× очков атакующего) → **1.2×** буст для
  атакующего аутсайдера.
- Отношение между `1.5` и `2` → **1.1×** буст.
- Отношение между `0.25` и `0.5` → **0.6×** ослабление.
- Отношение `< 0.25` (у обороняющегося менее четверти очков атакующего) →
  **0.25×** — жёсткое ослабление за фарм гораздо более слабых племён.

*Использует **оба** — и атакующего, и обороняющегося.*

### `Holograms`

Управляет плавающими числами очков, которые появляются в мире при изменении счёта.
`Damager` — это текст `+points`, показываемый атакующему; `Damagee` — это текст
`-points`, показываемый обороняющемуся.

```json
"Holograms": {
  "DecimalPrecision": 1,
  "LifeSpan": 6.0,
  "Scale":    { "X": 0.5, "Y": 0.5 },
  "FadeTime": { "In": 2.0, "Out": 3.0 },
  "Velocity": { "X": 0, "Y": 0, "Z": 10.0 },
  "Damager": { "Enabled": true, "Text": "+ {points} points", "Color": { "R": 0,   "G": 255, "B": 0 } },
  "Damagee": { "Enabled": true, "Text": "- {points} points", "Color": { "R": 255, "G": 0,   "B": 0 } }
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `DecimalPrecision` | number | Количество знаков после запятой, показываемое в значении `{points}`. |
| `LifeSpan` | number | Количество секунд, в течение которых голограмма остаётся видимой. |
| `Scale.X` / `Scale.Y` | number | Размер текста по каждой оси. |
| `FadeTime.In` / `FadeTime.Out` | number | Длительность появления / исчезновения в секундах. |
| `Velocity.X/Y/Z` | number | Скорость дрейфа текста; по умолчанию он плывёт вверх (`Z`). |
| `Damager` / `Damagee` | object | Всплывающие окна выигрыша / потери. `Enabled` переключает каждое; `Text` использует плейсхолдер `{points}`; `Color` — это RGB (0–255). |

Игроки могут включать или отключать голограммы для себя с помощью чат-команды
`/holograms` (см. [Команды](commands.md)).

### `ChatCommands`

Включает, переименовывает и стилизует три внутриигровые чат-команды. Каждая имеет
переключатель `Enabled` и настраиваемый триггер `Command`; отключение одной из них
полностью снимает её регистрацию.

```json
"ChatCommands": {
  "Holograms":   { "Enabled": true, "Command": "/holograms", "On": { "...": "..." }, "Off": { "...": "..." } },
  "Leaderboard": { "Enabled": true, "Lines": 15, "Command": "/leaderboard", "Text": "#{rank} [{tribe}] : {score}", "PerRankColor": { "...": "..." } },
  "MyTribeRank": { "Enabled": true, "Command": "/triberank", "Text": "Your tribe ({tribe}) is ranked #{rank} with {score}" }
}
```

Общие поля для каждой команды: `TextSize` (число), `Color` (RGB `{R,G,B}`) и
`DisplayTime` (секунды, в течение которых сообщение остаётся на экране).

**`Holograms`** — переключает отображение голограмм для каждого игрока. `On` и `Off`
каждое задаёт сообщение-подтверждение (`Text`, `TextSize`, `Color`, `DisplayTime`),
показываемое при переключении.

**`Leaderboard`** — выводит топ племён.

| Поле | Описание |
| ----- | ----------- |
| `Lines` | Сколько племён показывать в списке. |
| `Text` | Формат строки. Плейсхолдеры: `{rank}`, `{tribe}`, `{score}`. |
| `PerRankColor` | Необязательные переопределения цвета для каждого места, ключом является ранг (`"1"`, `"2"`, `"3"`, …), каждое — объект RGB. |

**`MyTribeRank`** — выводит ранг собственного племени вызывающего. `Text`
поддерживает те же плейсхолдеры `{rank}`, `{tribe}`, `{score}`.

### `Messages`

Зарезервировано для настройки сообщений; по умолчанию пусто (`{}`).

---

## `structures.json`

Значения очков для построек, определяемые сначала по **тиру** постройки, затем
переопределяемые конкретными **чертежами**. Постройка, которая ни с чем не
совпадает, использует `DefaultValue`.

```json
{
  "Tiers": {
    "Thatch": { "Value": 1.0,  "LossOverride": 0.5 },
    "Wood":   { "Value": 2.0,  "LossOverride": 1.25 },
    "Stone":  { "Value": 3.0,  "LossOverride": 2.0 },
    "Adobe":  { "Value": 5.0,  "LossOverride": 4.0 },
    "Metal":  { "Value": 10.0, "LossOverride": 7.0 },
    "Tek":    { "Value": 15.0, "LossOverride": 12.5 }
  },
  "DefaultValue": 10.0,
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Structures/Misc/PrimalItemStructure_HeavyTurret.PrimalItemStructure_HeavyTurret'",
      "Value": 25.0
    },
    {
      "BlueprintPath": "Blueprint'/Game/.../PrimalItemStructure_TurretTek.PrimalItemStructure_TurretTek'",
      "Value": 25.0,
      "LossOverride": 25.0
    }
  ]
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `Tiers` | object | Значения по тирам, ключом является материал постройки (`Thatch`, `Wood`, `Stone`, `Adobe`, `Metal`, `Tek`). |
| `Tiers.<tier>.Value` | number | Очки, которые атакующий получает за уничтожение постройки этого тира. |
| `Tiers.<tier>.LossOverride` | number | *(необязательно)* Фиксированные очки, которые теряет обороняющийся. Если опущено, используется `Value × GainLossRatio`. |
| `DefaultValue` | number | Резервное значение, когда постройка не совпадает ни с одним тиром или пользовательской записью. |
| `Customs[]` | array | Переопределения по конкретным чертежам, которые имеют приоритет над значением тира. |
| `Customs[].BlueprintPath` | string | Полный путь чертежа постройки. Используйте `ts.addstructure`, чтобы автоматически добавить постройку, на которую вы смотрите (см. [Команды](commands.md)). |
| `Customs[].Value` | number | Очки за этот конкретный чертёж. |
| `Customs[].LossOverride` | number | *(необязательно)* Фиксированная потеря для этого чертежа. |

---

## `dinos.json`

Значения очков и правила подсчёта по видам динозавров. `Defaults` применяется к
каждому динозавру, не указанному в `Customs`.

```json
{
  "Defaults": {
    "Value": 25.0,
    "LossOverride": 20.0,
    "CountBabies": true,
    "CountWithoutSaddle": true,
    "CountNotMounted": true,
    "ScoreFromWild": true
  },
  "Customs": [
    {
      "BlueprintPath": "Blueprint'/Game/PrimalEarth/Dinos/Giganotosaurus/Gigant_Character_BP.Gigant_Character_BP'",
      "Value": 50.0,
      "LossOverride": 45.0,
      "CountBabies": false
    }
  ]
}
```

| Поле | Тип | Описание |
| ----- | ---- | ----------- |
| `Value` | number | Очки, которые атакующий получает за убийство этого динозавра. |
| `LossOverride` | number | *(необязательно)* Фиксированные очки, которые теряет обороняющийся. Если опущено, используется `Value × GainLossRatio`. |
| `CountBabies` | boolean | Засчитывается ли убийство детёнышей/молодых динозавров. |
| `CountWithoutSaddle` | boolean | Засчитывается ли прирученный динозавр без седла. |
| `CountNotMounted` | boolean | Засчитывается ли динозавр, на котором в данный момент не едут верхом. |
| `ScoreFromWild` | boolean | Засчитывается ли убийство **дикого** (неприрученного) динозавра этого вида. |
| `Customs[].BlueprintPath` | string | Полный путь чертежа вида, на который нацелено это переопределение. |

Каждая запись `Customs` может задавать любое подмножество этих полей;
неуказанные поля берутся из `Defaults`.
