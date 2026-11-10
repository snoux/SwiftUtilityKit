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
    /// 元，沿用带符号的表示。
    public let yuan: Int
    public let jiao: Int
    public let fen: Int
    /// 整笔金额是否为负，包含元为 0 的情况。
    public let isNegative: Bool

    /// 初始化人民币元角分结构。
    ///
    /// - Parameters:
    ///   - yuan: 元。
    ///   - jiao: 角。
    ///   - fen: 分。
    public init(yuan: Int, jiao: Int, fen: Int) {
        self.init(yuan: yuan, jiao: jiao, fen: fen, isNegative: yuan < 0)
    }

    /// 初始化元角分。传入负的元或将 `isNegative` 设为 true 时，金额为负。
    public init(yuan: Int, jiao: Int, fen: Int, isNegative: Bool) {
        let isNegative = yuan < 0 || (isNegative && (yuan != 0 || jiao != 0 || fen != 0))
        self.yuan = isNegative && yuan > 0 ? -yuan : yuan
        self.jiao = jiao
        self.fen = fen
        self.isNegative = isNegative
    }
}

/// 拆分元角分时对分以下尾数的处理方式。
public enum CNYRounding: Equatable, Sendable {
    /// 四舍五入到分，中点向远离零的方向舍入。
    case round
    /// 向零截断到分。
    case truncate
    /// 要求金额可精确表示为整数分。
    case exact
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

    /// 将人民币主单位金额四舍五入到分后拆分。
    ///
    /// - Parameter amount: 人民币主单位金额。
    /// - Returns: 拆分结果。
    /// - Precondition: 金额有效，且舍入后的整元部分可用 `Int` 表示。
    public static func splitCNY(_ amount: Decimal) -> CNYParts {
        try! splitCNY(amount, rounding: .round)
    }

    /// 按指定策略拆分元角分。无效金额、精度不足或超出整数范围时抛出错误。
    public static func splitCNY(_ amount: Decimal, rounding: CNYRounding) throws -> CNYParts {
        guard !amount.isNaN else { throw ConversionError.invalidNumber("NaN") }

        let isNegative = amount < 0
        let magnitude = abs(amount)
        let quantized = magnitude.rounded(scale: 2, mode: rounding == .round ? .plain : .down)
        if rounding == .exact, quantized != magnitude {
            throw ConversionError.inexactCNYAmount
        }

        let wholeYuan = quantized.rounded(scale: 0, mode: .down)
        let signedYuan = isNegative ? -wholeYuan : wholeYuan
        guard let yuan = Int(NSDecimalNumber(decimal: signedYuan).stringValue) else {
            throw ConversionError.overflow
        }
        let remainder = NSDecimalNumber(decimal: (quantized - wholeYuan) * 100).intValue
        return CNYParts(yuan: yuan, jiao: remainder / 10, fen: remainder % 10, isNegative: isNegative)
    }

    /// 由人民币元角分组合为主单位金额。
    ///
    /// - Parameters:
    ///   - yuan: 元。
    ///   - jiao: 角。
    ///   - fen: 分。
    /// - Returns: 主单位金额。
    public static func mergeCNY(yuan: Int, jiao: Int, fen: Int) -> Decimal {
        mergeCNY(CNYParts(yuan: yuan, jiao: jiao, fen: fen))
    }

    /// 由拆分结果组合金额，保留不足一元的负金额的符号。
    public static func mergeCNY(_ parts: CNYParts) -> Decimal {
        let magnitude = abs(Decimal(parts.yuan)) + abs(Decimal(parts.jiao)) / 10 + abs(Decimal(parts.fen)) / 100
        return parts.isNegative ? -magnitude : magnitude
    }

    /// 金额格式化（仅用于展示，不做单位换算）。
    ///
    /// - Parameters:
    ///   - amount: 原金额。
    ///   - scale: 小数位（可选）。
    ///   - useGrouping: 是否启用千分位分组。
    ///   - locale: 地区格式，默认使用当前系统设置。
    /// - Returns: 格式化后的金额字符串。
    public static func format(
        _ amount: Decimal,
        scale: Int? = nil,
        useGrouping: Bool = false,
        locale: Locale = .current
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
