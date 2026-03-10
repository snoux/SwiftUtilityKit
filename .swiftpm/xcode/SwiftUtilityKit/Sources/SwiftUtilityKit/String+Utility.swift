import Foundation

private enum DateParser {
    static func formatter(format: String, locale: Locale, timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }

    static func parse(_ text: String, format: String, locale: Locale, timeZone: TimeZone) throws -> Date {
        let formatter = formatter(format: format, locale: locale, timeZone: timeZone)
        guard let date = formatter.date(from: text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            throw ConversionError.invalidDate(text)
        }
        return date
    }
}

/// 字符串常用工具扩展。
public extension String {
    // MARK: - 基础处理

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

    // MARK: - 日期转换

    /// 按指定格式将字符串解析为 `Date`。
    ///
    /// - Parameters:
    ///   - format: 输入日期格式。
    ///   - locale: 语言环境，默认当前。
    ///   - timeZone: 时区，默认当前。
    /// - Returns: 解析后的 `Date`。
    /// - Throws: `ConversionError.invalidDate`
    /// - Example: `try "2025-01-01 12:30:00".toDate(format: "yyyy-MM-dd HH:mm:ss")`
    func toDate(format: String, locale: Locale = .current, timeZone: TimeZone = .current) throws -> Date {
        try DateParser.parse(self, format: format, locale: locale, timeZone: timeZone)
    }

    /// 将日期字符串从一种格式转换为另一种格式。
    ///
    /// - Parameters:
    ///   - fromFormat: 输入格式。
    ///   - toFormat: 输出格式。
    ///   - locale: 语言环境，默认当前。
    ///   - timeZone: 时区，默认当前。
    /// - Returns: 转换后的日期字符串。
    /// - Throws: `ConversionError.invalidDate`
    /// - Example: `try "2025-01-01".convertDateFormat(from: "yyyy-MM-dd", to: "yyyy/MM/dd")`
    func convertDateFormat(from fromFormat: String, to toFormat: String, locale: Locale = .current, timeZone: TimeZone = .current) throws -> String {
        let date = try toDate(format: fromFormat, locale: locale, timeZone: timeZone)
        return date.toString(format: toFormat, locale: locale, timeZone: timeZone)
    }

    /// 比较两个日期字符串大小。
    ///
    /// - Parameters:
    ///   - other: 右值日期字符串。
    ///   - format: 两者共同格式。
    ///   - locale: 语言环境，默认当前。
    ///   - timeZone: 时区，默认当前。
    /// - Returns: 比较结果。
    /// - Throws: `ConversionError.invalidDate`
    /// - Example: `try "2025-01-01".compareDate(to: "2025-01-02", format: "yyyy-MM-dd")`
    func compareDate(to other: String, format: String, locale: Locale = .current, timeZone: TimeZone = .current) throws -> ComparisonResult {
        let lhsDate = try toDate(format: format, locale: locale, timeZone: timeZone)
        let rhsDate = try other.toDate(format: format, locale: locale, timeZone: timeZone)
        return lhsDate.compare(rhsDate)
    }

    /// 计算两个日期字符串差值（当前值减右值，可为负）。
    ///
    /// - Parameters:
    ///   - other: 右值日期字符串。
    ///   - format: 两者共同格式。
    ///   - unit: 输出单位。
    ///   - locale: 语言环境，默认当前。
    ///   - timeZone: 时区，默认当前。
    /// - Returns: 差值。
    /// - Throws: `ConversionError.invalidDate`
    /// - Example: `try "2025-01-02 00:00:00".dateDifference(to: "2025-01-01 00:00:00", format: "yyyy-MM-dd HH:mm:ss", in: .hour)`
    func dateDifference(to other: String, format: String, in unit: TimeUnit = .second, locale: Locale = .current, timeZone: TimeZone = .current) throws -> Decimal {
        let lhsDate = try toDate(format: format, locale: locale, timeZone: timeZone)
        let rhsDate = try other.toDate(format: format, locale: locale, timeZone: timeZone)

        let seconds = Decimal(lhsDate.timeIntervalSince(rhsDate))
        return ValueConversion.time(seconds, from: .second, to: unit)
    }
}

public extension Date {
    /// 将 `Date` 按指定格式输出为字符串。
    ///
    /// - Parameters:
    ///   - format: 输出格式。
    ///   - locale: 语言环境，默认当前。
    ///   - timeZone: 时区，默认当前。
    /// - Returns: 格式化后的字符串。
    /// - Example: `Date().toString(format: "yyyy-MM-dd")`
    func toString(format: String, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        let formatter = DateParser.formatter(format: format, locale: locale, timeZone: timeZone)
        return formatter.string(from: self)
    }
}
