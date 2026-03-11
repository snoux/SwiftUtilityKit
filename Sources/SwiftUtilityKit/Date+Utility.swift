import Foundation

/// 日期相对判断代理。
///
/// 调用链说明：
/// 1. `String` 先通过 `date(_:in:)` 解析为 `Date`
/// 2. 再通过 `relative(to:in:)` 绑定参考时间与上下文
/// 3. 最后读取 `isYesterday / isToday / ...` 等语义属性
///
/// 示例：
/// `try "2026-03-09 12:00:00".relative("yyyy-MM-dd HH:mm:ss", to: ref, in: .cn).isYesterday`
public struct DateRelativeProxy: Sendable {
    public let target: Date
    public let reference: Date
    public let context: DateKit.Context

    /// 初始化相对时间代理。
    ///
    /// - Parameters:
    ///   - target: 目标时间。
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    public init(target: Date, reference: Date, context: DateKit.Context) {
        self.target = target
        self.reference = reference
        self.context = context
    }

    /// 通用相对时间判断入口。
    ///
    /// - Parameter tag: 相对时间标签（如昨天、今天、上周等）。
    /// - Returns: 是否匹配指定相对时间标签。
    public func matches(_ tag: DateConversion.RelativeDateTag) -> Bool {
        DateConversion.isRelative(target, as: tag, reference: reference, context: context)
    }

    /// 目标时间是否为参考时间的前天。
    public var isDayBeforeYesterday: Bool {
        matches(.dayBeforeYesterday)
    }

    /// 目标时间是否为参考时间的昨天。
    public var isYesterday: Bool {
        matches(.yesterday)
    }

    /// 目标时间是否与参考时间同一天。
    public var isToday: Bool {
        matches(.today)
    }

    /// 目标时间是否为参考时间的明天。
    public var isTomorrow: Bool {
        matches(.tomorrow)
    }

    /// 目标时间是否处于参考时间的上周。
    public var isLastWeek: Bool {
        matches(.lastWeek)
    }

    /// 目标时间是否处于参考时间的下周。
    public var isNextWeek: Bool {
        matches(.nextWeek)
    }

    /// 目标时间是否处于参考时间的去年。
    public var isLastYear: Bool {
        matches(.lastYear)
    }

    /// 目标时间是否处于参考时间的明年。
    public var isNextYear: Bool {
        matches(.nextYear)
    }

    /// 判断是否在参考时间往前指定范围内。
    ///
    /// - Parameters:
    ///   - value: 范围值（例如 `7`）。
    ///   - component: 时间粒度（如 `.day`、`.month`）。
    ///   - inclusive: 是否包含边界。
    /// - Returns: 是否落在参考时间往前的指定范围内。
    public func withinPast(_ value: Int, _ component: Calendar.Component, inclusive: Bool = true) -> Bool {
        DateConversion.isWithinPastRange(
            target,
            value: value,
            component: component,
            reference: reference,
            context: context,
            inclusive: inclusive
        )
    }
}

/// 日期工具扩展。
public extension Date {
    /// 当天起始时间（00:00:00）。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 当前日期所在天的起始时间。
    func startOfDay(in context: DateKit.Context = DateKit.defaultContext) -> Date {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        return calendar.startOfDay(for: self)
    }

    /// 当天结束时间（23:59:59）。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 当前日期所在天的结束时间。
    func endOfDay(in context: DateKit.Context = DateKit.defaultContext) -> Date {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        let start = calendar.startOfDay(for: self)
        let next = calendar.date(byAdding: .day, value: 1, to: start) ?? self
        return next.addingTimeInterval(-1)
    }

    /// 本周起始时间（按上下文 `Calendar` 的周规则）。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 当前日期所在周的起始时间。
    func startOfWeek(in context: DateKit.Context = DateKit.defaultContext) -> Date {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        return calendar.dateInterval(of: .weekOfYear, for: self)?.start ?? startOfDay(in: context)
    }

    /// 本周结束时间。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 当前日期所在周的结束时间。
    func endOfWeek(in context: DateKit.Context = DateKit.defaultContext) -> Date {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        guard let end = calendar.dateInterval(of: .weekOfYear, for: self)?.end else {
            return endOfDay(in: context)
        }
        return end.addingTimeInterval(-1)
    }

    /// 本月起始时间。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 当前日期所在月的起始时间。
    func startOfMonth(in context: DateKit.Context = DateKit.defaultContext) -> Date {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        return calendar.dateInterval(of: .month, for: self)?.start ?? startOfDay(in: context)
    }

    /// 本月结束时间。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 当前日期所在月的结束时间。
    func endOfMonth(in context: DateKit.Context = DateKit.defaultContext) -> Date {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        guard let end = calendar.dateInterval(of: .month, for: self)?.end else {
            return endOfDay(in: context)
        }
        return end.addingTimeInterval(-1)
    }

