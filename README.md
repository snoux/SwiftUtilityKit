# SwiftUtilityKit

[中文](./README.md) | [English](./README_EN.md) | [自动选择语言（GitHub Pages）](./docs/index.html)

Swift 常用转换工具库。
- 默认日期上下文：`zh_CN + Asia/Shanghai + Gregorian`
- 覆盖：单位换算、日期时间、金额、百分比、颜色、字符串校验与格式化、设备诊断与应用信息、网络和电池状态监听

## 功能导航

- [安装](#安装)
- [单位换算与 BMI](#单位换算与-bmi)
- [金额与数字格式](#金额与数字格式)
- [日期与时间](#日期与时间)
- [字符串工具](#字符串工具)
- [颜色转换](#颜色转换)
- [坐标转换](#坐标转换)
- [设备与系统状态](#设备与系统状态)
  - [机型](#读取当前机型) · [诊断快照](#设备诊断快照) · [电池](#电池与设备状态) · [网络](#网络状态监听)
- [错误与本地化](#错误与本地化)
  - [错误触发条件](#conversionerror) · [处理转换错误](#处理转换错误) · [配置 App 多语言](#配置-app-多语言)

## 安装

说明：通过 Swift Package Manager 引入 SDK。

要求 Swift 6.2+；最低系统版本为 iOS / iPadOS 17、macOS 14、tvOS 17、watchOS 10、visionOS 1。

[GitHub 仓库](https://github.com/snoux/SwiftUtilityKit)

```swift
// 在代码文件中导入 SDK
import SwiftUtilityKit
```

- 点击观看：[SwiftUtilityKit Demo Video](https://github.com/snoux/SwiftUtilityKit/releases/download/1.0.0/demo.mp4)

## 单位换算与 BMI

换算扩展支持 `String`、`BinaryInteger`、`BinaryFloatingPoint` 和 `Decimal`，结果为 `Decimal`。字符串解析失败时抛出错误。数值也可以直接传给 `ValueConversion`。另见[时长换算与比较](#时长换算与比较)。

| 功能 | 单位枚举 | API | 基准或结果单位 |
|---|---|---|---|
| [长度换算](#长度换算) | `LengthUnit` | `convertLength(from:to:)` | m |
| [重量换算](#重量换算) | `WeightUnit` | `convertWeight(from:to:)` | kg |
| [面积换算](#面积换算) | `AreaUnit` | `convertArea(from:to:)` | m² |
| [体积换算](#体积换算) | `VolumeUnit` | `convertVolume(from:to:)` | L |
| [温度换算](#温度换算) | `TemperatureUnit` | `convertTemperature(from:to:)` | °C |
| [速度换算](#速度换算) | `SpeedUnit` | `convertSpeed(from:to:)` | m/s |
| [BMI](#bmi) | `WeightUnit` + `LengthUnit` | `ValueConversion.bmi` | kg/m² |

### 长度换算

```swift
// 把 2 海里换算为 3,704 米
let meters = 2.convertLength(from: .nauticalMile, to: .meter)
```

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.picometer` | 皮米 (pm) | `.nanometer` | 纳米 (nm) |
| `.micrometer` | 微米 (μm) | `.millimeter` | 毫米 (mm) |
| `.centimeter` | 厘米 (cm) | `.decimeter` | 分米 (dm) |
| `.meter` | 米 (m) | `.kilometer` | 千米 (km) |
| `.nauticalMile` | 海里 (nmi) | `.mile` | 英里 (mi) |
| `.furlong` | 弗隆 (fur) | `.yard` | 码 (yd) |
| `.foot` | 英尺 (ft) | `.inch` | 英寸 (in) |
| `.li` | 里 | `.zhang` | 丈 |
| `.chi` | 尺 | `.cun` | 寸 |
| `.fen` | 分 | `.liSmall` | 厘 |
| `.hao` | 毫 | `.lightYear` | 光年 (ly) |

### 重量换算

```swift
// 把 120 市斤换算为 60 千克
let kilograms = 120.convertWeight(from: .jin, to: .kilogram)
```

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.microgram` | 微克 (μg) | `.milligram` | 毫克 (mg) |
| `.gram` | 克 (g) | `.kilogram` | 千克 (kg) |
| `.ton` | 吨 (t) | `.ounce` | 盎司 (oz) |
| `.pound` | 磅 (lb) | `.stone` | 英石 (st) |
| `.jin` | 斤 | `.liang` | 两 |
| `.qian` | 钱 | `.dan` | 担（市制） |

### 面积换算

```swift
// 从字符串读取 1 市顷并换算为 100 市亩
let mu = try "1".convertArea(from: .qing, to: .mu)
```

1 市顷 = 100 市亩，1 公顷 = 15 市亩。 [土地单位换算资料](https://tjj.hubei.gov.cn/tjsj/sjkscx/tjnj/gsztj/snjlq/201911/P020250327358525034898.pdf)

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.squareMillimeter` | 平方毫米 (mm²) | `.squareCentimeter` | 平方厘米 (cm²) |
| `.squareDecimeter` | 平方分米 (dm²) | `.squareMeter` | 平方米 (m²) |
| `.squareKilometer` | 平方千米 (km²) | `.hectare` | 公顷 (ha) |
| `.acre` | 英亩 (ac) | `.squareFoot` | 平方英尺 (ft²) |
| `.squareInch` | 平方英寸 (in²) | `.mu` | 亩 |
| `.qing` | 顷（市制） | `.are` | 公亩 (a) |
| `.squareYard` | 平方码 (yd²) | `.squareMile` | 平方英里 (mi²) |

### 体积换算

```swift
// 把 1 立方分米换算为 1,000 毫升
let milliliters = 1.convertVolume(from: .cubicDecimeter, to: .milliliter)
```

1 cm³ = 1 mL，1 dm³ = 1 L。茶匙、汤匙、杯、品脱和加仑按美制液量单位换算。

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.milliliter` | 毫升 (mL) | `.liter` | 升 (L) |
| `.cubicMeter` | 立方米 (m³) | `.teaspoon` | 茶匙 (tsp) |
| `.tablespoon` | 汤匙 (tbsp) | `.cup` | 杯 (cup) |
| `.pint` | 品脱 (pt) | `.gallon` | 加仑 (gal) |
| `.cubicCentimeter` | 立方厘米 (cm³) | `.cubicInch` | 立方英寸 (in³) |
| `.microliter` | 微升 (μL) | `.cubicMillimeter` | 立方毫米 (mm³) |
| `.cubicDecimeter` | 立方分米 (dm³) | `.cubicFoot` | 立方英尺 (ft³) |
| `.cubicYard` | 立方码 (yd³) | — | — |

### 温度换算

```swift
// 把 0°C 换算为 273.15 K
let kelvin = 0.convertTemperature(from: .celsius, to: .kelvin)
```

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.celsius` | 摄氏度 (°C) | `.fahrenheit` | 华氏度 (°F) |
| `.kelvin` | 开尔文 (K) | — | — |

### 速度换算

```swift
// 按默认参考声速将 2 马赫换算为 686 m/s
let speed = 2.convertSpeed(from: .mach, to: .meterPerSecond)
// 按实际声速 330 m/s 将 2 马赫换算为 660 m/s
let localSpeed = ValueConversion.speed(2, from: .mach, to: .meterPerSecond, soundSpeedInMetersPerSecond: 330)
// 将一倍真空光速换算为 299,792,458 m/s
let light = 1.convertSpeed(from: .speedOfLight, to: .meterPerSecond)
```

`knot` 表示海里每小时。`.mach` 和 `.speedOfSound` 默认以 20°C 空气中的近似声速 343 m/s 为参考。已知实际声速时，传入 `soundSpeedInMetersPerSecond`。真空光速取 299,792,458 m/s。 [NASA 声速资料](https://ntrs.nasa.gov/api/citations/20160000818/downloads/20160000818.pdf) · [BIPM 米的定义](https://www.bipm.org/en/si-base-units/metre)

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.meterPerSecond` | 米每秒 (m/s) | `.kilometerPerHour` | 千米每小时 (km/h) |
| `.milePerHour` | 英里每小时 (mph) | `.knot` | 节 (kn) |
| `.footPerSecond` | 英尺每秒 (ft/s) | `.inchPerSecond` | 英寸每秒 (in/s) |
| `.kilometerPerSecond` | 千米每秒 (km/s) | `.nauticalMilePerSecond` | 海里每秒 (nmi/s) |
| `.speedOfLight` | 真空光速 (c) | `.speedOfSound` | 声速（20°C 空气） |
| `.mach` | 马赫 | — | — |

### BMI

```swift
// 计算 64 kg、160 cm 对应的 BMI，结果为 25
let bmi = ValueConversion.bmi(weight: 64, height: 160, heightUnit: .centimeter)
```

`bmi` 默认使用千克和米，也可指定 `WeightUnit` 与 `LengthUnit`。身高或体重为非正数、非有限值，或计算结果超出数值范围时，返回 `nil`。[CDC BMI 计算公式](https://www.cdc.gov/growth-chart-training/hcp/using-bmi/body-mass-index.html)

## 金额与数字格式

### 金额换算与格式化

```swift
import Foundation
import SwiftUtilityKit

// 人民币元转分 -> 1234
let fen = try "12.34".convertMoney(from: .major, to: .minor, currency: .cny)
// 拆出 12 元、3 角和 4 分
let parts = MoneyConversion.splitCNY(12.34)
// 将元角分合并为 12.34 元
let yuan = parts.toDecimalYuan()
// 金额千分位格式化 -> 1,234,567.80
let text = try "1234567.8".formattedMoney(scale: 2, useGrouping: true, locale: Locale(identifier: "en_US"))
```

金额用 Foundation 的 `Decimal` 保存，便于继续做十进制运算。换算发生在同一币种内，例如人民币元与分。币种参数决定哪些单位可用。

#### 枚举与类型

##### CurrencyCode

| 枚举值 | 含义 | 枚举值 | 含义 |
|---|---|---|---|
| `.cny` | 人民币 | `.usd` | 美元 |
| `.eur` | 欧元 | `.gbp` | 英镑 |
| `.jpy` | 日元 | — | — |

##### MoneyUnit

| 枚举值 | 含义 | 枚举值 | 含义 |
|---|---|---|---|
| `.major` | 主单位（如元/美元） | `.tenth` | 十分位单位（如角） |
| `.minor` | 百分位单位（如分/美分） | — | — |

`.jpy` 仅支持 `.major`。人民币、美元、欧元和英镑支持表中三种单位层级。

##### CNYParts

`CNYParts` 提供 `yuan`、`jiao`、`fen` 和 `isNegative`。整元字段沿用带符号的表示，拆分得到的角和分各为 0–9。单独展示负号时读取 `isNegative`。例如 `-0.34` 的整元字段为 0，调用 `toDecimalYuan()` 可以合并回 `-0.34`。

| `CNYRounding` | `12.346` 元的结果 |
|---|---|
| `.round` | 12 元 3 角 5 分。无参 `splitCNY()` 使用此策略。 |
| `.truncate` | 12 元 3 角 4 分。向零截断，舍弃分以下的尾数。 |
| `.exact` | 抛出 `ConversionError.inexactCNYAmount`。金额须能精确表示为整数分。 |

```swift
let amount = Decimal(string: "12.346")!
let truncated = try amount.splitCNY(rounding: .truncate)
let negative = try MoneyConversion.splitCNY(Decimal(string: "-0.34")!, rounding: .exact)
let yuan = negative.toDecimalYuan() // -0.34
```

未校验的金额可传给带策略的抛错版本。NaN 会抛出 `.invalidNumber`，舍入后的整元部分超出 `Int` 范围会抛出 `.overflow`。

#### 按用途选择调用方式

| 想做什么 | 直接调用 | 在已有值上调用 | 返回结果 |
|---|---|---|---|
| 换单位后继续计算 | `MoneyConversion.convert(_:from:to:currency:)` 接收 `Decimal` | `amount.convertMoney(from:to:currency:)` | `Decimal`，如 12.34 元 → 1234 分 |
| 换单位后直接显示 | 先 `convert` 再 `format` | `amount.convertMoneyString(from:to:currency:scale:useGrouping:locale:)` | `String`，可指定小数位与千分位 |
| 仅格式化当前金额 | `MoneyConversion.format(_:scale:useGrouping:locale:)` 接收 `Decimal`，可指定地区 | `amount.formattedMoney(scale:useGrouping:locale:)` | `String`，如 `1,234.50`，金额单位照旧 |
| 拆成元、角、分 | `MoneyConversion.splitCNY(_:)` 或 `splitCNY(_:rounding:)` | `decimalAmount.splitCNY()` 或 `splitCNY(rounding:)` | `CNYParts`，含元、角、分和符号 |
| 将元、角、分合并 | `MoneyConversion.mergeCNY(_:)` 接收完整的 `CNYParts` | `parts.toDecimalYuan()` | `Decimal`，单位是元 |

前三行的 `amount` 可以是 `String`、`Decimal`、整数或浮点数。字符串解析失败时抛出 `.invalidNumber`，换算遇到币种不支持的单位时抛出 `.invalidMoneyUnit`。地区格式见[单位名称与地区格式](#单位名称与地区格式)。

```swift
import Foundation
import SwiftUtilityKit

// 业务层已有 Decimal 金额，单位为元
let decimalAmount = Decimal(1234) / 100
// 换算后继续用 Decimal 运算
let amountInFen = try decimalAmount.convertMoney(from: .major, to: .minor)
// 取出整数角数供表单展示，结果为 3
let jiao = decimalAmount.splitCNY().jiao
// 通过 scale 保留两位小数，换成分后显示为 "1,234.00"
let display = try decimalAmount.convertMoneyString(from: .major, to: .minor, scale: 2, useGrouping: true, locale: Locale(identifier: "en_US"))
```

### 百分数与比率

```swift
// 百分数 12.5 转比率 0.125
let ratio = try "12.5".percentToRatio()
// 将 0.125 转回百分数 12.5
let percent = ratio.ratioToPercent()
```

| 输入 | API | 结果与用途 |
|---|---|---|
| `Decimal` | `PercentageConversion.percentToRatio(_:)` / `ratioToPercent(_:)` | 分别除以或乘以 100，返回 `Decimal` 供后续计算 |
| `String`、`Decimal`、整数、浮点数 | `percentToRatio()` / `ratioToPercent()` | 在值上直接调用，返回 `Decimal`。字符串传入 `"12.5"` 这类数字文本，解析失败时抛出 `.invalidNumber` |
| `String` | `percentToRatioString(scale:)` / `ratioToPercentString(scale:)` | 换算后返回数字文本，`scale` 指定舍入位数 |
| 比率形式的 `Decimal` | `asPercentString(scale:)` | 比率乘以 100 后转成数字文本，例如 `0.125` 得到 `"12.5"`，需要百分号时由界面添加 |

### 中文大写与进制

```swift
// 将 123.45 写成普通中文大写「壹佰贰拾叁点肆伍」
let number = try "123.45".toChineseUppercaseNumber()
// 将 123.45 元写成「壹佰贰拾叁元肆角伍分」
let amount = try "123.45".toChineseUppercaseCurrency()
// 将金额大写解析回 123.45
let decimal = try amount.chineseUppercaseToDecimal()
// 将十进制 255 转为十六进制 "FF"
let hexadecimal = try "255".convertRadix(from: 10, to: 16)
```

- `toChineseUppercaseNumber()` 与 `toChineseUppercaseCurrency()` 支持字符串、整数、浮点数和 `Decimal`。
- `String.chineseUppercaseToDecimal()` 将中文数字或金额大写解析为 `Decimal`。
- `String.convertRadix(from:to:uppercase:)` 与整数的 `convertRadix(to:uppercase:)` 支持 2 到 36 进制。

## 日期与时间

### 常用示例

日期示例使用默认上下文 `zh_CN + Asia/Shanghai + Gregorian`。

#### 日期格式转换

```swift
// 自动识别输入并输出为 yyyy/MM/dd HH:mm
let out = try "2026-03-10 08:00:00".dateString(to: .dateMinuteSlash)
```

#### 常用 Date 扩展

```swift
// 解析 Date
let d = try "2026-03-10 12:34:56".date(.dateTime)
// 当天开始时间 00:00:00
let start = d.startOfDay()
// 当天结束时间 23:59:59
let end = d.endOfDay()
// 日期加 7 天
let plus7 = d.adding(7, .day)
// 是否同一天
let sameDay = d.isSameDay(as: Date())
```

#### 判断是不是昨天（String 直调）

```swift
// 解析参考时间
let ref = try "2026-03-10 12:00:00".date(.dateTime)
// 判断目标时间是否是参考时间的昨天
let ok = try "2026-03-09 12:00:00".isYesterday(ref: ref)
```

#### 判断是不是昨天（Date 直调）

```swift
// 解析参考时间
let ref = try "2026-03-10 12:00:00".date(.dateTime)
// 解析目标时间
let target = try "2026-03-09 12:00:00".date(.dateTime)
// 直接通过 Date 扩展判断昨天
let ok = target.isYesterday(ref: ref)
```

#### 判断 7 天内

```swift
// 参考时间
let ref = try "2026-03-10 12:00:00".date(.dateTime)
// 按日期时间格式解析，判断目标是否在参考时间向前 7 天内
let in7 = try "2026-03-05 12:00:00".relative(.dateTime, to: ref).withinPast(7, .day)
```

#### 判断区间

```swift
// 判断字符串时间是否在区间内
let inRange = try "2026-03-10 08:00:00".isBetween("2026-03-10 07:00:00", and: "2026-03-10 09:00:00", format: "yyyy-MM-dd HH:mm:ss")
```

#### 时间戳互转

```swift
// 日期字符串转秒级时间戳
let ts = try "2026-03-10 08:00:00".timestamp(.dateTime)
// 秒级时间戳转日期字符串
let text = try "1704067200".dateStringFromTimestamp(unit: .second, format: "yyyy-MM-dd HH:mm:ss")
```

### 日期上下文与格式

`DateKit.Context` 将语言、时区和日历作为一组设置传给日期 API。日期文本的解析与格式化使用其中的语言和时区，自然日和周等比较使用其中的日历。日期模板由 `DateKit.Pattern` 或自定义格式字符串指定。见[自定义日期上下文示例](#单位名称与地区格式)。

#### 上下文类型 `DateKit.Context`

| API | 说明 |
|---|---|
| `DateKit.defaultContext` | 默认上下文（`zh_CN + Asia/Shanghai + Gregorian`） |
| `DateKit.Context.cn` | 显式使用简体中文、上海时区和公历 |
| `DateKit.Context(locale:timeZone:calendar:)` | 为某次调用设置语言、时区和日历，通过 `in:` 传入 |

#### 日期模式枚举 `DateKit.Pattern`

| 枚举值 | 格式 | 说明 | 示例 |
|---|---|---|---|
| `.dateTime` | `yyyy-MM-dd HH:mm:ss` | 常用秒级日期时间 | `2026-03-10 08:00:00` |
| `.dateTimeSlash` | `yyyy/MM/dd HH:mm:ss` | 斜杠版秒级日期时间 | `2026/03/10 08:00:00` |
| `.dateMinute` | `yyyy-MM-dd HH:mm` | 分钟级日期时间 | `2026-03-10 08:00` |
| `.dateMinuteSlash` | `yyyy/MM/dd HH:mm` | 斜杠版分钟级日期时间 | `2026/03/10 08:00` |
| `.date` | `yyyy-MM-dd` | 横杠日期 | `2026-03-10` |
| `.dateSlash` | `yyyy/MM/dd` | 斜杠日期 | `2026/03/10` |
| `.compactDateTime` | `yyyyMMddHHmmss` | 紧凑日期时间 | `20260310080000` |
| `.compactDate` | `yyyyMMdd` | 紧凑日期 | `20260310` |
| `.iso8601` | `yyyy-MM-dd'T'HH:mm:ssZ` | ISO8601 秒级 | `2026-03-10T08:00:00+0800` |
| `.iso8601Millis` | `yyyy-MM-dd'T'HH:mm:ss.SSSZ` | ISO8601 毫秒级 | `2026-03-10T08:00:00.000+0800` |

辅助集合：
- `DateKit.commonDatePatterns`：自动识别输入模式列表（顺序即尝试顺序）
- `DateKit.commonDateFormats`：自动识别输入格式字符串列表

### 字符串日期 API

说明：这是日期处理的主入口，支持“明确格式”和“自动识别”两种调用风格。

#### 解析
| API | 说明 |
|---|---|
| `date(_ format: String)` | 按格式解析 |
| `date(_ pattern: DateKit.Pattern)` | 按内置模式解析 |
| `date(_ formats: [String])` | 按多个格式依次尝试 |
| `date(_ patterns: [DateKit.Pattern])` | 按多个模式依次尝试 |
| `date(patterns:)` | 自动识别解析 |

#### 格式转换
| API | 说明 |
|---|---|
| `dateString(from:to:)`（String） | 输入格式 -> 输出格式 |
| `dateString(from:to:)`（Pattern） | 输入模式 -> 输出模式 |
| `dateString(to:inputFormats:)` | 自动识别输入格式后输出 |
| `dateString(to:inputPatterns:)` | 自动识别输入模式后输出 |

#### 比较与差值
| API | 说明 |
|---|---|
| `dateCompare(with:format:)` | 比较两个日期字符串 |
| `dateDistance(to:format:unit:)` | 计算日期差值（`other - self`） |

#### 时间戳
| API | 说明 |
|---|---|
| `timestamp(_ format: String, unit:)` | 按格式转时间戳 |
| `timestamp(_ pattern: DateKit.Pattern, unit:)` | 按模式转时间戳 |
| `timestamp(unit:patterns:)` | 自动识别后转时间戳 |
| `timestampString(_ format: String, unit:scale:)` | 转时间戳字符串 |
| `dateStringFromTimestamp(unit:format:)` | 时间戳字符串转日期字符串 |
| `convertTimestamp(from:to:scale:)` | 时间戳单位互转 |

#### 相对时间与区间
说明：`relative(...)` 返回 `DateRelativeProxy`（中间对象），它保存 `target + reference`，用于继续做 `.isYesterday/.isToday/...` 等判断。

| API | 说明 |
|---|---|
| `relative(_ format: String, to:)` | 按格式返回相对时间判断对象 |
| `relative(_ pattern: DateKit.Pattern, to:)` | 按模式返回相对时间判断对象 |
| `relative(to:patterns:)` | 自动识别后返回相对时间判断对象 |
| `isBetween(_:and:format:inclusive:)` | 判断字符串时间是否在区间内 |
| `isYesterday(_ format:ref:)` | 显式格式判断昨天 |
| `isYesterday(ref:patterns:)` | 自动识别判断昨天 |
| `isToday(_ format:ref:)` | 显式格式判断今天 |
| `isToday(ref:patterns:)` | 自动识别判断今天 |
| `isTomorrow(_ format:ref:)` | 显式格式判断明天 |
| `isTomorrow(ref:patterns:)` | 自动识别判断明天 |
| `isDayBeforeYesterday(_ format:ref:)` | 判断前天 |
| `isLastWeek(_ format:ref:)` | 判断上周 |
| `isNextWeek(_ format:ref:)` | 判断下周 |
| `isLastYear(_ format:ref:)` | 判断去年 |
| `isNextYear(_ format:ref:)` | 判断明年 |

### Date 扩展

说明：业务逻辑层推荐直接用 `Date` 扩展，调用更自然。

| API | 说明 |
|---|---|
| `formatted(_:)` | `Date` 格式化输出 |
| `timestamp(unit:)` | `Date` 转时间戳 |
| `relative(to:)` | 返回 `DateRelativeProxy` |
| `startOfDay()` | 获取当天开始时间 |
| `endOfDay()` | 获取当天结束时间 |
| `startOfWeek()` | 获取当周开始时间 |
| `endOfWeek()` | 获取当周结束时间 |
| `startOfMonth()` | 获取当月开始时间 |
| `endOfMonth()` | 获取当月结束时间 |
| `adding(_:_:)` | 日期加减（如加 7 天） |
| `isSameDay(as:)` | 判断是否同一天 |
| `isWeekend()` | 判断是否周末 |
| `days(to:)` | 计算相差自然日天数 |
| `isInRange(from:to:inclusive:)` | 区间判断 |
| `isBetween(_:and:inclusive:)` | 区间判断别名 |
| `isDayBeforeYesterday(ref:)` | 判断前天 |
| `isYesterday(ref:)` | 判断昨天 |
| `isToday(ref:)` | 判断今天 |
| `isTomorrow(ref:)` | 判断明天 |
| `isLastWeek(ref:)` | 判断上周 |
| `isNextWeek(ref:)` | 判断下周 |
| `isLastYear(ref:)` | 判断去年 |
| `isNextYear(ref:)` | 判断明年 |
| `isWithinPast(_:_:ref:in:inclusive:)` | 判断是否在参考时间向前范围内 |
| `Date.fromTimestamp(_:unit:)` | 时间戳转 `Date` |

`DateRelativeProxy` 复用同一个目标日期、参考日期和上下文，适合给列表记录加上「今天」「昨天」或「上周」标签。若标签由配置决定，调用 `matches(_:)` 并传入 [`RelativeDateTag`](#dateconversionrelativedatetag)。若要判断时间窗口，调用 `withinPast(_:_:inclusive:)`，例如 `withinPast(7, .day)` 默认包含参考时间及向前 7 天的边界。两种方法均返回 `Bool`。

### 时间戳 API

说明：当时间戳本来就是数值类型时，无需先转字符串。

| API | 返回结果 |
|---|---|
| `convertTimestamp(from:to:)` | 换算后的 `Decimal` 时间戳，单位为秒或毫秒 |
| `toDate(unit:)` | 按指定单位解析出的 `Date`，默认按秒读取 |

两种方法都可直接在整数、浮点数和 `Decimal` 上调用。

### 时长换算与比较

```swift
// 把 2 小时换算为 120 分钟
let minutes = 2.convertTime(from: .hour, to: .minute)
// 比较 2 小时与 90 分钟，得到 .orderedDescending
let comparison = 2.compareTime(with: 90, selfUnit: .hour, otherUnit: .minute)
// 用分钟计算 2 小时减 30 分钟，得到 90
let difference = 30.timeDifference(to: 2, selfUnit: .minute, otherUnit: .hour, resultUnit: .minute)
```

`String`、`BinaryInteger`、`BinaryFloatingPoint` 和 `Decimal` 提供以下扩展。字符串入口在解析失败时抛出错误。

- `convertTime(from:to:)` 换算时长。
- `compareTime(with:selfUnit:otherUnit:)` 比较两个时长。
- `timeDifference(to:selfUnit:otherUnit:resultUnit:)` 计算差值（`other - self`）。

#### `TimeUnit`

| 枚举值 | 单位（符号） | 枚举值 | 单位（符号） |
|---|---|---|---|
| `.nanosecond` | 纳秒 (ns) | `.microsecond` | 微秒 (μs) |
| `.millisecond` | 毫秒 (ms) | `.second` | 秒 (s) |
| `.minute` | 分钟 (min) | `.hour` | 小时 (h) |
| `.day` | 天 (d) | `.week` | 周 (wk) |

### 日期相关枚举

#### DateConversion.TimestampUnit

| 枚举值 | 含义 | 枚举值 | 含义 |
|---|---|---|---|
| `.second` | 秒级时间戳（如 `1704067200`） | `.millisecond` | 毫秒级时间戳（如 `1704067200000`） |

#### DateConversion.DateDifferenceUnit

| 枚举值 | 含义 | 枚举值 | 含义 |
|---|---|---|---|
| `.second` | 按秒输出差值 | `.minute` | 按分钟输出差值 |
| `.hour` | 按小时输出差值 | `.day` | 按天输出差值（24 小时） |

#### DateConversion.RelativeDateTag

| 枚举值 | 含义 | 枚举值 | 含义 |
|---|---|---|---|
| `.dayBeforeYesterday` | 前天 | `.yesterday` | 昨天 |
| `.today` | 今天 | `.tomorrow` | 明天 |
| `.lastWeek` | 上周 | `.nextWeek` | 下周 |
| `.lastYear` | 去年 | `.nextYear` | 明年 |

## 字符串工具

### 字符串清理与编码

```swift
// 判断是否空白字符串
let blank = " \n ".isBlank
// URL 编码
let encoded = "a b&c=1".urlEncoded()
// URL 解码
let decoded = "a%20b%26c%3D1".urlDecoded()
// Base64 编码
let b64 = "SwiftUtilityKit".base64Encoded()
// Base64 解码
let raw = "U3dpZnRVdGlsaXR5S2l0".base64Decoded()
```

| API | 说明 |
|---|---|
| `trimmed()` | 去首尾空白和换行 |
| `removingWhitespacesAndNewlines()` | 去全部空白和换行 |
| `isIntegerNumber` | 是否整数文本 |
| `isDecimalNumber` | 是否十进制数字文本 |
| `digitsOnly()` | 仅保留数字字符 |
| `formattedWithGrouping(maximumFractionDigits:minimumFractionDigits:)` | 数字千分位格式化 |
| `safeSubstring(start:length:)` | 从零基字符索引截取指定长度，越界时返回 `nil` |
| `isBlank` | 是否空白字符串 |
| `nilIfBlank()` | 空白转 `nil`，否则返回 trim 后内容 |
| `urlEncoded()` | URL 百分号编码，失败时返回原文 |
| `urlDecoded()` | URL 百分号解码，失败时返回原文 |
| `base64Encoded()` | Base64 编码（UTF-8） |
| `base64Decoded()` | Base64 解码为 UTF-8 文本，失败时返回 `nil` |

### 校验、格式化与脱敏

说明：用于输入合法性校验和展示脱敏。

```swift
// 校验大陆手机号
let phoneOK = "13800138000".isValidChineseMobile
// 校验邮箱
let emailOK = "demo@example.com".isValidEmail
// 校验 URL
let urlOK = "https://example.com/path?a=1".isValidURL
// 校验 IPv6
let ipv6OK = "2408:8400:9800:31d3:4ff7:f6d2:69f8:77b3".isValidIPv6
// 校验银行卡号（Luhn）
let cardOK = "4111111111111111".isValidBankCardNumber
// 校验身份证号（含校验码）
let idOK = "11010519491231002X".isValidChineseIDCard

// 银行卡分组格式化
let cardText = "6222021234567890123".formattedBankCardNumber()
// 手机号格式化为 XXX-XXXX-XXXX
let phoneText = "13800138000".formattedChineseMobile()
// 手机号脱敏为 XXX****XXXX
let phoneMask = "13800138000".maskedChineseMobile()
// 身份证脱敏为 前6 + **** + 后4
let idMask = "11010519491231002X".maskedChineseIDCard()
```

#### 校验

校验属性返回 `Bool`，适合在提交前检查输入格式。

| API | 检查规则 |
|---|---|
| `isValidChineseMobile` | 11 位中国大陆手机号，前两位为 13–19 |
| `isValidURL` | 检查 `http`、`https` 或 `ftp` URL 的文本格式 |
| `isValidEmail` | 检查邮箱地址格式 |
| `isValidIPv6` | 系统 IPv6 解析器接受该地址时为 `true` |
| `isValidBankCardNumber` | 12–19 位数字且通过 Luhn 校验 |
| `isValidChineseIDCard` | 校验 18 位身份证号码的结构、出生日期和校验位 |

#### 格式化与脱敏

| API | 输出与回退 |
|---|---|
| `formattedBankCardNumber(separator:)` | 提取数字并每 4 位分组，默认用 `-`，无数字时返回空字符串 |
| `formattedChineseMobile(separator:)` | 将 11 位数字按 3–4–4 分组，默认用 `-`。数字位数不同则返回原文 |
| `maskedChineseMobile(mask:)` | 保留 11 位号码的前 3 位与后 4 位，默认用 `****`。数字位数不同则返回原文 |
| `maskedChineseIDCard(mask:)` | 保留前 6 个和后 4 个字符，默认用 `****`。去掉首尾空白后不足 10 个字符则返回原文 |

## 颜色转换

```swift
// 颜色字符串标准化为 hex
let hex = try "rgba(255,102,0,0.5)".normalizedColorHex(includeAlpha: true)
```

说明：支持颜色字符串、整数、十六进制与系统颜色对象互转。

### ColorRGBA

| 输入或用途 | API | 结果 |
|---|---|---|
| 已有整数通道值 | `init(red:green:blue:alpha:)` | 接收 0–255 的通道值，默认 alpha 为 255 |
| 解析颜色文本 | `parse(_:)`、`fromHex(_:)`、`fromRGBString(_:)` | 将带 `#` 的 3、4、6、8 位十六进制文本，或 `rgb(...)`、`rgba(...)` 转成 `ColorRGBA` |
| 解析打包整数 | `fromPackedInt(_:hasAlpha:)` | 默认按 `0xRRGGBB` 读取。传 `hasAlpha: true` 时按 `0xRRGGBBAA` 读取 |
| 保存或传输颜色值 | `hexString(includeAlpha:prefixHash:)`、`packedInt(includeAlpha:)` | 分别得到十六进制文本或整数。保存透明度时传 `includeAlpha: true` |

### 在字符串或整数上调用

| 输入 | API | 返回结果 |
|---|---|---|
| 颜色字符串 | `toColorRGBA()`、`normalizedColorHex(includeAlpha:prefixHash:)`、`colorToPackedInt(includeAlpha:)` | 分别返回通道结构、规范的十六进制文本和打包整数 |
| 颜色字符串 | `toCGColor()`、`toUIColor()`、`toSwiftUIColor()` | 返回对应平台颜色对象，`UIColor` 需要 UIKit |
| 打包整数 | `toColorRGBA(hasAlpha:)`、`toColorHex(hasAlpha:prefixHash:)` | 解码为通道结构或十六进制文本，`hasAlpha` 指定输入末尾是否带 alpha |

### 颜色工厂函数
- `colorRGBA(_:)`：字符串直接创建 `ColorRGBA`
- `cgColor(_:) / cgcolor(_:)`：字符串直接创建 `CGColor`
- `uiColor(_:) / uicolor(_:)`：字符串直接创建 `UIColor`（UIKit）
- `swiftUIColor(_:)`：字符串直接创建 `SwiftUI.Color`

### 平台桥接

| 场景 | API | 说明 |
|---|---|---|
| 浮点通道 → `ColorRGBA` | `ColorRGBA.init(red:green:blue:alpha:)` 的 `CGFloat` 重载 | 输入用 0–1，转换为 0–255 的整数通道 |
| `ColorRGBA` → 平台颜色 | `cgColor`、`uiColor`、`swiftUIColor` | 读取属性得到对应的 CoreGraphics、UIKit 或 SwiftUI 对象 |
| 平台颜色 → `ColorRGBA` | `ColorRGBA.init(cgColor:)`、`ColorRGBA.init(uiColor:)`、`UIColor.toColorRGBA()`、`Color.toColorRGBA()` | 转换为可读取 RGBA 通道的值。最后一项需要 SwiftUI 和 UIKit |
| 直接构建 `UIColor` | `UIColor.init(_:)`、`init(hex:)`、`init(rgbString:)`、`init(colorString:)` | 输入分别为 `ColorRGBA`、十六进制文本、RGB 文本或任一受支持的颜色文本 |

## 坐标转换

```swift
// 字符串转坐标（默认纬度,经度）
let c = try "31.2304,121.4737".coordinate()
// 坐标转字符串（经度,纬度）
let text = c.string(order: .longitudeLatitude, fractionDigits: 6)
// 坐标转字典：["latitude":..., "longitude":...]
let dict = c.dictionary()
```

说明：在可导入 CoreLocation 的平台，支持 `CLLocationCoordinate2D` 与字符串、元组、字典互转。

### 枚举

| 枚举值 | 含义 | 枚举值 | 含义 |
|---|---|---|---|
| `CoordinateOrder.latitudeLongitude` | `纬度,经度` | `CoordinateOrder.longitudeLatitude` | `经度,纬度` |

### 创建、检查与导出坐标

| 想做什么 | API | 输入或返回结果 |
|---|---|---|
| 解析坐标文本 | `CLLocationCoordinate2D.parse(_:separator:order:)` 或 `String.coordinate(separator:order:)` | 默认按逗号分隔的「纬度,经度」读取。解析失败或越界时抛出 `.invalidCoordinate` |
| 从元组或字典创建 | `CLLocationCoordinate2D.make(_:order:)`、`make(from:)` | 接收两个 `Double`，或含 `latitude` / `longitude` 等键的字典，返回有效坐标 |
| 检查已有坐标 | `isValidCoordinate` | 纬度在 −90 到 90、经度在 −180 到 180 且通过系统校验时返回 `true` |
| 序列化为文本或元组 | `string(order:separator:fractionDigits:)`、`tuple(order:)` | 按指定顺序输出，文本可设分隔符与小数位 |
| 导出字典 | `dictionary()` | 返回 `[String: Double]`，固定使用 `latitude` 和 `longitude` 两个键 |
| 纠正装反的经纬度字段 | `swappedLatLon()` | 返回交换经纬度后的坐标，可用 `isValidCoordinate` 检查结果 |

## 设备与系统状态

说明：原生 macOS 14+ 和 UIKit 平台（watchOS 除外）支持系统版本、设备机型、App 版本、存储容量及诊断快照。屏幕接口适用于 UIKit 平台（visionOS 除外）。电量和充电状态支持 macOS 和 UIKit 平台（tvOS 除外）。跨平台应用信息也可使用 `AppInfo`。

### 读取设备信息

```swift
// 获取系统版本号
let sys = DeviceInfo.systemVersion
// 获取设备机型名称
let model = DeviceInfo.modelName
// 获取当前 App 版本号 + 构建号
let app = DeviceInfo.appVersionWithBuild
#if canImport(UIKit) && !os(visionOS)
// 获取屏幕物理分辨率（像素）
let px = DeviceInfo.pixelResolutionText
#endif
#if os(macOS) || (canImport(UIKit) && !os(tvOS) && !os(watchOS))
// 获取当前电池百分比文本
let battery = DeviceInfo.batteryPercentageText
#endif
// 获取设备总容量文本
let total = DeviceInfo.totalDiskSpaceText
// 获取设备剩余容量文本
let free = DeviceInfo.freeDiskSpaceText
// 获取设备已用容量文本
let used = DeviceInfo.usedDiskSpaceText
```

### 读取当前机型

```swift
import SwiftUtilityKit

// iPhone Duo 上为 "iPhone19,4"
let identifier = DeviceInfo.modelIdentifier
// iPhone Duo 上为 "iPhone Duo"
let name = DeviceInfo.modelName

// 判断当前机型是否为 iPhone Duo
if DeviceInfo.currentModel == .iPhoneDuo {
    // 处理 iPhone Duo 专属逻辑
}

// Optional("iPhone Duo")
let duoName = DeviceModel.iPhoneDuo.displayName
// ["iPhone19,4"]
let duoIdentifiers = DeviceModel.iPhoneDuo.identifiers
// 从已有硬件标识查出 .iPhoneDuo
let knownModel = DeviceModel(identifier: "iPhone19,4")
// 获取所有机型枚举值，含 .unknown 和 .simulator
let supportedModels = DeviceModel.allCases
```

已有硬件标识时，可用 `DeviceModel(identifier:)` 查询。同款机型的不同硬件标识共享一个枚举值，例如 `iPhone19,3` 和 `iPhone19,7` 都对应 `.iPhone18ProMax`。未收录的机型返回 `.unknown`，仍可通过 `DeviceInfo.modelIdentifier` 获取原始标识。模拟器能读取具体机型时也返回对应枚举，仅识别到模拟器架构时返回 `.simulator`。

诊断快照通过 `snapshot.model` 读取枚举，已保存的 JSON 可以直接解码并用原始标识解析。

也可以通过 `UIDevice` 扩展读取，结果与 `DeviceInfo` 一致：

```swift
import UIKit
import SwiftUtilityKit

@MainActor
func printDeviceModel() {
    // 输出硬件标识
    print(UIDevice.current.utilityModelIdentifier)
    // 输出机型名称
    print(UIDevice.current.utilityModelName)
}
```

- `modelIdentifier` 是硬件标识，数字不等于商品名称中的代数，例如 `iPhone18,1` 对应 `iPhone 17 Pro`。
- 当前 iPhone 映射包含 `iPhone18,1`～`iPhone18,5`，分别对应 iPhone 17 Pro、iPhone 17 Pro Max、iPhone 17、iPhone Air、iPhone 17e；资源还收录了 iPad 和 iPod。
- 已补充 iPhone 18 Pro（`iPhone19,2`）、iPhone 18 Pro Max（`iPhone19,3` / `iPhone19,7`）和 iPhone Duo（`iPhone19,4`）；两种 Pro Max 标识返回同一商品名称。
- 模拟器优先读取 `SIMULATOR_MODEL_IDENTIFIER`，名称带有 `Simulator (...)` 前缀，例如 `Simulator (iPhone Duo)`。
- 未收录的真机会直接返回原始标识；模拟器则返回 `Simulator (原始标识)`，便于后续补充映射。
- 机型读取适用于原生 macOS 和可导入 UIKit 的平台（watchOS 除外）。

#### 常用机型

| 枚举值 | 显示名称 | 硬件标识 |
|---|---|---|
| `.iPhoneDuo` | iPhone Duo | `iPhone19,4` |
| `.iPhone18ProMax` | iPhone 18 Pro Max | `iPhone19,3` / `iPhone19,7` |
| `.iPadAir11InchM2` | iPad Air 11-inch (M2) | `iPad14,8` / `iPad14,9` |
| `.macMini2024` | Mac mini (2024) | `Mac16,10` / `Mac16,11` |

在代码中用 `DeviceModel.allCases` 枚举全部机型，用 `DeviceModel(identifier:)` 查询硬件标识。完整内容见 [机型枚举](Sources/SwiftUtilityKit/DeviceModel.swift) 和 [标识映射表](Sources/SwiftUtilityKit/Resources/AppleDeviceList.txt)。

### macOS 读取机型

原生 macOS 无需导入 UIKit，调用方式与 iOS 一致：

```swift
import SwiftUtilityKit

// "macOS"
let system = DeviceInfo.systemName
// 获取当前 Mac 机型枚举，例如 .macMini2024
let macModel = DeviceInfo.currentModel
// 例如 "Mac14,7"
let identifier = DeviceInfo.modelIdentifier
// "MacBook Pro (13-inch, M2, 2022)"
let name = DeviceInfo.modelName
```

- macOS 使用 `sysctlbyname("hw.model")` 读取硬件标识，避免将 `arm64` / `x86_64` 当作机型；读取失败时标识与名称均为空字符串。
- 映射包含 Apple Silicon 及部分 Intel 的 MacBook Pro、MacBook Air、MacBook、iMac / iMac Pro、Mac mini、Mac Studio、Mac Pro；未收录的新机型仍返回原始标识。
- 单一标识无法区分的年份、机箱或配置不会被推测：例如 `MacBookPro15,1` 返回 `MacBook Pro (15-inch, 2018-2019)`，Mac Pro 塔式与机架式使用相同名称。
- `DeviceInfo.snapshot()` 也支持 macOS，返回的机型字段与上述接口一致；屏幕信息的适用范围见[设备诊断快照](#设备诊断快照)。
- 资源中收录旧机型不代表降低运行系统要求，macOS 最低版本仍为 14。

### 应用信息

仅依赖 Foundation，macOS SwiftUI 等非 UIKit 项目也可以使用：

```swift
// 优先本地化显示名称，缺失时回退到 CFBundleName
let name = AppInfo.name
// 读取 Bundle 标识
let bundleID = AppInfo.bundleIdentifier
// 读取面向用户的版本号
let version = AppInfo.version
// 读取构建号
let build = AppInfo.build
// 组合版本号与构建号，例如 1.2.3(45)
let fullVersion = AppInfo.versionWithBuild
// AppSnapshot，支持 Codable / Equatable / Sendable
let app = AppInfo.snapshot()
// 也可通过 AppInfo.snapshot(bundle: someBundle) 读取指定 Bundle。
```

字段缺失时返回空字符串；组合版本号会处理版本号或构建号缺失的情况。原有 `DeviceInfo.appVersion`、`appBuild`、`appVersionWithBuild` 保留并转发到 `AppInfo`。

### 设备诊断快照

iOS 等 UIKit 平台及原生 macOS 在主 Actor 上通过 `DeviceInfo.snapshot()` 一次采集系统、机型、应用、屏幕、电池、低电量模式、温度状态和存储信息。watchOS 不提供这个采集入口；macOS / visionOS 的 `screen` 为 `nil`。Mac 的电量和充电状态来自内置电池。

```swift
@MainActor
func exportDeviceDiagnostics() throws -> (json: String, text: String) {
    // 在主 Actor 上采集当前设备信息
    let snapshot = DeviceInfo.snapshot()
    // 同时导出 JSON 和可读文本
    return (try snapshot.jsonString(), snapshot.text)
}
```

`DeviceSnapshot` 是可跨平台传递和解码的 `Codable / Equatable / Sendable` 值类型，采集后不会自动变化。通过 `jsonData()` 或 `jsonString()` 导出，传入 `prettyPrinted: false` 可关闭缩进；时间使用 ISO 8601 字符串（秒精度），缺失的可选值不输出。`text` 生成适合日志和反馈页的本地化文本，也可通过 `text(locale:)` 指定语言和地区。

`screen` 的逻辑尺寸单位为 point，像素尺寸沿用 `bounds × scale`，不等同于所有机型的面板原生分辨率，也不表示当前 SwiftUI 窗口大小。`storage.totalBytes` / `freeBytes` / `usedBytes` 单位为字节，描述沙箱所在文件系统，不是 App 自身占用空间。模拟器上的容量对应模拟器所在文件系统，电量可能未知。

### 电池与设备状态

在主 Actor 上读取一次 Mac 电池快照。

```swift
// 在主 Actor 上采集一次电池快照
let battery = DeviceInfo.batterySnapshot
// 读取 0 到 100 的电量百分比，不可用时为 nil
let percentage = battery.percentage
// 读取可直接显示的状态，例如「已接电，未充电」
let status = battery.stateText
// 检查 Mac 是否接入外部电源
let isPluggedIn = battery.isConnectedToPower
// 检查 Mac 是否正在给内置电池充电
let isCharging = battery.isCharging
```

没有内置电池时，电量和接电标记为 `nil`。Mac 的接电和充电标记分别存放在 `isConnectedToPower` 和 `isCharging`。当两者为 `true` 和 `false` 且系统未报告充满时，`state` 为 `.unknown`，`stateText` 显示「已接电，未充电」对应的本地化标签。需要持续更新时可从 `BatteryMonitor.snapshot` 读取这些值。

#### 在 SwiftUI 中持续监听

```swift
import SwiftUI
import SwiftUtilityKit

@MainActor
struct BatteryStatusView: View {
    // 在当前页面持有电池监听器
    @State private var battery = BatteryMonitor()

    // 展示电量并跟随页面生命周期启停监听
    var body: some View {
        VStack {
            // 显示电量百分比
            Text(battery.batteryPercentageText)
            // 显示当前电池状态
            Text(battery.batteryStateText)
        }
        // 页面出现时开始监听
        .onAppear { battery.start() }
        // 页面消失时停止监听
        .onDisappear { battery.stop() }
        // 在电池或设备状态变化时执行回调
        .onChange(of: battery.snapshot) { _, newValue in
            // 记录新的电池快照
            print("电池 / 设备状态变化：", newValue)
        }
    }
}
```

| API | 说明 |
|---|---|
| `start()` / `stop()` | 启动时立即采样；重复调用安全，停止后清除快照，可再次启动 |
| `isMonitoring` / `snapshot` | 监听状态 / 完整快照，相同快照不重复发布 |
| `batteryLevel` / `batteryPercentage` | 0...1 / 0...100；不可用为 `nil` |
| `batteryPercentageText` | 本地化百分比或未知状态标签 |
| `batteryState` / `batteryStateText` | 电池状态枚举及对应本地化标签 |
| `isLowPowerModeEnabled` | `Bool?`，尚未采样或停止后为 `nil` |
| `thermalState` | 系统报告的温度压力等级 |

`BatteryMonitor` 使用 `@MainActor @Observable`，基于系统通知更新。macOS 通过 IOKit 读取和监听内置电池，iOS / iPadOS 等平台使用 UIKit。watchOS、tvOS 和没有内置电池的 Mac 仍可获取低电量模式和温度状态，电量为 `nil`，充电状态为 `.unknown`。

UIKit 平台上，库内多个监听实例和 `DeviceInfo` 的一次性读取共享电池监控开关，最后一个使用者结束时恢复原有开关状态。全 App 共享时可在根部持有并用 `.environment(battery)` 注入，子视图通过 `@Environment(BatteryMonitor.self)` 读取，由根部统一启停。

#### 电池和温度状态枚举

| `BatteryState` | 电池状态 | `DeviceThermalState` | 温度压力 |
|---|---|---|---|
| `.unknown` | 状态未知 | `.unknown` | 等级未知 |
| `.unplugged` | 未接电 | `.nominal` | 正常 |
| `.charging` | 充电中 | `.fair` | 升高 |
| `.full` | 已充满 | `.serious` | 严重 |
| — | — | `.critical` | 临界 |

### 网络状态监听

`NetworkMonitor` 使用 Observation 的 `@Observable` 宏，不依赖 UIKit 或 Combine。SwiftUI 用 `@State` 持有，读取属性即可响应网络变化：

```swift
import SwiftUI
import SwiftUtilityKit

@MainActor
struct NetworkStatusView: View {
    // 在当前页面持有网络监听器
    @State private var network = NetworkMonitor()

    // 展示连接状态并跟随页面生命周期启停监听
    var body: some View {
        VStack {
            // 显示网络路径是否可用
            Text(connectionText)
            // 显示当前连接类型
            Text(String(describing: network.connectionType))
        }
        // 页面出现时开始监听
        .onAppear { network.start() }
        // 页面消失时停止监听
        .onDisappear { network.stop() }
        // 在网络快照变化时执行回调
        .onChange(of: network.snapshot) { oldValue, newValue in
            // 记录变化前后的网络快照
            print("网络变化：", oldValue, "->", newValue)
        }
    }

    // 生成连接状态文案
    private var connectionText: String {
        // 区分可用、不可用和尚未检测
        switch network.isConnected {
        case true: "网络路径可用"
        case false: "网络路径不可用"
        case nil: "等待检测"
        }
    }
}
```

| API | 说明 |
|---|---|
| `start()` / `stop()` | 启动 / 停止；重复调用安全，停止后可重新启动 |
| `isMonitoring` | 是否正在监听 |
| `snapshot` | 完整状态快照，可用 `.onChange` 监听变化，相同快照不重复发布 |
| `status` | 当前路径状态，类型为 `NetworkStatus` |
| `isConnected` | `Bool?`；未知为 `nil`，可用为 `true`，断开或需要建立连接为 `false` |
| `connectionType` | 当前连接类型，类型为 `NetworkConnectionType` |
| `interfaces` | 可用路径使用的接口集合；多接口时可据此进一步判断 |

`start()` 不会同步返回检测结果；首次回调前以及 `stop()` 后状态均为未知，接口集合为空。网络断开时 `connectionType` 为 `.none`，接口集合也为空，不把仍存在的 Wi-Fi 接口当成可用连接。

`isConnected == true` 只表示系统存在可用网络路径，不保证互联网或业务服务器可访问；不要用它阻止实际请求，请求结果才是服务可达性的依据。本功能不主动发送探测请求。

上面的示例按页面生命周期监听。全 App 共享时，在 App 根部用 `@State` 持有一个实例，通过 `.environment(network)` 注入，子视图用 `@Environment(NetworkMonitor.self)` 读取；由根部统一管理启停，子视图不要调用 `stop()`。所有属性和启停方法均在 `@MainActor` 上访问；UIKit 同样可持有该对象并使用 Observation 观察。

在 SwiftUI 中可直接读取 `network.connectionType`，也可以用 `.onChange(of: network.connectionType)` 处理连接类型变化。

#### 网络状态与连接类型枚举

| `NetworkStatus` | 路径状态 | `NetworkConnectionType` | 连接类型 |
|---|---|---|---|
| `.unknown` | 尚未检测 | `.unknown` | 尚未检测 |
| `.satisfied` | 路径可用 | `.none` | 无可用路径 |
| `.unsatisfied` | 路径不可用 | `.multiple` | 路径可使用多个接口 |
| `.requiresConnection` | 需要先建立连接 | `.wifi` | Wi-Fi |
| — | — | `.cellular` | 蜂窝网络 |
| — | — | `.wiredEthernet` | 有线以太网 |
| — | — | `.other` | 其他 |

`NetworkInterfaceType` 包含表中的四种具体接口类型。连接类型为 `.multiple` 时，可从 `network.interfaces` 读取实际接口集合。

### 设备接口速查

#### DeviceInfo 属性

原生 macOS 可直接使用以下电池属性。屏幕属性依赖 UIKit。

- `DeviceInfo.systemName`：系统名称（如 iOS）
- `DeviceInfo.systemVersion`：系统版本号
- `DeviceInfo.currentModel` 返回当前机型的 `DeviceModel` 枚举，可直接比较或用于 `switch`。
- `DeviceInfo.modelIdentifier`：设备机型标识（如 `iPhone16,2`）
- `DeviceInfo.modelName`：设备机型名称（如 `iPhone 15 Pro Max`）
- `DeviceInfo.appVersion`：App 版本号（`CFBundleShortVersionString`）
- `DeviceInfo.appBuild`：App 构建号（`CFBundleVersion`）
- `DeviceInfo.appVersionWithBuild`：版本号 + 构建号（如 `1.2.3(45)`）
- `DeviceInfo.logicalResolution`：逻辑分辨率（point）
- `DeviceInfo.pixelResolution`：物理分辨率（pixel）
- `DeviceInfo.logicalResolutionText`：逻辑分辨率文本（如 `393x852 pt`）
- `DeviceInfo.pixelResolutionText`：物理分辨率文本（如 `1179x2556 px`）
- `DeviceInfo.screenScale`：屏幕缩放倍数
- `DeviceInfo.nativeScale`：原生缩放倍数
- `DeviceInfo.batterySnapshot` 一次读取电量、充电、低电量模式和温度状态。
- `DeviceInfo.batteryLevel`：电池电量（0...1，不可用时为 `nil`）
- `DeviceInfo.batteryPercentage`：电池百分比（0...100，不可用时为 `nil`）
- `DeviceInfo.batteryPercentageText`：本地化电池百分比或未知状态标签
- `DeviceInfo.batteryState` 返回电池状态。macOS 使用 `BatteryState`，UIKit 平台使用 `UIDevice.BatteryState`。
- `DeviceInfo.batteryStateText` 返回可读状态，macOS 也可显示「已接电，未充电」。
- `DeviceInfo.totalDiskSpace`：设备总容量（字节）
- `DeviceInfo.freeDiskSpace`：设备剩余容量（字节）
- `DeviceInfo.usedDiskSpace`：设备已用容量（字节）
- `DeviceInfo.totalDiskSpaceText`：设备总容量文本（如 `256 GB`）
- `DeviceInfo.freeDiskSpaceText`：设备剩余容量文本（如 `120 GB`）
- `DeviceInfo.usedDiskSpaceText`：设备已用容量文本（如 `136 GB`）

#### UIKit 扩展

- `UIDevice.utilityModel` 返回当前机型的 `DeviceModel`。
- `UIDevice.utilityModelIdentifier`：设备机型标识
- `UIDevice.utilityModelName`：设备机型名称
- `UIScreen.utilityPixelResolution`：屏幕像素分辨率

### 机型映射维护

- 参考来源：[adamawolf 的 Apple mobile device types](https://gist.github.com/adamawolf/3048717#file-apple_mobile_device_types-txt)
- 补充参考：[pluwen/apple-device-model-list](https://github.com/pluwen/apple-device-model-list)（当前主要收录移动设备）；Mac 映射依据 [Apple 官方机型识别入口](https://support.apple.com/en-us/102767)所链接的各系列列表整理，具体来源附在资源文件的 Mac 分区。
- Gist 尚未收录的新机型通过 Xcode 27.2 的 CoreSimulator 设备配置核对；本次 `iPhone19` 系列依据 `profile.plist` 的 `modelIdentifier`、`representedModelIdentifiers` 与设备名称整理。iPhone Duo 商品名称也可见 [Apple 官网](https://www.apple.com/iphone-duo/)。
- 机型映射独立维护在：`Sources/SwiftUtilityKit/Resources/AppleDeviceList.txt`
- 文件格式为 `identifier|name|case`，每行一条，`#` 开头为注释。`case` 对应 `DeviceModel` 的枚举成员。同款新增硬件标识时复用已有成员，新商品机型需同时添加成员和映射。

## 错误与本地化

### `ConversionError`

带 `throws` 的转换在失败时抛出错误，由调用方决定提示、重试或回退。以下调用省略了前面的 `try`。

| 错误 | 何时触发 | 会失败的调用 |
|---|---|---|
| `.invalidNumber(String)` | 数字文本为空，或无法解析为十进制数 | `"abc".convertLength(from: .meter, to: .kilometer)` |
| `.invalidBase(Int)` | 源进制或目标进制超出 2–36 | `"10".convertRadix(from: 1, to: 10)` |
| `.invalidRadixValue(String, base: Int)` | 进制合法，但文本含无效数字，或数值无法用 `Int64` 表示 | `"102".convertRadix(from: 2, to: 10)` |
| `.overflow` | 整数无法转换为目标 API 所需的 `Int64` 或 `Int` | `UInt64.max.convertRadix(to: 16)` |
| `.invalidChineseNumeral(String)` | 中文数字或金额大写无法解析 | `"你好".chineseUppercaseToDecimal()` |
| `.invalidColor(String)` | 颜色格式不受支持、通道超出范围，或平台颜色无法转为 RGBA | `ColorRGBA.parse("#GG0000")` |
| `.invalidDate(String)` | 日期文本不符合指定格式，或所有候选格式均解析失败 | `"not-a-date".date(.date)` |
| `.invalidCoordinate(String)` | 缺少坐标字段、无法解析数值，或经纬度越界 | `"91,121".coordinate()` |
| `.invalidMoneyUnit(currency: String, unit: String)` | 源单位或目标单位不受所选币种支持 | `"100".convertMoney(from: .major, to: .minor, currency: .jpy)` |
| `.inexactCNYAmount` | 金额包含分以下的尾数 | 对 `Decimal(1) / 1000` 调用 `splitCNY(rounding: .exact)` |

### 处理转换错误

```swift
import Foundation
import SwiftUtilityKit

do {
    // 模拟表单收到无法解析的输入
    let kilometers = try "abc".convertLength(from: .meter, to: .kilometer)
    // 转换成功时使用计算结果
    print(kilometers)
} catch ConversionError.invalidNumber {
    // 捕获无效数字，在表单中提示用户重新输入
    print("请输入有效数字，例如 12.5。")
} catch {
    // 其他错误使用库提供的可读描述
    print(error.localizedDescription)
}
```

需要区分失败原因时，按枚举值匹配。只需要可选结果时可用 `try?`，抛出的错误会变成 `nil`。`isValidEmail` 一类校验用 `false` 表示无效输入，`bmi` 用 `nil` 表示无法计算。这两类调用无需 `try`。

### 单位名称与地区格式

SDK 按系统首选语言顺序选择基础文案，未匹配时使用美式英语。支持简体中文（`zh-Hans`）、美式英语（`en`）、英式英语（`en-GB`）、法语（`fr`）和俄语（`ru`）。传入 `zh` 或 `zh_CN` 也能匹配简体中文资源。

| 内容 | 默认行为和自定义方式 |
|---|---|
| 单位名和电池状态标签 | `localizedName()` 跟随系统语言。App 有独立语言设置时可传 `locale:`。 |
| 转换错误描述 | `localizedDescription` 跟随系统语言。`ConversionError` 支持 `localizedDescription(locale:)`。 |
| 电池与诊断文本 | `BatterySnapshot.stateText`、`percentageText` 和 `DeviceSnapshot.text` 跟随系统设置，也可调用对应的 `locale:` 方法。 |
| 金额展示 | `MoneyConversion.format`、`formattedMoney` 和 `convertMoneyString` 默认使用 `Locale.current` 的地区格式，可传 `locale:`。 |
| 日期解析与固定格式 | `DateKit` 使用文档中的默认上下文，或通过 `in:` 指定。按用户地区习惯展示日期时，可用 Foundation 的 `Date.formatted(date:time:)`。 |

```swift
import Foundation
import SwiftUtilityKit

let unitName = LengthUnit.meter.localizedName()
let britishName = LengthUnit.meter.localizedName(locale: Locale(identifier: "en_GB"))
let amount = Decimal(12345) / 100
let frenchAmount = amount.formattedMoney(scale: 2, locale: Locale(identifier: "fr_FR")) // 123,45
```

### 配置 App 多语言

App 可以直接读取数值和枚举，将完整句子放进自己的 `Localizable.xcstrings`，让各语言分别处理语序和复数。例如 SDK 返回公里数，App 负责显示「还剩 1.5 公里」。

```swift
let kilometers = ValueConversion.length(1_500, from: .meter, to: .kilometer)
let distance = kilometers.formatted()
let message = String(localized: "Remaining distance: \(distance) km")
```

SDK 译文集中在 [Localization/Localizable.xcstrings](./Localization/Localizable.xcstrings)。修改后在安装了 Xcode 的 macOS 上运行 `./Scripts/update-localizations.sh`，并随译文一起更新生成的资源。运行 `./Scripts/update-localizations.sh --check` 可检查资源是否同步。
