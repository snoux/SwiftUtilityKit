import Foundation

/// 面积单位（以平方米 `squareMeter` 为基准单位）。
public enum AreaUnit: String, CaseIterable {
    /// 平方毫米（mm²）
    case squareMillimeter
    /// 平方厘米（cm²）
    case squareCentimeter
    /// 平方分米（dm²）
    case squareDecimeter
    /// 平方米（m²）
    case squareMeter
    /// 平方千米（km²）
    case squareKilometer
    /// 公顷（ha）
    case hectare
    /// 英亩（acre）
    case acre
    /// 平方英尺（ft²）
    case squareFoot
    /// 平方英寸（in²）
    case squareInch
    /// 亩（市制）
    case mu
    /// 市顷（1 顷 = 100 市亩）
    case qing
    /// 公亩（a）
    case are
    /// 平方码（yd²）
    case squareYard
    /// 平方英里（mi²）
    case squareMile
}

public extension AreaUnit {
    /// 获取单位的本地化名称。
    ///
    /// - Parameter locale: 传入 nil 时使用系统首选语言。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `AreaUnit.squareMeter.localizedName()`
    func localizedName(locale: Locale? = nil) -> String {
        SDKLocalization(locale: locale).text("unit.area.\(rawValue)")
    }
}

extension AreaUnit: FactorUnit {
    var factorToBase: Decimal {
        switch self {
        case .squareMillimeter: return .literal("0.000001")
        case .squareCentimeter: return .literal("0.0001")
        case .squareDecimeter: return .literal("0.01")
        case .squareMeter: return 1
        case .squareKilometer: return .literal("1000000")
        case .hectare: return .literal("10000")
        case .acre: return .literal("4046.8564224")
        case .squareFoot: return .literal("0.09290304")
        case .squareInch: return .literal("0.00064516")
        case .mu: return .literal("666.6666666666666667")
        case .qing: return AreaUnit.mu.factorToBase * 100
        case .are: return 100
        case .squareYard: return .literal("0.83612736")
        case .squareMile: return .literal("2589988.110336")
        }
    }
}
