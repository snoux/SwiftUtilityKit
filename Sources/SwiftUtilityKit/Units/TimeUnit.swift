import Foundation

/// 时间单位（以秒 `second` 为基准单位）。
public enum TimeUnit: String, CaseIterable {
    /// 纳秒（ns）
    case nanosecond
    /// 微秒（μs）
    case microsecond
    /// 毫秒（ms）
    case millisecond
    /// 秒（s）
    case second
    /// 分钟（min）
    case minute
    /// 小时（h）
    case hour
    /// 天（d）
    case day
    /// 周（week）
    case week
}

public extension TimeUnit {
    /// 获取单位本地化名称（中文/英文）。
    ///
    /// - Parameter locale: 语言环境，默认 `Locale.current`。
    /// - Returns: 本地化后的单位名称。
    /// - Example: `TimeUnit.second.localizedName()`
    func localizedName(locale: Locale = .current) -> String {
        let isChinese = locale.identifier.lowercased().hasPrefix("zh")
        switch self {
        case .nanosecond: return isChinese ? "纳秒" : "nanosecond"
        case .microsecond: return isChinese ? "微秒" : "microsecond"
        case .millisecond: return isChinese ? "毫秒" : "millisecond"
        case .second: return isChinese ? "秒" : "second"
        case .minute: return isChinese ? "分钟" : "minute"
        case .hour: return isChinese ? "小时" : "hour"
        case .day: return isChinese ? "天" : "day"
        case .week: return isChinese ? "周" : "week"
        }
    }
}

extension TimeUnit: FactorUnit {
    var factorToBase: Decimal {
        switch self {
        case .nanosecond: return .literal("0.000000001")
        case .microsecond: return .literal("0.000001")
        case .millisecond: return .literal("0.001")
        case .second: return 1
        case .minute: return 60
        case .hour: return 3600
        case .day: return 86400
        case .week: return 604800
        }
    }
}
