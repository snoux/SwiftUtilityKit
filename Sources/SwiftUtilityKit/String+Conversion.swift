import Foundation

/// 字符串转换扩展。
public extension String {
    // MARK: - Length

    /// 长度单位互转。
    ///
    /// - Parameters:
    ///   - from: 源长度单位。
    ///   - to: 目标长度单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "1200".convertLength(from: .meter, to: .kilometer)`
    func convertLength(from: LengthUnit, to: LengthUnit) throws -> Decimal {
        ValueConversion.length(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - Weight

    /// 重量单位互转。
    ///
    /// - Parameters:
    ///   - from: 源重量单位。
    ///   - to: 目标重量单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "500".convertWeight(from: .gram, to: .jin)`
    func convertWeight(from: WeightUnit, to: WeightUnit) throws -> Decimal {
        ValueConversion.weight(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - Area

    /// 面积单位互转。
    ///
    /// - Parameters:
    ///   - from: 源面积单位。
    ///   - to: 目标面积单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "1".convertArea(from: .hectare, to: .squareMeter)`
    func convertArea(from: AreaUnit, to: AreaUnit) throws -> Decimal {
        ValueConversion.area(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - Volume

    /// 体积单位互转。
    ///
    /// - Parameters:
    ///   - from: 源体积单位。
    ///   - to: 目标体积单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "2".convertVolume(from: .liter, to: .milliliter)`
    func convertVolume(from: VolumeUnit, to: VolumeUnit) throws -> Decimal {
        ValueConversion.volume(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - Time

    /// 时间单位互转。
    ///
    /// - Parameters:
    ///   - from: 源时间单位。
    ///   - to: 目标时间单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "5".convertTime(from: .minute, to: .second)`
    func convertTime(from: TimeUnit, to: TimeUnit) throws -> Decimal {
        ValueConversion.time(try DecimalParser.parse(self), from: from, to: to)
    }

    /// 比较两个时间值大小。
    ///
    /// - Parameters:
    ///   - other: 另一时间值字符串。
    ///   - selfUnit: 当前字符串对应时间单位。
    ///   - otherUnit: 另一时间值单位。
    /// - Returns: 比较结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "60".compareTime(with: "1", selfUnit: .minute, otherUnit: .hour)`
    func compareTime(with other: String, selfUnit: TimeUnit, otherUnit: TimeUnit) throws -> ComparisonResult {
        let lhs = try DecimalParser.parse(self)
        let rhs = try DecimalParser.parse(other)
        return ValueConversion.compareTime(lhs, lhsUnit: selfUnit, rhs, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值。
    ///
    /// - Parameters:
    ///   - other: 另一时间值字符串。
    ///   - selfUnit: 当前字符串对应时间单位。
    ///   - otherUnit: 另一时间值单位。
    ///   - resultUnit: 差值输出单位。
    /// - Returns: `other - self` 的差值。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "30".timeDifference(to: "2", selfUnit: .minute, otherUnit: .hour, resultUnit: .minute)`
    func timeDifference(
        to other: String,
        selfUnit: TimeUnit,
        otherUnit: TimeUnit,
        resultUnit: TimeUnit
    ) throws -> Decimal {
        let lhs = try DecimalParser.parse(self)
        let rhs = try DecimalParser.parse(other)
        return ValueConversion.timeDifference(lhs, lhsUnit: selfUnit, rhs, rhsUnit: otherUnit, resultUnit: resultUnit)
    }

    // MARK: - Temperature

    /// 温度单位互转。
    ///
    /// - Parameters:
    ///   - from: 源温度单位。
    ///   - to: 目标温度单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "100".convertTemperature(from: .celsius, to: .fahrenheit)`
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) throws -> Decimal {
        ValueConversion.temperature(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - Speed

    /// 速度单位互转。
    ///
    /// - Parameters:
    ///   - from: 源速度单位。
    ///   - to: 目标速度单位。
    /// - Returns: 转换后的结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "120".convertSpeed(from: .kilometerPerHour, to: .meterPerSecond)`
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) throws -> Decimal {
        ValueConversion.speed(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - Radix

    /// 进制互转。
    ///
    /// - Parameters:
    ///   - from: 源进制（2...36）。
    ///   - to: 目标进制（2...36）。
    ///   - uppercase: 字母是否大写。
    /// - Returns: 转换后的进制字符串。
    /// - Throws: `ConversionError.invalidBase`、`ConversionError.invalidRadixValue`。
    /// - Example: `try "FF".convertRadix(from: 16, to: 10)`
    func convertRadix(from: Int, to: Int, uppercase: Bool = true) throws -> String {
        guard (2...36).contains(from) else {
            throw ConversionError.invalidBase(from)
        }
        guard (2...36).contains(to) else {
            throw ConversionError.invalidBase(to)
        }

        let sanitized = trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int64(sanitized, radix: from) else {
            throw ConversionError.invalidRadixValue(self, base: from)
        }

        return String(value, radix: to, uppercase: uppercase)
    }

    // MARK: - Chinese Numerals

    /// 普通数字字符串转中文大写数字。
    ///
    /// - Returns: 中文大写数字字符串。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "1234.56".toChineseUppercaseNumber()`
    func toChineseUppercaseNumber() throws -> String {
        ChineseUppercaseConverter.toUppercaseNumber(try DecimalParser.parse(self))
    }

    /// 普通数字字符串转中文金额大写。
    ///
    /// - Returns: 中文金额大写字符串。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try "1234.56".toChineseUppercaseCurrency()`
    func toChineseUppercaseCurrency() throws -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(try DecimalParser.parse(self))
    }

    /// 中文大写数字（含金额格式）转普通数字。
    ///
    /// - Returns: 解析后的十进制值。
    /// - Throws: `ConversionError.invalidChineseNumeral`
    /// - Example: `try "壹仟贰佰叁拾肆元伍角陆分".chineseUppercaseToDecimal()`
    func chineseUppercaseToDecimal() throws -> Decimal {
        try ChineseUppercaseConverter.parse(self)
    }

    // MARK: - Color

    /// 将颜色字符串解析为 `ColorRGBA`。
    ///
    /// - Returns: 解析后的 RGBA 颜色。
    /// - Throws: `ConversionError.invalidColor`
    /// - Example: `try "#FF6600".toColorRGBA()`
    func toColorRGBA() throws -> ColorRGBA {
        try ColorRGBA.parse(self)
    }

    /// 将颜色字符串标准化为十六进制。
    ///
    /// - Parameters:
    ///   - includeAlpha: 是否输出 alpha。
    ///   - prefixHash: 是否输出 `#`。
    /// - Returns: 十六进制颜色。
    /// - Throws: `ConversionError.invalidColor`
    /// - Example: `try "rgb(255,102,0)".normalizedColorHex()`
    func normalizedColorHex(includeAlpha: Bool = false, prefixHash: Bool = true) throws -> String {
        try toColorRGBA().hexString(includeAlpha: includeAlpha, prefixHash: prefixHash)
    }

    /// 将颜色字符串转换为整数。
    ///
    /// - Parameter includeAlpha: 是否包含 alpha。
    /// - Returns: 颜色整数值。
    /// - Throws: `ConversionError.invalidColor`
    /// - Example: `try "#FF6600".colorToPackedInt()`
    func colorToPackedInt(includeAlpha: Bool = false) throws -> Int {
        try toColorRGBA().packedInt(includeAlpha: includeAlpha)
    }
}
