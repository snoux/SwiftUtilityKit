import Foundation

private extension BinaryInteger {
    var utilityDecimal: Decimal {
        Decimal(string: String(self)) ?? 0
    }
}

private extension BinaryFloatingPoint {
    var utilityDecimal: Decimal {
        Decimal(string: String(Double(self))) ?? 0
    }
}

/// 数字类型转换扩展（整数）。
public extension BinaryInteger {
    // MARK: - Length

    /// 长度单位互转。
    ///
    /// - Parameters:
    ///   - from: 源长度单位。
    ///   - to: 目标长度单位。
    /// - Returns: 转换后的结果。
    func convertLength(from: LengthUnit, to: LengthUnit) -> Decimal {
        ValueConversion.length(utilityDecimal, from: from, to: to)
    }

    // MARK: - Weight

    /// 重量单位互转。
    ///
    /// - Parameters:
    ///   - from: 源重量单位。
    ///   - to: 目标重量单位。
    /// - Returns: 转换后的结果。
    func convertWeight(from: WeightUnit, to: WeightUnit) -> Decimal {
        ValueConversion.weight(utilityDecimal, from: from, to: to)
    }

    // MARK: - Area

    /// 面积单位互转。
    ///
    /// - Parameters:
    ///   - from: 源面积单位。
    ///   - to: 目标面积单位。
    /// - Returns: 转换后的结果。
    func convertArea(from: AreaUnit, to: AreaUnit) -> Decimal {
        ValueConversion.area(utilityDecimal, from: from, to: to)
    }

    // MARK: - Volume

    /// 体积单位互转。
    ///
    /// - Parameters:
    ///   - from: 源体积单位。
    ///   - to: 目标体积单位。
    /// - Returns: 转换后的结果。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) -> Decimal {
        ValueConversion.volume(utilityDecimal, from: from, to: to)
    }

    // MARK: - Time

    /// 时间单位互转。
    ///
    /// - Parameters:
    ///   - from: 源时间单位。
    ///   - to: 目标时间单位。
    /// - Returns: 转换后的结果。
    func convertTime(from: TimeUnit, to: TimeUnit) -> Decimal {
        ValueConversion.time(utilityDecimal, from: from, to: to)
    }

    /// 比较两个时间值大小。
    ///
    /// - Parameters:
    ///   - other: 另一时间值。
    ///   - selfUnit: 当前值时间单位。
    ///   - otherUnit: 另一值时间单位。
    /// - Returns: 比较结果。
    func compareTime<T: BinaryInteger>(with other: T, selfUnit: TimeUnit, otherUnit: TimeUnit) -> ComparisonResult {
        ValueConversion.compareTime(utilityDecimal, lhsUnit: selfUnit, other.utilityDecimal, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值。
    ///
    /// - Parameters:
    ///   - other: 另一时间值。
    ///   - selfUnit: 当前值时间单位。
    ///   - otherUnit: 另一值时间单位。
    ///   - resultUnit: 差值输出单位。
    /// - Returns: `other - self` 的差值。
    func timeDifference<T: BinaryInteger>(
        to other: T,
        selfUnit: TimeUnit,
        otherUnit: TimeUnit,
        resultUnit: TimeUnit
    ) -> Decimal {
        ValueConversion.timeDifference(utilityDecimal, lhsUnit: selfUnit, other.utilityDecimal, rhsUnit: otherUnit, resultUnit: resultUnit)
    }

    // MARK: - Temperature

    /// 温度单位互转。
    ///
    /// - Parameters:
    ///   - from: 源温度单位。
    ///   - to: 目标温度单位。
    /// - Returns: 转换后的结果。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        ValueConversion.temperature(utilityDecimal, from: from, to: to)
    }

    // MARK: - Speed

    /// 速度单位互转。
    ///
    /// - Parameters:
    ///   - from: 源速度单位。
    ///   - to: 目标速度单位。
    /// - Returns: 转换后的结果。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) -> Decimal {
        ValueConversion.speed(utilityDecimal, from: from, to: to)
    }

    // MARK: - Radix

    /// 数字转目标进制字符串。
    ///
    /// - Parameters:
    ///   - to: 目标进制（2...36）。
    ///   - uppercase: 字母是否大写。
    /// - Returns: 转换后的进制字符串。
    /// - Throws: `ConversionError.invalidBase`、`ConversionError.overflow`。
    func convertRadix(to: Int, uppercase: Bool = true) throws -> String {
        guard (2...36).contains(to) else {
            throw ConversionError.invalidBase(to)
        }

        guard let value = Int64(exactly: self) else {
            throw ConversionError.overflow
        }

        return String(value, radix: to, uppercase: uppercase)
    }

    // MARK: - Chinese Numerals

    /// 普通数字转中文大写数字。
    ///
    /// - Returns: 中文大写数字字符串。
    func toChineseUppercaseNumber() -> String {
        ChineseUppercaseConverter.toUppercaseNumber(utilityDecimal)
    }

    /// 普通数字转中文金额大写。
    ///
    /// - Returns: 中文金额大写字符串。
    func toChineseUppercaseCurrency() -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(utilityDecimal)
    }

    // MARK: - Color

    /// 将数字解析为颜色。
    ///
    /// - Parameter hasAlpha: 是否按 `0xRRGGBBAA` 解析。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.overflow`、`ConversionError.invalidColor`
    func toColorRGBA(hasAlpha: Bool = false) throws -> ColorRGBA {
        guard let packed = Int(exactly: self) else {
            throw ConversionError.overflow
        }
        return try ColorRGBA.fromPackedInt(packed, hasAlpha: hasAlpha)
    }

    /// 将数字颜色值输出为十六进制字符串。
    ///
    /// - Parameters:
    ///   - hasAlpha: 是否按 `0xRRGGBBAA` 解析。
    ///   - prefixHash: 是否输出 `#`。
    /// - Returns: 十六进制颜色字符串。
    /// - Throws: `ConversionError.overflow`、`ConversionError.invalidColor`
    func toColorHex(hasAlpha: Bool = false, prefixHash: Bool = true) throws -> String {
        try toColorRGBA(hasAlpha: hasAlpha).hexString(includeAlpha: hasAlpha, prefixHash: prefixHash)
    }
}

