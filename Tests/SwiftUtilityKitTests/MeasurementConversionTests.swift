import Foundation
import Testing
@testable import SwiftUtilityKit

struct MeasurementConversionTests {
    @Test("Chinese land units and cubic units convert through the public extensions")
    func landAndVolume() throws {
        #expect(try "1".convertArea(from: .qing, to: .mu) == 100)
        #expect(1.convertArea(from: .hectare, to: .are) == 100)
        #expect(1.convertWeight(from: .dan, to: .jin) == 100)
        #expect(1.convertVolume(from: .cubicDecimeter, to: .milliliter) == 1_000)
        #expect(1.convertVolume(from: .cubicMillimeter, to: .microliter) == 1)
    }

    @Test("Speed supports distance-per-second units and vacuum light speed")
    func speedUnits() throws {
        #expect(try "100".convertSpeed(from: .inchPerSecond, to: .meterPerSecond) == Decimal.literal("2.54"))
        #expect(1.convertSpeed(from: .kilometerPerSecond, to: .meterPerSecond) == 1_000)
        #expect(1.convertSpeed(from: .nauticalMilePerSecond, to: .meterPerSecond) == 1_852)
        #expect(1.convertSpeed(from: .speedOfLight, to: .meterPerSecond) == 299_792_458)
    }

    @Test("Mach and sound-speed multiples use the selected reference in both directions")
    func soundReference() {
        #expect(2.convertSpeed(from: .mach, to: .meterPerSecond) == 686)
        #expect(ValueConversion.speed(2, from: .mach, to: .meterPerSecond, soundSpeedInMetersPerSecond: 330) == 660)
        #expect(ValueConversion.speed(660, from: .meterPerSecond, to: .speedOfSound, soundSpeedInMetersPerSecond: 330) == 2)
        #expect(ValueConversion.speed(1, from: .mach, to: .meterPerSecond, soundSpeedInMetersPerSecond: 0) == nil)
    }

    @Test("BMI accepts metric and imperial measurements and rejects invalid input")
    func bmi() {
        #expect(ValueConversion.bmi(weight: 64, height: 160, heightUnit: .centimeter) == 25)
        let imperial = ValueConversion.bmi(weight: 150, weightUnit: .pound, height: 70, heightUnit: .inch)
        #expect(imperial?.rounded(scale: 2) == Decimal.literal("21.52"))
        #expect(ValueConversion.bmi(weight: 70, height: 0) == nil)
        #expect(ValueConversion.bmi(weight: -70, height: 1.75) == nil)
        #expect(ValueConversion.bmi(weight: 70, height: .nan) == nil)
    }
}
