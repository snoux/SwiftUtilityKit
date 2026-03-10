# SwiftUtilityKit

A practical Swift utility toolkit focused on extension-based usage, robust unit conversion, and zh/en localization.

- Direct APIs for `String`, integer, floating-point, and `Decimal`
- Conversions for color, length, weight, area, volume, time, temperature, and speed
- Radix conversion (`2...36`)
- Chinese uppercase numeral conversion (both directions)
- Localized unit names and error messages

## Installation (SPM)

```swift
.dependencies: [
    .package(url: "<your-repo-url>", from: "1.0.0")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SwiftUtilityKit", package: "SwiftUtilityKit")
    ]
)
```

```swift
import SwiftUtilityKit
```

## Quick Usage

```swift
let km = 1200.convertLength(from: .meter, to: .kilometer)
let sec = try "5".convertTime(from: .minute, to: .second)
let cmp = 5.compareTime(to: 300, selfUnit: .minute, otherUnit: .second)
let date = try "2025-01-01 12:30:00".toDate(format: "yyyy-MM-dd HH:mm:ss")
let hex = try "rgb(255,0,0)".normalizedColorHex()
```

## Supported Features (By Category)

### Color Conversion

- `String -> ColorRGBA`: `toColorRGBA() throws`
- `String -> Hex`: `normalizedColorHex(includeAlpha:prefixHash:) throws`
- `String -> Packed Int`: `colorToPackedInt(includeAlpha:) throws`
- `Int -> ColorRGBA`: `toColorRGBA(hasAlpha:) throws`
- `Int -> Hex`: `toColorHex(hasAlpha:prefixHash:) throws`
- `ColorRGBA core`: `init(...) throws`, `parse(_:) throws`, `fromPackedInt(...) throws`, `hexString(...)`, `packedInt(...)`

### Length Conversion

- `convertLength(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)

### Weight Conversion

- `convertWeight(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)

### Area Conversion

- `convertArea(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)

### Volume Conversion

- `convertVolume(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)

### Time Conversion

- `convertTime(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)
- time comparison: `compareTime(...)` (`String` / numeric)
- time difference: `timeDifference(...)` (`String` / numeric)

### Date Conversion

- string -> date: `toDate(format:locale:timeZone:) throws`
- date format conversion: `convertDateFormat(from:to:locale:timeZone:) throws`
- date comparison: `compareDate(to:format:locale:timeZone:) throws`
- date difference: `dateDifference(to:format:in:locale:timeZone:) throws`
- date -> string: `Date.toString(format:locale:timeZone:)`

### Temperature Conversion

- `convertTemperature(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)

### Speed Conversion

- `convertSpeed(from:to:)` (`String` / `BinaryInteger` / `BinaryFloatingPoint` / `Decimal`)

### Radix Conversion

- string radix conversion: `convertRadix(from:to:uppercase:) throws`
- integer radix conversion: `convertRadix(to:uppercase:) throws`

### Chinese Uppercase Conversion

- numeric -> uppercase number: `toChineseUppercaseNumber()` / `toChineseUppercaseNumber() throws`
- numeric -> uppercase currency: `toChineseUppercaseCurrency()` / `toChineseUppercaseCurrency() throws`
- uppercase -> numeric: `chineseUppercaseToDecimal() throws`

### String Utilities

- `trimmed()`
- `removingWhitespacesAndNewlines()`
- `isIntegerNumber`
- `isDecimalNumber`
- `digitsOnly()`
- `formattedWithGrouping(...) throws`
- `safeSubstring(start:length:)`

### Static Entry (for wrapping)

- `ValueConversion.length/weight/area/volume/time/compareTime/timeDifference/temperature/speed`
