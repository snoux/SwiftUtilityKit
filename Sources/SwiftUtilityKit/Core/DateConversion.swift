import Foundation

/// 日期转换与比较工具。
public enum DateConversion {
    /// 时间戳单位。
    public enum TimestampUnit: String, CaseIterable {
        /// 秒级时间戳（如 `1704067200`）。
        case second
        /// 毫秒级时间戳（如 `1704067200000`）。
        case millisecond

        var factor: Decimal {
            switch self {
            case .second: return 1
            case .millisecond: return 1000
            }
        }
    }

    /// 日期差值单位。
    public enum DateDifferenceUnit: String, CaseIterable {
        /// 秒。
        case second
        /// 分钟。
        case minute
        /// 小时。
        case hour
        /// 天（按 24 小时）。
        case day

        var factor: Decimal {
            switch self {
            case .second: return 1
            case .minute: return 60
            case .hour: return 3600
            case .day: return 86400
            }
        }
    }

    /// 相对时间标签。
    public enum RelativeDateTag: String, CaseIterable {
        /// 前天。
        case dayBeforeYesterday
        /// 昨天。
        case yesterday
        /// 今天。
        case today
        /// 明天。
        case tomorrow
        /// 上周。
        case lastWeek
        /// 下周。
        case nextWeek
        /// 去年。
        case lastYear
        /// 明年。
        case nextYear
    }

    /// 将字符串解析为 `Date`。
    ///
    /// - Parameters:
    ///   - text: 输入日期字符串。
    ///   - format: 输入格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 解析后的 `Date`。
    /// - Throws: `ConversionError.invalidDate`
    public static func parse(
        _ text: String,
        format: String,
        context: DateKit.Context = DateKit.defaultContext
    ) throws -> Date {
        let formatter = DateFormatter()
        formatter.locale = context.locale
        formatter.timeZone = context.timeZone
        formatter.dateFormat = format

        guard let date = formatter.date(from: text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ConversionError.invalidDate(text)
        }

        return date
    }

