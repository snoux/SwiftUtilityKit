import Foundation

enum ChineseUppercaseConverter {
    private static let digits = ["零", "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖"]
    private static let smallUnits = ["", "拾", "佰", "仟"]
    private static let sectionUnits = ["", "万", "亿", "兆"]

    private static let digitValueMap: [Character: Int] = [
        "零": 0, "〇": 0,
        "一": 1, "壹": 1,
        "二": 2, "贰": 2, "两": 2,
        "三": 3, "叁": 3,
        "四": 4, "肆": 4,
        "五": 5, "伍": 5,
        "六": 6, "陆": 6,
        "七": 7, "柒": 7,
        "八": 8, "捌": 8,
        "九": 9, "玖": 9
    ]

    private static let smallUnitMap: [Character: Int] = [
        "十": 10, "拾": 10,
        "百": 100, "佰": 100,
        "千": 1000, "仟": 1000
    ]

    private static let sectionUnitMap: [Character: Int] = [
        "万": 10_000,
        "亿": 100_000_000,
        "兆": 1_000_000_000_000
    ]

    /// 普通数字转中文大写数字。
    ///
    /// - Parameter value: 输入值。
    /// - Returns: 中文大写数字。
    /// - Example: `ChineseUppercaseConverter.toUppercaseNumber(1234.56)`
    static func toUppercaseNumber(_ value: Decimal) -> String {
        let isNegative = value < 0
        let absValue = isNegative ? -value : value
        let plain = NSDecimalNumber(decimal: absValue).stringValue

        let parts = plain.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        let integerPart = String(parts[0])
        let decimalPart = parts.count > 1 ? String(parts[1]) : ""

        let integerUpper = integerToUppercase(integerPart)
        let decimalUpper = decimalPart.isEmpty ? "" : "点" + decimalPart.compactMap { $0.wholeNumberValue.map { digits[$0] } }.joined()
        return (isNegative ? "负" : "") + integerUpper + decimalUpper
    }

    /// 普通数字转中文金额大写。
    ///
    /// - Parameter value: 输入值。
    /// - Returns: 中文金额大写。
    /// - Example: `ChineseUppercaseConverter.toUppercaseCurrency(1234.56)`
    static func toUppercaseCurrency(_ value: Decimal) -> String {
        let isNegative = value < 0
        let absValue = isNegative ? -value : value
        let centValue = (absValue * 100).rounded(scale: 0, mode: .plain)
        let totalCent = NSDecimalNumber(decimal: centValue).int64Value

        let integerPart = Int(totalCent / 100)
        let fraction = Int(totalCent % 100)
        let jiao = fraction / 10
        let fen = fraction % 10

        var result = integerToUppercase(String(integerPart)) + "元"
        if jiao == 0 && fen == 0 {
            result += "整"
        } else {
            if jiao > 0 {
                result += digits[jiao] + "角"
            } else if fen > 0 {
                result += "零"
            }
            if fen > 0 {
                result += digits[fen] + "分"
            }
        }

        return (isNegative ? "负" : "") + result
    }

    /// 中文大写数字（含金额）转普通数字。
    ///
    /// - Parameter text: 中文数字文本。
    /// - Returns: 解析后的十进制数值。
    /// - Throws: `ConversionError.invalidChineseNumeral`
    /// - Example: `try ChineseUppercaseConverter.parse("壹仟元整")`
    static func parse(_ text: String) throws -> Decimal {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ConversionError.invalidChineseNumeral(text)
        }

