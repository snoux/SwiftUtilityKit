import Foundation

/// 字符串金额转换。
public extension String {
    /// 金额单位互转（同币种内部，不涉及汇率）。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    /// - Returns: 转换后的金额。
    /// - Throws: `ConversionError.invalidNumber`、`ConversionError.invalidMoneyUnit`
    func convertMoney(from: MoneyUnit, to: MoneyUnit, currency: CurrencyCode = .cny) throws -> Decimal {
        let value = try DecimalParser.parse(self)
        return try MoneyConversion.convert(value, from: from, to: to, currency: currency)
    }

    /// 金额单位互转并返回字符串。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 转换后的金额字符串。
    /// - Throws: `ConversionError.invalidNumber`、`ConversionError.invalidMoneyUnit`
    func convertMoneyString(
        from: MoneyUnit,
        to: MoneyUnit,
        currency: CurrencyCode = .cny,
        scale: Int? = nil,
        useGrouping: Bool = false
    ) throws -> String {
        let converted = try convertMoney(from: from, to: to, currency: currency)
        return MoneyConversion.format(converted, scale: scale, useGrouping: useGrouping)
    }

    /// 金额字符串格式化（仅用于展示，不做换算）。
    ///
    /// - Parameters:
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 格式化后的金额字符串。
    /// - Throws: `ConversionError.invalidNumber`
    func formattedMoney(scale: Int? = nil, useGrouping: Bool = true) throws -> String {
        MoneyConversion.format(try DecimalParser.parse(self), scale: scale, useGrouping: useGrouping)
    }
}

/// 数字金额转换（整数）。
public extension BinaryInteger {
    /// 金额单位互转（同币种内部，不涉及汇率）。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    /// - Returns: 转换后的金额。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    func convertMoney(from: MoneyUnit, to: MoneyUnit, currency: CurrencyCode = .cny) throws -> Decimal {
        try MoneyConversion.convert(Decimal(string: String(self)) ?? 0, from: from, to: to, currency: currency)
    }

    /// 金额单位互转并返回字符串。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 转换后的金额字符串。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    func convertMoneyString(
        from: MoneyUnit,
        to: MoneyUnit,
        currency: CurrencyCode = .cny,
        scale: Int? = nil,
        useGrouping: Bool = false
    ) throws -> String {
        let converted = try convertMoney(from: from, to: to, currency: currency)
        return MoneyConversion.format(converted, scale: scale, useGrouping: useGrouping)
    }

    /// 金额格式化（仅用于展示，不做换算）。
    ///
    /// - Parameters:
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 格式化后的金额字符串。
    func formattedMoney(scale: Int? = nil, useGrouping: Bool = true) -> String {
        MoneyConversion.format(Decimal(string: String(self)) ?? 0, scale: scale, useGrouping: useGrouping)
    }
}

/// 数字金额转换（浮点）。
public extension BinaryFloatingPoint {
    /// 金额单位互转（同币种内部，不涉及汇率）。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    /// - Returns: 转换后的金额。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    func convertMoney(from: MoneyUnit, to: MoneyUnit, currency: CurrencyCode = .cny) throws -> Decimal {
        let value = Decimal(string: String(Double(self))) ?? 0
        return try MoneyConversion.convert(value, from: from, to: to, currency: currency)
    }

    /// 金额单位互转并返回字符串。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 转换后的金额字符串。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    func convertMoneyString(
        from: MoneyUnit,
        to: MoneyUnit,
        currency: CurrencyCode = .cny,
        scale: Int? = nil,
        useGrouping: Bool = false
    ) throws -> String {
        let converted = try convertMoney(from: from, to: to, currency: currency)
        return MoneyConversion.format(converted, scale: scale, useGrouping: useGrouping)
    }

    /// 金额格式化（仅用于展示，不做换算）。
    ///
    /// - Parameters:
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 格式化后的金额字符串。
    func formattedMoney(scale: Int? = nil, useGrouping: Bool = true) -> String {
        let value = Decimal(string: String(Double(self))) ?? 0
        return MoneyConversion.format(value, scale: scale, useGrouping: useGrouping)
    }
}

/// 金额转换（Decimal）。
public extension Decimal {
    /// 金额单位互转（同币种内部，不涉及汇率）。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    /// - Returns: 转换后的金额。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    func convertMoney(from: MoneyUnit, to: MoneyUnit, currency: CurrencyCode = .cny) throws -> Decimal {
        try MoneyConversion.convert(self, from: from, to: to, currency: currency)
    }

    /// 金额单位互转并返回字符串。
    ///
    /// - Parameters:
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 转换后的金额字符串。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    func convertMoneyString(
        from: MoneyUnit,
        to: MoneyUnit,
        currency: CurrencyCode = .cny,
        scale: Int? = nil,
        useGrouping: Bool = false
    ) throws -> String {
        let converted = try convertMoney(from: from, to: to, currency: currency)
        return MoneyConversion.format(converted, scale: scale, useGrouping: useGrouping)
    }

    /// 金额格式化（仅用于展示，不做换算）。
    ///
    /// - Parameters:
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    /// - Returns: 格式化后的金额字符串。
    func formattedMoney(scale: Int? = nil, useGrouping: Bool = true) -> String {
        MoneyConversion.format(self, scale: scale, useGrouping: useGrouping)
    }

    /// 人民币主单位金额拆分为元角分。
    func splitCNY() -> CNYParts {
        MoneyConversion.splitCNY(self)
    }
}

/// 人民币元角分工具。
public extension CNYParts {
    /// 元角分合并为人民币主单位金额。
    func toDecimalYuan() -> Decimal {
        MoneyConversion.mergeCNY(yuan: yuan, jiao: jiao, fen: fen)
    }
}
