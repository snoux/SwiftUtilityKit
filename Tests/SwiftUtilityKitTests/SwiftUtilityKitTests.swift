import Foundation
import Testing
@testable import SwiftUtilityKit

@Suite("SwiftUtilityKit Tests")
struct SwiftUtilityKitTests {
    @Test("Length conversion")
    func testLengthConversion() {
        let result = 1200.convertLength(from: .meter, to: .kilometer)
        #expect(result == Decimal(string: "1.2")!)
    }

    @Test("Weight conversion")
    func testWeightConversion() {
        let result = 1000.convertWeight(from: .gram, to: .kilogram)
        #expect(result == Decimal(1))
    }

    @Test("Time conversion")
    func testTimeConversion() {
        let result = 5.convertTime(from: .minute, to: .second)
        #expect(result == Decimal(300))
    }

    @Test("Time compare and difference")
    func testTimeCompareAndDifference() {
        let compare = 60.compareTime(with: 1, selfUnit: .minute, otherUnit: .hour)
        #expect(compare == .orderedSame)

        let diff = 30.timeDifference(to: 2, selfUnit: .minute, otherUnit: .hour, resultUnit: .minute)
        #expect(diff == Decimal(90))
    }

    @Test("Temperature conversion")
    func testTemperatureConversion() {
        let result = Decimal(0).convertTemperature(from: .celsius, to: .fahrenheit)
        #expect(result == Decimal(32))
    }

    @Test("String radix conversion")
    func testRadixConversion() throws {
        let result = try "FF".convertRadix(from: 16, to: 10)
        #expect(result == "255")
    }

    @Test("Chinese currency roundtrip")
    func testChineseCurrencyRoundtrip() throws {
        let text = try "1234.56".toChineseUppercaseCurrency()
        let value = try text.chineseUppercaseToDecimal()
        #expect(value == Decimal(string: "1234.56")!)
    }

    @Test("Color conversion")
    func testColorConversion() throws {
        let hex = try "rgb(255,102,0)".normalizedColorHex()
        #expect(hex == "#FF6600")

        let packed = try "#3366CC".colorToPackedInt()
        #expect(packed == 0x3366CC)

        let fromInt = try 0x3366CC.toColorHex()
        #expect(fromInt == "#3366CC")
    }

    @Test("Date conversion and comparison")
    func testDateConversionAndComparison() throws {
        let cn = DateKit.Context.cn

        let converted = try "2026-03-10 08:00:00".dateString(
            from: "yyyy-MM-dd HH:mm:ss",
            to: "yyyy/MM/dd HH:mm",
            in: cn
        )
        #expect(converted == "2026/03/10 08:00")

        let autoConverted = try "2026-03-10 08:00:00".dateString(
            to: "yyyy/MM/dd HH:mm",
            inputFormats: DateKit.commonDateFormats,
            in: cn
        )
        #expect(autoConverted == "2026/03/10 08:00")

        let autoConvertedByPattern = try "2026-03-10 08:00:00".dateString(to: .dateMinuteSlash, in: cn)
        #expect(autoConvertedByPattern == "2026/03/10 08:00")

        let cmp = try "2026-03-10 08:00:00".dateCompare(
            with: "2026-03-10 09:00:00",
            format: "yyyy-MM-dd HH:mm:ss",
            in: cn
        )
        #expect(cmp == .orderedAscending)

        let diff = try "2026-03-10 08:00:00".dateDistance(
            to: "2026-03-10 10:30:00",
            format: "yyyy-MM-dd HH:mm:ss",
            unit: .minute,
            in: cn
        )
        #expect(diff == Decimal(150))
    }

