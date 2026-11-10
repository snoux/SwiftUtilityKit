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
    /// 获取单位的本地化名称。
    ///
    /// - Parameter locale: 传入 nil 时使用系统首选语言。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `TemperatureUnit.celsius.localizedName()`
    func localizedName(locale: Locale? = nil) -> String {
        SDKLocalization(locale: locale).text("unit.temperature.\(rawValue)")
    }
}
