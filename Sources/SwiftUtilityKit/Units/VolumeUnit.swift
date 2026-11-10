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
    /// 微升（μL）
    case microliter
    /// 立方毫米（mm³）
    case cubicMillimeter
    /// 立方分米（dm³）
    case cubicDecimeter
    /// 立方英尺（ft³）
    case cubicFoot
    /// 立方码（yd³）
    case cubicYard
}

public extension VolumeUnit {
    /// 获取单位的本地化名称。
    ///
    /// - Parameter locale: 传入 nil 时使用系统首选语言。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `VolumeUnit.liter.localizedName()`
    func localizedName(locale: Locale? = nil) -> String {
        SDKLocalization(locale: locale).text("unit.volume.\(rawValue)")
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
        case .cubicCentimeter: return VolumeUnit.milliliter.factorToBase
        case .cubicInch: return .literal("0.016387064")
        case .microliter, .cubicMillimeter: return .literal("0.000001")
        case .cubicDecimeter: return VolumeUnit.liter.factorToBase
        case .cubicFoot: return .literal("28.316846592")
        case .cubicYard: return .literal("764.554857984")
        }
    }
}
