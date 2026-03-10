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
}

public extension AreaUnit {
    /// 获取单位本地化名称（中文/英文）。
    ///
    /// - Parameter locale: 语言环境，默认 `Locale.current`。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `AreaUnit.squareMeter.localizedName()`
    func localizedName(locale: Locale = .current) -> String {
        let isChinese = locale.identifier.lowercased().hasPrefix("zh")
        switch self {
        case .squareMillimeter: return isChinese ? "平方毫米" : "square millimeter"
        case .squareCentimeter: return isChinese ? "平方厘米" : "square centimeter"
        case .squareDecimeter: return isChinese ? "平方分米" : "square decimeter"
        case .squareMeter: return isChinese ? "平方米" : "square meter"
        case .squareKilometer: return isChinese ? "平方千米" : "square kilometer"
        case .hectare: return isChinese ? "公顷" : "hectare"
        case .acre: return isChinese ? "英亩" : "acre"
        case .squareFoot: return isChinese ? "平方英尺" : "square foot"
        case .squareInch: return isChinese ? "平方英寸" : "square inch"
        case .mu: return isChinese ? "亩" : "mu"
        }
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
        }
    }
}