    @Test("Timestamp conversion")
    func testTimestampConversion() throws {
        let utc = DateKit.Context(
            locale: Locale(identifier: "zh_CN"),
            timeZone: TimeZone(secondsFromGMT: 0)!,
            calendar: Calendar(identifier: .gregorian)
        )

        let dateString = try "1704067200".dateStringFromTimestamp(
            unit: .second,
            format: "yyyy-MM-dd HH:mm:ss",
            in: utc
        )
        #expect(dateString == "2024-01-01 00:00:00")

        let timestamp = try "2024-01-01 00:00:00".timestamp(
            "yyyy-MM-dd HH:mm:ss",
            unit: .second,
            in: utc
        )
        #expect(timestamp == Decimal(1704067200))

        let ms = try "1704067200".convertTimestamp(from: .second, to: .millisecond)
        #expect(ms == "1704067200000")
    }

    @Test("Date range and relative checks")
    func testDateRangeAndRelativeChecks() throws {
        let cn = DateKit.Context.cn
        let reference = try "2026-03-10 12:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)
        let target = try "2026-03-09 12:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)

        let within7Days = try "2026-03-05 12:00:00"
            .relative("yyyy-MM-dd HH:mm:ss", to: reference, in: cn)
            .withinPast(7, .day)
        #expect(within7Days)

        let within1Year = try "2025-05-01 12:00:00"
            .relative("yyyy-MM-dd HH:mm:ss", to: reference, in: cn)
            .withinPast(1, .year)
        #expect(within1Year)

        #expect(try "2026-03-09 12:00:00".isYesterday("yyyy-MM-dd HH:mm:ss", ref: reference, in: cn))
        #expect(try "2026-03-09 12:00:00".isYesterday(ref: reference, in: cn))
        #expect(target.isYesterday(ref: reference, in: cn))

        #expect(try "2026-03-08 12:00:00"
            .relative("yyyy-MM-dd HH:mm:ss", to: reference, in: cn)
            .isDayBeforeYesterday)

        #expect(try "2026-03-08 12:00:00".isDayBeforeYesterday("yyyy-MM-dd HH:mm:ss", ref: reference, in: cn))

