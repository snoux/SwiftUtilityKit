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

    @Test("Time comparison")
    func testTimeComparison() {
        let result = 5.compareTime(to: 300, selfUnit: .minute, otherUnit: .second)
        #expect(result == .orderedSame)
    }

    @Test("Time difference")
    func testTimeDifference() {
        let diff = 2.timeDifference(to: 30, selfUnit: .hour, otherUnit: .minute, resultUnit: .minute)
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

    @Test("String utility")
    func testStringUtility() throws {
        #expect(" 123 \n".trimmed() == "123")
        #expect("a1b2c3".digitsOnly() == "123")

        let grouped = try "12345.6".formattedWithGrouping()
        #expect(grouped == "12,345.6")

        let substring = "abcdef".safeSubstring(start: 2, length: 3)
        #expect(substring == "cde")
    }

    @Test("Date parse and format")
    func testDateParseAndFormat() throws {
        let timezone = TimeZone(secondsFromGMT: 0)!
        let date = try "2025-01-01 12:30:00".toDate(
            format: "yyyy-MM-dd HH:mm:ss",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timezone
        )
        let output = date.toString(
            format: "yyyy/MM/dd HH:mm:ss",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timezone
        )
        #expect(output == "2025/01/01 12:30:00")
    }

    @Test("Date compare and difference")
    func testDateCompareAndDifference() throws {
        let timezone = TimeZone(secondsFromGMT: 0)!
        let lhs = "2025-01-02 00:00:00"
        let rhs = "2025-01-01 00:00:00"

        let diff = try lhs.dateDifference(
            to: rhs,
            format: "yyyy-MM-dd HH:mm:ss",
            in: .hour,
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timezone
        )
        #expect(diff == Decimal(24))

        let cmp = try lhs.compareDate(
            to: rhs,
            format: "yyyy-MM-dd HH:mm:ss",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: timezone
        )
        #expect(cmp == .orderedDescending)
    }

    @Test("Localized names")
    func testLocalizedNames() {
        let zh = LengthUnit.meter.localizedName(locale: Locale(identifier: "zh_CN"))
        let en = LengthUnit.meter.localizedName(locale: Locale(identifier: "en_US"))
        #expect(zh == "米")
        #expect(en == "meter")
    }
}