    /// 将 `Date` 格式化为字符串。
    ///
    /// - Parameters:
    ///   - date: 输入日期。
    ///   - format: 输出格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 格式化后的日期字符串。
    public static func format(
        _ date: Date,
        format: String,
        context: DateKit.Context = DateKit.defaultContext
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = context.locale
        formatter.timeZone = context.timeZone
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    /// 比较两个日期字符串。
    ///
    /// - Parameters:
    ///   - lhs: 左侧日期字符串。
    ///   - rhs: 右侧日期字符串。
    ///   - format: 输入格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 比较结果。
    /// - Throws: `ConversionError.invalidDate`
    public static func compare(
        _ lhs: String,
        _ rhs: String,
        format: String,
        context: DateKit.Context = DateKit.defaultContext
    ) throws -> ComparisonResult {
        let left = try parse(lhs, format: format, context: context)
        let right = try parse(rhs, format: format, context: context)
        return left.compare(right)
    }

    /// 计算两个日期字符串的差值。
    ///
    /// - Parameters:
    ///   - lhs: 左侧日期字符串。
    ///   - rhs: 右侧日期字符串。
    ///   - unit: 差值单位。
    ///   - format: 输入格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: `rhs - lhs` 的差值。
    /// - Throws: `ConversionError.invalidDate`
    public static func difference(
        _ lhs: String,
        _ rhs: String,
        unit: DateDifferenceUnit,
        format: String,
        context: DateKit.Context = DateKit.defaultContext
    ) throws -> Decimal {
        let left = try parse(lhs, format: format, context: context)
        let right = try parse(rhs, format: format, context: context)

        let seconds = Decimal(right.timeIntervalSince1970 - left.timeIntervalSince1970)
        return seconds / unit.factor
    }

    /// 时间戳转 `Date`。
    ///
    /// - Parameters:
    ///   - timestamp: 时间戳值。
    ///   - unit: 时间戳单位（秒或毫秒）。
    /// - Returns: 转换后的日期。
    public static func date(from timestamp: Decimal, unit: TimestampUnit = .second) -> Date {
        let seconds = timestamp / unit.factor
        return Date(timeIntervalSince1970: NSDecimalNumber(decimal: seconds).doubleValue)
    }

    /// `Date` 转时间戳。
    ///
    /// - Parameters:
    ///   - date: 输入日期。
    ///   - unit: 时间戳单位（秒或毫秒）。
    /// - Returns: 时间戳值。
    public static func timestamp(from date: Date, unit: TimestampUnit = .second) -> Decimal {
        Decimal(date.timeIntervalSince1970) * unit.factor
    }

    /// 时间戳单位转换。
    ///
    /// - Parameters:
    ///   - value: 原始时间戳。
    ///   - from: 源时间戳单位。
    ///   - to: 目标时间戳单位。
    /// - Returns: 转换后的时间戳。
    public static func convertTimestamp(_ value: Decimal, from: TimestampUnit, to: TimestampUnit) -> Decimal {
        let seconds = value / from.factor
        return seconds * to.factor
    }

    /// 判断目标时间是否在“参考时间往前指定区间”内。
    ///
    /// - Parameters:
    ///   - target: 目标时间。
    ///   - value: 范围值（例如 `7`）。
    ///   - component: 时间粒度（如 `.day`、`.month`）。
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    ///   - inclusive: 是否包含边界。
    /// - Returns: 是否落在指定区间内。
    public static func isWithinPastRange(
        _ target: Date,
        value: Int,
        component: Calendar.Component,
        reference: Date = Date(),
        context: DateKit.Context = DateKit.defaultContext,
        inclusive: Bool = true
    ) -> Bool {
        guard value >= 0 else { return false }
        guard let start = context.calendar.date(byAdding: component, value: -value, to: reference) else {
            return false
        }

        if inclusive {
            return target >= start && target <= reference
        }
        return target > start && target < reference
    }

    /// 判断目标时间是否处于指定起止时间区间。
    ///
    /// - Parameters:
    ///   - target: 目标时间。
    ///   - start: 起始时间。
    ///   - end: 结束时间。
    ///   - inclusive: 是否包含边界。
    /// - Returns: 是否处于指定区间内。
    public static func isInRange(_ target: Date, from start: Date, to end: Date, inclusive: Bool = true) -> Bool {
        let lower = min(start, end)
        let upper = max(start, end)
        if inclusive {
            return target >= lower && target <= upper
        }
        return target > lower && target < upper
    }

    /// 判断目标时间是否符合“昨天/今天/明天/上周/下周/去年/明年”等相对标签。
    ///
    /// - Parameters:
    ///   - target: 目标时间。
    ///   - tag: 相对时间标签。
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否匹配指定相对时间标签。
    public static func isRelative(
        _ target: Date,
        as tag: RelativeDateTag,
        reference: Date = Date(),
        context: DateKit.Context = DateKit.defaultContext
    ) -> Bool {
        let calendar = context.calendar

        switch tag {
        case .today:
            return calendar.isDate(target, inSameDayAs: reference)
        case .yesterday:
            guard let expected = calendar.date(byAdding: .day, value: -1, to: reference) else { return false }
            return calendar.isDate(target, inSameDayAs: expected)
        case .tomorrow:
            guard let expected = calendar.date(byAdding: .day, value: 1, to: reference) else { return false }
            return calendar.isDate(target, inSameDayAs: expected)
        case .dayBeforeYesterday:
            guard let expected = calendar.date(byAdding: .day, value: -2, to: reference) else { return false }
            return calendar.isDate(target, inSameDayAs: expected)
        case .lastWeek:
            guard let expected = calendar.date(byAdding: .weekOfYear, value: -1, to: reference) else { return false }
            return calendar.isDate(target, equalTo: expected, toGranularity: .weekOfYear)
        case .nextWeek:
            guard let expected = calendar.date(byAdding: .weekOfYear, value: 1, to: reference) else { return false }
            return calendar.isDate(target, equalTo: expected, toGranularity: .weekOfYear)
        case .lastYear:
            guard let expected = calendar.date(byAdding: .year, value: -1, to: reference) else { return false }
            return calendar.isDate(target, equalTo: expected, toGranularity: .year)
        case .nextYear:
            guard let expected = calendar.date(byAdding: .year, value: 1, to: reference) else { return false }
            return calendar.isDate(target, equalTo: expected, toGranularity: .year)
        }
    }
}
