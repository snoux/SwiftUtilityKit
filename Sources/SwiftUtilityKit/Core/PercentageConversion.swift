import Foundation

/// 百分比转换工具。
public enum PercentageConversion {
    /// 百分数转比率。
    ///
    /// - Parameter percent: 百分数（例如 12.5 表示 12.5%）。
    /// - Returns: 比率（例如 0.125）。
    public static func percentToRatio(_ percent: Decimal) -> Decimal {
        percent / 100
    }

    /// 比率转百分数。
    ///
    /// - Parameter ratio: 比率（例如 0.125）。
    /// - Returns: 百分数（例如 12.5）。
    public static func ratioToPercent(_ ratio: Decimal) -> Decimal {
        ratio * 100
    }
}
