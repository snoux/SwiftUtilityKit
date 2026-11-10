# SwiftUtilityKit

[中文](./README.md) | [English](./README_EN.md) | [Auto Language (GitHub Pages)](./docs/index.html)

A Swift utility toolkit for daily conversions.
- Default date context: `zh_CN + Asia/Shanghai + Gregorian`
- Covers units, date/time, money, percentage, colors, string validation/formatting, device diagnostics and app info, network and battery monitoring

## Contents

- [Installation](#installation)
- [Unit conversion and BMI](#unit-conversion-and-bmi)
- [Money and number formatting](#money-and-number-formatting)
- [Date and time](#date-and-time)
- [String utilities](#string-utilities)
- [Color conversion](#color-conversion)
- [Coordinate conversion](#coordinate-conversion)
- [Device and system status](#device-and-system-status)
  - [Models](#read-the-current-model) · [Diagnostics](#device-diagnostic-snapshots) · [Battery](#battery-and-power-status) · [Network](#network-monitoring)
- [Errors and localization](#errors-and-localization)
  - [Error triggers](#conversionerror) · [Handle conversion errors](#handle-conversion-errors) · [Localize your app](#localize-your-app)

## Installation

Description: Add the SDK via Swift Package Manager.

Requires Swift 6.2+ and iOS / iPadOS 17, macOS 14, tvOS 17, watchOS 10, or visionOS 1 and later.

[GitHub repository](https://github.com/snoux/SwiftUtilityKit)

```swift
// Import SDK in source file
import SwiftUtilityKit
```

- Watch here: [SwiftUtilityKit Demo Video](https://github.com/snoux/SwiftUtilityKit/releases/download/1.0.0/demo.mp4)

## Unit conversion and BMI

These conversion extensions accept `String`, `BinaryInteger`, `BinaryFloatingPoint`, and `Decimal` and return `Decimal`. String overloads throw on parse failure. You can also pass a numeric value to `ValueConversion`. See also [Duration conversion and comparison](#duration-conversion-and-comparison).

| Task | Unit enum | API | Base or result unit |
|---|---|---|---|
| [Length conversion](#length-conversion) | `LengthUnit` | `convertLength(from:to:)` | m |
| [Weight conversion](#weight-conversion) | `WeightUnit` | `convertWeight(from:to:)` | kg |
| [Area conversion](#area-conversion) | `AreaUnit` | `convertArea(from:to:)` | m² |
| [Volume conversion](#volume-conversion) | `VolumeUnit` | `convertVolume(from:to:)` | L |
| [Temperature conversion](#temperature-conversion) | `TemperatureUnit` | `convertTemperature(from:to:)` | °C |
| [Speed conversion](#speed-conversion) | `SpeedUnit` | `convertSpeed(from:to:)` | m/s |
| [BMI](#bmi) | `WeightUnit` + `LengthUnit` | `ValueConversion.bmi` | kg/m² |

### Length conversion

```swift
// Convert 2 nautical miles to 3,704 meters
let meters = 2.convertLength(from: .nauticalMile, to: .meter)
```

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.picometer` | picometer (pm) | `.nanometer` | nanometer (nm) |
| `.micrometer` | micrometer (μm) | `.millimeter` | millimeter (mm) |
| `.centimeter` | centimeter (cm) | `.decimeter` | decimeter (dm) |
| `.meter` | meter (m) | `.kilometer` | kilometer (km) |
| `.nauticalMile` | nautical mile (nmi) | `.mile` | mile (mi) |
| `.furlong` | furlong (fur) | `.yard` | yard (yd) |
| `.foot` | foot (ft) | `.inch` | inch (in) |
| `.li` | li | `.zhang` | zhang |
| `.chi` | chi | `.cun` | cun |
| `.fen` | fen | `.liSmall` | li (small) |
| `.hao` | hao | `.lightYear` | light year (ly) |

### Weight conversion

```swift
// Convert 120 Chinese jin to 60 kilograms
let kilograms = 120.convertWeight(from: .jin, to: .kilogram)
```

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.microgram` | microgram (μg) | `.milligram` | milligram (mg) |
| `.gram` | gram (g) | `.kilogram` | kilogram (kg) |
| `.ton` | ton (t) | `.ounce` | ounce (oz) |
| `.pound` | pound (lb) | `.stone` | stone (st) |
| `.jin` | jin | `.liang` | liang |
| `.qian` | qian | `.dan` | dan (Chinese weight unit) |

### Area conversion

```swift
// Read 1 qing from a string and convert it to 100 mu
let mu = try "1".convertArea(from: .qing, to: .mu)
```

One Chinese qing equals 100 mu. One hectare equals 15 mu. [Chinese land units](https://tjj.hubei.gov.cn/tjsj/sjkscx/tjnj/gsztj/snjlq/201911/P020250327358525034898.pdf)

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.squareMillimeter` | square millimeter (mm²) | `.squareCentimeter` | square centimeter (cm²) |
| `.squareDecimeter` | square decimeter (dm²) | `.squareMeter` | square meter (m²) |
| `.squareKilometer` | square kilometer (km²) | `.hectare` | hectare (ha) |
| `.acre` | acre (ac) | `.squareFoot` | square foot (ft²) |
| `.squareInch` | square inch (in²) | `.mu` | mu |
| `.qing` | qing (Chinese land unit) | `.are` | are (a) |
| `.squareYard` | square yard (yd²) | `.squareMile` | square mile (mi²) |

### Volume conversion

```swift
// Convert 1 cubic decimeter to 1,000 milliliters
let milliliters = 1.convertVolume(from: .cubicDecimeter, to: .milliliter)
```

One cm³ equals one mL, and one dm³ equals one L. Teaspoons, tablespoons, cups, pints, and gallons use US liquid measures.

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.milliliter` | milliliter (mL) | `.liter` | liter (L) |
| `.cubicMeter` | cubic meter (m³) | `.teaspoon` | teaspoon (tsp) |
| `.tablespoon` | tablespoon (tbsp) | `.cup` | cup (cup) |
| `.pint` | pint (pt) | `.gallon` | gallon (gal) |
| `.cubicCentimeter` | cubic centimeter (cm³) | `.cubicInch` | cubic inch (in³) |
| `.microliter` | microliter (μL) | `.cubicMillimeter` | cubic millimeter (mm³) |
| `.cubicDecimeter` | cubic decimeter (dm³) | `.cubicFoot` | cubic foot (ft³) |
| `.cubicYard` | cubic yard (yd³) | — | — |

### Temperature conversion

```swift
// Convert 0°C to 273.15 K
let kelvin = 0.convertTemperature(from: .celsius, to: .kelvin)
```

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.celsius` | Celsius (°C) | `.fahrenheit` | Fahrenheit (°F) |
| `.kelvin` | Kelvin (K) | — | — |

### Speed conversion

```swift
// Convert Mach 2 to 686 m/s at the default sound speed
let speed = 2.convertSpeed(from: .mach, to: .meterPerSecond)
// Convert Mach 2 to 660 m/s using a local sound speed of 330 m/s
let localSpeed = ValueConversion.speed(2, from: .mach, to: .meterPerSecond, soundSpeedInMetersPerSecond: 330)
// Convert one vacuum light speed to 299,792,458 m/s
let light = 1.convertSpeed(from: .speedOfLight, to: .meterPerSecond)
```

`knot` means nautical miles per hour. `.mach` and `.speedOfSound` default to approximately 343 m/s in air at 20°C. Pass `soundSpeedInMetersPerSecond` for a known local reference. Vacuum light speed is 299,792,458 m/s. [NASA sound speed reference](https://ntrs.nasa.gov/api/citations/20160000818/downloads/20160000818.pdf) · [BIPM definition of the meter](https://www.bipm.org/en/si-base-units/metre)

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.meterPerSecond` | meter per second (m/s) | `.kilometerPerHour` | kilometer per hour (km/h) |
| `.milePerHour` | mile per hour (mph) | `.knot` | knot (kn) |
| `.footPerSecond` | foot per second (ft/s) | `.inchPerSecond` | inch per second (in/s) |
| `.kilometerPerSecond` | kilometer per second (km/s) | `.nauticalMilePerSecond` | nautical mile per second (nmi/s) |
| `.speedOfLight` | speed of light in vacuum (c) | `.speedOfSound` | speed of sound in air at 20°C |
| `.mach` | Mach | — | — |

### BMI

```swift
// Calculate BMI for 64 kg and 160 cm and get 25
let bmi = ValueConversion.bmi(weight: 64, height: 160, heightUnit: .centimeter)
```

`bmi` defaults to kilograms and meters and also accepts `WeightUnit` and `LengthUnit`. It returns `nil` for nonpositive or nonfinite measurements and results outside the supported numeric range. [CDC BMI formula](https://www.cdc.gov/growth-chart-training/hcp/using-bmi/body-mass-index.html)

## Money and number formatting

### Money conversion and formatting

```swift
import Foundation
import SwiftUtilityKit

// CNY yuan -> fen = 1234
let fen = try "12.34".convertMoney(from: .major, to: .minor, currency: .cny)
// Split into 12 yuan, 3 jiao, and 4 fen
let parts = MoneyConversion.splitCNY(12.34)
// Combine the parts back into 12.34 yuan
let yuan = parts.toDecimalYuan()
// Grouped money text -> 1,234,567.80
let text = try "1234567.8".formattedMoney(scale: 2, useGrouping: true, locale: Locale(identifier: "en_US"))
```

Amounts use Foundation's `Decimal` for decimal arithmetic. Conversion changes units within a currency, such as CNY yuan to fen. The currency determines which units are supported.

#### Enums and types

##### `CurrencyCode`

| Case | Meaning | Case | Meaning |
|---|---|---|---|
| `.cny` | Chinese Yuan | `.usd` | US Dollar |
| `.eur` | Euro | `.gbp` | British Pound |
| `.jpy` | Japanese Yen | — | — |

##### `MoneyUnit`

| Case | Meaning | Case | Meaning |
|---|---|---|---|
| `.major` | major unit (yuan/dollar) | `.tenth` | tenth unit (jiao) |
| `.minor` | minor unit (fen/cent) | — | — |

`.jpy` supports `.major` only. CNY, USD, EUR, and GBP accept the three unit levels in the table.

##### `CNYParts`

`CNYParts` exposes `yuan`, `jiao`, `fen`, and `isNegative`. The whole-yuan component remains signed and the jiao and fen from a split are each in the range 0–9. Read `isNegative` when displaying the sign separately. For example, the whole-yuan component of `-0.34` is zero, and `toDecimalYuan()` reconstructs `-0.34`.

| `CNYRounding` | Result for `12.346` yuan |
|---|---|
| `.round` | 12 yuan, 3 jiao, and 5 fen. The no-argument `splitCNY()` uses this policy. |
| `.truncate` | 12 yuan, 3 jiao, and 4 fen. Discards digits beyond fen, toward zero. |
| `.exact` | Throws `ConversionError.inexactCNYAmount`. The amount must be representable as a whole number of fen. |

```swift
let amount = Decimal(string: "12.346")!
let truncated = try amount.splitCNY(rounding: .truncate)
let negative = try MoneyConversion.splitCNY(Decimal(string: "-0.34")!, rounding: .exact)
let yuan = negative.toDecimalYuan() // -0.34
```

Use the throwing overload for unvalidated values. It reports `.invalidNumber` for NaN and `.overflow` if the whole-yuan component after rounding cannot fit in `Int`.

#### Choose an API by task

| Task | Static call | Call on an existing value | Result |
|---|---|---|---|
| Convert units for further calculation | `MoneyConversion.convert(_:from:to:currency:)` takes a `Decimal` | `amount.convertMoney(from:to:currency:)` | `Decimal`, such as 12.34 yuan → 1234 fen |
| Convert units for display | Call `convert` then `format` | `amount.convertMoneyString(from:to:currency:scale:useGrouping:locale:)` | `String` with configurable decimal places and grouping |
| Format an amount for display | `MoneyConversion.format(_:scale:useGrouping:locale:)` takes a `Decimal` and an optional locale | `amount.formattedMoney(scale:useGrouping:locale:)` | `String` such as `1,234.50` in the original unit |
| Split into yuan, jiao, and fen | `MoneyConversion.splitCNY(_:)` or `splitCNY(_:rounding:)` | `decimalAmount.splitCNY()` or `splitCNY(rounding:)` | `CNYParts` with separate components and sign |
| Combine yuan, jiao, and fen | `MoneyConversion.mergeCNY(_:)` takes the complete `CNYParts` | `parts.toDecimalYuan()` | `Decimal` in yuan |

In the first three rows, `amount` can be a `String`, `Decimal`, integer, or floating-point value. String parsing failures throw `.invalidNumber`. A conversion with a unit the currency cannot represent throws `.invalidMoneyUnit`. For regional formatting, see [Unit names and regional formatting](#unit-names-and-regional-formatting).

```swift
import Foundation
import SwiftUtilityKit

// Start with a Decimal amount in yuan
let decimalAmount = Decimal(1234) / 100
// Convert to fen and keep a Decimal for further calculations
let amountInFen = try decimalAmount.convertMoney(from: .major, to: .minor)
// Read the jiao field for display, which is 3
let jiao = decimalAmount.splitCNY().jiao
// Convert to fen and display it with two decimal places as "1,234.00"
let display = try decimalAmount.convertMoneyString(from: .major, to: .minor, scale: 2, useGrouping: true, locale: Locale(identifier: "en_US"))
```

### Percentages and ratios

```swift
// Percent 12.5 -> ratio 0.125
let ratio = try "12.5".percentToRatio()
// Convert 0.125 back to the percentage 12.5
let percent = ratio.ratioToPercent()
```

| Input | API | Result and purpose |
|---|---|---|
| `Decimal` | `PercentageConversion.percentToRatio(_:)` / `ratioToPercent(_:)` | Divide or multiply by 100, respectively, and return a `Decimal` for further calculations |
| `String`, `Decimal`, integer, or floating-point value | `percentToRatio()` / `ratioToPercent()` | Call directly on the value to get a `Decimal`. Pass numeric text such as `"12.5"`. A string parsing failure throws `.invalidNumber` |
| `String` | `percentToRatioString(scale:)` / `ratioToPercentString(scale:)` | Return the converted number as text, optionally rounded to `scale` decimal places |
| Ratio as a `Decimal` | `asPercentString(scale:)` | Multiply by 100 and return numeric text such as `"12.5"` for `0.125`. Add the percent sign in your UI as needed |

### Chinese uppercase numerals and radix

```swift
// Write 123.45 as uppercase numerals 壹佰贰拾叁点肆伍
let number = try "123.45".toChineseUppercaseNumber()
// Write 123.45 yuan as 壹佰贰拾叁元肆角伍分
let amount = try "123.45".toChineseUppercaseCurrency()
// Parse the uppercase amount back to 123.45
let decimal = try amount.chineseUppercaseToDecimal()
// Convert decimal 255 to hexadecimal "FF"
let hexadecimal = try "255".convertRadix(from: 10, to: 16)
```

- `toChineseUppercaseNumber()` and `toChineseUppercaseCurrency()` accept strings, integers, floating-point values, and `Decimal`.
- `String.chineseUppercaseToDecimal()` parses Chinese numerals or uppercase currency text as `Decimal`.
- `String.convertRadix(from:to:uppercase:)` and the integer method `convertRadix(to:uppercase:)` support bases 2 through 36.

## Date and time

### Common examples

Date examples use the default context `zh_CN + Asia/Shanghai + Gregorian`.

#### Date format conversion

```swift
// Auto-detect input and output as yyyy/MM/dd HH:mm
let out = try "2026-03-10 08:00:00".dateString(to: .dateMinuteSlash)
```

#### Common Date extensions

```swift
// Parse Date
let d = try "2026-03-10 12:34:56".date(.dateTime)
// Start of day 00:00:00
let start = d.startOfDay()
// End of day 23:59:59
let end = d.endOfDay()
// Add 7 days
let plus7 = d.adding(7, .day)
// Check if same calendar day
let sameDay = d.isSameDay(as: Date())
```

#### Check if yesterday (String call)

```swift
// Parse reference time
let ref = try "2026-03-10 12:00:00".date(.dateTime)
// Check if target string date is yesterday relative to ref
let ok = try "2026-03-09 12:00:00".isYesterday(ref: ref)
```

#### Check if yesterday (Date call)

```swift
// Parse reference Date
let ref = try "2026-03-10 12:00:00".date(.dateTime)
// Parse target Date
let target = try "2026-03-09 12:00:00".date(.dateTime)
// Use Date extension directly
let ok = target.isYesterday(ref: ref)
```

#### Check within last 7 days

```swift
// Reference Date
let ref = try "2026-03-10 12:00:00".date(.dateTime)
// Parse a date and time, then check whether it is within 7 days before ref
let in7 = try "2026-03-05 12:00:00".relative(.dateTime, to: ref).withinPast(7, .day)
```

#### Range check

```swift
// Check if target is inside range
let inRange = try "2026-03-10 08:00:00".isBetween("2026-03-10 07:00:00", and: "2026-03-10 09:00:00", format: "yyyy-MM-dd HH:mm:ss")
```

#### Timestamp conversion

```swift
// Date string -> second timestamp
let ts = try "2026-03-10 08:00:00".timestamp(.dateTime)
// Timestamp string -> date string
let text = try "1704067200".dateStringFromTimestamp(unit: .second, format: "yyyy-MM-dd HH:mm:ss")
```

### Date context and formats

`DateKit.Context` supplies a locale, time zone, and calendar. Text parsing and formatting use the locale and time zone, while calendar comparisons use the calendar. Choose a format string or `DateKit.Pattern` for the text layout. See the [custom date context example](#unit-names-and-regional-formatting).

#### Context (`DateKit.Context`)

| API | Description |
|---|---|
| `DateKit.defaultContext` | Default context (`zh_CN + Asia/Shanghai + Gregorian`) |
| `DateKit.Context.cn` | Explicitly use Simplified Chinese, Shanghai time, and the Gregorian calendar |
| `DateKit.Context(locale:timeZone:calendar:)` | Customize these settings and pass the context with `in:` |

#### Pattern enum (`DateKit.Pattern`)

| Case | Format | Description | Example |
|---|---|---|---|
| `.dateTime` | `yyyy-MM-dd HH:mm:ss` | Common second-level datetime | `2026-03-10 08:00:00` |
| `.dateTimeSlash` | `yyyy/MM/dd HH:mm:ss` | Slash second-level datetime | `2026/03/10 08:00:00` |
| `.dateMinute` | `yyyy-MM-dd HH:mm` | Minute-level datetime | `2026-03-10 08:00` |
| `.dateMinuteSlash` | `yyyy/MM/dd HH:mm` | Slash minute-level datetime | `2026/03/10 08:00` |
| `.date` | `yyyy-MM-dd` | Hyphen date | `2026-03-10` |
| `.dateSlash` | `yyyy/MM/dd` | Slash date | `2026/03/10` |
| `.compactDateTime` | `yyyyMMddHHmmss` | Compact datetime | `20260310080000` |
| `.compactDate` | `yyyyMMdd` | Compact date | `20260310` |
| `.iso8601` | `yyyy-MM-dd'T'HH:mm:ssZ` | ISO8601 second-level | `2026-03-10T08:00:00+0800` |
| `.iso8601Millis` | `yyyy-MM-dd'T'HH:mm:ss.SSSZ` | ISO8601 millisecond | `2026-03-10T08:00:00.000+0800` |

Helpers:
- `DateKit.commonDatePatterns` provides the default list of patterns in parsing order.
- `DateKit.commonDateFormats` provides the same list as format strings.

### Date APIs for strings

Description: Main date API for both explicit format and auto-detection usage.

#### Parse

| API | Use and result |
|---|---|
| `date(_ format: String)` / `date(_ pattern: DateKit.Pattern)` | Parse a known format or built-in pattern into a `Date` |
| `date(_ formats: [String])` / `date(_ patterns: [DateKit.Pattern])` | Try candidate formats in order and return the first `Date` that parses |
| `date(patterns:)` | Auto-detect using the common patterns by default. Throws `.invalidDate` if none match |

#### Format convert

| API | Use and result |
|---|---|
| `dateString(from:to:)` | Parse with the specified source format and return text in the destination format. Accepts format strings or patterns |
| `dateString(to:inputFormats:)` / `dateString(to:inputPatterns:)` | Try the candidate input formats in order and return text in the requested output format |

#### Compare + distance

| API | Result |
|---|---|
| `dateCompare(with:format:)` | Chronological order as a `ComparisonResult` after parsing both inputs |
| `dateDistance(to:format:unit:)` | The elapsed difference `other - self` in the requested unit |

#### Timestamp

| API | Use and result |
|---|---|
| `timestamp(_ format: String, unit:)` / `timestamp(_ pattern: DateKit.Pattern, unit:)` | Parse a known date format and return epoch seconds or milliseconds as a `Decimal` |
| `timestamp(unit:patterns:)` | Try candidate date patterns and return a numeric timestamp |
| `timestampString(_ format: String, unit:scale:)` | Return the timestamp as numeric text with optional rounding |
| `dateStringFromTimestamp(unit:format:)` | Read a timestamp string in the specified unit and return formatted date text |
| `convertTimestamp(from:to:scale:)` | Convert a timestamp string between seconds and milliseconds, returning text |

#### Relative + range

| API | Use and result |
|---|---|
| `relative(_ format: String, to:)` / `relative(_ pattern: DateKit.Pattern, to:)` / `relative(to:patterns:)` | Parse the input and bind it to a reference date in a `DateRelativeProxy` |
| `isBetween(_:and:format:inclusive:)` | Check whether the date falls within the given bounds, optionally including endpoints |
| `isYesterday(_ format:ref:)` / `isToday(_ format:ref:)` / `isTomorrow(_ format:ref:)` | Parse the given format and check whether the input falls on the corresponding calendar day |
| `isYesterday(ref:patterns:)` / `isToday(ref:patterns:)` / `isTomorrow(ref:patterns:)` | Perform the same day checks with automatic format detection |
| `isDayBeforeYesterday(_ format:ref:)`, `isLastWeek(_ format:ref:)`, `isNextWeek(_ format:ref:)`, `isLastYear(_ format:ref:)`, `isNextYear(_ format:ref:)` | Parse the given format and check the corresponding calendar period relative to the reference date |

### Date extensions

| Task | API | Result |
|---|---|---|
| Format or export a date | `formatted(_:)` / `timestamp(unit:)` | Date text or a numeric timestamp |
| Find day, week, or month boundaries | `startOfDay()` / `endOfDay()`, `startOfWeek()` / `endOfWeek()`, `startOfMonth()` / `endOfMonth()` | Start or last second of the period in the date context |
| Offset a date | `adding(_:_:)` | `Date?`. Pass a positive value to add time or a negative value to subtract it |
| Compare calendar days | `isSameDay(as:)` / `isWeekend()` / `days(to:)` | Same-day or weekend flag, or the signed difference in calendar days |
| Check bounds | `isInRange(from:to:inclusive:)` / `isBetween(_:and:inclusive:)` | Whether the date lies within two endpoints |
| Compare to a reference date | `isDayBeforeYesterday(ref:)`, `isYesterday(ref:)`, `isToday(ref:)`, `isTomorrow(ref:)`, `isLastWeek(ref:)`, `isNextWeek(ref:)`, `isLastYear(ref:)`, `isNextYear(ref:)` | Whether the date falls in the corresponding calendar period |
| Check a lookback window | `isWithinPast(_:_:ref:in:inclusive:)` | Whether the date is between the reference and the requested time before it |
| Reuse a comparison context | `relative(to:)` | A `DateRelativeProxy` bound to the target and reference dates |
| Read a timestamp | `Date.fromTimestamp(_:unit:)` | A `Date` from epoch seconds or milliseconds |

`DateRelativeProxy` keeps the target date, reference date, and context together so a list can label records as today, yesterday, or last week. Use `matches(_:)` with a [relative date tag](#dateconversionrelativedatetag) chosen at runtime. Use `withinPast(_:_:inclusive:)` to check a window. For example, `withinPast(7, .day)` includes both the reference and the boundary seven days earlier by default. Both methods return `Bool`.

### Timestamp APIs

Use these extensions when the timestamp is already an integer, floating-point number, or `Decimal`.

| API | Result |
|---|---|
| `convertTimestamp(from:to:)` | A `Decimal` timestamp in seconds or milliseconds |
| `toDate(unit:)` | A `Date` interpreted in the supplied unit, which defaults to seconds |

### Duration conversion and comparison

```swift
// Convert 2 hours to 120 minutes
let minutes = 2.convertTime(from: .hour, to: .minute)
// Compare 2 hours with 90 minutes and get .orderedDescending
let comparison = 2.compareTime(with: 90, selfUnit: .hour, otherUnit: .minute)
// Subtract 30 minutes from 2 hours and get 90 minutes
let difference = 30.timeDifference(to: 2, selfUnit: .minute, otherUnit: .hour, resultUnit: .minute)
```

`String`, `BinaryInteger`, `BinaryFloatingPoint`, and `Decimal` provide the following extensions. String overloads throw on parse failure.

- `convertTime(from:to:)` converts durations.
- `compareTime(with:selfUnit:otherUnit:)` compares durations.
- `timeDifference(to:selfUnit:otherUnit:resultUnit:)` returns the difference (`other - self`).

#### `TimeUnit`

| Case | Unit (symbol) | Case | Unit (symbol) |
|---|---|---|---|
| `.nanosecond` | nanosecond (ns) | `.microsecond` | microsecond (μs) |
| `.millisecond` | millisecond (ms) | `.second` | second (s) |
| `.minute` | minute (min) | `.hour` | hour (h) |
| `.day` | day (d) | `.week` | week (wk) |

### Date enums

#### `DateConversion.TimestampUnit`

| Case | Meaning | Case | Meaning |
|---|---|---|---|
| `.second` | second-level timestamp (e.g. `1704067200`) | `.millisecond` | millisecond-level timestamp (e.g. `1704067200000`) |

#### `DateConversion.DateDifferenceUnit`

| Case | Meaning | Case | Meaning |
|---|---|---|---|
| `.second` | output difference in seconds | `.minute` | output difference in minutes |
| `.hour` | output difference in hours | `.day` | output difference in days (24h) |

#### `DateConversion.RelativeDateTag`

| Case | Meaning | Case | Meaning |
|---|---|---|---|
| `.dayBeforeYesterday` | day before yesterday | `.yesterday` | yesterday |
| `.today` | today | `.tomorrow` | tomorrow |
| `.lastWeek` | last week | `.nextWeek` | next week |
| `.lastYear` | last year | `.nextYear` | next year |

## String utilities

### String cleanup and encoding

```swift
// Check whether the string is blank after trimming
let blank = " \n ".isBlank
// URL encode
let encoded = "a b&c=1".urlEncoded()
// URL decode
let decoded = "a%20b%26c%3D1".urlDecoded()
// Base64 encode
let b64 = "SwiftUtilityKit".base64Encoded()
// Base64 decode
let raw = "U3dpZnRVdGlsaXR5S2l0".base64Decoded()
```

| API | Result |
|---|---|
| `trimmed()` | Remove leading and trailing whitespace and newlines |
| `removingWhitespacesAndNewlines()` | Remove whitespace and newlines throughout the string |
| `isIntegerNumber` / `isDecimalNumber` | Whether the trimmed input parses as `Int` or `Decimal`, respectively |
| `digitsOnly()` | Keep only numeric characters |
| `formattedWithGrouping(maximumFractionDigits:minimumFractionDigits:)` | Format numeric text with grouping and configurable fraction digits |
| `safeSubstring(start:length:)` | A substring at a zero-based character offset, or `nil` for an invalid range |
| `isBlank` / `nilIfBlank()` | Test for blank input, or return the trimmed input with blank values represented by `nil` |
| `urlEncoded()` / `urlDecoded()` | Percent-encode or decode, returning the original text if the operation fails |
| `base64Encoded()` / `base64Decoded()` | Convert between UTF-8 text and Base64, with `nil` on failure |

### Validation, formatting, and masking

Description: Input validation + display masking/formatting.

```swift
// Validate Mainland China mobile number format
let phoneOK = "13800138000".isValidChineseMobile
// Validate email format
let emailOK = "demo@example.com".isValidEmail
// Validate URL format
let urlOK = "https://example.com/path?a=1".isValidURL
// Validate IPv6 address format
let ipv6OK = "2408:8400:9800:31d3:4ff7:f6d2:69f8:77b3".isValidIPv6
// Validate bank card number (Luhn)
let cardOK = "4111111111111111".isValidBankCardNumber
// Validate China ID card number (with checksum)
let idOK = "11010519491231002X".isValidChineseIDCard

// Format bank card as grouped text
let cardText = "6222021234567890123".formattedBankCardNumber()
// Format mobile as XXX-XXXX-XXXX
let phoneText = "13800138000".formattedChineseMobile()
// Mask mobile as XXX****XXXX
let phoneMask = "13800138000".maskedChineseMobile()
// Mask ID card as first 6 + **** + last 4
let idMask = "11010519491231002X".maskedChineseIDCard()
```

#### Validation

These properties return `Bool` and are useful for checking input before submission.

| API | Rule |
|---|---|
| `isValidChineseMobile` | Mainland China mobile number with 11 digits starting with 13–19 |
| `isValidURL` | Text format for `http`, `https`, or `ftp` URLs |
| `isValidEmail` | Email address format |
| `isValidIPv6` | The system IPv6 parser accepts the address |
| `isValidBankCardNumber` | 12–19 digits with a valid Luhn checksum |
| `isValidChineseIDCard` | 18-character ID structure, birth date, and checksum |

#### Formatting/masking

| API | Output and fallback |
|---|---|
| `formattedBankCardNumber(separator:)` | Extract digits and group them in fours using `-` by default. Returns an empty string when there are no digits |
| `formattedChineseMobile(separator:)` | Group 11 digits as 3–4–4 with `-` by default. Returns the input unchanged for other digit counts |
| `maskedChineseMobile(mask:)` | Keep the first 3 and last 4 of 11 digits with `****` by default. Returns the input unchanged for other digit counts |
| `maskedChineseIDCard(mask:)` | Keep the first 6 and last 4 characters with `****` by default. Returns the input unchanged if it has fewer than 10 characters after trimming |

## Color conversion

```swift
// Normalize color string to hex
let hex = try "rgba(255,102,0,0.5)".normalizedColorHex(includeAlpha: true)
```

Description: Convert among color string/int/hex and platform color types.

### `ColorRGBA`

| Input or task | API | Result |
|---|---|---|
| Integer channel values | `init(red:green:blue:alpha:)` | Create a color from channels in 0–255. Alpha defaults to 255 |
| Parse color text | `parse(_:)`, `fromHex(_:)`, `fromRGBString(_:)` | Convert `#`-prefixed 3-, 4-, 6-, or 8-digit hex, `rgb(...)`, or `rgba(...)` to `ColorRGBA` |
| Parse a packed integer | `fromPackedInt(_:hasAlpha:)` | Read `0xRRGGBB` by default or `0xRRGGBBAA` with `hasAlpha: true` |
| Store or send a color | `hexString(includeAlpha:prefixHash:)`, `packedInt(includeAlpha:)` | Return hexadecimal text or a packed integer. Pass `includeAlpha: true` to preserve alpha |

### Call on a string or integer

| Input | API | Result |
|---|---|---|
| Color text | `toColorRGBA()`, `normalizedColorHex(includeAlpha:prefixHash:)`, `colorToPackedInt(includeAlpha:)` | Return the channel values, normalized hex, or packed integer, respectively |
| Color text | `toCGColor()`, `toUIColor()`, `toSwiftUIColor()` | Return a platform color. `UIColor` requires UIKit |
| Packed integer | `toColorRGBA(hasAlpha:)`, `toColorHex(hasAlpha:prefixHash:)` | Decode to channels or hex text. `hasAlpha` indicates whether the input ends in an alpha byte |

### Color factories
- `colorRGBA(_:)`: create `ColorRGBA` directly from string
- `cgColor(_:) / cgcolor(_:)`: create `CGColor` directly from string
- `uiColor(_:) / uicolor(_:)`: create `UIColor` directly from string (UIKit)
- `swiftUIColor(_:)`: create `SwiftUI.Color` directly from string

### Platform bridge

| Task | API | Details |
|---|---|---|
| Build `ColorRGBA` from floating-point channels | The `CGFloat` overload of `ColorRGBA.init(red:green:blue:alpha:)` | Supply channels in 0–1 to get integer channels in 0–255 |
| Convert `ColorRGBA` to a platform color | `cgColor`, `uiColor`, `swiftUIColor` | Read the property for CoreGraphics, UIKit, or SwiftUI, respectively |
| Convert a platform color to `ColorRGBA` | `ColorRGBA.init(cgColor:)`, `ColorRGBA.init(uiColor:)`, `UIColor.toColorRGBA()`, `Color.toColorRGBA()` | Read the result's RGBA channels. The final method requires SwiftUI and UIKit |
| Create a `UIColor` directly | `UIColor.init(_:)`, `init(hex:)`, `init(rgbString:)`, `init(colorString:)` | Pass `ColorRGBA`, hex text, RGB text, or any supported color text, respectively |

## Coordinate conversion

```swift
// String -> coordinate (default latitude,longitude)
let c = try "31.2304,121.4737".coordinate()
// Coordinate -> string (longitude,latitude)
let text = c.string(order: .longitudeLatitude, fractionDigits: 6)
// Coordinate -> dictionary: ["latitude":..., "longitude":...]
let dict = c.dictionary()
```

Description: On CoreLocation-capable platforms, supports bidirectional conversion among coordinate/string/tuple/dictionary.

### Enum

| Case | Meaning | Case | Meaning |
|---|---|---|---|
| `CoordinateOrder.latitudeLongitude` | `latitude,longitude` | `CoordinateOrder.longitudeLatitude` | `longitude,latitude` |

### Create, validate, and export coordinates

| Task | API | Input or result |
|---|---|---|
| Parse coordinate text | `CLLocationCoordinate2D.parse(_:separator:order:)` or `String.coordinate(separator:order:)` | Reads comma-separated latitude and longitude by default. Throws `.invalidCoordinate` for invalid or out-of-range input |
| Create from a tuple or dictionary | `CLLocationCoordinate2D.make(_:order:)`, `make(from:)` | Takes two `Double` values or a dictionary with keys such as `latitude` and `longitude` |
| Check an existing coordinate | `isValidCoordinate` | `true` if latitude is within −90 to 90, longitude within −180 to 180, and system validation passes |
| Serialize as text or a tuple | `string(order:separator:fractionDigits:)`, `tuple(order:)` | Output in the requested order. Text also accepts a separator and a decimal-place count |
| Export a dictionary | `dictionary()` | A `[String: Double]` with fixed `latitude` and `longitude` keys |
| Correct swapped fields | `swappedLatLon()` | A coordinate with latitude and longitude exchanged. Check it with `isValidCoordinate` |

## Device and system status

Description: Native macOS 14+ and UIKit platforms except watchOS support system, model, app, storage, and diagnostic snapshot APIs. Screen properties require UIKit and are unavailable on visionOS. Battery level and charging state are available on macOS and UIKit platforms except tvOS. `AppInfo` also provides cross-platform app metadata.

### Read device information

```swift
// Get system version
let sys = DeviceInfo.systemVersion
// Get human-readable device model name
let model = DeviceInfo.modelName
// Get app version + build
let app = DeviceInfo.appVersionWithBuild
#if canImport(UIKit) && !os(visionOS)
// Get physical screen resolution in pixels
let px = DeviceInfo.pixelResolutionText
#endif
#if os(macOS) || (canImport(UIKit) && !os(tvOS) && !os(watchOS))
// Get battery percentage text
let battery = DeviceInfo.batteryPercentageText
#endif
// Get total device storage text
let total = DeviceInfo.totalDiskSpaceText
// Get free device storage text
let free = DeviceInfo.freeDiskSpaceText
// Get used device storage text
let used = DeviceInfo.usedDiskSpaceText
```

### Read the current model

```swift
import SwiftUtilityKit

// "iPhone19,4" on iPhone Duo
let identifier = DeviceInfo.modelIdentifier
// "iPhone Duo" on iPhone Duo
let name = DeviceInfo.modelName

// Check whether the current model is iPhone Duo
if DeviceInfo.currentModel == .iPhoneDuo {
    // Handle iPhone Duo-specific behavior.
}

// Optional("iPhone Duo")
let duoName = DeviceModel.iPhoneDuo.displayName
// ["iPhone19,4"]
let duoIdentifiers = DeviceModel.iPhoneDuo.identifiers
// Resolve a saved hardware identifier to .iPhoneDuo
let knownModel = DeviceModel(identifier: "iPhone19,4")
// List every model case, including .unknown and .simulator
let supportedModels = DeviceModel.allCases
```

Use `DeviceModel(identifier:)` to look up a hardware identifier. Variants of the same product share a case. For example, `iPhone19,3` and `iPhone19,7` both resolve to `.iPhone18ProMax`. Unlisted devices return `.unknown`, with the original identifier available through `DeviceInfo.modelIdentifier`. Simulators return the emulated model when known and `.simulator` when only a recognized simulator architecture is available.

Read the typed model from a diagnostic snapshot with `snapshot.model`. Previously saved JSON decodes and resolves the case from its stored identifier.

The equivalent UIKit extensions are also available:

```swift
import UIKit
import SwiftUtilityKit

@MainActor
func printDeviceModel() {
    // Print the hardware identifier
    print(UIDevice.current.utilityModelIdentifier)
    // Print the model name
    print(UIDevice.current.utilityModelName)
}
```

- Hardware identifier numbers do not match product generations: `iPhone18,1` means iPhone 17 Pro.
- The iPhone mapping includes `iPhone18,1` through `iPhone18,5`: iPhone 17 Pro, iPhone 17 Pro Max, iPhone 17, iPhone Air, and iPhone 17e. The resource also includes iPad and iPod models.
- Newer mappings include iPhone 18 Pro (`iPhone19,2`), iPhone 18 Pro Max (`iPhone19,3` / `iPhone19,7`), and iPhone Duo (`iPhone19,4`). Both Pro Max identifiers return the same product name.
- Simulators prefer `SIMULATOR_MODEL_IDENTIFIER` and wrap the name, e.g. `Simulator (iPhone Duo)`.
- Unknown devices return the raw identifier; simulators return `Simulator (raw identifier)`.
- Model reading is available on native macOS and UIKit platforms except watchOS. See [Read Mac models](#read-mac-models) for examples and mapping coverage.

#### Selected models

| Case | Display name | Hardware identifiers |
|---|---|---|
| `.iPhoneDuo` | iPhone Duo | `iPhone19,4` |
| `.iPhone18ProMax` | iPhone 18 Pro Max | `iPhone19,3` / `iPhone19,7` |
| `.iPadAir11InchM2` | iPad Air 11-inch (M2) | `iPad14,8` / `iPad14,9` |
| `.macMini2024` | Mac mini (2024) | `Mac16,10` / `Mac16,11` |

Use `DeviceModel.allCases` to enumerate models and `DeviceModel(identifier:)` to look up hardware identifiers. See the [model enum](Sources/SwiftUtilityKit/DeviceModel.swift) and [identifier map](Sources/SwiftUtilityKit/Resources/AppleDeviceList.txt) for the full lists.

### Read Mac models

Native macOS uses the same API without importing UIKit:

```swift
import SwiftUtilityKit

// "macOS"
let system = DeviceInfo.systemName
// Read the Mac model case, such as .macMini2024
let macModel = DeviceInfo.currentModel
// e.g. "Mac14,7"
let identifier = DeviceInfo.modelIdentifier
// "MacBook Pro (13-inch, M2, 2022)"
let name = DeviceInfo.modelName
```

- macOS reads `hw.model` through `sysctlbyname`, rather than returning the `arm64` / `x86_64` CPU architecture. A failed read returns an empty identifier and name.
- The map covers Apple Silicon and selected Intel MacBook Pro, MacBook Air, MacBook, iMac / iMac Pro, Mac mini, Mac Studio, and Mac Pro models. Unknown models return their raw identifiers.
- Shared identifiers retain year ranges or omit details that cannot be distinguished. For example, `MacBookPro15,1` returns `MacBook Pro (15-inch, 2018-2019)`; tower and rack Mac Pro variants share a name.
- `DeviceInfo.snapshot()` also collects Mac model information. See [Device diagnostic snapshots](#device-diagnostic-snapshots) for screen availability.
- Legacy entries do not lower the minimum supported macOS version, which remains 14.

### App information

Only Foundation is required, including in macOS SwiftUI projects:

```swift
// Localized display name, falling back to CFBundleName
let name = AppInfo.name
// Read the bundle identifier
let bundleID = AppInfo.bundleIdentifier
// Read the user-facing version
let version = AppInfo.version
// Read the build number
let build = AppInfo.build
// Combine the version and build, for example 1.2.3(45)
let fullVersion = AppInfo.versionWithBuild
// AppSnapshot: Codable / Equatable / Sendable
let app = AppInfo.snapshot()
// Use AppInfo.snapshot(bundle: someBundle) to read another bundle.
```

Missing fields produce empty strings; combined version formatting handles a missing version or build. Existing `DeviceInfo.appVersion`, `appBuild`, and `appVersionWithBuild` remain available and forward to `AppInfo`.

### Device diagnostic snapshots

On native macOS and UIKit platforms that support `DeviceInfo`, including iOS, call `DeviceInfo.snapshot()` on the main actor to collect system, model, app, screen, battery, power mode, thermal, and storage information. This collection entry point is unavailable on watchOS. macOS and visionOS return `nil` for `screen`. macOS reports level and charging state for its internal battery.

```swift
@MainActor
func exportDeviceDiagnostics() throws -> (json: String, text: String) {
    // Capture device information on the main actor
    let snapshot = DeviceInfo.snapshot()
    // Export both JSON and readable text
    return (try snapshot.jsonString(), snapshot.text)
}
```

`DeviceSnapshot` is a `Codable / Equatable / Sendable` value that can be transferred and decoded across platforms. It does not update after capture. Export using `jsonData()` or `jsonString()`; pass `prettyPrinted: false` for compact JSON. Timestamps use ISO 8601 strings with second precision; unavailable optional fields are omitted. `text` provides a localized diagnostic summary for logs and feedback pages. Pass a `Locale` to `text(locale:)` to choose the display language and region.

Screen dimensions use points and `bounds × scale` pixels; the latter is not necessarily the native panel resolution and is not the current SwiftUI window size. `storage.totalBytes` / `freeBytes` / `usedBytes` describe the sandbox's file system in bytes, not the app's own disk usage. Simulator storage describes its host file system and battery values may be unavailable.

### Battery and power status

Read a Mac battery snapshot on the main actor.

```swift
// Capture one battery snapshot on the main actor
let battery = DeviceInfo.batterySnapshot
// Read battery percentage from 0 to 100, or nil when unavailable
let percentage = battery.percentage
// Read display text, such as plugged in without charging
let status = battery.stateText
// Check whether the Mac is connected to external power
let isPluggedIn = battery.isConnectedToPower
// Check whether the Mac is charging its internal battery
let isCharging = battery.isCharging
```

Without an internal battery, level and connection information are `nil`. macOS reports power connection and active charging through `isConnectedToPower` and `isCharging`. If those values are `true` and `false` and the system has not reported a full battery, `state` is `.unknown` and `stateText` displays the localized label for “Plugged in, not charging”. Read `BatteryMonitor.snapshot` for live updates.

#### Observe changes in SwiftUI

```swift
import SwiftUI
import SwiftUtilityKit

@MainActor
struct BatteryStatusView: View {
    // Keep the battery monitor for this view
    @State private var battery = BatteryMonitor()

    // Show battery status and monitor it while the view is visible
    var body: some View {
        VStack {
            // Show battery percentage
            Text(battery.batteryPercentageText)
            // Show the current battery state
            Text(battery.batteryStateText)
        }
        // Start monitoring when the view appears
        .onAppear { battery.start() }
        // Stop monitoring when the view disappears
        .onDisappear { battery.stop() }
        // Handle battery or device state changes
        .onChange(of: battery.snapshot) { _, newValue in
            // Log the updated battery snapshot
            print("Battery / device state changed:", newValue)
        }
    }
}
```

| API | Description |
|---|---|
| `start()` / `stop()` | Start samples immediately; calls are idempotent; stop clears state and allows restarting |
| `isMonitoring` / `snapshot` | Monitoring flag / complete state; identical snapshots are suppressed |
| `batteryLevel` / `batteryPercentage` | 0...1 / 0...100, or `nil` when unavailable |
| `batteryPercentageText` | Localized percentage or unknown label |
| `batteryState` / `batteryStateText` | Battery state enum and Chinese display text |
| `isLowPowerModeEnabled` | `Bool?`, `nil` before sampling and after stopping |
| `thermalState` | System-reported thermal pressure |

`BatteryMonitor` uses `@MainActor @Observable` and system notifications. It reads and monitors the Mac's internal battery through IOKit. iOS and iPadOS use UIKit. watchOS, tvOS, and Macs without an internal battery still report power mode and thermal state, with `nil` for battery level and `.unknown` for charging state.

On UIKit platforms, multiple monitors and one-shot `DeviceInfo` reads share the battery-monitoring flag; the last user restores its original state. For app-wide sharing, own an instance at the root, inject with `.environment(battery)`, and read with `@Environment(BatteryMonitor.self)`. Manage start / stop at the root.

#### Battery and thermal state enums

| `BatteryState` | Battery status | `DeviceThermalState` | Thermal pressure |
|---|---|---|---|
| `.unknown` | State unavailable | `.unknown` | Level unavailable |
| `.unplugged` | Unplugged | `.nominal` | Nominal |
| `.charging` | Charging | `.fair` | Elevated |
| `.full` | Fully charged | `.serious` | Serious |
| — | — | `.critical` | Critical |

### Network monitoring

`NetworkMonitor` uses Observation's `@Observable` macro without UIKit or Combine. Own it with `@State`; reading its properties makes the view react to network changes:

```swift
import SwiftUI
import SwiftUtilityKit

@MainActor
struct NetworkStatusView: View {
    // Keep the network monitor for this view
    @State private var network = NetworkMonitor()

    // Show connection status and monitor it while the view is visible
    var body: some View {
        VStack {
            // Show whether a network path is available
            Text(connectionText)
            // Show the current connection type
            Text(String(describing: network.connectionType))
        }
        // Start monitoring when the view appears
        .onAppear { network.start() }
        // Stop monitoring when the view disappears
        .onDisappear { network.stop() }
        // Handle network snapshot changes
        .onChange(of: network.snapshot) { oldValue, newValue in
            // Log the previous and new network snapshots
            print("Network changed:", oldValue, "->", newValue)
        }
    }

    // Provide a display label for the current connection state
    private var connectionText: String {
        // Distinguish available, unavailable, and pending states
        switch network.isConnected {
        case true: "Network path available"
        case false: "Network path unavailable"
        case nil: "Waiting for detection"
        }
    }
}
```

| API | Description |
|---|---|
| `start()` / `stop()` | Start / stop; repeated calls are safe and restarting is supported |
| `isMonitoring` | Whether monitoring is running |
| `snapshot` | Complete state; observe with `.onChange`, identical snapshots are suppressed |
| `status` | Current path state, represented by `NetworkStatus` |
| `isConnected` | `Bool?`: `nil` when unknown, `true` when satisfied, otherwise `false` |
| `connectionType` | Current connection type, represented by `NetworkConnectionType` |
| `interfaces` | Interface types used by the available path, including simultaneous interfaces |

`start()` does not synchronously return a result. Before the first callback and after `stop()`, state is unknown and interfaces are empty. Disconnected paths report `.none` and no interfaces, even if a Wi-Fi interface still exists.

`isConnected == true` only indicates an available system network path, not guaranteed internet or server access. Do not block requests based on this value; actual request results determine service reachability. The monitor sends no probe requests.

The example owns monitoring at the page level. For app-wide sharing, own one instance with `@State` at the app root, inject it with `.environment(network)`, and read it with `@Environment(NetworkMonitor.self)`. Manage start / stop at the root; child views should not call `stop()`. All properties and lifecycle methods are `@MainActor`-isolated. UIKit can also own the object and observe it through Observation.

Read `network.connectionType` in SwiftUI or handle changes with `.onChange(of: network.connectionType)`.

#### Network state and interface enums

| `NetworkStatus` | Path state | `NetworkConnectionType` | Connection type |
|---|---|---|---|
| `.unknown` | Pending detection | `.unknown` | Pending detection |
| `.satisfied` | Path available | `.none` | No available path |
| `.unsatisfied` | Path unavailable | `.multiple` | Multiple available interfaces |
| `.requiresConnection` | Connection required | `.wifi` | Wi-Fi |
| — | — | `.cellular` | Cellular |
| — | — | `.wiredEthernet` | Wired Ethernet |
| — | — | `.other` | Other |

`NetworkInterfaceType` contains the four concrete interface types in the table. When the connection type is `.multiple`, read `network.interfaces` for the set of interfaces.

### Device API reference

#### DeviceInfo properties

Native macOS supports the battery properties below. The screen properties require UIKit.

- `DeviceInfo.systemName`: system name (e.g. iOS)
- `DeviceInfo.systemVersion`: system version
- `DeviceInfo.currentModel` returns the current `DeviceModel` for equality comparisons and `switch` statements.
- `DeviceInfo.modelIdentifier`: model identifier (e.g. `iPhone16,2`)
- `DeviceInfo.modelName`: model display name (e.g. `iPhone 15 Pro Max`)
- `DeviceInfo.appVersion`: app version (`CFBundleShortVersionString`)
- `DeviceInfo.appBuild`: app build number (`CFBundleVersion`)
- `DeviceInfo.appVersionWithBuild`: version + build (e.g. `1.2.3(45)`)
- `DeviceInfo.logicalResolution`: logical resolution in points
- `DeviceInfo.pixelResolution`: physical resolution in pixels
- `DeviceInfo.logicalResolutionText`: logical resolution text (e.g. `393x852 pt`)
- `DeviceInfo.pixelResolutionText`: physical resolution text (e.g. `1179x2556 px`)
- `DeviceInfo.screenScale`: screen scale
- `DeviceInfo.nativeScale`: native screen scale
- `DeviceInfo.batterySnapshot` reads level, charging, power mode, and thermal information in one call.
- `DeviceInfo.batteryLevel`: battery level (0...1, `nil` if unavailable)
- `DeviceInfo.batteryPercentage`: battery percentage (0...100, `nil` if unavailable)
- `DeviceInfo.batteryPercentageText`: localized battery percentage or unknown label
- `DeviceInfo.batteryState` returns `BatteryState` on macOS and `UIDevice.BatteryState` on UIKit platforms.
- `DeviceInfo.batteryStateText` returns display text and distinguishes plugged in without charging on macOS.
- `DeviceInfo.totalDiskSpace`: total device storage in bytes
- `DeviceInfo.freeDiskSpace`: free device storage in bytes
- `DeviceInfo.usedDiskSpace`: used device storage in bytes
- `DeviceInfo.totalDiskSpaceText`: total storage text (e.g. `256 GB`)
- `DeviceInfo.freeDiskSpaceText`: free storage text (e.g. `120 GB`)
- `DeviceInfo.usedDiskSpaceText`: used storage text (e.g. `136 GB`)

#### UIKit extensions

- `UIDevice.utilityModel` returns the current `DeviceModel`.
- `UIDevice.utilityModelIdentifier`: device model identifier
- `UIDevice.utilityModelName`: device model display name
- `UIScreen.utilityPixelResolution`: screen physical resolution in pixels

### Device map maintenance

- Source for mobile mappings: [adamawolf's Apple mobile device types](https://gist.github.com/adamawolf/3048717#file-apple_mobile_device_types-txt)
- Additional reference: [pluwen/apple-device-model-list](https://github.com/pluwen/apple-device-model-list), currently focused on mobile devices. Mac mappings use the family lists linked from [Apple's Mac identification guide](https://support.apple.com/en-us/102767); per-family sources are recorded in the resource's Mac section.
- Device mapping file: `Sources/SwiftUtilityKit/Resources/AppleDeviceList.txt`
- Use `identifier|name|case`, one record per line, with `#` for comments. Reuse the existing `DeviceModel` case for new variants and add a case for each new product model.
- If no mapping is found, SDK falls back to raw model identifier

New models missing from the Gist are checked against Xcode 27.2 CoreSimulator device profiles. The `iPhone19` entries use the device names and the `modelIdentifier` / `representedModelIdentifiers` fields in `profile.plist`. Apple also lists the [iPhone Duo product name](https://www.apple.com/iphone-duo/).

## Errors and localization

### `ConversionError`

Throwing conversion APIs pass failures back to the caller, which can display a message, retry, or use a fallback. The table omits the leading `try` from each call.

| Error | When it occurs | Example that fails |
|---|---|---|
| `.invalidNumber(String)` | Numeric text is empty or cannot be parsed as a decimal number | `"abc".convertLength(from: .meter, to: .kilometer)` |
| `.invalidBase(Int)` | The source or destination base is outside 2–36 | `"10".convertRadix(from: 1, to: 10)` |
| `.invalidRadixValue(String, base: Int)` | The base is valid, but the text contains an invalid digit or its value does not fit in `Int64` | `"102".convertRadix(from: 2, to: 10)` |
| `.overflow` | An integer does not fit in the `Int64` or `Int` required by the API | `UInt64.max.convertRadix(to: 16)` |
| `.invalidChineseNumeral(String)` | Chinese numeral or uppercase amount text cannot be parsed | `"你好".chineseUppercaseToDecimal()` |
| `.invalidColor(String)` | The format or channel values are invalid, or the platform color cannot be converted to RGBA | `ColorRGBA.parse("#GG0000")` |
| `.invalidDate(String)` | The text does not parse with the given format or any of the candidate formats | `"not-a-date".date(.date)` |
| `.invalidCoordinate(String)` | A coordinate field is missing, a value cannot be parsed, or latitude or longitude is out of range | `"91,121".coordinate()` |
| `.invalidMoneyUnit(currency: String, unit: String)` | The selected currency does not support the source or destination unit | `"100".convertMoney(from: .major, to: .minor, currency: .jpy)` |
| `.inexactCNYAmount` | The amount includes a fraction of a fen | `Decimal(1) / 1000` with `splitCNY(rounding: .exact)` |

### Handle conversion errors

```swift
import Foundation
import SwiftUtilityKit

do {
    // Simulate invalid input from a form
    let kilometers = try "abc".convertLength(from: .meter, to: .kilometer)
    // Use the result when conversion succeeds
    print(kilometers)
} catch ConversionError.invalidNumber {
    // Ask the user to correct the input
    print("Enter a valid number, such as 12.5.")
} catch {
    // Use the library's readable description for other errors
    print(error.localizedDescription)
}
```

Match the error case when the response depends on the cause. Use `try?` when you only need an optional result. It turns any thrown error into `nil`. Validation APIs such as `isValidEmail` return `false` for invalid input, and `bmi` returns `nil` when it cannot compute a result. Both are nonthrowing.

### Unit names and regional formatting

SDK display text selects the first supported language in the system preference list and falls back to American English. The catalog includes Simplified Chinese (`zh-Hans`), American English (`en`), British English (`en-GB`), French (`fr`), and Russian (`ru`). You can also pass `zh` or `zh_CN` to select the Simplified Chinese resources.

| Content | Default and override |
|---|---|
| Unit and battery labels | `localizedName()` follows the system language. Pass `locale:` for an in-app language choice. |
| Conversion error descriptions | `localizedDescription` follows the system language. A `ConversionError` also accepts `localizedDescription(locale:)`. |
| Battery and diagnostic text | `BatterySnapshot.stateText`, `percentageText`, and `DeviceSnapshot.text` use system preferences. Each has a `locale:` override. |
| Amount formatting | `MoneyConversion.format`, `formattedMoney`, and `convertMoneyString` use `Locale.current`. Pass `locale:` to use a different regional format. |
| Date parsing and fixed patterns | `DateKit` uses its documented default context or an explicit `in:` context. For a date shown in the user's regional format, use Foundation's `Date.formatted(date:time:)`. |

```swift
import Foundation
import SwiftUtilityKit

let unitName = LengthUnit.meter.localizedName()
let britishName = LengthUnit.meter.localizedName(locale: Locale(identifier: "en_GB"))
let amount = Decimal(12345) / 100
let frenchAmount = amount.formattedMoney(scale: 2, locale: Locale(identifier: "fr_FR")) // 123,45
```

### Localize your app

Read the numeric or typed result when the app owns the wording. Keep the full sentence in your app's `Localizable.xcstrings` so its translators can control word order and plural forms.

```swift
let kilometers = ValueConversion.length(1_500, from: .meter, to: .kilometer)
let distance = kilometers.formatted()
let message = String(localized: "Remaining distance: \(distance) km")
```

The package maintains its translations in [Localization/Localizable.xcstrings](./Localization/Localizable.xcstrings). After editing it, run `./Scripts/update-localizations.sh` on macOS with Xcode and include the generated resources in the change. Run `./Scripts/update-localizations.sh --check` to verify that the packaged strings are current.
