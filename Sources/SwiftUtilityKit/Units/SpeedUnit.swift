import Foundation

/// 速度单位（以米每秒 `meterPerSecond` 为基准单位）。
public enum SpeedUnit: String, CaseIterable {
    /// 米每秒（m/s）
    case meterPerSecond
    /// 千米每小时（km/h）
    case kilometerPerHour
    /// 英里每小时（mph）
    case milePerHour
    /// 节（kn）
    case knot
    /// 英尺每秒（ft/s）
    case footPerSecond
}

public extension SpeedUnit {
    /// 获取单位本地化名称（中文/英文）。
    ///
    /// - Parameter locale: 语言环境，默认 `Locale.current`。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `SpeedUnit.meterPerSecond.localizedName()`
    func localizedName(locale: Locale = .current) -> String {
        let isChinese = locale.identifier.lowercased().hasPrefix("zh")
        switch self {
        case .meterPerSecond: return isChinese ? "米每秒" : "meter per second"
        case .kilometerPerHour: return isChinese ? "千米每小时" : "kilometer per hour"
        case .milePerHour: return isChinese ? "英里每小时" : "mile per hour"
        case .knot: return isChinese ? "节" : "knot"
        case .footPerSecond: return isChinese ? "英尺每秒" : "foot per second"
        }
    }
}

extension SpeedUnit: FactorUnit {
    var factorToBase: Decimal {
        switch self {
        case .meterPerSecond: return 1
        case .kilometerPerHour: return .literal("0.2777777777777778")
        case .milePerHour: return .literal("0.44704")
        case .knot: return .literal("0.5144444444444444")
        case .footPerSecond: return .literal("0.3048")
        }
    }
}
