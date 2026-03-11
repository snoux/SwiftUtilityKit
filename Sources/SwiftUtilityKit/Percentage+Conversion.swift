import Foundation

/// 百分比转换（字符串）。
public extension String {
    /// 百分数转比率，例如 `"12.5" -> 0.125`。
    ///
    /// - Throws: `ConversionError.invalidNumber`
    func percentToRatio() throws -> Decimal {
        PercentageConversion.percentToRatio(try DecimalParser.parse(self))
    }

    /// 比率转百分数，例如 `"0.125" -> 12.5`。
    ///
    /// - Throws: `ConversionError.invalidNumber`
    func ratioToPercent() throws -> Decimal {
        PercentageConversion.ratioToPercent(try DecimalParser.parse(self))
    }

    /// 百分数转比率并输出字符串。
    ///
    /// - Parameter scale: 小数位（可选）。
    /// - Returns: 比率字符串。
    /// - Throws: `ConversionError.invalidNumber`
    func percentToRatioString(scale: Int? = nil) throws -> String {
        try percentToRatio().stringValue(scale: scale)
    }

    /// 比率转百分数并输出字符串。
    ///
    /// - Parameter scale: 小数位（可选）。
    /// - Returns: 百分数字符串。
    /// - Throws: `ConversionError.invalidNumber`
    func ratioToPercentString(scale: Int? = nil) throws -> String {
        try ratioToPercent().stringValue(scale: scale)
    }
}

/// 百分比转换（整数）。
public extension BinaryInteger {
    /// 百分数转比率。
    func percentToRatio() -> Decimal {
        let value = Decimal(string: String(self)) ?? 0
        return PercentageConversion.percentToRatio(value)
    }

    /// 比率转百分数。
    func ratioToPercent() -> Decimal {
        let value = Decimal(string: String(self)) ?? 0
        return PercentageConversion.ratioToPercent(value)
    }
}

/// 百分比转换（浮点）。
public extension BinaryFloatingPoint {
    /// 百分数转比率。
    func percentToRatio() -> Decimal {
        let value = Decimal(string: String(Double(self))) ?? 0
        return PercentageConversion.percentToRatio(value)
    }

    /// 比率转百分数。
    func ratioToPercent() -> Decimal {
        let value = Decimal(string: String(Double(self))) ?? 0
        return PercentageConversion.ratioToPercent(value)
    }
}

/// 百分比转换（Decimal）。
public extension Decimal {
    /// 百分数转比率。
    func percentToRatio() -> Decimal {
        PercentageConversion.percentToRatio(self)
    }

    /// 比率转百分数。
    func ratioToPercent() -> Decimal {
        PercentageConversion.ratioToPercent(self)
    }

    /// 百分数字符串形式。
    ///
    /// - Parameter scale: 小数位（可选）。
    /// - Returns: 百分数字符串。
    func asPercentString(scale: Int? = nil) -> String {
        ratioToPercent().stringValue(scale: scale)
    }
}
