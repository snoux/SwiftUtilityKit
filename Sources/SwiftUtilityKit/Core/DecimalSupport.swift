import Foundation

/// 具备“到基准单位系数”的单位协议。
protocol FactorUnit {
    /// 当前单位转换到基准单位的系数。
    var factorToBase: Decimal { get }
}

/// 基于“基准单位系数法”的通用转换器。
enum FactorUnitConverter {
    /// 执行同一维度内的单位转换。
    ///
    /// - Parameters:
    ///   - value: 输入值。
    ///   - from: 源单位。
    ///   - to: 目标单位。
    /// - Returns: 转换后的值。
    static func convert<U: FactorUnit>(_ value: Decimal, from: U, to: U) -> Decimal {
        value * from.factorToBase / to.factorToBase
    }
}

/// 十进制字符串解析工具。
enum DecimalParser {
    /// 将字符串解析为 `Decimal`。
    ///
    /// - Parameter text: 输入字符串。
    /// - Returns: 解析结果。
    /// - Throws: `ConversionError.invalidNumber`
    /// - Example: `try DecimalParser.parse("123.45")`
    static func parse(_ text: String) throws -> Decimal {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ConversionError.invalidNumber(text)
        }

        let number = NSDecimalNumber(string: trimmed)
        guard number != .notANumber else {
            throw ConversionError.invalidNumber(text)
        }
        return number.decimalValue
    }
}

extension Decimal {
    /// 通过字符串字面值创建 `Decimal`。
    ///
    /// - Parameter text: 十进制字符串。
    /// - Returns: 创建的 `Decimal`。
    /// - Example: `Decimal.literal("0.001")`
    static func literal(_ text: String) -> Decimal {
        NSDecimalNumber(string: text).decimalValue
    }

    /// 返回指定小数位的四舍五入结果。
    ///
    /// - Parameters:
    ///   - scale: 保留小数位。
    ///   - mode: 舍入模式，默认 `.plain`。
    /// - Returns: 舍入后的值。
    /// - Example: `Decimal(string: "1.234")?.rounded(scale: 2)`
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }

    /// 按指定规则输出字符串。
    ///
    /// - Parameters:
    ///   - scale: 可选的小数位。
    ///   - roundingMode: 舍入模式，默认 `.plain`。
    /// - Returns: 字符串结果。
    /// - Example: `Decimal(string: "1.234")?.stringValue(scale: 2)`
    func stringValue(scale: Int? = nil, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        let value = scale.map { rounded(scale: $0, mode: roundingMode) } ?? self
        return NSDecimalNumber(decimal: value).stringValue
    }
}
