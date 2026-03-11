import Foundation

/// SwiftUtilityKit 命名空间。
public enum SwiftUtilityKit {}

/// RGBA 颜色结构。
public struct ColorRGBA: Equatable, Sendable {
    /// 红色通道（0...255）。
    public let red: Int
    /// 绿色通道（0...255）。
    public let green: Int
    /// 蓝色通道（0...255）。
    public let blue: Int
    /// 透明度（0...255，255 为不透明）。
    public let alpha: Int

    /// 初始化颜色。
    ///
    /// - Parameters:
    ///   - red: 红色通道（0...255）。
    ///   - green: 绿色通道（0...255）。
    ///   - blue: 蓝色通道（0...255）。
    ///   - alpha: 透明度（0...255）。
    /// - Throws: `ConversionError.invalidColor`
    public init(red: Int, green: Int, blue: Int, alpha: Int = 255) throws {
        guard (0...255).contains(red), (0...255).contains(green), (0...255).contains(blue), (0...255).contains(alpha) else {
            throw ConversionError.invalidColor("(\(red),\(green),\(blue),\(alpha))")
        }
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// 从颜色字符串解析 RGBA。
    ///
    /// 支持：`#RGB`、`#RGBA`、`#RRGGBB`、`#RRGGBBAA`、`rgb(r,g,b)`、`rgba(r,g,b,a)`。
    ///
    /// - Parameter text: 颜色字符串。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    public static func parse(_ text: String) throws -> ColorRGBA {
        let raw = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if raw.hasPrefix("#") {
            return try parseHex(raw)
        }
        if raw.lowercased().hasPrefix("rgb") {
            return try parseRGBFunction(raw)
        }
        throw ConversionError.invalidColor(text)
    }

    /// 从整型颜色值创建 RGBA。
    ///
    /// - Parameters:
    ///   - value: 颜色整数。
    ///   - hasAlpha: 是否包含 alpha（`0xRRGGBBAA`）。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    public static func fromPackedInt(_ value: Int, hasAlpha: Bool = false) throws -> ColorRGBA {
        if hasAlpha {
            guard (0...0xFFFFFFFF).contains(value) else {
                throw ConversionError.invalidColor(String(value))
            }
            let r = (value >> 24) & 0xFF
            let g = (value >> 16) & 0xFF
            let b = (value >> 8) & 0xFF
            let a = value & 0xFF
            return try ColorRGBA(red: r, green: g, blue: b, alpha: a)
        }

