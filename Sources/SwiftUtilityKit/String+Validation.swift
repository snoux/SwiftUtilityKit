import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// 字符串校验与格式化扩展。
public extension String {
    /// 是否为中国大陆手机号（11 位，1[3-9] 开头）。
    var isValidChineseMobile: Bool {
        matchRegex("^1[3-9]\\d{9}$")
    }

    /// 是否为 URL（http/https/ftp）。
    var isValidURL: Bool {
        matchRegex("^(https?|ftp)://[A-Za-z0-9.-]+(?::\\d{1,5})?(?:/[A-Za-z0-9._~:/?#\\[\\]@!$&'()*+,;=%-]*)?$")
    }

    /// 是否为邮箱地址。
    var isValidEmail: Bool {
        matchRegex("^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
    }

    /// 是否为 IPv6 地址。
    var isValidIPv6: Bool {
        let text = trimmed()
        guard !text.isEmpty else { return false }
        var addr = in6_addr()
        return text.withCString { inet_pton(AF_INET6, $0, &addr) } == 1
    }

    /// 是否为银行卡号（12~19 位数字，且通过 Luhn 校验）。
    var isValidBankCardNumber: Bool {
        let digits = digitsOnly()
        guard (12...19).contains(digits.count), digits.count == trimmed().count else {
            return false
        }
        return Self.luhnCheck(digits)
    }

    /// 是否为中国身份证号（18 位，含校验码）。
    var isValidChineseIDCard: Bool {
        let text = trimmed().uppercased()
        guard text.matchRegex("^[1-9]\\d{5}(19\\d{2}|20[0-2]\\d)((0[1-9])|(1[0-2]))((0[1-9])|([12]\\d)|(3[01]))\\d{3}[0-9X]$") else {
            return false
        }

        // 出生日期有效性校验
        let birth = String(text.dropFirst(6).prefix(8))
        let formatter = DateFormatter()
        formatter.locale = DateKit.defaultContext.locale
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd"
        guard formatter.date(from: birth) != nil else {
            return false
        }

        let weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        let checkCodes: [Character] = ["1", "0", "X", "9", "8", "7", "6", "5", "4", "3", "2"]

        let chars = Array(text)
        var sum = 0
        for idx in 0..<17 {
            guard let value = chars[idx].wholeNumberValue else {
                return false
            }
            sum += value * weights[idx]
        }
        let expected = checkCodes[sum % 11]
        return chars[17] == expected
    }

    /// 银行卡号格式化为 `XXXX-XXXX-XXXX-XXXX...`。
    ///
    /// - Parameter separator: 分隔符，默认 `-`。
    /// - Returns: 格式化后的字符串。
    func formattedBankCardNumber(separator: String = "-") -> String {
        let digits = digitsOnly()
        guard !digits.isEmpty else { return "" }

        var groups: [String] = []
        var index = digits.startIndex
        while index < digits.endIndex {
            let end = digits.index(index, offsetBy: 4, limitedBy: digits.endIndex) ?? digits.endIndex
            groups.append(String(digits[index..<end]))
            index = end
        }
        return groups.joined(separator: separator)
    }

    /// 中国手机号格式化为 `XXX-XXXX-XXXX`。
    ///
    /// - Parameter separator: 分隔符，默认 `-`。
    /// - Returns: 格式化后的手机号字符串。
    func formattedChineseMobile(separator: String = "-") -> String {
        let digits = digitsOnly()
        guard digits.count == 11 else { return self }

        let part1 = digits.prefix(3)
        let part2 = digits.dropFirst(3).prefix(4)
        let part3 = digits.suffix(4)
        return "\(part1)\(separator)\(part2)\(separator)\(part3)"
    }

    /// 中国手机号格式化为 `XXX****XXXX`。
    ///
    /// - Parameter mask: 掩码文本，默认 `****`。
    /// - Returns: 脱敏后的手机号字符串。
    func maskedChineseMobile(mask: String = "****") -> String {
        let digits = digitsOnly()
        guard digits.count == 11 else { return self }

        let head = digits.prefix(3)
        let tail = digits.suffix(4)
        return "\(head)\(mask)\(tail)"
    }

    /// 身份证号脱敏（默认 `前6 + **** + 后4`）。
    ///
    /// - Parameter mask: 掩码文本，默认 `****`。
    /// - Returns: 脱敏后的身份证号字符串。
    func maskedChineseIDCard(mask: String = "****") -> String {
        let text = trimmed()
        guard text.count >= 10 else { return self }
        let start = text.prefix(6)
        let end = text.suffix(4)
        return "\(start)\(mask)\(end)"
    }

    /// 正则全匹配（默认忽略大小写）。
    ///
    /// - Parameter pattern: 正则表达式。
    /// - Returns: 是否全匹配成功。
    private func matchRegex(_ pattern: String) -> Bool {
        matchRegex(pattern, options: [.caseInsensitive])
    }

    /// 正则全匹配。
    ///
    /// - Parameters:
    ///   - pattern: 正则表达式。
    ///   - options: 正则选项。
    /// - Returns: 是否全匹配成功。
    private func matchRegex(_ pattern: String, options: NSRegularExpression.Options) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let target = trimmed()
        let range = NSRange(location: 0, length: target.utf16.count)
        guard let match = regex.firstMatch(in: target, options: [], range: range) else {
            return false
        }
        return match.range.location == 0 && match.range.length == range.length
    }

    /// Luhn 校验。
    ///
    /// - Parameter digits: 纯数字银行卡号字符串。
    /// - Returns: 是否通过 Luhn 校验。
    private static func luhnCheck(_ digits: String) -> Bool {
        var sum = 0
        let reversed = digits.reversed().map { String($0) }

        for (index, char) in reversed.enumerated() {
            guard var value = Int(char) else { return false }
            if index % 2 == 1 {
                value *= 2
                if value > 9 {
                    value -= 9
                }
            }
            sum += value
        }

        return sum % 10 == 0
    }
}