/// 数字类型转换扩展（浮点）。
public extension BinaryFloatingPoint {
    // MARK: - Length

    /// 长度单位互转。
    func convertLength(from: LengthUnit, to: LengthUnit) -> Decimal {
        ValueConversion.length(utilityDecimal, from: from, to: to)
    }

    // MARK: - Weight

    /// 重量单位互转。
    func convertWeight(from: WeightUnit, to: WeightUnit) -> Decimal {
        ValueConversion.weight(utilityDecimal, from: from, to: to)
    }

    // MARK: - Area

    /// 面积单位互转。
    func convertArea(from: AreaUnit, to: AreaUnit) -> Decimal {
        ValueConversion.area(utilityDecimal, from: from, to: to)
    }

    // MARK: - Volume

    /// 体积单位互转。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) -> Decimal {
        ValueConversion.volume(utilityDecimal, from: from, to: to)
    }

    // MARK: - Time

    /// 时间单位互转。
    func convertTime(from: TimeUnit, to: TimeUnit) -> Decimal {
        ValueConversion.time(utilityDecimal, from: from, to: to)
    }

    /// 比较两个时间值大小。
    func compareTime<T: BinaryFloatingPoint>(with other: T, selfUnit: TimeUnit, otherUnit: TimeUnit) -> ComparisonResult {
        ValueConversion.compareTime(utilityDecimal, lhsUnit: selfUnit, other.utilityDecimal, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值。
    func timeDifference<T: BinaryFloatingPoint>(
        to other: T,
        selfUnit: TimeUnit,
        otherUnit: TimeUnit,
        resultUnit: TimeUnit
    ) -> Decimal {
        ValueConversion.timeDifference(utilityDecimal, lhsUnit: selfUnit, other.utilityDecimal, rhsUnit: otherUnit, resultUnit: resultUnit)
    }

    // MARK: - Temperature

    /// 温度单位互转。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        ValueConversion.temperature(utilityDecimal, from: from, to: to)
    }

    // MARK: - Speed

    /// 速度单位互转。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) -> Decimal {
        ValueConversion.speed(utilityDecimal, from: from, to: to)
    }

    // MARK: - Chinese Numerals

    /// 普通数字转中文大写数字。
    func toChineseUppercaseNumber() -> String {
        ChineseUppercaseConverter.toUppercaseNumber(utilityDecimal)
    }

    /// 普通数字转中文金额大写。
    func toChineseUppercaseCurrency() -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(utilityDecimal)
    }
}

/// 数字类型转换扩展（Decimal）。
public extension Decimal {
    // MARK: - Length

    /// 长度单位互转。
    func convertLength(from: LengthUnit, to: LengthUnit) -> Decimal {
        ValueConversion.length(self, from: from, to: to)
    }

    // MARK: - Weight

    /// 重量单位互转。
    func convertWeight(from: WeightUnit, to: WeightUnit) -> Decimal {
        ValueConversion.weight(self, from: from, to: to)
    }

    // MARK: - Area

    /// 面积单位互转。
    func convertArea(from: AreaUnit, to: AreaUnit) -> Decimal {
        ValueConversion.area(self, from: from, to: to)
    }

    // MARK: - Volume

    /// 体积单位互转。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) -> Decimal {
        ValueConversion.volume(self, from: from, to: to)
    }

    // MARK: - Time

    /// 时间单位互转。
    func convertTime(from: TimeUnit, to: TimeUnit) -> Decimal {
        ValueConversion.time(self, from: from, to: to)
    }

    /// 比较两个时间值大小。
    func compareTime(with other: Decimal, selfUnit: TimeUnit, otherUnit: TimeUnit) -> ComparisonResult {
        ValueConversion.compareTime(self, lhsUnit: selfUnit, other, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值。
    func timeDifference(to other: Decimal, selfUnit: TimeUnit, otherUnit: TimeUnit, resultUnit: TimeUnit) -> Decimal {
        ValueConversion.timeDifference(self, lhsUnit: selfUnit, other, rhsUnit: otherUnit, resultUnit: resultUnit)
    }

    // MARK: - Temperature

    /// 温度单位互转。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        ValueConversion.temperature(self, from: from, to: to)
    }

    // MARK: - Speed

    /// 速度单位互转。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) -> Decimal {
        ValueConversion.speed(self, from: from, to: to)
    }

    // MARK: - Chinese Numerals

    /// 普通数字转中文大写数字。
    func toChineseUppercaseNumber() -> String {
        ChineseUppercaseConverter.toUppercaseNumber(self)
    }

    /// 普通数字转中文金额大写。
    func toChineseUppercaseCurrency() -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(self)
    }
}
