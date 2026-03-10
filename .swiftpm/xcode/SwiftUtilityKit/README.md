# SwiftUtilityKit

一个面向日常开发的 Swift 工具库，主打“直接扩展调用 + 单位互转 + 字符串/数字双入口 + 国际化”。

- 支持 `String`、整数、浮点、`Decimal` 直接调用
- 支持颜色、长度、重量、面积、体积、时间、温度、速度转换
- 支持进制转换（2...36）
- 支持中文大写与普通数字双向转换
- 支持单位名与错误信息中英文国际化

## 安装（SPM）

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

## 简单使用

```swift
let km = 1200.convertLength(from: .meter, to: .kilometer)
let sec = try "5".convertTime(from: .minute, to: .second)
let cmp = 5.compareTime(to: 300, selfUnit: .minute, otherUnit: .second)
let date = try "2025-01-01 12:30:00".toDate(format: "yyyy-MM-dd HH:mm:ss")
let hex = try "rgb(255,0,0)".normalizedColorHex()
```

## 支持功能（按分类）

### 颜色转换

- `String -> ColorRGBA`: `toColorRGBA() throws`
- `String -> Hex`: `normalizedColorHex(includeAlpha:prefixHash:) throws`
- `String -> Packed Int`: `colorToPackedInt(includeAlpha:) throws`
- `Int -> ColorRGBA`: `toColorRGBA(hasAlpha:) throws`
- `Int -> Hex`: `toColorHex(hasAlpha:prefixHash:) throws`
- `ColorRGBA 核心`: `init(red:green:blue:alpha:) throws` / `parse(_:) throws` / `fromPackedInt(_:hasAlpha:) throws` / `hexString(...)` / `packedInt(...)`

### 长度转换

- `convertLength(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）

### 重量转换

- `convertWeight(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）

### 面积转换

- `convertArea(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）

### 体积转换

- `convertVolume(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）

### 时间转换

- `convertTime(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）
- 时间大小比较：`compareTime(...)`（`String`/数字）
- 时间差值：`timeDifference(...)`（`String`/数字）

### 日期转换

- 字符串转日期：`toDate(format:locale:timeZone:) throws`
- 日期格式转换：`convertDateFormat(from:to:locale:timeZone:) throws`
- 日期比较：`compareDate(to:format:locale:timeZone:) throws`
- 日期差值：`dateDifference(to:format:in:locale:timeZone:) throws`
- 日期转字符串：`Date.toString(format:locale:timeZone:)`

### 温度转换

- `convertTemperature(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）

### 速度转换

- `convertSpeed(from:to:)`（`String`/`BinaryInteger`/`BinaryFloatingPoint`/`Decimal`）

### 进制转换

- `String` 进制互转：`convertRadix(from:to:uppercase:) throws`
- 整数转目标进制：`convertRadix(to:uppercase:) throws`

### 数字与中文大写互转

- 普通数字转中文大写：`toChineseUppercaseNumber()` / `toChineseUppercaseNumber() throws`
- 普通数字转金额大写：`toChineseUppercaseCurrency()` / `toChineseUppercaseCurrency() throws`
- 中文大写转普通数字：`chineseUppercaseToDecimal() throws`

### 字符串处理

- `trimmed()`
- `removingWhitespacesAndNewlines()`
- `isIntegerNumber`
- `isDecimalNumber`
- `digitsOnly()`
- `formattedWithGrouping(maximumFractionDigits:minimumFractionDigits:) throws`
- `safeSubstring(start:length:)`

### 统一静态入口（便于二次封装）

- `ValueConversion.length(_:from:to:)`
- `ValueConversion.weight(_:from:to:)`
- `ValueConversion.area(_:from:to:)`
- `ValueConversion.volume(_:from:to:)`
- `ValueConversion.time(_:from:to:)`
- `ValueConversion.compareTime(_:lhsUnit:_:rhsUnit:)`
- `ValueConversion.timeDifference(_:lhsUnit:_:rhsUnit:resultUnit:)`
- `ValueConversion.temperature(_:from:to:)`
- `ValueConversion.speed(_:from:to:)`
