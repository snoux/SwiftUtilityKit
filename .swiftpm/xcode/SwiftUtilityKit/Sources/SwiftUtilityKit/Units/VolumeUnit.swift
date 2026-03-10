import Foundation

/// 体积单位（以升 `liter` 为基准单位）。
public enum VolumeUnit: String, CaseIterable {
    /// 毫升（mL）
    case milliliter
    /// 升（L）
    case liter
    /// 立方米（m³）
    case cubicMeter
    /// 茶匙（tsp）
    case teaspoon
    /// 汤匙（tbsp）
    case tablespoon
    /// 杯（cup）
    case cup
    /// 品脱（pt）
    case pint
    /// 加仑（gal）
    case gallon
    /// 立方厘米（cm³）
    case cubicCentimeter
    /// 立方英寸（in³）
    case cubicInch
}

public extension VolumeUnit {
    /// 获取单位本地化名称（中文/英文）。
    ///
    /// - Parameter locale: 语言环境，默认 `Locale.current`。
    /// - Returns: 本地化后的单位名称。
    func localizedName(locale: Locale = .current) -> String {
        let isChinese = locale.identifier.lowercased().hasPrefix("zh")
        switch self {
        case .milliliter: return isChinese ? "毫升" : "milliliter"
        case .liter: return isChinese ? "升" : "liter"
        case .cubicMeter: return isChinese ? "立方米" : "cubic meter"
        case .teaspoon: return isChinese ? "茶匙" : "teaspoon"
        case .tablespoon: return isChinese ? "汤匙" : "tablespoon"
        case .cup: return isChinese ? "杯" : "cup"
        case .pint: return isChinese ? "品脱" : "pint"
        case .gallon: return isChinese ? "加仑" : "gallon"
        case .cubicCentimeter: return isChinese ? "立方厘米" : "cubic centimeter"
        case .cubicInch: return isChinese ? "立方英寸" : "cubic inch"
        }
    }
}

extension VolumeUnit: FactorUnit {
    var factorToBase: Decimal {
        switch self {
        case .milliliter: return .literal("0.001")
        case .liter: return 1
        case .cubicMeter: return .literal("1000")
        case .teaspoon: return .literal("0.00492892159375")
        case .tablespoon: return .literal("0.01478676478125")
        case .cup: return .literal("0.2365882365")
        case .pint: return .literal("0.473176473")
        case .gallon: return .literal("3.785411784")
        case .cubicCentimeter: return .literal("0.001")
        case .cubicInch: return .literal("0.016387064")
        }
    }
}
