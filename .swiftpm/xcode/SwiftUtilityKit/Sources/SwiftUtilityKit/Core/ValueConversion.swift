import Foundation

/// 各类型数值转换入口。
public enum ValueConversion {
    // MARK: - 长度

    /// 长度单位互转。
    public static func length(_ value: Decimal, from: LengthUnit, to: LengthUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - 重量

    /// 重量单位互转。
    public static func weight(_ value: Decimal, from: WeightUnit, to: WeightUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - 面积

    /// 面积单位互转。
    public static func area(_ value: Decimal, from: AreaUnit, to: AreaUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - 体积

    /// 体积单位互转。
    public static func volume(_ value: Decimal, from: VolumeUnit, to: VolumeUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - 时间

    /// 时间单位互转。
    public static func time(_ value: Decimal, from: TimeUnit, to: TimeUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    /// 比较两个时间值大小。
    ///
    /// - Parameters:
    ///   - lhs: 左值。
    ///   - lhsUnit: 左值单位。
    ///   - rhs: 右值。
    ///   - rhsUnit: 右值单位。
    /// - Returns: 比较结果：`orderedAscending/orderedSame/orderedDescending`。
    /// - Example: `ValueConversion.compareTime(5, lhsUnit: .minute, 300, rhsUnit: .second)`
    public static func compareTime(_ lhs: Decimal, lhsUnit: TimeUnit, _ rhs: Decimal, rhsUnit: TimeUnit) -> ComparisonResult {
        let left = time(lhs, from: lhsUnit, to: .second)
        let right = time(rhs, from: rhsUnit, to: .second)

        if left < right { return .orderedAscending }
        if left > right { return .orderedDescending }
        return .orderedSame
    }

    /// 计算两个时间值的差值（左值减右值，可为负值）。
    ///
    /// - Parameters:
    ///   - lhs: 左值。
    ///   - lhsUnit: 左值单位。
    ///   - rhs: 右值。
    ///   - rhsUnit: 右值单位。
    ///   - resultUnit: 结果单位，默认秒。
    /// - Returns: 差值（`lhs - rhs`）。
    /// - Example: `ValueConversion.timeDifference(2, lhsUnit: .hour, 30, rhsUnit: .minute, resultUnit: .minute)`
    public static func timeDifference(
        _ lhs: Decimal,
        lhsUnit: TimeUnit,
        _ rhs: Decimal,
        rhsUnit: TimeUnit,
        resultUnit: TimeUnit = .second
    ) -> Decimal {
        let left = time(lhs, from: lhsUnit, to: .second)
        let right = time(rhs, from: rhsUnit, to: .second)
        let diffInSecond = left - right
        return time(diffInSecond, from: .second, to: resultUnit)
    }

    // MARK: - 速度

    /// 速度单位互转。
    public static func speed(_ value: Decimal, from: SpeedUnit, to: SpeedUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - 温度

    /// 温度单位互转（摄氏/华氏/开尔文）。
    public static func temperature(_ value: Decimal, from: TemperatureUnit, to: TemperatureUnit) -> Decimal {
        if from == to {
            return value
        }

        let celsius: Decimal
        switch from {
        case .celsius:
            celsius = value
        case .fahrenheit:
            celsius = (value - 32) * 5 / 9
        case .kelvin:
            celsius = value - .literal("273.15")
        }

        switch to {
        case .celsius:
            return celsius
        case .fahrenheit:
            return celsius * 9 / 5 + 32
        case .kelvin:
            return celsius + .literal("273.15")
        }
    }
}
