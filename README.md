# SwiftUtilityKit

[中文](./README.md) | [English](./README_EN.md) | [自动选择语言（GitHub Pages）](./docs/index.html)

Swift 常用转换工具库（默认中文语境）：
- 默认日期上下文：`zh_CN + Asia/Shanghai + Gregorian`
- 覆盖：单位换算、日期时间、金额、百分比、颜色、字符串校验与格式化、设备与应用信息

## 演示视频

- 点击观看：[SwiftUtilityKit Demo Video](https://github.com/snoux/SwiftUtilityKit/releases/download/1.0.0/demo.mp4)

---

## 1. 安装（SPM）

说明：通过 Swift Package Manager 引入 SDK。

```swift
https://github.com/snoux/SwiftUtilityKit
```



```swift
import SwiftUtilityKit // 在代码文件中导入 SDK
```

---

## 2. 最简场景调用

说明：以下示例全部使用默认上下文（不传 `in: cn`）。

### 2.1 日期格式转换

```swift
let out = try "2026-03-10 08:00:00".dateString(to: .dateMinuteSlash) // 自动识别输入并输出为 yyyy/MM/dd HH:mm
```

### 2.2 判断是不是昨天（String 直调）

```swift
let ref = try "2026-03-10 12:00:00".date(.dateTime) // 解析参考时间
let ok = try "2026-03-09 12:00:00".isYesterday(ref: ref) // 判断目标时间是否是参考时间的昨天
```

### 2.3 判断是不是昨天（Date 直调）

```swift
let ref = try "2026-03-10 12:00:00".date(.dateTime) // 解析参考时间
let target = try "2026-03-09 12:00:00".date(.dateTime) // 解析目标时间
let ok = target.isYesterday(ref: ref) // 直接通过 Date 扩展判断昨天
```

### 2.4 判断 7 天内

```swift
let ref = try "2026-03-10 12:00:00".date(.dateTime) // 参考时间
let in7 = try "2026-03-05 12:00:00".relative(to: ref).withinPast(7, .day) // 目标时间是否在参考时间向前 7 天范围内
```

### 2.5 判断区间

```swift
let inRange = try "2026-03-10 08:00:00".isBetween("2026-03-10 07:00:00", and: "2026-03-10 09:00:00", format: "yyyy-MM-dd HH:mm:ss") // 判断字符串时间是否在区间内
```

### 2.6 时间戳互转

```swift
let ts = try "2026-03-10 08:00:00".timestamp(.dateTime) // 日期字符串转秒级时间戳
let text = try "1704067200".dateStringFromTimestamp(unit: .second, format: "yyyy-MM-dd HH:mm:ss") // 秒级时间戳转日期字符串
```

### 2.7 金额换算

```swift
let fen = try "12.34".convertMoney(from: .major, to: .minor, currency: .cny) // 人民币元转分 -> 1234
let text = try "1234567.8".formattedMoney(scale: 2, useGrouping: true) // 金额千分位格式化 -> 1,234,567.80
```

### 2.8 百分比换算

```swift
let ratio = try "12.5".percentToRatio() // 百分数 12.5 转比率 0.125
```

### 2.9 颜色转换

```swift
let hex = try "rgba(255,102,0,0.5)".normalizedColorHex(includeAlpha: true) // 颜色字符串标准化为 hex
```

### 2.10 字符串校验

```swift
let phoneOK = "13800138000".isValidChineseMobile // 校验是否中国大陆手机号
let emailOK = "demo@example.com".isValidEmail // 校验邮箱格式
```

### 2.11 常用字符串扩展

```swift
let blank = " \n ".isBlank // 判断是否空白字符串
let encoded = "a b&c=1".urlEncoded() // URL 编码
let decoded = "a%20b%26c%3D1".urlDecoded() // URL 解码
let b64 = "SwiftUtilityKit".base64Encoded() // Base64 编码
let raw = "U3dpZnRVdGlsaXR5S2l0".base64Decoded() // Base64 解码
```

### 2.12 常用 Date 扩展

```swift
let d = try "2026-03-10 12:34:56".date(.dateTime) // 解析 Date
let start = d.startOfDay() // 当天开始时间 00:00:00
let end = d.endOfDay() // 当天结束时间 23:59:59
let plus7 = d.adding(7, .day) // 日期加 7 天
let sameDay = d.isSameDay(as: Date()) // 是否同一天
```

### 2.13 设备与应用信息

```swift
let sys = DeviceInfo.systemVersion // 获取系统版本号
let model = DeviceInfo.modelName // 获取设备机型名称
let app = DeviceInfo.appVersionWithBuild // 获取当前 App 版本号 + 构建号
let px = DeviceInfo.pixelResolutionText // 获取屏幕物理分辨率（像素）
let battery = DeviceInfo.batteryPercentageText // 获取当前电池百分比文本
let total = DeviceInfo.totalDiskSpaceText // 获取设备总容量文本
let free = DeviceInfo.freeDiskSpaceText // 获取设备剩余容量文本
let used = DeviceInfo.usedDiskSpaceText // 获取设备已用容量文本
```

### 2.14 坐标互转（CLLocationCoordinate2D）

```swift
let c = try "31.2304,121.4737".coordinate() // 字符串转坐标（默认纬度,经度）
let text = c.string(order: .longitudeLatitude, fractionDigits: 6) // 坐标转字符串（经度,纬度）
let dict = c.dictionary() // 坐标转字典：["latitude":..., "longitude":...]
```

---

## 3. DateKit（上下文与日期模式）

说明：DateKit 统一管理“解析/格式化的语言、时区、日历”和“日期格式模式”。

### 3.1 上下文类型 `DateKit.Context`

| API | 说明 |
|---|---|
| `DateKit.defaultContext` | 默认上下文（`zh_CN + Asia/Shanghai + Gregorian`） |
| `DateKit.Context.cn` | 中文预设上下文 |
| `DateKit.Context(locale:timeZone:calendar:)` | 自定义上下文 |

### 3.2 日期模式枚举 `DateKit.Pattern`

| case | 格式 | 说明 |
|---|---|---|
| `dateTime` | `yyyy-MM-dd HH:mm:ss` | 常用秒级日期时间 |
| `dateTimeSlash` | `yyyy/MM/dd HH:mm:ss` | 斜杠版秒级日期时间 |
| `dateMinute` | `yyyy-MM-dd HH:mm` | 分钟级日期时间 |
| `dateMinuteSlash` | `yyyy/MM/dd HH:mm` | 斜杠版分钟级日期时间 |
| `date` | `yyyy-MM-dd` | 横杠日期 |
| `dateSlash` | `yyyy/MM/dd` | 斜杠日期 |
| `compactDateTime` | `yyyyMMddHHmmss` | 紧凑日期时间 |
| `compactDate` | `yyyyMMdd` | 紧凑日期 |
| `iso8601` | `yyyy-MM-dd'T'HH:mm:ssZ` | ISO8601 秒级 |
| `iso8601Millis` | `yyyy-MM-dd'T'HH:mm:ss.SSSZ` | ISO8601 毫秒级 |

辅助集合：
- `DateKit.commonDatePatterns`：自动识别输入模式列表（顺序即尝试顺序）
- `DateKit.commonDateFormats`：自动识别输入格式字符串列表

---

## 4. String：单位换算与基础转换（String+Conversion.swift）

说明：当原始输入是字符串时，使用这组 API 最方便。

| API | 说明 |
|---|---|
| `convertLength(from:to:)` | 长度换算 |
| `convertWeight(from:to:)` | 重量换算 |
| `convertArea(from:to:)` | 面积换算 |
| `convertVolume(from:to:)` | 体积换算 |
| `convertTime(from:to:)` | 时间换算 |
| `compareTime(with:selfUnit:otherUnit:)` | 比较两个时间值 |
| `timeDifference(to:selfUnit:otherUnit:resultUnit:)` | 计算两个时间值差值（`other - self`） |
| `convertTemperature(from:to:)` | 温度换算 |
| `convertSpeed(from:to:)` | 速度换算 |
| `convertRadix(from:to:uppercase:)` | 字符串进制换算（2...36） |
| `toChineseUppercaseNumber()` | 数字转中文大写数字 |
| `toChineseUppercaseCurrency()` | 数字转中文金额大写 |
| `chineseUppercaseToDecimal()` | 中文大写转十进制 |
| `toColorRGBA()` | 颜色字符串转 RGBA |
| `normalizedColorHex(includeAlpha:prefixHash:)` | 颜色字符串转标准 hex |
| `colorToPackedInt(includeAlpha:)` | 颜色字符串转整数颜色值 |

---

## 5. String：日期 DSL（String+Utility.swift）

说明：这是日期处理的主入口，支持“明确格式”和“自动识别”两种调用风格。

### 5.1 解析
| API | 说明 |
|---|---|
| `date(_ format: String)` | 按格式解析 |
| `date(_ pattern: DateKit.Pattern)` | 按内置模式解析 |
| `date(_ formats: [String])` | 按多个格式依次尝试 |
| `date(_ patterns: [DateKit.Pattern])` | 按多个模式依次尝试 |
| `date(patterns:)` | 自动识别解析 |

### 5.2 格式转换
| API | 说明 |
|---|---|
| `dateString(from:to:)`（String） | 输入格式 -> 输出格式 |
| `dateString(from:to:)`（Pattern） | 输入模式 -> 输出模式 |
| `dateString(to:inputFormats:)` | 自动识别输入格式后输出 |
| `dateString(to:inputPatterns:)` | 自动识别输入模式后输出 |

### 5.3 比较与差值
| API | 说明 |
|---|---|
| `dateCompare(with:format:)` | 比较两个日期字符串 |
| `dateDistance(to:format:unit:)` | 计算日期差值（`other - self`） |

### 5.4 时间戳
| API | 说明 |
|---|---|
| `timestamp(_ format: String, unit:)` | 按格式转时间戳 |
| `timestamp(_ pattern: DateKit.Pattern, unit:)` | 按模式转时间戳 |
| `timestamp(unit:patterns:)` | 自动识别后转时间戳 |
| `timestampString(_ format: String, unit:scale:)` | 转时间戳字符串 |
| `dateStringFromTimestamp(unit:format:)` | 时间戳字符串转日期字符串 |
| `convertTimestamp(from:to:scale:)` | 时间戳单位互转 |

### 5.5 相对时间与区间
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

### 5.6 字符串工具
| API | 说明 |
|---|---|
| `trimmed()` | 去首尾空白和换行 |
| `removingWhitespacesAndNewlines()` | 去全部空白和换行 |
| `isIntegerNumber` | 是否整数文本 |
| `isDecimalNumber` | 是否十进制数字文本 |
| `digitsOnly()` | 仅保留数字字符 |
| `formattedWithGrouping(maximumFractionDigits:minimumFractionDigits:)` | 数字千分位格式化 |
| `safeSubstring(start:length:)` | 安全截取子串 |
| `isBlank` | 是否空白字符串 |
| `nilIfBlank()` | 空白转 `nil`，否则返回 trim 后内容 |
| `urlEncoded()` | URL 编码 |
| `urlDecoded()` | URL 解码 |
| `base64Encoded()` | Base64 编码（UTF-8） |
| `base64Decoded()` | Base64 解码（UTF-8） |
| `coordinate(separator:order:)` | 字符串转 `CLLocationCoordinate2D`（CoreLocation） |

---

## 6. Date 默认语义扩展（Date+Utility.swift）

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
| `isWithinPast(_:_:,ref:inclusive:)` | 判断是否在参考时间向前范围内 |
| `Date.fromTimestamp(_:unit:)` | 时间戳转 `Date` |

`DateRelativeProxy` 说明：
- 是什么：相对时间判断对象，内部绑定 `target` 与 `reference`
- 何时用：需要连续判断多个相对条件时，减少重复传参
- 属性：`isDayBeforeYesterday / isYesterday / isToday / isTomorrow / isLastWeek / isNextWeek / isLastYear / isNextYear`
- 方法：`matches(_:)`（按标签通用判断）
- 方法：`withinPast(_:_:,inclusive:)`（范围判断）

---

## 7. 时间戳扩展（Timestamp+Conversion.swift）

说明：当时间戳本来就是数值类型时，无需先转字符串。

适用于 `BinaryInteger / BinaryFloatingPoint / Decimal`：
- `convertTimestamp(from:to:)`：时间戳单位换算
- `toDate(unit:)`：时间戳转 `Date`

---

## 8. 金额换算（MoneyConversion.swift + Money+Conversion.swift）

说明：仅做同币种单位换算（不涉及汇率），内部使用 `Decimal` 确保精度。

### 8.1 枚举与类型

#### CurrencyCode
- `cny`：人民币
- `usd`：美元
- `eur`：欧元
- `gbp`：英镑
- `jpy`：日元

#### MoneyUnit
- `major`：主单位（如元/美元）
- `tenth`：十分位单位（如角）
- `minor`：百分位单位（如分/美分）

#### CNYParts
- `yuan`：元
- `jiao`：角
- `fen`：分

### 8.2 核心 API
- `MoneyConversion.convert(_:from:to:currency:)`
- `MoneyConversion.splitCNY(_:)`
- `MoneyConversion.mergeCNY(yuan:jiao:fen:)`
- `MoneyConversion.format(_:scale:useGrouping:locale:)`

### 8.3 扩展入口
String / BinaryInteger / BinaryFloatingPoint / Decimal：
- `convertMoney(from:to:currency:)`
- `convertMoneyString(from:to:currency:scale:useGrouping:)`
- `formattedMoney(scale:useGrouping:)`

Decimal：
- `splitCNY()`

CNYParts：
- `toDecimalYuan()`

---

## 9. 百分比换算（PercentageConversion.swift + Percentage+Conversion.swift）

说明：支持“百分数 <-> 比率”双向转换。

### 9.1 核心 API
- `PercentageConversion.percentToRatio(_:)`
- `PercentageConversion.ratioToPercent(_:)`

### 9.2 扩展入口
- String：`percentToRatio / ratioToPercent / percentToRatioString / ratioToPercentString`
- BinaryInteger：`percentToRatio / ratioToPercent`
- BinaryFloatingPoint：`percentToRatio / ratioToPercent`
- Decimal：`percentToRatio / ratioToPercent / asPercentString`

---

## 10. 颜色转换（SwiftUtilityKit.swift + Color+Platform.swift）

说明：支持颜色字符串、整数、十六进制与系统颜色对象互转。

### 10.1 ColorRGBA
- `init(red:green:blue:alpha:)`
- `parse(_:)`
- `fromRGBString(_:)`
- `fromPackedInt(_:hasAlpha:)`
- `hexString(includeAlpha:prefixHash:)`
- `packedInt(includeAlpha:)`

### 10.2 String / Integer 扩展
- String：`toColorRGBA / normalizedColorHex / colorToPackedInt / toCGColor / toUIColor / toSwiftUIColor`
- BinaryInteger：`toColorRGBA(hasAlpha:) / toColorHex(hasAlpha:prefixHash:)`

### 10.2.1 颜色工厂函数（更直接）
- `colorRGBA(_:)`：字符串直接创建 `ColorRGBA`
- `cgColor(_:) / cgcolor(_:)`：字符串直接创建 `CGColor`
- `uiColor(_:) / uicolor(_:)`：字符串直接创建 `UIColor`（UIKit）
- `swiftUIColor(_:)`：字符串直接创建 `SwiftUI.Color`

### 10.3 平台桥接
ColorRGBA：
- `init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)`
- `fromHex(_:)`
- `cgColor`
- `init(cgColor:)`
- `uiColor`（UIKit）
- `init(uiColor:)`（UIKit）
- `swiftUIColor`（SwiftUI）

UIColor（UIKit）：
- `init(_ color: ColorRGBA)`
- `init(hex:)`
- `init(rgbString:)`
- `init(colorString:)`
- `toColorRGBA()`

Color（SwiftUI + UIKit 桥接）：
- `toColorRGBA()`

---

## 11. 设备与应用信息（Device+Info.swift）

说明：用于获取系统版本、设备机型、App 版本和屏幕分辨率等信息（UIKit 平台可用）。

### 11.1 核心 API
- `DeviceInfo.systemName`：系统名称（如 iOS）
- `DeviceInfo.systemVersion`：系统版本号
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
- `DeviceInfo.batteryLevel`：电池电量（0...1，不可用时为 `nil`）
- `DeviceInfo.batteryPercentage`：电池百分比（0...100，不可用时为 `nil`）
- `DeviceInfo.batteryPercentageText`：电池百分比文本（如 `80%`，不可用时为 `未知`）
- `DeviceInfo.batteryState`：电池状态（`UIDevice.BatteryState`）
- `DeviceInfo.batteryStateText`：电池状态文本（`未知 / 未充电 / 充电中 / 已充满`）
- `DeviceInfo.totalDiskSpace`：设备总容量（字节）
- `DeviceInfo.freeDiskSpace`：设备剩余容量（字节）
- `DeviceInfo.usedDiskSpace`：设备已用容量（字节）
- `DeviceInfo.totalDiskSpaceText`：设备总容量文本（如 `256 GB`）
- `DeviceInfo.freeDiskSpaceText`：设备剩余容量文本（如 `120 GB`）
- `DeviceInfo.usedDiskSpaceText`：设备已用容量文本（如 `136 GB`）

### 11.2 扩展 API
- `UIDevice.utilityModelIdentifier`：设备机型标识
- `UIDevice.utilityModelName`：设备机型名称
- `UIScreen.utilityPixelResolution`：屏幕像素分辨率

### 11.3 机型映射维护
- 机型映射独立维护在：`Sources/SwiftUtilityKit/Resources/AppleDeviceList.txt`
- 文件格式：`identifier|name`（一行一条，`#` 开头为注释）
- 未命中映射时会自动回退为原始机型标识

---

## 12. 字符串校验与格式化（String+Validation.swift）

说明：用于输入合法性校验和展示脱敏。

最简示例：

```swift
let phoneOK = "13800138000".isValidChineseMobile // 校验大陆手机号
let emailOK = "demo@example.com".isValidEmail // 校验邮箱
let urlOK = "https://example.com/path?a=1".isValidURL // 校验 URL
let ipv6OK = "2408:8400:9800:31d3:4ff7:f6d2:69f8:77b3".isValidIPv6 // 校验 IPv6
let cardOK = "4111111111111111".isValidBankCardNumber // 校验银行卡号（Luhn）
let idOK = "11010519491231002X".isValidChineseIDCard // 校验身份证号（含校验码）

let cardText = "6222021234567890123".formattedBankCardNumber() // 银行卡分组格式化
let phoneText = "13800138000".formattedChineseMobile() // 手机号格式化为 XXX-XXXX-XXXX
let phoneMask = "13800138000".maskedChineseMobile() // 手机号脱敏为 XXX****XXXX
let idMask = "11010519491231002X".maskedChineseIDCard() // 身份证脱敏为 前6 + **** + 后4
```

### 12.1 校验
- `isValidChineseMobile`
- `isValidURL`
- `isValidEmail`
- `isValidIPv6`
- `isValidBankCardNumber`
- `isValidChineseIDCard`

### 12.2 格式化与脱敏
- `formattedBankCardNumber(separator:)`
- `formattedChineseMobile(separator:)`
- `maskedChineseMobile(mask:)`
- `maskedChineseIDCard(mask:)`

---

## 13. 坐标互转（Coordinate+Conversion.swift）

说明：在可导入 CoreLocation 的平台，支持 `CLLocationCoordinate2D` 与字符串、元组、字典互转。

### 13.1 枚举
- `CoordinateOrder.latitudeLongitude`：`纬度,经度`
- `CoordinateOrder.longitudeLatitude`：`经度,纬度`

### 13.2 坐标 API
- `CLLocationCoordinate2D.parse(_:separator:order:)`
- `CLLocationCoordinate2D.make(_:order:)`
- `CLLocationCoordinate2D.make(from:)`
- `isValidCoordinate`
- `string(order:separator:fractionDigits:)`
- `tuple(order:)`
- `dictionary()`
- `swappedLatLon()`

### 13.3 字符串 API
- `coordinate(separator:order:)`

---

## 14. 数值扩展（Numeric+Conversion.swift）

说明：当数据已是数值类型时，直接调用数值扩展更高效。

### 14.1 BinaryInteger
- 单位：`convertLength / convertWeight / convertArea / convertVolume / convertTime / convertTemperature / convertSpeed`
- 时间关系：`compareTime / timeDifference`
- 进制：`convertRadix(to:uppercase:)`
- 中文大写：`toChineseUppercaseNumber / toChineseUppercaseCurrency`
- 颜色：`toColorRGBA / toColorHex`

### 14.2 BinaryFloatingPoint
- 单位：`convertLength / convertWeight / convertArea / convertVolume / convertTime / convertTemperature / convertSpeed`
- 时间关系：`compareTime / timeDifference`
- 中文大写：`toChineseUppercaseNumber / toChineseUppercaseCurrency`

### 14.3 Decimal
- 单位：`convertLength / convertWeight / convertArea / convertVolume / convertTime / convertTemperature / convertSpeed`
- 时间关系：`compareTime / timeDifference`
- 中文大写：`toChineseUppercaseNumber / toChineseUppercaseCurrency`

---

## 15. 单位枚举完整列表（含说明）

### 15.1 LengthUnit（长度）
- `picometer`：皮米
- `nanometer`：纳米
- `micrometer`：微米
- `millimeter`：毫米
- `centimeter`：厘米
- `decimeter`：分米
- `meter`：米
- `kilometer`：千米
- `nauticalMile`：海里
- `mile`：英里
- `furlong`：弗隆
- `yard`：码
- `foot`：英尺
- `inch`：英寸
- `li`：里
- `zhang`：丈
- `chi`：尺
- `cun`：寸
- `fen`：分
- `liSmall`：厘
- `hao`：毫
- `lightYear`：光年

### 15.2 WeightUnit（重量）
- `microgram`：微克
- `milligram`：毫克
- `gram`：克
- `kilogram`：千克
- `ton`：吨
- `ounce`：盎司
- `pound`：磅
- `stone`：英石
- `jin`：斤
- `liang`：两
- `qian`：钱

### 15.3 AreaUnit（面积）
- `squareMillimeter`：平方毫米
- `squareCentimeter`：平方厘米
- `squareDecimeter`：平方分米
- `squareMeter`：平方米
- `squareKilometer`：平方千米
- `hectare`：公顷
- `acre`：英亩
- `squareFoot`：平方英尺
- `squareInch`：平方英寸
- `mu`：亩

### 15.4 VolumeUnit（体积）
- `milliliter`：毫升
- `liter`：升
- `cubicMeter`：立方米
- `teaspoon`：茶匙
- `tablespoon`：汤匙
- `cup`：杯
- `pint`：品脱
- `gallon`：加仑
- `cubicCentimeter`：立方厘米
- `cubicInch`：立方英寸

### 15.5 TimeUnit（时间）
- `nanosecond`：纳秒
- `microsecond`：微秒
- `millisecond`：毫秒
- `second`：秒
- `minute`：分钟
- `hour`：小时
- `day`：天
- `week`：周

### 15.6 TemperatureUnit（温度）
- `celsius`：摄氏度
- `fahrenheit`：华氏度
- `kelvin`：开尔文

### 15.7 SpeedUnit（速度）
- `meterPerSecond`：米每秒
- `kilometerPerHour`：千米每小时
- `milePerHour`：英里每小时
- `knot`：节
- `footPerSecond`：英尺每秒

---

## 16. 日期相关枚举完整列表（含说明）

### 16.1 DateConversion.TimestampUnit
- `second`：秒级时间戳（如 `1704067200`）
- `millisecond`：毫秒级时间戳（如 `1704067200000`）

### 16.2 DateConversion.DateDifferenceUnit
- `second`：按秒输出差值
- `minute`：按分钟输出差值
- `hour`：按小时输出差值
- `day`：按天输出差值（24 小时）

### 16.3 DateConversion.RelativeDateTag
- `dayBeforeYesterday`：前天
- `yesterday`：昨天
- `today`：今天
- `tomorrow`：明天
- `lastWeek`：上周
- `nextWeek`：下周
- `lastYear`：去年
- `nextYear`：明年

---

## 17. 错误类型完整列表（ConversionError）

- `invalidNumber`：无效数字
- `invalidBase`：无效进制范围
- `invalidRadixValue`：进制值不合法
- `overflow`：溢出
- `invalidChineseNumeral`：中文数字不合法
- `invalidColor`：颜色不合法
- `invalidDate`：日期不合法
- `invalidCoordinate`：坐标不合法
- `invalidMoneyUnit`：币种与金额单位不匹配

---

## 18. 国际化

- 单位名称本地化：`localizedName(locale:)`
- 错误信息本地化：`ConversionError.errorDescription`
