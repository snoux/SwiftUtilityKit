import Foundation

/// 转换与解析过程中可能抛出的错误。
public enum ConversionError: Error, LocalizedError {
    /// 输入文本无法解析为有效数字。
    case invalidNumber(String)
    /// 进制超出支持范围。
    case invalidBase(Int)
    /// 指定进制下的值非法。
    case invalidRadixValue(String, base: Int)
    /// 转换后超出支持的数值范围。
    case overflow
    /// 中文数字文本无法解析。
    case invalidChineseNumeral(String)
    /// 颜色文本或颜色值无法解析。
    case invalidColor(String)
    /// 日期文本无法按指定格式解析。
    case invalidDate(String)

    public var errorDescription: String? {
        let isChinese = Locale.preferredLanguages.first?.hasPrefix("zh") == true
        switch self {
        case .invalidNumber(let raw):
            return isChinese ? "无效数字：\(raw)" : "Invalid numeric value: \(raw)"
        case .invalidBase(let base):
            return isChinese
                ? "无效进制：\(base)。支持范围为 2...36。"
                : "Invalid base: \(base). Supported range is 2...36."
        case .invalidRadixValue(let raw, let base):
            return isChinese
                ? "进制值非法：'\(raw)'（进制 \(base)）。"
                : "Invalid radix value '\(raw)' for base \(base)."
        case .overflow:
            return isChinese ? "转换过程中发生数值溢出。" : "Numeric overflow during conversion."
        case .invalidChineseNumeral(let raw):
            return isChinese ? "无效中文数字：\(raw)" : "Invalid Chinese numeral: \(raw)"
        case .invalidColor(let raw):
            return isChinese ? "无效颜色：\(raw)" : "Invalid color value: \(raw)"
        case .invalidDate(let raw):
            return isChinese ? "无效日期：\(raw)" : "Invalid date value: \(raw)"
        }
    }
}
