import Testing
@testable import SwiftUtilityKit

#if os(macOS) || (canImport(UIKit) && !os(watchOS))
@Suite("Device model lookup")
struct DeviceInfoTests {
    @Test("Bundled names cover Mac families and retain iPhone support", arguments: [
        ["Mac14,7", "MacBook Pro (13-inch, M2, 2022)"],
        ["MacBookPro15,1", "MacBook Pro (15-inch, 2018-2019)"],
        ["MacBookAir10,1", "MacBook Air (M1, 2020)"],
        ["Mac17,4", "MacBook Air (15-inch, M5, 2026)"],
        ["MacBook10,1", "MacBook (Retina, 12-inch, 2017)"],
        ["iMac21,1", "iMac (24-inch, M1, 2021)"],
        ["iMacPro1,1", "iMac Pro (2017)"],
        ["Macmini8,1", "Mac mini (2018)"],
        ["Mac18,5", "Mac mini (M6, 2026)"],
        ["Mac17,15", "Mac Studio (M5 Ultra, 2026)"],
        ["Mac14,8", "Mac Pro (2023)"],
        ["iPhone19,4", "iPhone Duo"]
    ])
    func bundledNames(_ entry: [String]) {
        #expect(DeviceInfo.resolvedModelName(for: entry[0]) == entry[1])
        #expect(DeviceModel(identifier: entry[0]).displayName == entry[1])
    }

    @Test("Hardware variants share a typed model")
    func typedModelVariants() {
        #expect(DeviceModel(identifier: "iPhone19,4") == .iPhoneDuo)
        #expect(DeviceModel.iPhoneDuo.identifiers == ["iPhone19,4"])
        #expect(DeviceModel(identifier: "iPhone19,3") == .iPhone18ProMax)
        #expect(DeviceModel(identifier: "iPhone19,7") == .iPhone18ProMax)
        #expect(DeviceModel.iPhone18ProMax.identifiers == ["iPhone19,3", "iPhone19,7"])
        #expect(DeviceModel(identifier: "Mac16,10") == .macMini2024)
        #expect(DeviceModel(identifier: "arm64") == .simulator)
    }

    @Test("Every bundled hardware identifier resolves to a declared model")
    func catalogCoverage() {
        let entries = DeviceModelCatalog.entries
        #expect(!entries.isEmpty)
        #expect(Set(entries.values.map(\.model)) == Set(DeviceModel.allCases.filter { $0 != .unknown }))
        for (identifier, entry) in entries {
            #expect(entry.model.identifiers.contains(identifier))
            #expect(entry.model.displayName == entry.name)
        }
    }

    @Test("Unknown and unavailable identifiers are preserved")
    func unknownModel() {
        #expect(DeviceInfo.resolvedModelName(for: "Mac999,1") == "Mac999,1")
        #expect(DeviceInfo.resolvedModelName(for: "") == "")
        #expect(DeviceModel(identifier: "Mac999,1") == .unknown)
        #expect(DeviceModel(identifier: "") == .unknown)
        #expect(DeviceModel.unknown.displayName == nil)
        #expect(DeviceModel.unknown.identifiers.isEmpty)
    }

    #if os(macOS)
    @Test("Native macOS reports a Mac model instead of a CPU architecture")
    func nativeMacModel() {
        let identifier = DeviceInfo.modelIdentifier
        #expect(identifier.hasPrefix("Mac") || identifier.hasPrefix("iMac"))
        #expect(!DeviceInfo.modelName.isEmpty)
        #expect(DeviceInfo.systemName == "macOS")
        print("Native Mac model: \(identifier) -> \(DeviceInfo.modelName)")
    }
    #endif
}
#endif
