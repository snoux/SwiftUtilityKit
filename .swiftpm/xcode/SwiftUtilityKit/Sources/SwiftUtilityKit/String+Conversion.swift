import Foundation

/// 字符串转换扩展。
public extension String {
    // MARK: - 长度

    /// 长度单位互转。
    func convertLength(from: LengthUnit, to: LengthUnit) throws -> Decimal {
        ValueConversion.length(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - 重量

    /// 重量单位互转。
    func convertWeight(from: WeightUnit, to: WeightUnit) throws -> Decimal {
        ValueConversion.weight(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - 面积

    /// 面积单位互转。
    func convertArea(from: AreaUnit, to: AreaUnit) throws -> Decimal {
        ValueConversion.area(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - 体积

    /// 体积单位互转。
    func convertVolume(from: VolumeUnit, to: VolumeUnit) throws -> Decimal {
        ValueConversion.volume(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - 时间

    /// 时间单位互转。
    func convertTime(from: TimeUnit, to: TimeUnit) throws -> Decimal {
        ValueConversion.time(try DecimalParser.parse(self), from: from, to: to)
    }

    /// 比较两个时间值大小。
    ///
    /// - Parameters:
    ///   - other: 右值文本。
    ///   - selfUnit: 当前值单位。
    ///   - otherUnit: 右值单位。
    /// - Returns: 比较结果。
    func compareTime(to other: String, selfUnit: TimeUnit, otherUnit: TimeUnit) throws -> ComparisonResult {
        let lhs = try DecimalParser.parse(self)
        let rhs = try DecimalParser.parse(other)
        return ValueConversion.compareTime(lhs, lhsUnit: selfUnit, rhs, rhsUnit: otherUnit)
    }

    /// 计算两个时间值差值（当前值减右值，可为负）。
    ///
    /// - Parameters:
    ///   - other: 右值文本。
    ///   - selfUnit: 当前值单位。
    ///   - otherUnit: 右值单位。
    ///   - resultUnit: 输出单位，默认秒。
    /// - Returns: 差值。
    func timeDifference(to other: String, selfUnit: TimeUnit, otherUnit: TimeUnit, resultUnit: TimeUnit = .second) throws -> Decimal {
        let lhs = try DecimalParser.parse(self)
        let rhs = try DecimalParser.parse(other)
        return ValueConversion.timeDifference(lhs, lhsUnit: selfUnit, rhs, rhsUnit: otherUnit, resultUnit: resultUnit)
    }

    // MARK: - 温度

    /// 温度单位互转。
    func convertTemperature(from: TemperatureUnit, to: TemperatureUnit) throws -> Decimal {
        ValueConversion.temperature(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - 速度

    /// 速度单位互转。
    func convertSpeed(from: SpeedUnit, to: SpeedUnit) throws -> Decimal {
        ValueConversion.speed(try DecimalParser.parse(self), from: from, to: to)
    }

    // MARK: - 进制

    /// 进制互转。
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

    // MARK: - 中文大写

    /// 普通数字字符串转中文大写数字。
    func toChineseUppercaseNumber() throws -> String {
        ChineseUppercaseConverter.toUppercaseNumber(try DecimalParser.parse(self))
    }

    /// 普通数字字符串转中文金额大写。
    func toChineseUppercaseCurrency() throws -> String {
        ChineseUppercaseConverter.toUppercaseCurrency(try DecimalParser.parse(self))
    }

    /// 中文大写数字（含金额格式）转普通数字。
    func chineseUppercaseToDecimal() throws -> Decimal {
        try ChineseUppercaseConverter.parse(self)
    }

    // MARK: - 颜色

    /// 解析颜色字符串（支持 `#RGB/#RGBA/#RRGGBB/#RRGGBBAA/rgb()/rgba()`）。
    func toColorRGBA() throws -> ColorRGBA {
        try ColorRGBA.parse(self)
    }

    /// 将颜色字符串标准化为十六进制字符串。
    func normalizedColorHex(includeAlpha: Bool = false, prefixHash: Bool = true) throws -> String {
        try toColorRGBA().hexString(includeAlpha: includeAlpha, prefixHash: prefixHash)
    }

    /// 颜色字符串转打包整数。
    func colorToPackedInt(includeAlpha: Bool = false) throws -> Int {
        try toColorRGBA().packedInt(includeAlpha: includeAlpha)
    }
}