        if trimmed.contains("元") || trimmed.contains("角") || trimmed.contains("分") {
            return try parseCurrency(trimmed)
        }
        return try parseStandard(trimmed)
    }

    private static func integerToUppercase(_ text: String) -> String {
        let stripped = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Int(stripped), value != 0 else {
            return digits[0]
        }

        var sections: [Int] = []
        var remaining = value
        while remaining > 0 {
            sections.append(remaining % 10_000)
            remaining /= 10_000
        }

        var result = ""
        var needsZero = false

        for index in stride(from: sections.count - 1, through: 0, by: -1) {
            let section = sections[index]
            if section == 0 {
                needsZero = true
                continue
            }

            if needsZero && !result.isEmpty && !result.hasSuffix(digits[0]) {
                result += digits[0]
            }

            result += sectionToUppercase(section) + sectionUnits[index]
            needsZero = section < 1000
        }

        while result.contains("零零") {
            result = result.replacingOccurrences(of: "零零", with: "零")
        }

        if result.hasSuffix("零") {
            result.removeLast()
        }

        return result
    }

    private static func sectionToUppercase(_ section: Int) -> String {
        var value = section
        var index = 0
        var result = ""
        var zeroPending = false

        while value > 0 {
            let digit = value % 10
            if digit == 0 {
                if !result.isEmpty {
                    zeroPending = true
                }
            } else {
                var segment = digits[digit] + smallUnits[index]
                if zeroPending {
                    segment = digits[0] + segment
                    zeroPending = false
                }
                result = segment + result
            }

            value /= 10
            index += 1
        }

        return result
    }

    private static func parseStandard(_ text: String) throws -> Decimal {
        var normalized = text.replacingOccurrences(of: "圆", with: "")
            .replacingOccurrences(of: "元", with: "")
            .replacingOccurrences(of: "整", with: "")
            .replacingOccurrences(of: "正", with: "")

        let isNegative = normalized.hasPrefix("负") || normalized.hasPrefix("-")
        if isNegative {
            normalized.removeFirst()
        }

        let parts = normalized.split(separator: "点", maxSplits: 1, omittingEmptySubsequences: false)
        let integerPart = String(parts[0])
        let decimalPart = parts.count > 1 ? String(parts[1]) : ""

        let integerValue = try parseChineseInteger(integerPart)

        var decimalDigits = ""
        for char in decimalPart {
            guard let value = digitValueMap[char] else {
                throw ConversionError.invalidChineseNumeral(text)
            }
            decimalDigits.append(String(value))
        }

        let finalText = decimalDigits.isEmpty ? "\(integerValue)" : "\(integerValue).\(decimalDigits)"
        guard var result = Decimal(string: finalText) else {
            throw ConversionError.invalidChineseNumeral(text)
        }
        if isNegative {
            result *= -1
        }
        return result
    }

    private static func parseCurrency(_ text: String) throws -> Decimal {
        var normalized = text.replacingOccurrences(of: "圆", with: "元")
            .replacingOccurrences(of: "整", with: "")
            .replacingOccurrences(of: "正", with: "")

        let isNegative = normalized.hasPrefix("负") || normalized.hasPrefix("-")
        if isNegative {
            normalized.removeFirst()
        }

        let yuanPart: String
        if let range = normalized.range(of: "元") {
            yuanPart = String(normalized[..<range.lowerBound])
            normalized = String(normalized[range.upperBound...])
        } else {
            yuanPart = normalized
            normalized = ""
        }

        let yuan = try parseChineseInteger(yuanPart.isEmpty ? "零" : yuanPart)

        var jiao = 0
        var fen = 0

        if let range = normalized.range(of: "角") {
            let raw = String(normalized[..<range.lowerBound])
            jiao = try parseFractionDigit(raw, source: text)
            normalized = String(normalized[range.upperBound...])
        }

        if let range = normalized.range(of: "分") {
            let raw = String(normalized[..<range.lowerBound])
            fen = try parseFractionDigit(raw, source: text)
        }

        var result = Decimal(yuan) + Decimal(jiao) / 10 + Decimal(fen) / 100
        if isNegative {
            result *= -1
        }
        return result
    }

    private static func parseFractionDigit(_ text: String, source: String) throws -> Int {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty || cleaned == "零" {
            return 0
        }

        if cleaned.count == 1, let char = cleaned.first, let value = digitValueMap[char] {
            return value
        }

        throw ConversionError.invalidChineseNumeral(source)
    }

    private static func parseChineseInteger(_ text: String) throws -> Int {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty {
            return 0
        }

        var total = 0
        var section = 0
        var number = 0
        var hasAny = false

        for char in cleaned {
            if let digit = digitValueMap[char] {
                number = digit
                hasAny = true
                continue
            }

            if let unit = smallUnitMap[char] {
                if number == 0 {
                    number = 1
                }
                section += number * unit
                number = 0
                hasAny = true
                continue
            }

            if let sectionUnit = sectionUnitMap[char] {
                section = (section + number) * sectionUnit
                total += section
                section = 0
                number = 0
                hasAny = true
                continue
            }

            if char == "零" || char == "〇" {
                hasAny = true
                continue
            }

            throw ConversionError.invalidChineseNumeral(text)
        }

        guard hasAny else {
            throw ConversionError.invalidChineseNumeral(text)
        }

        return total + section + number
    }
}
