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
    // MARK: - 长度

    /// 长度单位互转。
    func convertLength(from: LengthUnit, to: LengthUnit) -> Decimal {
        ValueConversion.length(utilityDecimal, from: from, to: to)
    }

    // MARK: - 重量

    /// 重量单位互转。
    func convertWeight(from: WeightUnit, to: WeightUnit) -> Decimal {
        ValueConversion.weight(utilityDecimal, from: from, to: to)
    }

    // MARK: - 面积

    /// 面积单位互转。
    func convertArea(from: AreaUnit, to: AreaUnit) -> Decimal {
        ValueConversion.area(utilityDecimal, from: from, to: to)
    }

    // MARK: - 体积

    /// 体积单位互转。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) -> Decimal {
        ValueConversion.volume(utilityDecimal, from: from, to: to)
    }

    // MARK: - 时间

    /// 时间单位互转。
    func convertTime(from: TimeUnit, to: TimeUnit) -> Decimal {
        ValueConversion.time(utilityDecimal, from: from, to: to)
    }

    /// 比较两个时间值大小。
    ///
    /// - Parameters:
    ///   - other: 右值。
    ///   - selfUnit: 当前值单位。
    ///   - otherUnit: 右值单位。
    /// - Returns: 比较结果。
    func compareTime(to other: Self, selfUnit: TimeUnit, otherUnit: TimeUnit) -> ComparisonResult {
        ValueConversion.compareTime(utilityDecimal, lhsUnit: selfUnit, Decimal(string: String(other)) ?? 0, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值（当前值减右值，可为负）。
    ///
    /// - Parameters:
    ///   - other: 右值。
    ///   - selfUnit: 当前值单位。
    ///   - otherUnit: 右值单位。
    ///   - resultUnit: 输出单位，默认秒。
    /// - Returns: 差值。
    func timeDifference(to other: Self, selfUnit: TimeUnit, otherUnit: TimeUnit, resultUnit: TimeUnit = .second) -> Decimal {
        ValueConversion.timeDifference(
            utilityDecimal,
            lhsUnit: selfUnit,
            Decimal(string: String(other)) ?? 0,
            rhsUnit: otherUnit,
            resultUnit: resultUnit
        )
    }

    // MARK: - 温度

    /// 温度单位互转。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        ValueConversion.temperature(utilityDecimal, from: from, to: to)
    }

    // MARK: - 速度

    /// 速度单位互转。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) -> Decimal {
        ValueConversion.speed(utilityDecimal, from: from, to: to)
    }

    // MARK: - 进制

    /// 数字转目标进制字符串。
    func convertRadix(to: Int, uppercase: Bool = true) throws -> String {
        guard (2...36).contains(to) else {
            throw ConversionError.invalidBase(to)
        }

        guard let value = Int64(exactly: self) else {
            throw ConversionError.overflow
        }

        return String(value, radix: to, uppercase: uppercase)
    }

    // MARK: - 中文大写

    /// 普通数字转中文大写数字。
    func toChineseUppercaseNumber() -> String {
        ChineseUppercaseConverter.toUppercaseNumber(utilityDecimal)
    }

    /// 普通数字转中文金额大写。
    func toChineseUppercaseCurrency() -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(utilityDecimal)
    }

    // MARK: - 颜色

    /// 将打包颜色整数转换为 RGBA 颜色值。
    func toColorRGBA(hasAlpha: Bool = false) throws -> ColorRGBA {
        guard let intValue = Int(exactly: self) else {
            throw ConversionError.overflow
        }
        return try ColorRGBA.fromPackedInt(intValue, hasAlpha: hasAlpha)
    }

    /// 将打包颜色整数转换为十六进制字符串。
    func toColorHex(hasAlpha: Bool = false, prefixHash: Bool = true) throws -> String {
        try toColorRGBA(hasAlpha: hasAlpha).hexString(includeAlpha: hasAlpha, prefixHash: prefixHash)
    }
}

/// 数字类型转换扩展（浮点）。
public extension BinaryFloatingPoint {
    // MARK: - 长度

