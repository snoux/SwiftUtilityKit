# SwiftUtilityKit

[中文](./README.md) | [English](./README_EN.md) | [Auto Language (GitHub Pages)](./docs/index.html)

A Swift utility toolkit for daily conversions (Chinese-first defaults):
- Default date context: `zh_CN + Asia/Shanghai + Gregorian`
- Covers units, date/time, money, percentage, colors, string validation/formatting, device and app info

## Demo Video

- Watch here: [SwiftUtilityKit Demo Video](https://github.com/snoux/SwiftUtilityKit/releases/download/1.0.0/demo.mp4)

---

## 1. Installation (SPM)

Description: Add the SDK via Swift Package Manager.

```swift
https://github.com/snoux/SwiftUtilityKit
```


```swift
import SwiftUtilityKit // Import SDK in source file
```

---

## 2. Simplest Scenario Calls

Note: All examples use default context (no `in: cn` passed).

### 2.1 Date format conversion

```swift
let out = try "2026-03-10 08:00:00".dateString(to: .dateMinuteSlash) // Auto-detect input and output as yyyy/MM/dd HH:mm
```

### 2.2 Check if yesterday (String call)

```swift
let ref = try "2026-03-10 12:00:00".date(.dateTime) // Parse reference time
let ok = try "2026-03-09 12:00:00".isYesterday(ref: ref) // Check if target string date is yesterday relative to ref
```

### 2.3 Check if yesterday (Date call)

```swift
let ref = try "2026-03-10 12:00:00".date(.dateTime) // Parse reference Date
let target = try "2026-03-09 12:00:00".date(.dateTime) // Parse target Date
let ok = target.isYesterday(ref: ref) // Use Date extension directly
```

### 2.4 Check within last 7 days

```swift
let ref = try "2026-03-10 12:00:00".date(.dateTime) // Reference Date
let in7 = try "2026-03-05 12:00:00".relative(to: ref).withinPast(7, .day) // Check if target is within 7 days before ref
```

### 2.5 Range check

```swift
let inRange = try "2026-03-10 08:00:00".isBetween("2026-03-10 07:00:00", and: "2026-03-10 09:00:00", format: "yyyy-MM-dd HH:mm:ss") // Check if target is inside range
```

### 2.6 Timestamp conversion

```swift
let ts = try "2026-03-10 08:00:00".timestamp(.dateTime) // Date string -> second timestamp
let text = try "1704067200".dateStringFromTimestamp(unit: .second, format: "yyyy-MM-dd HH:mm:ss") // Timestamp string -> date string
```

### 2.7 Money conversion

```swift
let fen = try "12.34".convertMoney(from: .major, to: .minor, currency: .cny) // CNY yuan -> fen = 1234
let text = try "1234567.8".formattedMoney(scale: 2, useGrouping: true) // Grouped money text -> 1,234,567.80
```

### 2.8 Percentage conversion

```swift
let ratio = try "12.5".percentToRatio() // Percent 12.5 -> ratio 0.125
```

### 2.9 Color conversion

```swift
let hex = try "rgba(255,102,0,0.5)".normalizedColorHex(includeAlpha: true) // Normalize color string to hex
```

### 2.10 String validation

```swift
let phoneOK = "13800138000".isValidChineseMobile // Validate Mainland China mobile number
let emailOK = "demo@example.com".isValidEmail // Validate email
```

### 2.11 Common String extensions

```swift
let blank = " \n ".isBlank // Check whether the string is blank after trimming
let encoded = "a b&c=1".urlEncoded() // URL encode
let decoded = "a%20b%26c%3D1".urlDecoded() // URL decode
let b64 = "SwiftUtilityKit".base64Encoded() // Base64 encode
let raw = "U3dpZnRVdGlsaXR5S2l0".base64Decoded() // Base64 decode
```

### 2.12 Common Date extensions

```swift
let d = try "2026-03-10 12:34:56".date(.dateTime) // Parse Date
let start = d.startOfDay() // Start of day 00:00:00
let end = d.endOfDay() // End of day 23:59:59
let plus7 = d.adding(7, .day) // Add 7 days
let sameDay = d.isSameDay(as: Date()) // Check if same calendar day
```

### 2.13 Device and app info

```swift
let sys = DeviceInfo.systemVersion // Get system version
let model = DeviceInfo.modelName // Get human-readable device model name
let app = DeviceInfo.appVersionWithBuild // Get app version + build
let px = DeviceInfo.pixelResolutionText // Get physical screen resolution in pixels
let battery = DeviceInfo.batteryPercentageText // Get battery percentage text
let total = DeviceInfo.totalDiskSpaceText // Get total device storage text
let free = DeviceInfo.freeDiskSpaceText // Get free device storage text
let used = DeviceInfo.usedDiskSpaceText // Get used device storage text
```

### 2.14 Coordinate conversion (`CLLocationCoordinate2D`)

```swift
let c = try "31.2304,121.4737".coordinate() // String -> coordinate (default latitude,longitude)
let text = c.string(order: .longitudeLatitude, fractionDigits: 6) // Coordinate -> string (longitude,latitude)
let dict = c.dictionary() // Coordinate -> dictionary: ["latitude":..., "longitude":...]
```

---

## 3. DateKit (Context + Date Patterns)

Description: DateKit centralizes locale/timezone/calendar and date format patterns.

### 3.1 Context (`DateKit.Context`)

| API | Description |
|---|---|
| `DateKit.defaultContext` | Default context (`zh_CN + Asia/Shanghai + Gregorian`) |
| `DateKit.Context.cn` | Chinese preset context |
| `DateKit.Context(locale:timeZone:calendar:)` | Custom context |

### 3.2 Pattern enum (`DateKit.Pattern`)

| case | Format | Description |
|---|---|---|
| `dateTime` | `yyyy-MM-dd HH:mm:ss` | Common second-level datetime |
| `dateTimeSlash` | `yyyy/MM/dd HH:mm:ss` | Slash second-level datetime |
| `dateMinute` | `yyyy-MM-dd HH:mm` | Minute-level datetime |
| `dateMinuteSlash` | `yyyy/MM/dd HH:mm` | Slash minute-level datetime |
| `date` | `yyyy-MM-dd` | Hyphen date |
| `dateSlash` | `yyyy/MM/dd` | Slash date |
| `compactDateTime` | `yyyyMMddHHmmss` | Compact datetime |
| `compactDate` | `yyyyMMdd` | Compact date |
| `iso8601` | `yyyy-MM-dd'T'HH:mm:ssZ` | ISO8601 second-level |
| `iso8601Millis` | `yyyy-MM-dd'T'HH:mm:ss.SSSZ` | ISO8601 millisecond |

Helpers:
- `DateKit.commonDatePatterns`
- `DateKit.commonDateFormats`

---

## 4. String: Unit + Basic Conversion (`String+Conversion.swift`)

Description: Best when your input values are strings.

- `convertLength(from:to:)`: length conversion
- `convertWeight(from:to:)`: weight conversion
- `convertArea(from:to:)`: area conversion
- `convertVolume(from:to:)`: volume conversion
- `convertTime(from:to:)`: time conversion
- `compareTime(with:selfUnit:otherUnit:)`: compare time values
- `timeDifference(to:selfUnit:otherUnit:resultUnit:)`: time difference (`other - self`)
- `convertTemperature(from:to:)`: temperature conversion
- `convertSpeed(from:to:)`: speed conversion
- `convertRadix(from:to:uppercase:)`: radix conversion (2...36)
- `toChineseUppercaseNumber()`: number -> Chinese uppercase number
- `toChineseUppercaseCurrency()`: number -> Chinese uppercase currency text
- `chineseUppercaseToDecimal()`: Chinese uppercase -> decimal
- `toColorRGBA()`: color string -> RGBA
- `normalizedColorHex(includeAlpha:prefixHash:)`: color string -> normalized hex
- `colorToPackedInt(includeAlpha:)`: color string -> packed int

---

## 5. String: Date DSL (`String+Utility.swift`)

Description: Main date API for both explicit format and auto-detection usage.

### 5.1 Parse
- `date(_ format: String)`
- `date(_ pattern: DateKit.Pattern)`
- `date(_ formats: [String])`
- `date(_ patterns: [DateKit.Pattern])`
- `date(patterns:)`

### 5.2 Format convert
- `dateString(from:to:)` (String formats)
- `dateString(from:to:)` (Pattern formats)
- `dateString(to:inputFormats:)`
- `dateString(to:inputPatterns:)`

### 5.3 Compare + distance
- `dateCompare(with:format:)`
- `dateDistance(to:format:unit:)`

### 5.4 Timestamp
- `timestamp(_ format: String, unit:)`
- `timestamp(_ pattern: DateKit.Pattern, unit:)`
- `timestamp(unit:patterns:)`
- `timestampString(_ format: String, unit:scale:)`
- `dateStringFromTimestamp(unit:format:)`
- `convertTimestamp(from:to:scale:)`

### 5.5 Relative + range
Note: `relative(...)` returns `DateRelativeProxy` (not Bool). It stores `target + reference`, then you read semantic flags like `.isYesterday`.

- `relative(_ format: String, to:)`
- `relative(_ pattern: DateKit.Pattern, to:)`
- `relative(to:patterns:)`
- `isBetween(_:and:format:inclusive:)`
- `isYesterday(_ format:ref:)`
- `isYesterday(ref:patterns:)`
- `isToday(_ format:ref:)`
- `isToday(ref:patterns:)`
- `isTomorrow(_ format:ref:)`
- `isTomorrow(ref:patterns:)`
- `isDayBeforeYesterday(_ format:ref:)`
- `isLastWeek(_ format:ref:)`
- `isNextWeek(_ format:ref:)`
- `isLastYear(_ format:ref:)`
- `isNextYear(_ format:ref:)`

### 5.6 String utilities
- `trimmed()`
- `removingWhitespacesAndNewlines()`
- `isIntegerNumber`
- `isDecimalNumber`
- `digitsOnly()`
- `formattedWithGrouping(maximumFractionDigits:minimumFractionDigits:)`
- `safeSubstring(start:length:)`
- `isBlank`
- `nilIfBlank()`
- `urlEncoded()`
- `urlDecoded()`
- `base64Encoded()`
- `base64Decoded()`
- `coordinate(separator:order:)`

---

## 6. Date Semantic Extensions (`Date+Utility.swift`)

Description: Preferred API for business logic when you already have `Date`.

- `formatted(_:)`
- `timestamp(unit:)`
- `relative(to:) -> DateRelativeProxy`
- `startOfDay()`
- `endOfDay()`
- `startOfWeek()`
- `endOfWeek()`
- `startOfMonth()`
- `endOfMonth()`
- `adding(_:_:)`
- `isSameDay(as:)`
- `isWeekend()`
- `days(to:)`
- `isInRange(from:to:inclusive:)`
- `isBetween(_:and:inclusive:)`
- `isDayBeforeYesterday(ref:)`
- `isYesterday(ref:)`
- `isToday(ref:)`
- `isTomorrow(ref:)`
- `isLastWeek(ref:)`
- `isNextWeek(ref:)`
- `isLastYear(ref:)`
- `isNextYear(ref:)`
- `isWithinPast(_:_:,ref:inclusive:)`
- `Date.fromTimestamp(_:unit:)`

`DateRelativeProxy`:
- properties: `isDayBeforeYesterday / isYesterday / isToday / isTomorrow / isLastWeek / isNextWeek / isLastYear / isNextYear`
- method: `matches(_:)`
- method: `withinPast(_:_:,inclusive:)`

---

## 7. Timestamp Numeric Extensions (`Timestamp+Conversion.swift`)

Description: Use directly when timestamp is already numeric.

For `BinaryInteger / BinaryFloatingPoint / Decimal`:
- `convertTimestamp(from:to:)`
- `toDate(unit:)`

---

## 8. Money Conversion (`MoneyConversion.swift` + `Money+Conversion.swift`)

Description: Same-currency unit conversion only (no FX). Uses `Decimal` for precision.

### 8.1 Enums and types

#### `CurrencyCode`
- `cny`: Chinese Yuan
- `usd`: US Dollar
- `eur`: Euro
- `gbp`: British Pound
- `jpy`: Japanese Yen

#### `MoneyUnit`
- `major`: major unit (yuan/dollar)
- `tenth`: tenth unit (jiao)
- `minor`: minor unit (fen/cent)

#### `CNYParts`
- `yuan`: yuan part
- `jiao`: jiao part
- `fen`: fen part

### 8.2 Core APIs
- `MoneyConversion.convert(_:from:to:currency:)`
- `MoneyConversion.splitCNY(_:)`
- `MoneyConversion.mergeCNY(yuan:jiao:fen:)`
- `MoneyConversion.format(_:scale:useGrouping:locale:)`

### 8.3 Extension APIs
For `String / BinaryInteger / BinaryFloatingPoint / Decimal`:
- `convertMoney(from:to:currency:)`
- `convertMoneyString(from:to:currency:scale:useGrouping:)`
- `formattedMoney(scale:useGrouping:)`

For `Decimal`:
- `splitCNY()`

For `CNYParts`:
- `toDecimalYuan()`

---

## 9. Percentage Conversion (`PercentageConversion.swift` + `Percentage+Conversion.swift`)

Description: Bidirectional conversion between percent and ratio.

### 9.1 Core APIs
- `PercentageConversion.percentToRatio(_:)`
- `PercentageConversion.ratioToPercent(_:)`

### 9.2 Extension APIs
- String: `percentToRatio / ratioToPercent / percentToRatioString / ratioToPercentString`
- BinaryInteger: `percentToRatio / ratioToPercent`
- BinaryFloatingPoint: `percentToRatio / ratioToPercent`
- Decimal: `percentToRatio / ratioToPercent / asPercentString`

---

## 10. Color Conversion (`SwiftUtilityKit.swift` + `Color+Platform.swift`)

Description: Convert among color string/int/hex and platform color types.

### 10.1 `ColorRGBA`
- `init(red:green:blue:alpha:)`
- `parse(_:)`
- `fromRGBString(_:)`
- `fromPackedInt(_:hasAlpha:)`
- `hexString(includeAlpha:prefixHash:)`
- `packedInt(includeAlpha:)`

### 10.2 String / Integer APIs
- String: `toColorRGBA / normalizedColorHex / colorToPackedInt / toCGColor / toUIColor / toSwiftUIColor`
- BinaryInteger: `toColorRGBA(hasAlpha:) / toColorHex(hasAlpha:prefixHash:)`

### 10.2.1 Color factory functions (direct style)
- `colorRGBA(_:)`: create `ColorRGBA` directly from string
- `cgColor(_:) / cgcolor(_:)`: create `CGColor` directly from string
- `uiColor(_:) / uicolor(_:)`: create `UIColor` directly from string (UIKit)
- `swiftUIColor(_:)`: create `SwiftUI.Color` directly from string

### 10.3 Platform bridge
For `ColorRGBA`:
- `init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)`
- `fromHex(_:)`
- `cgColor`
- `init(cgColor:)`
- `uiColor` (UIKit)
- `init(uiColor:)` (UIKit)
- `swiftUIColor` (SwiftUI)

For `UIColor` (UIKit):
- `init(_ color: ColorRGBA)`
- `init(hex:)`
- `init(rgbString:)`
- `init(colorString:)`
- `toColorRGBA()`

For `Color` (SwiftUI + UIKit bridge):
- `toColorRGBA()`

---

## 11. Device and App Info (`Device+Info.swift`)

Description: Read system version, device model, app version, and screen resolution (available on UIKit platforms).

### 11.1 Core APIs
- `DeviceInfo.systemName`: system name (e.g. iOS)
- `DeviceInfo.systemVersion`: system version
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
- `DeviceInfo.batteryLevel`: battery level (0...1, `nil` if unavailable)
- `DeviceInfo.batteryPercentage`: battery percentage (0...100, `nil` if unavailable)
- `DeviceInfo.batteryPercentageText`: battery percentage text (e.g. `80%`, `未知` if unavailable)
- `DeviceInfo.batteryState`: battery state (`UIDevice.BatteryState`)
- `DeviceInfo.batteryStateText`: battery state text (`未知 / 未充电 / 充电中 / 已充满`)
- `DeviceInfo.totalDiskSpace`: total device storage in bytes
- `DeviceInfo.freeDiskSpace`: free device storage in bytes
- `DeviceInfo.usedDiskSpace`: used device storage in bytes
- `DeviceInfo.totalDiskSpaceText`: total storage text (e.g. `256 GB`)
- `DeviceInfo.freeDiskSpaceText`: free storage text (e.g. `120 GB`)
- `DeviceInfo.usedDiskSpaceText`: used storage text (e.g. `136 GB`)

### 11.2 Extension APIs
- `UIDevice.utilityModelIdentifier`: device model identifier
- `UIDevice.utilityModelName`: device model display name
- `UIScreen.utilityPixelResolution`: screen physical resolution in pixels

### 11.3 Device map maintenance
- Device mapping file: `Sources/SwiftUtilityKit/Resources/AppleDeviceList.txt`
- File format: `identifier|name` (one record per line, `#` for comments)
- If no mapping is found, SDK falls back to raw model identifier

---

## 12. String Validation and Formatting (`String+Validation.swift`)

Description: Input validation + display masking/formatting.

Simplest example:

```swift
let phoneOK = "13800138000".isValidChineseMobile // Validate Mainland China mobile number format
let emailOK = "demo@example.com".isValidEmail // Validate email format
let urlOK = "https://example.com/path?a=1".isValidURL // Validate URL format
let ipv6OK = "2408:8400:9800:31d3:4ff7:f6d2:69f8:77b3".isValidIPv6 // Validate IPv6 address format
let cardOK = "4111111111111111".isValidBankCardNumber // Validate bank card number (Luhn)
let idOK = "11010519491231002X".isValidChineseIDCard // Validate China ID card number (with checksum)

let cardText = "6222021234567890123".formattedBankCardNumber() // Format bank card as grouped text
let phoneText = "13800138000".formattedChineseMobile() // Format mobile as XXX-XXXX-XXXX
let phoneMask = "13800138000".maskedChineseMobile() // Mask mobile as XXX****XXXX
let idMask = "11010519491231002X".maskedChineseIDCard() // Mask ID card as first 6 + **** + last 4
```

### 12.1 Validation
- `isValidChineseMobile`
- `isValidURL`
- `isValidEmail`
- `isValidIPv6`
- `isValidBankCardNumber`
- `isValidChineseIDCard`

### 12.2 Formatting/masking
- `formattedBankCardNumber(separator:)`
- `formattedChineseMobile(separator:)`
- `maskedChineseMobile(mask:)`
- `maskedChineseIDCard(mask:)`

---

## 13. Coordinate Conversion (`Coordinate+Conversion.swift`)

Description: On CoreLocation-capable platforms, supports bidirectional conversion among coordinate/string/tuple/dictionary.

### 13.1 Enum
- `CoordinateOrder.latitudeLongitude`: `latitude,longitude`
- `CoordinateOrder.longitudeLatitude`: `longitude,latitude`

### 13.2 Coordinate APIs
- `CLLocationCoordinate2D.parse(_:separator:order:)`
- `CLLocationCoordinate2D.make(_:order:)`
- `CLLocationCoordinate2D.make(from:)`
- `isValidCoordinate`
- `string(order:separator:fractionDigits:)`
- `tuple(order:)`
- `dictionary()`
- `swappedLatLon()`

### 13.3 String API
- `coordinate(separator:order:)`

---

## 14. Numeric Extensions (`Numeric+Conversion.swift`)

Description: Direct conversion APIs when input is already numeric.

### 14.1 `BinaryInteger`
- Units: `convertLength / convertWeight / convertArea / convertVolume / convertTime / convertTemperature / convertSpeed`
- Time relation: `compareTime / timeDifference`
- Radix: `convertRadix(to:uppercase:)`
- Chinese uppercase: `toChineseUppercaseNumber / toChineseUppercaseCurrency`
- Color: `toColorRGBA / toColorHex`

### 14.2 `BinaryFloatingPoint`
- Units: `convertLength / convertWeight / convertArea / convertVolume / convertTime / convertTemperature / convertSpeed`
- Time relation: `compareTime / timeDifference`
- Chinese uppercase: `toChineseUppercaseNumber / toChineseUppercaseCurrency`

### 14.3 `Decimal`
- Units: `convertLength / convertWeight / convertArea / convertVolume / convertTime / convertTemperature / convertSpeed`
- Time relation: `compareTime / timeDifference`
- Chinese uppercase: `toChineseUppercaseNumber / toChineseUppercaseCurrency`

---

## 15. Full Unit Enum Lists (with meanings)

### 15.1 `LengthUnit`
- `picometer`: picometer
- `nanometer`: nanometer
- `micrometer`: micrometer
- `millimeter`: millimeter
- `centimeter`: centimeter
- `decimeter`: decimeter
- `meter`: meter
- `kilometer`: kilometer
- `nauticalMile`: nautical mile
- `mile`: mile
- `furlong`: furlong
- `yard`: yard
- `foot`: foot
- `inch`: inch
- `li`: li
- `zhang`: zhang
- `chi`: chi
- `cun`: cun
- `fen`: fen
- `liSmall`: li (small)
- `hao`: hao
- `lightYear`: light year

### 15.2 `WeightUnit`
- `microgram`: microgram
- `milligram`: milligram
- `gram`: gram
- `kilogram`: kilogram
- `ton`: ton
- `ounce`: ounce
- `pound`: pound
- `stone`: stone
- `jin`: jin
- `liang`: liang
- `qian`: qian

### 15.3 `AreaUnit`
- `squareMillimeter`: square millimeter
- `squareCentimeter`: square centimeter
- `squareDecimeter`: square decimeter
- `squareMeter`: square meter
- `squareKilometer`: square kilometer
- `hectare`: hectare
- `acre`: acre
- `squareFoot`: square foot
- `squareInch`: square inch
- `mu`: mu

### 15.4 `VolumeUnit`
- `milliliter`: milliliter
- `liter`: liter
- `cubicMeter`: cubic meter
- `teaspoon`: teaspoon
- `tablespoon`: tablespoon
- `cup`: cup
- `pint`: pint
- `gallon`: gallon
- `cubicCentimeter`: cubic centimeter
- `cubicInch`: cubic inch

### 15.5 `TimeUnit`
- `nanosecond`: nanosecond
- `microsecond`: microsecond
- `millisecond`: millisecond
- `second`: second
- `minute`: minute
- `hour`: hour
- `day`: day
- `week`: week

### 15.6 `TemperatureUnit`
- `celsius`: Celsius
- `fahrenheit`: Fahrenheit
- `kelvin`: Kelvin

### 15.7 `SpeedUnit`
- `meterPerSecond`: meter per second
- `kilometerPerHour`: kilometer per hour
- `milePerHour`: mile per hour
- `knot`: knot
- `footPerSecond`: foot per second

---

## 16. Date-related Enums (with meanings)

### 16.1 `DateConversion.TimestampUnit`
- `second`: second-level timestamp (e.g. `1704067200`)
- `millisecond`: millisecond-level timestamp (e.g. `1704067200000`)

### 16.2 `DateConversion.DateDifferenceUnit`
- `second`: output difference in seconds
- `minute`: output difference in minutes
- `hour`: output difference in hours
- `day`: output difference in days (24h)

### 16.3 `DateConversion.RelativeDateTag`
- `dayBeforeYesterday`: day before yesterday
- `yesterday`: yesterday
- `today`: today
- `tomorrow`: tomorrow
- `lastWeek`: last week
- `nextWeek`: next week
- `lastYear`: last year
- `nextYear`: next year

---

## 17. Full Error Enum List (`ConversionError`)

- `invalidNumber`: invalid number
- `invalidBase`: invalid base range
- `invalidRadixValue`: invalid radix value
- `overflow`: numeric overflow
- `invalidChineseNumeral`: invalid Chinese numeral text
- `invalidColor`: invalid color text/value
- `invalidDate`: invalid date text
- `invalidCoordinate`: invalid coordinate text/value
- `invalidMoneyUnit`: money unit not supported for the selected currency

---

## 18. Localization

- Localized unit names: `localizedName(locale:)`
- Localized errors: `ConversionError.errorDescription`