        #expect(try "2026-03-17 09:00:00"
            .relative("yyyy-MM-dd HH:mm:ss", to: reference, in: cn)
            .isNextWeek)

        #expect(try "2026-03-17 09:00:00".isNextWeek("yyyy-MM-dd HH:mm:ss", ref: reference, in: cn))

        #expect(try "2025-01-01 00:00:00"
            .relative("yyyy-MM-dd HH:mm:ss", to: reference, in: cn)
            .isLastYear)

        #expect(try "2025-01-01 00:00:00".isLastYear("yyyy-MM-dd HH:mm:ss", ref: reference, in: cn))

        #expect(try "2026-03-10 08:00:00".isBetween(
            "2026-03-10 07:00:00",
            and: "2026-03-10 09:00:00",
            format: "yyyy-MM-dd HH:mm:ss",
            in: cn
        ))

        let start = try "2026-03-10 07:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)
        let end = try "2026-03-10 09:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)
        let mid = try "2026-03-10 08:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)
        #expect(mid.isBetween(start, and: end))
        #expect(mid.isWithinPast(7, .day, ref: reference, in: cn))

    }

    @Test("Money conversion")
    func testMoneyConversion() throws {
        let fen = try "12.34".convertMoney(from: .major, to: .minor, currency: .cny)
        #expect(fen == Decimal(1234))

        let dollarToCent = try Decimal(string: "5.67")!.convertMoney(from: .major, to: .minor, currency: .usd)
        #expect(dollarToCent == Decimal(567))

        let parts = Decimal(string: "1234.56")!.splitCNY()
        #expect(parts.yuan == 1234)
        #expect(parts.jiao == 5)
        #expect(parts.fen == 6)

        let merged = CNYParts(yuan: 1234, jiao: 5, fen: 6).toDecimalYuan()
        #expect(merged == Decimal(string: "1234.56")!)
    }

    @Test("Percentage conversion")
    func testPercentageConversion() throws {
        let ratio = try "12.5".percentToRatio()
        #expect(ratio == Decimal(string: "0.125")!)

        let percent = try "0.125".ratioToPercent()
        #expect(percent == Decimal(string: "12.5")!)
    }

    @Test("String validation and formatting")
    func testStringValidationAndFormatting() {
        #expect("13800138000".isValidChineseMobile)
        #expect("https://example.com/path?a=1".isValidURL)
        #expect("test@example.com".isValidEmail)
        #expect("2408:8400:9800:31d3:4ff7:f6d2:69f8:77b3".isValidIPv6)
        #expect("6222021234567890123".formattedBankCardNumber() == "6222-0212-3456-7890-123")
        #expect("13800138000".formattedChineseMobile() == "138-0013-8000")
        #expect("13800138000".maskedChineseMobile() == "138****8000")
        #expect("11010519491231002X".isValidChineseIDCard)
        #expect("11010519491231002X".maskedChineseIDCard() == "110105****002X")

        #expect("4111111111111111".isValidBankCardNumber)
    }

    @Test("String utility")
    func testStringUtility() throws {
        #expect(" \n\t ".isBlank)
        #expect("  abc  ".nilIfBlank() == "abc")
        #expect(" \n".nilIfBlank() == nil)
        #expect(" 123 \n".trimmed() == "123")
        #expect("a1b2c3".digitsOnly() == "123")

        let grouped = try "12345.6".formattedWithGrouping()
        #expect(grouped == "12,345.6")

        let substring = "abcdef".safeSubstring(start: 2, length: 3)
        #expect(substring == "cde")

        let encoded = "a b&c=1".urlEncoded()
        #expect(encoded.contains("%20") || encoded.contains("+"))
        #expect(encoded.urlDecoded() == "a b&c=1")

        let b64 = "SwiftUtilityKit".base64Encoded()
        #expect(b64?.base64Decoded() == "SwiftUtilityKit")
    }

    @Test("Date common extensions")
    func testDateCommonExtensions() throws {
        let cn = DateKit.Context.cn
        let date = try "2026-03-10 12:34:56".date("yyyy-MM-dd HH:mm:ss", in: cn)

        #expect(date.startOfDay(in: cn).formatted("yyyy-MM-dd HH:mm:ss", in: cn) == "2026-03-10 00:00:00")
        #expect(date.endOfDay(in: cn).formatted("yyyy-MM-dd HH:mm:ss", in: cn) == "2026-03-10 23:59:59")
        #expect(date.startOfMonth(in: cn).formatted("yyyy-MM-dd", in: cn) == "2026-03-01")
        #expect(date.endOfMonth(in: cn).formatted("yyyy-MM-dd", in: cn) == "2026-03-31")

        let plus7 = date.adding(7, .day, in: cn)
        #expect(plus7?.formatted("yyyy-MM-dd", in: cn) == "2026-03-17")

        let sameDay = try "2026-03-10 23:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)
        let nextDay = try "2026-03-11 00:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn)
        #expect(date.isSameDay(as: sameDay, in: cn))
        #expect(!date.isSameDay(as: nextDay, in: cn))
        #expect(date.days(to: nextDay, in: cn) == 1)

        let weekend = try "2026-03-08 12:00:00".date("yyyy-MM-dd HH:mm:ss", in: cn) // Sunday
        #expect(weekend.isWeekend(in: cn))
    }

    @Test("Localized names")
    func testLocalizedNames() {
        let zh = LengthUnit.meter.localizedName(locale: Locale(identifier: "zh_CN"))
        let en = LengthUnit.meter.localizedName(locale: Locale(identifier: "en_US"))
        #expect(zh == "米")
        #expect(en == "meter")
    }

    #if canImport(UIKit)
    @Test("Device info")
    func testDeviceInfo() {
        #expect(!DeviceInfo.systemVersion.isEmpty)
        #expect(!DeviceInfo.modelIdentifier.isEmpty)
        #expect(!DeviceInfo.modelName.isEmpty)
    }
    #endif
}
