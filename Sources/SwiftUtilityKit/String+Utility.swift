import Foundation

/// 字符串常用工具扩展。
public extension String {
    // MARK: - Text

    /// 判断是否为空白字符串（去除空白与换行后为空）。
    var isBlank: Bool {
        trimmed().isEmpty
    }

    /// 如果为空白字符串返回 `nil`，否则返回去除首尾空白后的内容。
    func nilIfBlank() -> String? {
        let value = trimmed()
        return value.isEmpty ? nil : value
    }

    /// 去除首尾空白与换行。
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 去除所有空白与换行。
    func removingWhitespacesAndNewlines() -> String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }

    /// 判断是否为整数。
    var isIntegerNumber: Bool {
        Int(trimmed()) != nil
    }

    /// 判断是否为十进制数字。
    var isDecimalNumber: Bool {
        Decimal(string: trimmed()) != nil
    }

    /// 仅保留数字字符。
    func digitsOnly() -> String {
        filter { $0.isNumber }
    }

    /// 数字字符串千分位格式化。
    ///
    /// - Parameters:
    ///   - maximumFractionDigits: 最大小数位。
    ///   - minimumFractionDigits: 最小小数位。
    /// - Returns: 千分位格式化后的字符串。
    /// - Throws: `ConversionError.invalidNumber`
    func formattedWithGrouping(maximumFractionDigits: Int = 6, minimumFractionDigits: Int = 0) throws -> String {
        let value = try DecimalParser.parse(self)

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = minimumFractionDigits

        guard let formatted = formatter.string(from: NSDecimalNumber(decimal: value)) else {
            throw ConversionError.invalidNumber(self)
        }

        return formatted
    }

    /// 安全截取子串。
    ///
    /// - Parameters:
    ///   - start: 起始索引（从 0 开始）。
    ///   - length: 截取长度。
    /// - Returns: 截取结果；参数越界时返回 `nil`。
    func safeSubstring(start: Int, length: Int) -> String? {
        guard start >= 0, length >= 0 else {
            return nil
        }
        guard start < count else {
            return nil
        }

        let begin = index(startIndex, offsetBy: start)
        guard let end = index(begin, offsetBy: length, limitedBy: endIndex) else {
            return nil
        }

        return String(self[begin..<end])
    }

    /// URL 编码（用于 query/path 场景）。
    func urlEncoded() -> String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    /// URL 解码。
    func urlDecoded() -> String {
        removingPercentEncoding ?? self
    }

    /// Base64 编码（UTF-8）。
    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    /// Base64 解码（UTF-8）。
    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Date DSL

    /// 按给定格式解析为 `Date`。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 解析后的日期。
    /// - Throws: `ConversionError.invalidDate`
    func date(_ format: String, in context: DateKit.Context = DateKit.defaultContext) throws -> Date {
        try DateConversion.parse(self, format: format, context: context)
    }

    /// 按内置日期模式解析为 `Date`。
    ///
    /// - Parameters:
    ///   - pattern: 输入日期模式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 解析后的日期。
    /// - Throws: `ConversionError.invalidDate`
    func date(_ pattern: DateKit.Pattern = .dateTime, in context: DateKit.Context = DateKit.defaultContext) throws -> Date {
        try date(pattern.rawValue, in: context)
    }

    /// 按候选格式列表解析为 `Date`（依次尝试，成功即返回）。
    ///
    /// 适用于“后端返回日期格式不固定”的场景：
    /// 例如同一字段可能返回 `yyyy-MM-dd HH:mm:ss` 或 `yyyy/MM/dd HH:mm`。
    /// 通过候选格式列表可以避免业务层写多重 if/else 判断。
    ///
    /// - Parameters:
    ///   - formats: 输入候选格式列表。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 解析后的日期。
    /// - Throws: `ConversionError.invalidDate`
    func date(_ formats: [String], in context: DateKit.Context = DateKit.defaultContext) throws -> Date {
        for format in formats {
            if let parsed = try? DateConversion.parse(self, format: format, context: context) {
                return parsed
            }
        }
        throw ConversionError.invalidDate(self)
    }

    /// 按候选日期模式列表解析为 `Date`（依次尝试，成功即返回）。
    ///
    /// 适用于“后端返回日期格式不固定”的场景，
    /// 与 `date(_ formats:)` 作用一致，但使用内置 `DateKit.Pattern` 更易维护。
    ///
    /// - Parameters:
    ///   - patterns: 输入候选日期模式列表。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 解析后的日期。
    /// - Throws: `ConversionError.invalidDate`
    func date(_ patterns: [DateKit.Pattern], in context: DateKit.Context = DateKit.defaultContext) throws -> Date {
        try date(patterns.map(\.rawValue), in: context)
    }

    /// 自动识别常见日期模式并解析为 `Date`。
    ///
    /// 适用于“后端返回格式不明确且希望零配置快速解析”的场景。
    /// 内部会按 `patterns` 的顺序依次尝试。
    ///
    /// - Parameters:
    ///   - context: 日期上下文（语言/时区/日历）。
    ///   - patterns: 自动识别模式列表。
    /// - Returns: 解析后的日期。
    /// - Throws: `ConversionError.invalidDate`
    func date(in context: DateKit.Context = DateKit.defaultContext, patterns: [DateKit.Pattern] = DateKit.commonDatePatterns) throws -> Date {
        try date(patterns, in: context)
    }

    /// 日期字符串格式互转。
    ///
    /// - Parameters:
    ///   - inputFormat: 输入格式。
    ///   - outputFormat: 输出格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 转换后的日期字符串。
    /// - Throws: `ConversionError.invalidDate`
    func dateString(from inputFormat: String, to outputFormat: String, in context: DateKit.Context = DateKit.defaultContext) throws -> String {
        let value = try date(inputFormat, in: context)
        return DateConversion.format(value, format: outputFormat, context: context)
    }

    /// 日期模式转换。
    ///
    /// - Parameters:
    ///   - inputPattern: 输入模式。
    ///   - outputPattern: 输出模式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 转换后的日期字符串。
    /// - Throws: `ConversionError.invalidDate`
    func dateString(from inputPattern: DateKit.Pattern, to outputPattern: DateKit.Pattern, in context: DateKit.Context = DateKit.defaultContext) throws -> String {
        try dateString(from: inputPattern.rawValue, to: outputPattern.rawValue, in: context)
    }

    /// 日期字符串格式转换（自动识别输入格式）。
    ///
    /// 适用于“输入日期格式不固定，但输出格式固定”的场景，
    /// 常用于接口数据统一展示格式。
    ///
    /// - Parameters:
    ///   - outputFormat: 输出格式。
    ///   - inputFormats: 输入候选格式列表，默认 `DateKit.commonDateFormats`。
    /// - Throws: `ConversionError.invalidDate`
    func dateString(
        to outputFormat: String,
        inputFormats: [String] = DateKit.commonDateFormats,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> String {
        let value = try date(inputFormats, in: context)
        return DateConversion.format(value, format: outputFormat, context: context)
    }

    /// 日期字符串格式转换（自动识别输入模式）。
    ///
    /// 适用于“输入格式不固定，但希望通过 `DateKit.Pattern` 管理格式定义”的场景。
    ///
    /// - Throws: `ConversionError.invalidDate`
    func dateString(
        to outputPattern: DateKit.Pattern,
        inputPatterns: [DateKit.Pattern] = DateKit.commonDatePatterns,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> String {
        let value = try date(inputPatterns, in: context)
        return DateConversion.format(value, format: outputPattern.rawValue, context: context)
    }

    /// 比较两个日期字符串。
    ///
    /// - Parameters:
    ///   - other: 另一日期字符串。
    ///   - format: 输入格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 比较结果。
    /// - Throws: `ConversionError.invalidDate`
    func dateCompare(with other: String, format: String, in context: DateKit.Context = DateKit.defaultContext) throws -> ComparisonResult {
        try DateConversion.compare(self, other, format: format, context: context)
    }

    /// 计算两个日期字符串差值（`other - self`）。
    ///
    /// - Throws: `ConversionError.invalidDate`
    func dateDistance(
        to other: String,
        format: String,
        unit: DateConversion.DateDifferenceUnit,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> Decimal {
        try DateConversion.difference(self, other, unit: unit, format: format, context: context)
    }

    /// 日期字符串转时间戳。
    ///
    /// - Throws: `ConversionError.invalidDate`
    func timestamp(
        _ format: String,
        unit: DateConversion.TimestampUnit = .second,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> Decimal {
        DateConversion.timestamp(from: try date(format, in: context), unit: unit)
    }

    /// 日期字符串按内置模式转时间戳。
    ///
    /// - Throws: `ConversionError.invalidDate`
    func timestamp(
        _ pattern: DateKit.Pattern = .dateTime,
        unit: DateConversion.TimestampUnit = .second,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> Decimal {
        try timestamp(pattern.rawValue, unit: unit, in: context)
    }

    /// 日期字符串按自动识别模式转时间戳。
    ///
    /// - Throws: `ConversionError.invalidDate`
    func timestamp(
        unit: DateConversion.TimestampUnit = .second,
        in context: DateKit.Context = DateKit.defaultContext,
        patterns: [DateKit.Pattern] = DateKit.commonDatePatterns
    ) throws -> Decimal {
        DateConversion.timestamp(from: try date(patterns, in: context), unit: unit)
    }

    /// 日期字符串转时间戳字符串。
    ///
    /// - Parameters:
    ///   - format: 输入格式。
    ///   - unit: 输出时间戳单位。
    ///   - scale: 小数位（可选）。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 时间戳字符串。
    /// - Throws: `ConversionError.invalidDate`
    func timestampString(
        _ format: String,
        unit: DateConversion.TimestampUnit = .second,
        scale: Int? = nil,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> String {
        try timestamp(format, unit: unit, in: context).stringValue(scale: scale)
    }

    /// 当前字符串按时间戳解析并格式化为日期字符串。
    ///
    /// - Parameters:
    ///   - unit: 当前时间戳单位。
    ///   - format: 输出日期格式。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 格式化后的日期字符串。
    /// - Throws: `ConversionError.invalidNumber`
    func dateStringFromTimestamp(
        unit: DateConversion.TimestampUnit = .second,
        format: String,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> String {
        let value = try DecimalParser.parse(self)
        return Date.fromTimestamp(value, unit: unit).formatted(format, in: context)
    }

    /// 时间戳单位互转并返回字符串。
    ///
    /// - Parameters:
    ///   - from: 源时间戳单位。
    ///   - to: 目标时间戳单位。
    ///   - scale: 小数位（可选）。
    /// - Returns: 转换后的时间戳字符串。
    /// - Throws: `ConversionError.invalidNumber`
    func convertTimestamp(
        from: DateConversion.TimestampUnit,
        to: DateConversion.TimestampUnit,
        scale: Int? = nil
    ) throws -> String {
        let value = try DecimalParser.parse(self)
        let converted = DateConversion.convertTimestamp(value, from: from, to: to)
        return converted.stringValue(scale: scale)
    }

    /// 获取相对时间代理。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 相对时间代理。
    /// - Throws: `ConversionError.invalidDate`
    func relative(
        _ format: String,
        to reference: Date = Date(),
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> DateRelativeProxy {
        try date(format, in: context).relative(to: reference, in: context)
    }

    /// 获取相对时间代理（内置模式）。
    ///
    /// - Parameters:
    ///   - pattern: 输入日期模式。
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 相对时间代理。
    /// - Throws: `ConversionError.invalidDate`
    func relative(
        _ pattern: DateKit.Pattern = .dateTime,
        to reference: Date = Date(),
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> DateRelativeProxy {
        try relative(pattern.rawValue, to: reference, in: context)
    }

    /// 获取相对时间代理（自动识别模式）。
    ///
    /// - Parameters:
    ///   - reference: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    ///   - patterns: 自动识别模式列表。
    /// - Returns: 相对时间代理。
    /// - Throws: `ConversionError.invalidDate`
    func relative(
        to reference: Date = Date(),
        in context: DateKit.Context = DateKit.defaultContext,
        patterns: [DateKit.Pattern] = DateKit.commonDatePatterns
    ) throws -> DateRelativeProxy {
        try date(patterns, in: context).relative(to: reference, in: context)
    }

    /// 判断当前日期字符串是否在 `start...end` 范围。
    ///
    /// - Parameters:
    ///   - start: 起始日期字符串。
    ///   - end: 结束日期字符串。
    ///   - format: 输入格式。
    ///   - inclusive: 是否包含边界。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否在区间内。
    /// - Throws: `ConversionError.invalidDate`
    func isBetween(
        _ start: String,
        and end: String,
        format: String,
        inclusive: Bool = true,
        in context: DateKit.Context = DateKit.defaultContext
    ) throws -> Bool {
        let target = try date(format, in: context)
        let startDate = try start.date(format, in: context)
        let endDate = try end.date(format, in: context)
        return target.isInRange(from: startDate, to: endDate, inclusive: inclusive)
    }

    /// 判断是否为昨天。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为昨天。
    /// - Throws: `ConversionError.invalidDate`
    func isYesterday(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isYesterday
    }

    /// 判断是否为昨天（自动识别模式）。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    ///   - patterns: 自动识别模式列表。
    /// - Returns: 是否为昨天。
    /// - Throws: `ConversionError.invalidDate`
    func isYesterday(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext, patterns: [DateKit.Pattern] = DateKit.commonDatePatterns) throws -> Bool {
        try relative(to: ref, in: context, patterns: patterns).isYesterday
    }

    /// 判断是否为今天。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为今天。
    /// - Throws: `ConversionError.invalidDate`
    func isToday(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isToday
    }

    /// 判断是否为今天（自动识别模式）。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    ///   - patterns: 自动识别模式列表。
    /// - Returns: 是否为今天。
    /// - Throws: `ConversionError.invalidDate`
    func isToday(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext, patterns: [DateKit.Pattern] = DateKit.commonDatePatterns) throws -> Bool {
        try relative(to: ref, in: context, patterns: patterns).isToday
    }

    /// 判断是否为明天。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为明天。
    /// - Throws: `ConversionError.invalidDate`
    func isTomorrow(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isTomorrow
    }

    /// 判断是否为明天（自动识别模式）。
    ///
    /// - Parameters:
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    ///   - patterns: 自动识别模式列表。
    /// - Returns: 是否为明天。
    /// - Throws: `ConversionError.invalidDate`
    func isTomorrow(ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext, patterns: [DateKit.Pattern] = DateKit.commonDatePatterns) throws -> Bool {
        try relative(to: ref, in: context, patterns: patterns).isTomorrow
    }

    /// 判断是否为前天。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为前天。
    /// - Throws: `ConversionError.invalidDate`
    func isDayBeforeYesterday(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isDayBeforeYesterday
    }

    /// 判断是否为上周。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为上周。
    /// - Throws: `ConversionError.invalidDate`
    func isLastWeek(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isLastWeek
    }

    /// 判断是否为下周。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为下周。
    /// - Throws: `ConversionError.invalidDate`
    func isNextWeek(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isNextWeek
    }

    /// 判断是否为去年。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为去年。
    /// - Throws: `ConversionError.invalidDate`
    func isLastYear(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isLastYear
    }

    /// 判断是否为明年。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - ref: 参考时间。
    ///   - context: 日期上下文（语言/时区/日历）。
    /// - Returns: 是否为明年。
    /// - Throws: `ConversionError.invalidDate`
    func isNextYear(_ format: String, ref: Date = Date(), in context: DateKit.Context = DateKit.defaultContext) throws -> Bool {
        try relative(format, to: ref, in: context).isNextYear
    }
}
