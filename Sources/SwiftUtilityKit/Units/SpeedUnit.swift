import Foundation

/// 速度单位（以米每秒 `meterPerSecond` 为基准单位）。
public enum SpeedUnit: String, CaseIterable {
    /// 米每秒（m/s）
    case meterPerSecond
    /// 千米每小时（km/h）
    case kilometerPerHour
    /// 英里每小时（mph）
    case milePerHour
    /// 节（kn，1 节 = 1 海里每小时）
    case knot
    /// 英尺每秒（ft/s）
    case footPerSecond
    /// 英寸每秒（in/s）
    case inchPerSecond
    /// 千米每秒（km/s）
    case kilometerPerSecond
    /// 海里每秒（nmi/s）
    case nauticalMilePerSecond
    /// 真空光速（c，精确值 299 792 458 m/s）
    case speedOfLight
    /// 20°C 空气中的参考声速，约 343 m/s。
    case speedOfSound
    /// 马赫数。默认以 20°C 空气中的近似声速为参考。
    case mach
}

public extension SpeedUnit {
    /// 获取单位的本地化名称。
    ///
    /// - Parameter locale: 传入 nil 时使用系统首选语言。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `SpeedUnit.meterPerSecond.localizedName()`
    func localizedName(locale: Locale? = nil) -> String {
        SDKLocalization(locale: locale).text("unit.speed.\(rawValue)")
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
        case .inchPerSecond: return LengthUnit.inch.factorToBase
        case .kilometerPerSecond: return LengthUnit.kilometer.factorToBase
        case .nauticalMilePerSecond: return LengthUnit.nauticalMile.factorToBase
        case .speedOfLight: return 299_792_458
        case .speedOfSound, .mach: return 343
        }
    }
}