        guard (0...0xFFFFFF).contains(value) else {
            throw ConversionError.invalidColor(String(value))
        }
        let r = (value >> 16) & 0xFF
        let g = (value >> 8) & 0xFF
        let b = value & 0xFF
        return try ColorRGBA(red: r, green: g, blue: b, alpha: 255)
    }

    /// 输出十六进制字符串。
    ///
    /// - Parameters:
    ///   - includeAlpha: 是否包含 alpha。
    ///   - prefixHash: 是否带 `#` 前缀。
    /// - Returns: 十六进制颜色字符串。
    public func hexString(includeAlpha: Bool = false, prefixHash: Bool = true) -> String {
        let prefix = prefixHash ? "#" : ""
        if includeAlpha {
            return String(format: "%@%02X%02X%02X%02X", prefix, red, green, blue, alpha)
        }
        return String(format: "%@%02X%02X%02X", prefix, red, green, blue)
    }

    /// 输出整型颜色值。
    ///
    /// - Parameter includeAlpha: 是否包含 alpha。
    /// - Returns: 颜色整数。
    public func packedInt(includeAlpha: Bool = false) -> Int {
        if includeAlpha {
            return (red << 24) | (green << 16) | (blue << 8) | alpha
        }
        return (red << 16) | (green << 8) | blue
    }

    /// 解析 HEX 颜色字符串。
    ///
    /// - Parameter text: HEX 颜色字符串。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    private static func parseHex(_ text: String) throws -> ColorRGBA {
        let hex = String(text.dropFirst())
        switch hex.count {
        case 3:
            let chars = Array(hex)
            let r = try parseHexPair("\(chars[0])\(chars[0])", raw: text)
            let g = try parseHexPair("\(chars[1])\(chars[1])", raw: text)
            let b = try parseHexPair("\(chars[2])\(chars[2])", raw: text)
            return try ColorRGBA(red: r, green: g, blue: b)
        case 4:
            let chars = Array(hex)
            let r = try parseHexPair("\(chars[0])\(chars[0])", raw: text)
            let g = try parseHexPair("\(chars[1])\(chars[1])", raw: text)
            let b = try parseHexPair("\(chars[2])\(chars[2])", raw: text)
            let a = try parseHexPair("\(chars[3])\(chars[3])", raw: text)
            return try ColorRGBA(red: r, green: g, blue: b, alpha: a)
        case 6:
            let r = try parseHexPair(String(hex.prefix(2)), raw: text)
            let g = try parseHexPair(String(hex.dropFirst(2).prefix(2)), raw: text)
            let b = try parseHexPair(String(hex.dropFirst(4).prefix(2)), raw: text)
            return try ColorRGBA(red: r, green: g, blue: b)
        case 8:
            let r = try parseHexPair(String(hex.prefix(2)), raw: text)
            let g = try parseHexPair(String(hex.dropFirst(2).prefix(2)), raw: text)
            let b = try parseHexPair(String(hex.dropFirst(4).prefix(2)), raw: text)
            let a = try parseHexPair(String(hex.dropFirst(6).prefix(2)), raw: text)
            return try ColorRGBA(red: r, green: g, blue: b, alpha: a)
        default:
            throw ConversionError.invalidColor(text)
        }
    }

    /// 解析 `rgb(...)` / `rgba(...)` 颜色字符串。
    ///
    /// - Parameter text: RGB 函数颜色字符串。
    /// - Returns: 解析后的颜色。
    /// - Throws: `ConversionError.invalidColor`
    private static func parseRGBFunction(_ text: String) throws -> ColorRGBA {
        let normalized = text.replacingOccurrences(of: " ", with: "")
        if normalized.lowercased().hasPrefix("rgba(") && normalized.hasSuffix(")") {
            let content = String(normalized.dropFirst(5).dropLast())
            let parts = content.split(separator: ",", omittingEmptySubsequences: false)
            guard parts.count == 4 else {
                throw ConversionError.invalidColor(text)
            }

            guard
                let r = Int(parts[0]), let g = Int(parts[1]), let b = Int(parts[2]),
                let alphaValue = Decimal(string: String(parts[3]))
            else {
                throw ConversionError.invalidColor(text)
            }

            let alpha = NSDecimalNumber(decimal: alphaValue * 255).intValue
            return try ColorRGBA(red: r, green: g, blue: b, alpha: max(0, min(255, alpha)))
        }

        if normalized.lowercased().hasPrefix("rgb(") && normalized.hasSuffix(")") {
            let content = String(normalized.dropFirst(4).dropLast())
            let parts = content.split(separator: ",", omittingEmptySubsequences: false)
            guard parts.count == 3,
                  let r = Int(parts[0]), let g = Int(parts[1]), let b = Int(parts[2]) else {
                throw ConversionError.invalidColor(text)
            }
            return try ColorRGBA(red: r, green: g, blue: b)
        }

        throw ConversionError.invalidColor(text)
    }

    /// 解析 2 位十六进制通道值。
    ///
    /// - Parameters:
    ///   - value: 两位十六进制字符串。
    ///   - raw: 原始输入文本（用于错误提示）。
    /// - Returns: 解析后的通道值。
    /// - Throws: `ConversionError.invalidColor`
    private static func parseHexPair(_ value: String, raw: String) throws -> Int {
        guard let parsed = Int(value, radix: 16) else {
            throw ConversionError.invalidColor(raw)
        }
        return parsed
    }
}
