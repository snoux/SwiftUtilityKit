import Foundation
import Testing
@testable import SwiftUtilityKit
#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

@Suite("Device diagnostic snapshots")
struct DeviceSnapshotTests {
    @Test("Exported JSON roundtrips with ISO 8601 dates and includes raw units")
    func jsonExport() throws {
        let snapshot = fixture()
        let data = try snapshot.jsonData()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        #expect(try decoder.decode(DeviceSnapshot.self, from: data) == snapshot)

        let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        #expect(json["capturedAt"] as? String == "2023-11-14T22:13:20Z")
        let storage = try #require(json["storage"] as? [String: Any])
        #expect(storage["totalBytes"] as? Int == 1_000_000)
        #expect(try snapshot.jsonString().contains("\n"))
        #expect(try !snapshot.jsonString(prettyPrinted: false).contains("\n"))
    }

    @Test("Missing information stays unknown in text and absent in JSON")
    func unknownValues() throws {
        let snapshot = DeviceSnapshot(
            systemName: "TestOS", systemVersion: "1.0", modelIdentifier: "Test1,1",
            modelName: "Test Device", app: AppSnapshot(infoDictionary: [:])
        )
        #expect(snapshot.text.contains("电量：未知"))
        #expect(snapshot.text.contains("剩余容量：未知"))
        let json = try #require(JSONSerialization.jsonObject(with: snapshot.jsonData()) as? [String: Any])
        #expect(json["screen"] == nil)
        let battery = try #require(json["battery"] as? [String: Any])
        #expect(battery["level"] == nil)
    }

    @Test("Storage rejects negative values and clamps inconsistent capacity to zero")
    func storage() {
        #expect(DeviceSnapshot.Storage(totalBytes: 100, freeBytes: 40).usedBytes == 60)
        #expect(DeviceSnapshot.Storage(totalBytes: 40, freeBytes: 100).usedBytes == 0)
        #expect(DeviceSnapshot.Storage(totalBytes: -1, freeBytes: 10).usedBytes == nil)
        #expect(DeviceSnapshot.Storage(totalBytes: 100, freeBytes: nil).usedBytes == nil)
    }

    @Test("Decoded values enforce the same bounds as directly initialized snapshots")
    func decodedBounds() throws {
        let decoder = JSONDecoder()
        let storageJSON = Data(#"{"totalBytes":9223372036854775807,"freeBytes":-1}"#.utf8)
        let storage = try decoder.decode(DeviceSnapshot.Storage.self, from: storageJSON)
        #expect(storage.freeBytes == nil)
        #expect(storage.usedBytes == nil)
        let batteryJSON = Data(#"{"level":2,"state":"unknown","thermalState":"unknown"}"#.utf8)
        let battery = try decoder.decode(BatterySnapshot.self, from: batteryJSON)
        #expect(battery.level == nil)
    }

    @Test("Readable text includes app, battery, storage and screen diagnostics")
    func readableText() {
        let text = fixture().text
        #expect(text.contains("应用版本：1.2.3(45)"))
        #expect(text.contains("电量：50%"))
        #expect(text.contains("充电状态：充电中"))
        #expect(text.contains("低电量模式：开启"))
        #expect(text.contains("温度状态：fair"))
        #expect(text.contains("393.0x852.0 pt"))
    }

    #if canImport(UIKit) && !os(watchOS)
    @MainActor
    @Test("Live collection preserves DeviceInfo compatibility")
    func liveCollection() throws {
        let snapshot = DeviceInfo.snapshot()
        #expect(snapshot.systemName == DeviceInfo.systemName)
        #expect(snapshot.modelIdentifier == DeviceInfo.modelIdentifier)
        #expect(snapshot.app == AppInfo.snapshot())
        #expect(DeviceInfo.appVersion == AppInfo.version)
        #expect(DeviceInfo.appBuild == AppInfo.build)
        #expect(DeviceInfo.appVersionWithBuild == AppInfo.versionWithBuild)
        #if os(visionOS)
        #expect(snapshot.screen == nil)
        #else
        #expect(snapshot.screen?.scale == Double(UIScreen.main.scale))
        #endif
        #expect(try !snapshot.jsonData().isEmpty)
    }
    #endif

    private func fixture() -> DeviceSnapshot {
        DeviceSnapshot(
            capturedAt: Date(timeIntervalSince1970: 1_700_000_000),
            systemName: "iOS", systemVersion: "17.0.0",
            modelIdentifier: "iPhone16,2", modelName: "iPhone 15 Pro Max",
            app: AppSnapshot(name: "Example", bundleIdentifier: "com.example", version: "1.2.3", build: "45"),
            screen: DeviceSnapshot.Screen(
                logicalWidth: 393, logicalHeight: 852, pixelWidth: 1179, pixelHeight: 2556,
                scale: 3, nativeScale: 3
            ),
            battery: BatterySnapshot(level: 0.5, state: .charging, isLowPowerModeEnabled: true, thermalState: .fair),
            storage: DeviceSnapshot.Storage(totalBytes: 1_000_000, freeBytes: 400_000)
        )
    }
}
