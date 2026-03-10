import Foundation

/// 具备“到基准单位系数”的单位协议。
protocol FactorUnit {
    /// 当前单位转换到基准单位的系数。
    var factorToBase: Decimal { get }
}

/// 基于“基准单位系数法”的通用转换器。
enum FactorUnitConverter {
    /// 执行同一维度内的单位转换。
    ///
    /// - Parameters:
    ///   - value: 输入值。
    ///   - from: 源单位。
    ///   - to: 目标单位。
    /// - Returns: 转换后的值。
    static func convert<U: FactorUnit>(_ value: Decimal, from: U, to: U) -> Decimal {
        value * from.factorToBase / to.factorToBase
    }
}

/// 十进制字符串解析工具。
enum DecimalParser {
    /// 将字符串解析为 `Decimal`。
    ///
    /// - Parameter text: 输入字符串。
    /// - Returns: 解析结果。
    /// - Throws: `ConversionError.invalidNumber`
    static func parse(_ text: String) throws -> Decimal {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ConversionError.invalidNumber(text)
        }

        let number = NSDecimalNumber(string: trimmed)
        guard number != .notANumber else {
            throw ConversionError.invalidNumber(text)
        }
        return number.decimalValue
    }
}

extension Decimal {
    /// 通过字符串字面值创建 `Decimal`。
    ///
    /// - Parameter text: 十进制字符串。
    /// - Returns: 创建的 `Decimal`。
    static func literal(_ text: String) -> Decimal {
        NSDecimalNumber(string: text).decimalValue
    }

    /// 返回指定小数位的四舍五入结果。
    ///
    /// - Parameters:
    ///   - scale: 保留小数位。
    ///   - mode: 舍入模式，默认 `.plain`。
    /// - Returns: 舍入后的值。
    func rounded(scale: Int, mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, mode)
        return result
    }

    /// 按指定规则输出字符串。
    ///
    /// - Parameters:
    ///   - scale: 可选的小数位。
    ///   - roundingMode: 舍入模式，默认 `.plain`。
    /// - Returns: 字符串结果。
    func stringValue(scale: Int? = nil, roundingMode: NSDecimalNumber.RoundingMode = .plain) -> String {
        let value = scale.map { rounded(scale: $0, mode: roundingMode) } ?? self
        return NSDecimalNumber(decimal: value).stringValue
    }
}

/// RGBA 颜色值，分量范围为 `0...1`。
public struct ColorRGBA: Equatable {
    /// 红色分量。
    public let red: Decimal
    /// 绿色分量。
    public let green: Decimal
    /// 蓝色分量。
    public let blue: Decimal
    /// 透明度分量。
    public let alpha: Decimal

    /// 创建 RGBA 颜色值。
    ///
    /// - Parameters:
    ///   - red: 红色分量（`0...1`）。
    ///   - green: 绿色分量（`0...1`）。
    ///   - blue: 蓝色分量（`0...1`）。
    ///   - alpha: 透明度分量（`0...1`）。
    /// - Throws: `ConversionError.invalidColor`
    /// - Example: `try ColorRGBA(red: 1, green: 0, blue: 0, alpha: 1)`
    public init(red: Decimal, green: Decimal, blue: Decimal, alpha: Decimal = 1) throws {
        guard ColorRGBA.isValidUnitValue(red), ColorRGBA.isValidUnitValue(green), ColorRGBA.isValidUnitValue(blue), ColorRGBA.isValidUnitValue(alpha) else {
            throw ConversionError.invalidColor("RGBA components must be in 0...1")
        }
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// 输出十六进制颜色字符串。
    ///
    /// - Parameters:
    ///   - includeAlpha: 是否包含 alpha 分量。
    ///   - prefixHash: 是否包含 `#` 前缀。
    /// - Returns: 十六进制字符串。
    /// - Example: `try color.hexString(includeAlpha: true)`
    public func hexString(includeAlpha: Bool = false, prefixHash: Bool = true) -> String {
        let r = ColorRGBA.byteString(red)
        let g = ColorRGBA.byteString(green)
        let b = ColorRGBA.byteString(blue)
        let a = ColorRGBA.byteString(alpha)

        let core = includeAlpha ? "\(r)\(g)\(b)\(a)" : "\(r)\(g)\(b)"
        return prefixHash ? "#\(core)" : core
    }

    /// 输出打包整数。
    ///
    /// - Parameter includeAlpha: 是否包含 alpha 分量，包含时格式为 `0xRRGGBBAA`。
    /// - Returns: 打包后的整数。
    /// - Example: `try color.packedInt(includeAlpha: true)`
    public func packedInt(includeAlpha: Bool = false) -> Int {
        let r = ColorRGBA.byteValue(red)
        let g = ColorRGBA.byteValue(green)
        let b = ColorRGBA.byteValue(blue)
        let a = ColorRGBA.byteValue(alpha)

        if includeAlpha {
            return (r << 24) | (g << 16) | (b << 8) | a
        }
        return (r << 16) | (g << 8) | b
    }

    /// 从打包整数解析 RGBA。
    ///
    /// - Parameters:
    ///   - value: 打包整数。
    ///   - hasAlpha: 输入是否包含 alpha（`0xRRGGBBAA`）。
    /// - Returns: 解析后的 RGBA 颜色值。
    /// - Example: `try ColorRGBA.fromPackedInt(0xFF0000, hasAlpha: false)`
    public static func fromPackedInt(_ value: Int, hasAlpha: Bool = false) throws -> ColorRGBA {
        guard value >= 0 else {
            throw ConversionError.invalidColor("Packed color value must be non-negative")
        }

        let r: Int
        let g: Int
        let b: Int
        let a: Int

        if hasAlpha {
            r = (value >> 24) & 0xFF
            g = (value >> 16) & 0xFF
            b = (value >> 8) & 0xFF
            a = value & 0xFF
        } else {
            r = (value >> 16) & 0xFF
            g = (value >> 8) & 0xFF
            b = value & 0xFF
            a = 255
        }

        return try ColorRGBA(
            red: Decimal(r) / 255,
            green: Decimal(g) / 255,
            blue: Decimal(b) / 255,
            alpha: Decimal(a) / 255
        )
    }

    /// 解析字符串颜色，支持 hex/rgb/rgba。
    ///
    /// - Parameter raw: 输入颜色字符串。
    /// - Returns: 解析后的 RGBA 颜色值。
    /// - Throws: `ConversionError.invalidColor`
    /// - Example: `try ColorRGBA.parse("#FF0000")`
    public static func parse(_ raw: String) throws -> ColorRGBA {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ConversionError.invalidColor(raw)
        }

        let lower = trimmed.lowercased()
        if lower.hasPrefix("rgb(") || lower.hasPrefix("rgba(") {
            return try parseRGBFunction(trimmed)
        }
        return try parseHex(trimmed)
    }

