import Foundation

/// 重量单位（以千克 `kilogram` 为基准单位）。
public enum WeightUnit: String, CaseIterable {
    /// 微克（μg）
    case microgram
    /// 毫克（mg）
    case milligram
    /// 克（g）
    case gram
    /// 千克（kg）
    case kilogram
    /// 吨（t）
    case ton
    /// 盎司（oz）
    case ounce
    /// 磅（lb）
    case pound
    /// 英石（st）
    case stone
    /// 斤（市制）
    case jin
    /// 两（市制）
    case liang
    /// 钱（市制）
    case qian
}

public extension WeightUnit {
    /// 获取单位本地化名称（中文/英文）。
    ///
    /// - Parameter locale: 语言环境，默认 `Locale.current`。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `WeightUnit.kilogram.localizedName()`
    func localizedName(locale: Locale = .current) -> String {
        let isChinese = locale.identifier.lowercased().hasPrefix("zh")
        switch self {
        case .microgram: return isChinese ? "微克" : "microgram"
        case .milligram: return isChinese ? "毫克" : "milligram"
        case .gram: return isChinese ? "克" : "gram"
        case .kilogram: return isChinese ? "千克" : "kilogram"
        case .ton: return isChinese ? "吨" : "ton"
        case .ounce: return isChinese ? "盎司" : "ounce"
        case .pound: return isChinese ? "磅" : "pound"
        case .stone: return isChinese ? "英石" : "stone"
        case .jin: return isChinese ? "斤" : "jin"
        case .liang: return isChinese ? "两" : "liang"
        case .qian: return isChinese ? "钱" : "qian"
        }
    }
}

extension WeightUnit: FactorUnit {
    var factorToBase: Decimal {
        switch self {
        case .microgram: return .literal("0.000000001")
        case .milligram: return .literal("0.000001")
        case .gram: return .literal("0.001")
        case .kilogram: return 1
        case .ton: return 1000
        case .ounce: return .literal("0.028349523125")
        case .pound: return .literal("0.45359237")
        case .stone: return .literal("6.35029318")
        case .jin: return .literal("0.5")
        case .liang: return .literal("0.05")
        case .qian: return .literal("0.005")
        }
    }
}
