import Foundation
import Testing
@testable import SwiftUtilityKit

@Suite("App information")
struct AppInfoTests {
    @Test("Display name takes precedence and bundle metadata is preserved")
    func metadata() {
        let snapshot = AppSnapshot(infoDictionary: [
            "CFBundleDisplayName": "显示名称", "CFBundleName": "InternalName",
            "CFBundleIdentifier": "com.example.app", "CFBundleShortVersionString": "1.2.3",
            "CFBundleVersion": "45"
        ])
        #expect(snapshot.name == "显示名称")
        #expect(snapshot.bundleIdentifier == "com.example.app")
        #expect(snapshot.versionWithBuild == "1.2.3(45)")
    }

    @Test("Missing or incorrectly typed metadata falls back safely")
    func missingMetadata() {
        let snapshot = AppSnapshot(infoDictionary: [
            "CFBundleDisplayName": "", "CFBundleName": "Fallback",
            "CFBundleVersion": 42
        ])
        #expect(snapshot.name == "Fallback")
        #expect(snapshot.bundleIdentifier.isEmpty)
        #expect(snapshot.version.isEmpty)
        #expect(snapshot.build.isEmpty)
        #expect(AppSnapshot(infoDictionary: [:]).name.isEmpty)
    }

    @Test("Version formatting handles partial metadata")
    func partialVersion() {
        #expect(AppSnapshot(infoDictionary: [:]).versionWithBuild == "")
        #expect(AppSnapshot(infoDictionary: ["CFBundleVersion": "45"]).versionWithBuild == "45")
        #expect(AppSnapshot(infoDictionary: ["CFBundleShortVersionString": "1.2.3"]).versionWithBuild == "1.2.3")
    }

    @Test("Snapshot reads the supplied bundle instead of the main bundle")
    func customBundle() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".bundle")
        #if os(macOS)
        let contents = root.appendingPathComponent("Contents")
        #else
        let contents = root
        #endif
        try FileManager.default.createDirectory(at: contents, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let plist = try PropertyListSerialization.data(fromPropertyList: [
            "CFBundleName": "Fixture", "CFBundleIdentifier": "com.example.fixture",
            "CFBundleShortVersionString": "9.8.7", "CFBundleVersion": "654",
            "CFBundlePackageType": "BNDL"
        ], format: .xml, options: 0)
        try plist.write(to: contents.appendingPathComponent("Info.plist"))
        let bundle = try #require(Bundle(url: root))
        let snapshot = AppInfo.snapshot(bundle: bundle)
        #expect(snapshot.name == "Fixture")
        #expect(snapshot.bundleIdentifier == "com.example.fixture")
        #expect(snapshot.versionWithBuild == "9.8.7(654)")
    }

    @Test("Foundation-only accessors match the main bundle snapshot")
    func accessors() {
        let snapshot = AppInfo.snapshot()
        #expect(AppInfo.name == snapshot.name)
        #expect(AppInfo.bundleIdentifier == snapshot.bundleIdentifier)
        #expect(AppInfo.version == snapshot.version)
        #expect(AppInfo.build == snapshot.build)
        #expect(AppInfo.versionWithBuild == snapshot.versionWithBuild)
    }
}
