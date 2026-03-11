import Foundation

/// 货币类型。
public enum CurrencyCode: String, CaseIterable, Sendable {
    /// 人民币。
    case cny
    /// 美元。
    case usd
    /// 欧元。
    case eur
    /// 英镑。
    case gbp
    /// 日元。
    case jpy

    /// 主单位小数精度（即最小单位是主单位的 10^-fractionDigits）。
    public var fractionDigits: Int {
        switch self {
        case .jpy:
            return 0
        case .cny, .usd, .eur, .gbp:
            return 2
        }
    }

    /// 主单位名称。
    public var majorUnitName: String {
        switch self {
        case .cny:
            return "yuan"
        case .usd:
            return "dollar"
        case .eur:
            return "euro"
        case .gbp:
            return "pound"
        case .jpy:
            return "yen"
        }
    }

    /// 次单位名称。
    public var minorUnitName: String {
        switch self {
        case .cny:
            return "fen"
        case .usd:
            return "cent"
        case .eur:
            return "cent"
        case .gbp:
            return "pence"
        case .jpy:
            return "yen"
        }
    }
}

/// 金额单位层级。
public enum MoneyUnit: Int, CaseIterable, Sendable {
    /// 主单位（如元/美元/欧元）。
    case major = 0
    /// 1/10 主单位（如角）。
    case tenth = 1
    /// 1/100 主单位（如分/美分）。
    case minor = 2

    var power: Int { rawValue }
}

/// 人民币的元角分拆分结果。
public struct CNYParts: Equatable, Sendable {
    public let yuan: Int
    public let jiao: Int
    public let fen: Int

    /// 初始化人民币元角分结构。
    ///
    /// - Parameters:
    ///   - yuan: 元。
    ///   - jiao: 角。
    ///   - fen: 分。
    public init(yuan: Int, jiao: Int, fen: Int) {
        self.yuan = yuan
        self.jiao = jiao
        self.fen = fen
    }
}

/// 金额转换工具（不涉及汇率）。
public enum MoneyConversion {
    /// 金额单位互转（同一币种内部，不涉及汇率）。
    ///
    /// - Parameters:
    ///   - amount: 原金额。
    ///   - from: 源金额单位。
    ///   - to: 目标金额单位。
    ///   - currency: 币种，默认人民币。
    /// - Returns: 转换后的金额。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    public static func convert(
        _ amount: Decimal,
        from: MoneyUnit,
        to: MoneyUnit,
        currency: CurrencyCode = .cny
    ) throws -> Decimal {
        try validate(unit: from, for: currency)
        try validate(unit: to, for: currency)

        let fromFactor = decimalPow10(from.power)
        let toFactor = decimalPow10(to.power)
        return amount * toFactor / fromFactor
    }

    /// 将人民币主单位金额拆分为元角分。
    ///
    /// - Parameter amount: 人民币主单位金额。
    /// - Returns: 拆分结果。
    public static func splitCNY(_ amount: Decimal) -> CNYParts {
        let fenDecimal = (amount * 100).rounded(scale: 0, mode: .plain)
        let fenTotal = NSDecimalNumber(decimal: fenDecimal).intValue
        let sign = fenTotal < 0 ? -1 : 1
        let absValue = Swift.abs(fenTotal)

        let yuan = absValue / 100
        let jiao = (absValue % 100) / 10
        let fen = absValue % 10

        return CNYParts(yuan: yuan * sign, jiao: jiao, fen: fen)
    }

    /// 由人民币元角分组合为主单位金额。
    ///
    /// - Parameters:
    ///   - yuan: 元。
    ///   - jiao: 角。
    ///   - fen: 分。
    /// - Returns: 主单位金额。
    public static func mergeCNY(yuan: Int, jiao: Int, fen: Int) -> Decimal {
        let sign: Decimal = yuan < 0 ? -1 : 1
        let absYuan = Swift.abs(yuan)
        let totalFen = absYuan * 100 + Swift.abs(jiao) * 10 + Swift.abs(fen)
        let amount = Decimal(totalFen) / 100
        return amount * sign
    }

    /// 金额格式化（仅用于展示，不做单位换算）。
    ///
    /// - Parameters:
    ///   - amount: 原金额。
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    ///   - locale: 语言环境，默认中文。
    /// - Returns: 格式化后的金额字符串。
    public static func format(
        _ amount: Decimal,
        scale: Int? = nil,
        useGrouping: Bool = false,
        locale: Locale = Locale(identifier: "zh_CN")
    ) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = useGrouping

        if let scale {
            let rounded = amount.rounded(scale: scale)
            formatter.minimumFractionDigits = max(0, scale)
            formatter.maximumFractionDigits = max(0, scale)
            return formatter.string(from: NSDecimalNumber(decimal: rounded))
                ?? NSDecimalNumber(decimal: rounded).stringValue
        }

        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 16
        return formatter.string(from: NSDecimalNumber(decimal: amount))
            ?? NSDecimalNumber(decimal: amount).stringValue
    }

    /// 校验币种支持的金额单位层级。
    ///
    /// - Parameters:
    ///   - unit: 目标单位层级。
    ///   - currency: 币种。
    /// - Throws: `ConversionError.invalidMoneyUnit`
    private static func validate(unit: MoneyUnit, for currency: CurrencyCode) throws {
        guard unit.power <= currency.fractionDigits else {
            throw ConversionError.invalidMoneyUnit(currency: currency.rawValue.uppercased(), unit: String(describing: unit))
        }
    }

    /// 计算 10 的幂（Decimal）。
    ///
    /// - Parameter power: 幂指数。
    /// - Returns: `10^power` 的十进制结果。
    private static func decimalPow10(_ power: Int) -> Decimal {
        if power <= 0 { return 1 }
        var result: Decimal = 1
        for _ in 0..<power {
            result *= 10
        }
        return result
    }
}
