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
    /// 坐标文本无法解析或坐标超出范围。
    case invalidCoordinate(String)
    /// 货币单位与币种不匹配。
    case invalidMoneyUnit(currency: String, unit: String)
    /// 金额包含分以下的尾数，无法精确拆分。
    case inexactCNYAmount

    /// 按系统首选语言返回错误描述。
    public var errorDescription: String? {
        localizedDescription(locale: nil)
    }

    /// 返回指定语言的错误描述。传入 nil 时使用系统首选语言。
    public func localizedDescription(locale: Locale?) -> String {
        let localization = SDKLocalization(locale: locale)
        switch self {
        case .invalidNumber(let raw):
            return localization.format("error.invalidNumber", raw)
        case .invalidBase(let base):
            return localization.format("error.invalidBase", String(base))
        case .invalidRadixValue(let raw, let base):
            return localization.format("error.invalidRadixValue", raw, String(base))
        case .overflow:
            return localization.text("error.overflow")
        case .invalidChineseNumeral(let raw):
            return localization.format("error.invalidChineseNumeral", raw)
        case .invalidColor(let raw):
            return localization.format("error.invalidColor", raw)
        case .invalidDate(let raw):
            return localization.format("error.invalidDate", raw)
        case .invalidCoordinate(let raw):
            return localization.format("error.invalidCoordinate", raw)
        case .invalidMoneyUnit(let currency, let unit):
            return localization.format("error.invalidMoneyUnit", currency, unit)
        case .inexactCNYAmount:
            return localization.text("error.inexactCNYAmount")
        }
    }
}
