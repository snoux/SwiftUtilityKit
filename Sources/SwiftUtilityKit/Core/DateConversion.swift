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
    public static func date(from timestamp: Decimal, unit: TimestampUnit = .second) -> Date {
        let seconds = timestamp / unit.factor
        return Date(timeIntervalSince1970: NSDecimalNumber(decimal: seconds).doubleValue)
    }

    /// `Date` 转时间戳。
    public static func timestamp(from date: Date, unit: TimestampUnit = .second) -> Decimal {
        Decimal(date.timeIntervalSince1970) * unit.factor
    }

    /// 时间戳单位转换。
    public static func convertTimestamp(_ value: Decimal, from: TimestampUnit, to: TimestampUnit) -> Decimal {
        let seconds = value / from.factor
        return seconds * to.factor
    }

    /// 判断目标时间是否在“参考时间往前指定区间”内。
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
    public static func isInRange(_ target: Date, from start: Date, to end: Date, inclusive: Bool = true) -> Bool {
        let lower = min(start, end)
        let upper = max(start, end)
        if inclusive {
            return target >= lower && target <= upper
        }
        return target > lower && target < upper
    }

    /// 判断目标时间是否符合“昨天/今天/明天/上周/下周/去年/明年”等相对标签。
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
            return calendar.isDateInYesterday(target)
        case .tomorrow:
            return calendar.isDateInTomorrow(target)
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
