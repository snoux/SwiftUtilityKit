import Foundation

/// 日期上下文配置。
public enum DateKit {
    /// 内置日期格式模式。
    public enum Pattern: String, CaseIterable, Sendable {
        /// `yyyy-MM-dd HH:mm:ss`
        case dateTime = "yyyy-MM-dd HH:mm:ss"
        /// `yyyy/MM/dd HH:mm:ss`
        case dateTimeSlash = "yyyy/MM/dd HH:mm:ss"
        /// `yyyy-MM-dd HH:mm`
        case dateMinute = "yyyy-MM-dd HH:mm"
        /// `yyyy/MM/dd HH:mm`
        case dateMinuteSlash = "yyyy/MM/dd HH:mm"
        /// `yyyy-MM-dd`
        case date = "yyyy-MM-dd"
        /// `yyyy/MM/dd`
        case dateSlash = "yyyy/MM/dd"
        /// `yyyyMMddHHmmss`
        case compactDateTime = "yyyyMMddHHmmss"
        /// `yyyyMMdd`
        case compactDate = "yyyyMMdd"
        /// ISO8601（秒）
        case iso8601 = "yyyy-MM-dd'T'HH:mm:ssZ"
        /// ISO8601（毫秒）
        case iso8601Millis = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        /// 自动识别常用模式集合（按常见输入优先级排列）。
        public static let common: [Pattern] = [
            .dateTime,
            .dateTimeSlash,
            .dateMinute,
            .dateMinuteSlash,
            .date,
            .dateSlash,
            .compactDateTime,
            .compactDate,
            .iso8601,
            .iso8601Millis
        ]
    }

    /// 日期上下文（语言、时区、日历）。
    public struct Context: Sendable {
        /// 语言环境（默认中文上下文为 `zh_CN`）。
        public let locale: Locale
        /// 时区（默认中文上下文为 `Asia/Shanghai`）。
        public let timeZone: TimeZone
        /// 日历（默认中文上下文为公历 `gregorian`）。
        public let calendar: Calendar

        public init(locale: Locale, timeZone: TimeZone, calendar: Calendar) {
            var configured = calendar
            configured.timeZone = timeZone
            self.locale = locale
            self.timeZone = timeZone
            self.calendar = configured
        }

        /// 中文 + 东八区 + 公历。
        public static var cn: Context {
            let tz = TimeZone(identifier: "Asia/Shanghai") ?? TimeZone(secondsFromGMT: 8 * 3600) ?? .current
            return Context(
                locale: Locale(identifier: "zh_CN"),
                timeZone: tz,
                calendar: Calendar(identifier: .gregorian)
            )
        }
    }

    /// 内置常见输入日期格式（用于自动识别）。
    public static let commonDateFormats: [String] = Pattern.common.map(\.rawValue)

    /// 内置常见输入日期模式（用于自动识别，顺序即尝试顺序）。
    public static let commonDatePatterns: [Pattern] = [
        .dateTime,
        .dateTimeSlash,
        .dateMinute,
        .dateMinuteSlash,
        .date,
        .dateSlash,
        .compactDateTime,
        .compactDate,
        .iso8601,
        .iso8601Millis
    ]

    /// 默认上下文（全局生效）。
    public static let defaultContext: Context = .cn
}
