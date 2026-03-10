import Foundation

/// 各类型数值转换入口。
public enum ValueConversion {
    // MARK: - Length

    /// 长度单位互转。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源长度单位。
    ///   - to: 目标长度单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.length(1200, from: .meter, to: .kilometer)`
    public static func length(_ value: Decimal, from: LengthUnit, to: LengthUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - Weight

    /// 重量单位互转。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源重量单位。
    ///   - to: 目标重量单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.weight(500, from: .gram, to: .jin)`
    public static func weight(_ value: Decimal, from: WeightUnit, to: WeightUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - Area

    /// 面积单位互转。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源面积单位。
    ///   - to: 目标面积单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.area(1, from: .hectare, to: .squareMeter)`
    public static func area(_ value: Decimal, from: AreaUnit, to: AreaUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - Volume

    /// 体积单位互转。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源体积单位。
    ///   - to: 目标体积单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.volume(2, from: .liter, to: .milliliter)`
    public static func volume(_ value: Decimal, from: VolumeUnit, to: VolumeUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    // MARK: - Time

    /// 时间单位互转。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源时间单位。
    ///   - to: 目标时间单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.time(5, from: .minute, to: .second)`
    public static func time(_ value: Decimal, from: TimeUnit, to: TimeUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }

    /// 比较两个时间值大小。
    ///
    /// - Parameters:
    ///   - lhs: 左侧时间值。
    ///   - lhsUnit: 左侧时间单位。
    ///   - rhs: 右侧时间值。
    ///   - rhsUnit: 右侧时间单位。
    /// - Returns: 比较结果。
    /// - Example: `ValueConversion.compareTime(1, lhsUnit: .hour, 30, rhsUnit: .minute)`
    public static func compareTime(_ lhs: Decimal, lhsUnit: TimeUnit, _ rhs: Decimal, rhsUnit: TimeUnit) -> ComparisonResult {
        let left = time(lhs, from: lhsUnit, to: .second)
        let right = time(rhs, from: rhsUnit, to: .second)
        if left == right { return .orderedSame }
        return left < right ? .orderedAscending : .orderedDescending
    }

    /// 计算两个时间值差值。
    ///
    /// - Parameters:
    ///   - lhs: 左侧时间值。
    ///   - lhsUnit: 左侧时间单位。
    ///   - rhs: 右侧时间值。
    ///   - rhsUnit: 右侧时间单位。
    ///   - resultUnit: 差值输出单位。
    /// - Returns: `rhs - lhs` 的差值。
    /// - Example: `ValueConversion.timeDifference(10, lhsUnit: .minute, 1, rhsUnit: .hour, resultUnit: .minute)`
    public static func timeDifference(
        _ lhs: Decimal,
        lhsUnit: TimeUnit,
        _ rhs: Decimal,
        rhsUnit: TimeUnit,
        resultUnit: TimeUnit
    ) -> Decimal {
        let left = time(lhs, from: lhsUnit, to: .second)
        let right = time(rhs, from: rhsUnit, to: .second)
        return time(right - left, from: .second, to: resultUnit)
    }

    // MARK: - Temperature

    /// 温度单位互转（摄氏/华氏/开尔文）。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源温度单位。
    ///   - to: 目标温度单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.temperature(100, from: .celsius, to: .fahrenheit)`
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

    // MARK: - Speed

    /// 速度单位互转。
    ///
    /// - Parameters:
    ///   - value: 待转换的数值。
    ///   - from: 源速度单位。
    ///   - to: 目标速度单位。
    /// - Returns: 转换后的结果。
    /// - Example: `ValueConversion.speed(120, from: .kilometerPerHour, to: .meterPerSecond)`
    public static func speed(_ value: Decimal, from: SpeedUnit, to: SpeedUnit) -> Decimal {
        FactorUnitConverter.convert(value, from: from, to: to)
    }
}