    /// 长度单位互转。
    func convertLength(from: LengthUnit, to: LengthUnit) -> Decimal {
        ValueConversion.length(utilityDecimal, from: from, to: to)
    }

    // MARK: - 重量

    /// 重量单位互转。
    func convertWeight(from: WeightUnit, to: WeightUnit) -> Decimal {
        ValueConversion.weight(utilityDecimal, from: from, to: to)
    }

    // MARK: - 面积

    /// 面积单位互转。
    func convertArea(from: AreaUnit, to: AreaUnit) -> Decimal {
        ValueConversion.area(utilityDecimal, from: from, to: to)
    }

    // MARK: - 体积

    /// 体积单位互转。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) -> Decimal {
        ValueConversion.volume(utilityDecimal, from: from, to: to)
    }

    // MARK: - 时间

    /// 时间单位互转。
    func convertTime(from: TimeUnit, to: TimeUnit) -> Decimal {
        ValueConversion.time(utilityDecimal, from: from, to: to)
    }

    /// 比较两个时间值大小。
    func compareTime(to other: Self, selfUnit: TimeUnit, otherUnit: TimeUnit) -> ComparisonResult {
        ValueConversion.compareTime(utilityDecimal, lhsUnit: selfUnit, Decimal(string: String(Double(other))) ?? 0, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值（当前值减右值，可为负）。
    func timeDifference(to other: Self, selfUnit: TimeUnit, otherUnit: TimeUnit, resultUnit: TimeUnit = .second) -> Decimal {
        ValueConversion.timeDifference(
            utilityDecimal,
            lhsUnit: selfUnit,
            Decimal(string: String(Double(other))) ?? 0,
            rhsUnit: otherUnit,
            resultUnit: resultUnit
        )
    }

    // MARK: - 温度

    /// 温度单位互转。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        ValueConversion.temperature(utilityDecimal, from: from, to: to)
    }

    // MARK: - 速度

    /// 速度单位互转。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) -> Decimal {
        ValueConversion.speed(utilityDecimal, from: from, to: to)
    }

    // MARK: - 中文大写

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
    // MARK: - 长度

    /// 长度单位互转。
    func convertLength(from: LengthUnit, to: LengthUnit) -> Decimal {
        ValueConversion.length(self, from: from, to: to)
    }

    // MARK: - 重量

    /// 重量单位互转。
    func convertWeight(from: WeightUnit, to: WeightUnit) -> Decimal {
        ValueConversion.weight(self, from: from, to: to)
    }

    // MARK: - 面积

    /// 面积单位互转。
    func convertArea(from: AreaUnit, to: AreaUnit) -> Decimal {
        ValueConversion.area(self, from: from, to: to)
    }

    // MARK: - 体积

    /// 体积单位互转。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) -> Decimal {
        ValueConversion.volume(self, from: from, to: to)
    }

    // MARK: - 时间

    /// 时间单位互转。
    func convertTime(from: TimeUnit, to: TimeUnit) -> Decimal {
        ValueConversion.time(self, from: from, to: to)
    }

    /// 比较两个时间值大小。
    func compareTime(to other: Decimal, selfUnit: TimeUnit, otherUnit: TimeUnit) -> ComparisonResult {
        ValueConversion.compareTime(self, lhsUnit: selfUnit, other, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值（当前值减右值，可为负）。
    func timeDifference(to other: Decimal, selfUnit: TimeUnit, otherUnit: TimeUnit, resultUnit: TimeUnit = .second) -> Decimal {
        ValueConversion.timeDifference(self, lhsUnit: selfUnit, other, rhsUnit: otherUnit, resultUnit: resultUnit)
    }

    // MARK: - 温度

    /// 温度单位互转。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        ValueConversion.temperature(self, from: from, to: to)
    }

    // MARK: - 速度

    /// 速度单位互转。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) -> Decimal {
        ValueConversion.speed(self, from: from, to: to)
    }

    // MARK: - 中文大写

    /// 普通数字转中文大写数字。
    func toChineseUppercaseNumber() -> String {
        ChineseUppercaseConverter.toUppercaseNumber(self)
    }

    /// 普通数字转中文金额大写。
    func toChineseUppercaseCurrency() -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(self)
    }
}