    /// 日期加减（例如加 7 天、减 1 月）。
    ///
    /// - Parameters:
    ///   - value: 增减值（正数为增加，负数为减少）。
    ///   - component: 时间粒度（如 `.day`、`.month`）。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 计算后的日期；无法计算时返回 `nil`。
    func adding(
        _ value: Int,
        _ component: Calendar.Component,
        in context: DateKit.Context = DateKit.defaultContext
    ) -> Date? {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        return calendar.date(byAdding: component, value: value, to: self)
    }

    /// 是否与另一个时间处于同一天。
    ///
    /// - Parameters:
    ///   - other: 对比时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为同一天。
    func isSameDay(as other: Date, in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        return calendar.isDate(self, inSameDayAs: other)
    }

    /// 是否为周末。
    ///
    /// - Parameter context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为周末。
    func isWeekend(in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        return calendar.isDateInWeekend(self)
    }

    /// 计算到另一个日期的“天数差”（按自然日，不含小数）。
    ///
    /// - Parameters:
    ///   - other: 目标日期。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: `other - self` 的自然日差值。
    func days(to other: Date, in context: DateKit.Context = DateKit.defaultContext) -> Int {
        var calendar = context.calendar
        calendar.timeZone = context.timeZone
        let from = calendar.startOfDay(for: self)
        let to = calendar.startOfDay(for: other)
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    /// 日期格式化。
    ///
    /// - Parameters:
    ///   - format: 输出日期格式。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 格式化后的日期字符串。
    func formatted(_ format: String, in context: DateKit.Context = DateKit.defaultContext) -> String {
        DateConversion.format(self, format: format, context: context)
    }

    /// 转换为时间戳。
    ///
    /// - Parameter unit: 时间戳单位（秒或毫秒）。
    /// - Returns: 时间戳值。
    func timestamp(unit: DateConversion.TimestampUnit = .second) -> Decimal {
        DateConversion.timestamp(from: self, unit: unit)
    }

    /// 相对时间代理（昨天/今天/明天等）。
    ///
    /// - Parameters:
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 绑定参考时间与上下文的相对判断代理。
    func relative(to reference: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> DateRelativeProxy {
        DateRelativeProxy(target: self, reference: reference, context: context)
    }

    /// 判断是否在指定区间。
    ///
    /// - Parameters:
    ///   - start: 起始时间。
    ///   - end: 结束时间。
    ///   - inclusive: 是否包含边界。
    /// - Returns: 是否在区间内。
    func isInRange(from start: Date, to end: Date, inclusive: Bool = true) -> Bool {
        DateConversion.isInRange(self, from: start, to: end, inclusive: inclusive)
    }

    /// 判断是否在指定区间（语义化别名）。
    ///
    /// - Parameters:
    ///   - start: 起始时间。
    ///   - end: 结束时间。
    ///   - inclusive: 是否包含边界。
    /// - Returns: 是否在区间内。
    func isBetween(_ start: Date, and end: Date, inclusive: Bool = true) -> Bool {
        isInRange(from: start, to: end, inclusive: inclusive)
    }

    /// 判断是否为前天。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的前天。
    func isDayBeforeYesterday(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isDayBeforeYesterday
    }

    /// 判断是否为昨天。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的昨天。
    func isYesterday(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isYesterday
    }

    /// 判断是否为今天。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否与参考时间同一天。
    func isToday(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isToday
    }

    /// 判断是否为明天。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的明天。
    func isTomorrow(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isTomorrow
    }

    /// 判断是否为上周。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的上周。
    func isLastWeek(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isLastWeek
    }

    /// 判断是否为下周。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的下周。
    func isNextWeek(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isNextWeek
    }

    /// 判断是否为去年。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的去年。
    func isLastYear(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isLastYear
    }

    /// 判断是否为明年。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    /// - Returns: 是否为参考时间的明年。
    func isNextYear(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) -> Bool {
        relative(to: ref, in: context).isNextYear
    }

    /// 判断是否在参考时间往前指定范围内。
    ///
    /// - Parameters:
    ///   - value: 范围值（例如 `7`）。
    ///   - component: 时间粒度（如 `.day`、`.month`）。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（默认中文东八区公历）。
    ///   - inclusive: 是否包含边界。
    /// - Returns: 是否落在参考时间往前的指定范围内。
    func isWithinPast(
        _ value: Int,
        _ component: Calendar.Component,
        ref: Date = Date(),
        in context: DateKit.Context = DateKit.defaultContext,
        inclusive: Bool = true
    ) -> Bool {
        relative(to: ref, in: context).withinPast(value, component, inclusive: inclusive)
    }

    /// 时间戳转日期。
    ///
    /// - Parameters:
    ///   - value: 时间戳值。
    ///   - unit: 时间戳单位（秒或毫秒）。
    /// - Returns: 转换后的日期。
    static func fromTimestamp(_ value: Decimal, unit: DateConversion.TimestampUnit = .second) -> Date {
        DateConversion.date(from: value, unit: unit)
    }
}
