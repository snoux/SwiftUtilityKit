import Foundation

/// 时间戳转换（整数）。
public extension BinaryInteger {
    /// 时间戳单位互转。
    ///
    /// - Parameters:
    ///   - from: 源时间戳单位。
    ///   - to: 目标时间戳单位。
    /// - Returns: 转换后的时间戳。
    func convertTimestamp(from: DateConversion.TimestampUnit, to: DateConversion.TimestampUnit) -> Decimal {
        let value = Decimal(string: String(self)) ?? 0
        return DateConversion.convertTimestamp(value, from: from, to: to)
    }

    /// 时间戳转日期。
    ///
    /// - Parameter unit: 当前时间戳单位。
    /// - Returns: 转换后的 `Date`。
    func toDate(unit: DateConversion.TimestampUnit = .second) -> Date {
        let value = Decimal(string: String(self)) ?? 0
        return DateConversion.date(from: value, unit: unit)
    }
}

/// 时间戳转换（浮点）。
public extension BinaryFloatingPoint {
    /// 时间戳单位互转。
    ///
    /// - Parameters:
    ///   - from: 源时间戳单位。
    ///   - to: 目标时间戳单位。
    /// - Returns: 转换后的时间戳。
    func convertTimestamp(from: DateConversion.TimestampUnit, to: DateConversion.TimestampUnit) -> Decimal {
        let value = Decimal(string: String(Double(self))) ?? 0
        return DateConversion.convertTimestamp(value, from: from, to: to)
    }

    /// 时间戳转日期。
    ///
    /// - Parameter unit: 当前时间戳单位。
    /// - Returns: 转换后的 `Date`。
    func toDate(unit: DateConversion.TimestampUnit = .second) -> Date {
        let value = Decimal(string: String(Double(self))) ?? 0
        return DateConversion.date(from: value, unit: unit)
    }
}

/// 时间戳转换（Decimal）。
public extension Decimal {
    /// 时间戳单位互转。
    ///
    /// - Parameters:
    ///   - from: 源时间戳单位。
    ///   - to: 目标时间戳单位。
    /// - Returns: 转换后的时间戳。
    func convertTimestamp(from: DateConversion.TimestampUnit, to: DateConversion.TimestampUnit) -> Decimal {
        DateConversion.convertTimestamp(self, from: from, to: to)
    }

    /// 时间戳转日期。
    ///
    /// - Parameter unit: 当前时间戳单位。
    /// - Returns: 转换后的 `Date`。
    func toDate(unit: DateConversion.TimestampUnit = .second) -> Date {
        DateConversion.date(from: self, unit: unit)
    }
}
