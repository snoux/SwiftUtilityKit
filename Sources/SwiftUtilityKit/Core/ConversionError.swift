import Foundation

/// 转换与解析相关错误。
public enum ConversionError: Error, LocalizedError {
    /// 输入文本无法解析为有效数字。
    case invalidNumber(String)
    /// 进制超出支持范围。
    case invalidBase(Int)
    /// 指定进制下的值非法。
    case invalidRadixValue(String, base: Int)
    /// 转换结果超出支持数值范围。
    case overflow
    /// 中文数字文本无法解析。
    case invalidChineseNumeral(String)
    /// 颜色文本无法解析。
    case invalidColor(String)
    /// 日期文本无法解析。
    case invalidDate(String)
    /// 货币单位与币种不匹配。
    case invalidMoneyUnit(currency: String, unit: String)

    /// 获取本地化错误描述（中文/英文）。
    public var errorDescription: String? {
        let isChinese = Locale.preferredLanguages.first?.hasPrefix("zh") == true

        switch self {
        case .invalidNumber(let raw):
            return isChinese ? "无效数字：\(raw)" : "Invalid numeric value: \(raw)"
        case .invalidBase(let base):
            return isChinese ? "无效进制：\(base)。支持范围 2...36。" : "Invalid base: \(base). Supported range is 2...36."
        case .invalidRadixValue(let raw, let base):
            return isChinese ? "无效进制值：\(raw)（基数 \(base)）" : "Invalid radix value '\(raw)' for base \(base)."
        case .overflow:
            return isChinese ? "转换过程中发生数值溢出。" : "Numeric overflow during conversion."
        case .invalidChineseNumeral(let raw):
            return isChinese ? "无效中文数字：\(raw)" : "Invalid Chinese numeral: \(raw)"
        case .invalidColor(let raw):
            return isChinese ? "无效颜色：\(raw)" : "Invalid color: \(raw)"
        case .invalidDate(let raw):
            return isChinese ? "无效日期：\(raw)" : "Invalid date: \(raw)"
        case .invalidMoneyUnit(let currency, let unit):
            return isChinese
                ? "货币单位不支持：\(currency) 不支持 \(unit)"
                : "Unsupported money unit '\(unit)' for currency '\(currency)'."
        }
    }
}
