import Foundation

/// 长度单位（以米 `meter` 为基准单位）。
public enum LengthUnit: String, CaseIterable {
    /// 皮米（pm）
    case picometer
    /// 纳米（nm）
    case nanometer
    /// 微米（μm）
    case micrometer
    /// 毫米（mm）
    case millimeter
    /// 厘米（cm）
    case centimeter
    /// 分米（dm）
    case decimeter
    /// 米（m）
    case meter
    /// 千米/公里（km）
    case kilometer
    /// 海里（nmi）
    case nauticalMile
    /// 英里（mi）
    case mile
    /// 弗隆（fur）
    case furlong
    /// 码（yd）
    case yard
    /// 英尺（ft）
    case foot
    /// 英寸（in）
    case inch
    /// 里（市制）
    case li
    /// 丈（市制）
    case zhang
    /// 尺（市制）
    case chi
    /// 寸（市制）
    case cun
    /// 分（市制）
    case fen
    /// 厘（市制）
    case liSmall
    /// 毫（市制）
    case hao
    /// 光年（ly）
    case lightYear
}

public extension LengthUnit {
    /// 获取单位的本地化名称。
    ///
    /// - Parameter locale: 传入 nil 时使用系统首选语言。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `LengthUnit.meter.localizedName()`
    func localizedName(locale: Locale? = nil) -> String {
        SDKLocalization(locale: locale).text("unit.length.\(rawValue)")
    }
}

extension LengthUnit: FactorUnit {
    var factorToBase: Decimal {
        switch self {
        case .picometer: return .literal("0.000000000001")
        case .nanometer: return .literal("0.000000001")
        case .micrometer: return .literal("0.000001")
        case .millimeter: return .literal("0.001")
        case .centimeter: return .literal("0.01")
        case .decimeter: return .literal("0.1")
        case .meter: return 1
        case .kilometer: return 1000
        case .nauticalMile: return 1852
        case .mile: return .literal("1609.344")
        case .furlong: return .literal("201.168")
        case .yard: return .literal("0.9144")
        case .foot: return .literal("0.3048")
        case .inch: return .literal("0.0254")
        case .li: return 500
        case .zhang: return .literal("3.333333333333333333")
        case .chi: return .literal("0.333333333333333333")
        case .cun: return .literal("0.033333333333333333")
        case .fen: return .literal("0.003333333333333333")
        case .liSmall: return .literal("0.000333333333333333")
        case .hao: return .literal("0.000033333333333333")
        case .lightYear: return .literal("9460730472580800")
        }
    }
}