    private static func parseHex(_ raw: String) throws -> ColorRGBA {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.hasPrefix("#") {
            text.removeFirst()
        } else if text.lowercased().hasPrefix("0x") {
            text = String(text.dropFirst(2))
        }

        let chars = Array(text)
        let full: String
        switch chars.count {
        case 3:
            full = chars.map { "\($0)\($0)" }.joined() + "FF"
        case 4:
            full = chars.map { "\($0)\($0)" }.joined()
        case 6:
            full = text + "FF"
        case 8:
            full = text
        default:
            throw ConversionError.invalidColor(raw)
        }

        guard let packed = Int(full, radix: 16) else {
            throw ConversionError.invalidColor(raw)
        }

        return try fromPackedInt(packed, hasAlpha: true)
    }

    private static func parseRGBFunction(_ raw: String) throws -> ColorRGBA {
        let lower = raw.lowercased()
        let hasAlpha = lower.hasPrefix("rgba(")

        guard let start = raw.firstIndex(of: "("), let end = raw.lastIndex(of: ")"), start < end else {
            throw ConversionError.invalidColor(raw)
        }

        let inner = raw[raw.index(after: start)..<end]
        let parts = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if hasAlpha {
            guard parts.count == 4 else {
                throw ConversionError.invalidColor(raw)
            }
        } else {
            guard parts.count == 3 else {
                throw ConversionError.invalidColor(raw)
            }
        }

        guard
            let r = Int(parts[0]), let g = Int(parts[1]), let b = Int(parts[2]),
            (0...255).contains(r), (0...255).contains(g), (0...255).contains(b)
        else {
            throw ConversionError.invalidColor(raw)
        }

        let alpha: Decimal
        if hasAlpha {
            guard let aDecimal = Decimal(string: parts[3]) else {
                throw ConversionError.invalidColor(raw)
            }

            if aDecimal <= 1 {
                alpha = aDecimal
            } else {
                alpha = aDecimal / 255
            }

            guard isValidUnitValue(alpha) else {
                throw ConversionError.invalidColor(raw)
            }
        } else {
            alpha = 1
        }

        return try ColorRGBA(
            red: Decimal(r) / 255,
            green: Decimal(g) / 255,
            blue: Decimal(b) / 255,
            alpha: alpha
        )
    }

    private static func isValidUnitValue(_ value: Decimal) -> Bool {
        value >= 0 && value <= 1
    }

    private static func byteValue(_ value: Decimal) -> Int {
        let clamped = min(max(value, 0), 1)
        return NSDecimalNumber(decimal: (clamped * 255).rounded(scale: 0, mode: .plain)).intValue
    }

    private static func byteString(_ value: Decimal) -> String {
        String(format: "%02X", byteValue(value))
    }
}
