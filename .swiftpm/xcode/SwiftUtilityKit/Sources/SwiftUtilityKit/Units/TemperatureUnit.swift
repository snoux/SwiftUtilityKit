import Foundation

/// 温度单位。
public enum TemperatureUnit: String, CaseIterable {
    /// 摄氏度（°C）
    case celsius
    /// 华氏度（°F）
    case fahrenheit
    /// 开尔文（K）
    case kelvin
}

public extension TemperatureUnit {
    /// 获取单位本地化名称（中文/英文）。
    ///
    /// - Parameter locale: 语言环境，默认 `Locale.current`。
    /// - Returns: 本地化后的单位名称。
    func localizedName(locale: Locale = .current) -> String {
        let isChinese = locale.identifier.lowercased().hasPrefix("zh")
        switch self {
        case .celsius: return isChinese ? "摄氏度" : "Celsius"
        case .fahrenheit: return isChinese ? "华氏度" : "Fahrenheit"
        case .kelvin: return isChinese ? "开尔文" : "Kelvin"
        }
    }
}
