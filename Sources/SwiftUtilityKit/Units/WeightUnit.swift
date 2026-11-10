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
    /// 担（市制，1 担 = 100 斤）
    case dan
}

public extension WeightUnit {
    /// 获取单位的本地化名称。
    ///
    /// - Parameter locale: 传入 nil 时使用系统首选语言。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `WeightUnit.kilogram.localizedName()`
    func localizedName(locale: Locale? = nil) -> String {
        SDKLocalization(locale: locale).text("unit.weight.\(rawValue)")
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
        case .dan: return WeightUnit.jin.factorToBase * 100
        }
    }
}
