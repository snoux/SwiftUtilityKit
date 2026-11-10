#if os(macOS)
import Foundation
import IOKit.ps
import Testing
@testable import SwiftUtilityKit

struct MacBatteryPowerTests {
    @Test("Internal battery capacity and power source are sampled independently")
    func internalBattery() {
        let ups: [String: Any] = [kIOPSTypeKey: kIOPSUPSType, kIOPSCurrentCapacityKey: 100]
        let missing: [String: Any] = [kIOPSTypeKey: kIOPSInternalBatteryType, kIOPSIsPresentKey: false]
        let battery: [String: Any] = [
            kIOPSTypeKey: kIOPSInternalBatteryType,
            kIOPSIsPresentKey: true,
            kIOPSCurrentCapacityKey: 40,
            kIOPSMaxCapacityKey: 80,
            kIOPSPowerSourceStateKey: kIOPSBatteryPowerValue,
            kIOPSIsChargingKey: false
        ]
        let snapshot = MacBatteryPower.snapshot(from: [ups, missing, battery])
        #expect(snapshot.level == 0.5)
        #expect(snapshot.state == .unplugged)
        #expect(snapshot.isConnectedToPower == false)
    }

    @Test("External power distinguishes charging, full and charge paused")
    func externalPower() throws {
        var battery: [String: Any] = [
            kIOPSTypeKey: kIOPSInternalBatteryType,
            kIOPSPowerSourceStateKey: kIOPSACPowerValue,
            kIOPSCurrentCapacityKey: 80,
            kIOPSMaxCapacityKey: 100,
            kIOPSIsChargingKey: true,
            kIOPSIsChargedKey: false
        ]
        #expect(MacBatteryPower.snapshot(from: [battery]).state == .charging)

        battery[kIOPSIsChargingKey] = false
        let paused = MacBatteryPower.snapshot(from: [battery])
        #expect(paused.state == .unknown)
        #expect(paused.isConnectedToPower == true)
        #expect(paused.isCharging == false)
        #expect(paused.stateText(locale: Locale(identifier: "zh_CN")) == "已接电，未充电")
        let encoded = try JSONEncoder().encode(paused)
        #expect(try JSONDecoder().decode(BatterySnapshot.self, from: encoded) == paused)

        battery[kIOPSIsChargedKey] = true
        #expect(MacBatteryPower.snapshot(from: [battery]).state == .full)
    }

    @Test("External UPS and invalid capacity do not supply battery level")
    func unavailableBattery() {
        let ups: [String: Any] = [
            kIOPSTypeKey: kIOPSUPSType, kIOPSCurrentCapacityKey: 75, kIOPSMaxCapacityKey: 100
        ]
        let noBattery = MacBatteryPower.snapshot(from: [ups], isLowPowerModeEnabled: false, thermalState: .nominal)
        #expect(noBattery.level == nil)
        #expect(noBattery.state == .unknown)
        #expect(noBattery.isConnectedToPower == nil)
        #expect(noBattery.isLowPowerModeEnabled == false)
        #expect(noBattery.thermalState == .nominal)

        let invalid: [String: Any] = [
            kIOPSTypeKey: kIOPSInternalBatteryType, kIOPSCurrentCapacityKey: 75, kIOPSMaxCapacityKey: 0
        ]
        #expect(MacBatteryPower.snapshot(from: [invalid]).level == nil)
    }
}
#endif
