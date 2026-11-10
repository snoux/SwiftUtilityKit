import Foundation

/// 商品机型。同一商品机型的不同硬件标识共享一个枚举值。
public enum DeviceModel: String, CaseIterable, Sendable {
    /// 未收录或无法读取硬件标识。
    case unknown

    // Simulator
    case simulator

    // iPod
    case iPodTouch
    case iPodTouchGeneration2
    case iPodTouchGeneration3
    case iPodTouchGeneration4
    case iPodTouchGeneration5
    case iPodTouchGeneration6
    case iPodTouchGeneration7

    // iPhone
    case iPhone
    case iPhone3G
    case iPhone3GS
    case iPhone4
    case iPhone4s
    case iPhone5
    case iPhone5c
    case iPhone5s
    case iPhone6Plus
    case iPhone6
    case iPhone6s
    case iPhone6sPlus
    case iPhoneSEGeneration1
    case iPhone7
    case iPhone7Plus
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
    case iPhoneXSMax
    case iPhoneXR
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax
    case iPhoneSEGeneration2
    case iPhone12Mini
    case iPhone12
    case iPhone12Pro
    case iPhone12ProMax
    case iPhone13Pro
    case iPhone13ProMax
    case iPhone13Mini
    case iPhone13
    case iPhoneSEGeneration3
    case iPhone14
    case iPhone14Plus
    case iPhone14Pro
    case iPhone14ProMax
    case iPhone15
    case iPhone15Plus
    case iPhone15Pro
    case iPhone15ProMax
    case iPhone16Pro
    case iPhone16ProMax
    case iPhone16
    case iPhone16Plus
    case iPhone16e
    case iPhone17Pro
    case iPhone17ProMax
    case iPhone17
    case iPhoneAir
    case iPhone17e
    case iPhone18Pro
    case iPhone18ProMax
    case iPhoneDuo

    // iPad
    case iPad
    case iPad2
    case iPadMini
    case iPadGeneration3
    case iPadGeneration4
    case iPadAir
    case iPadMini2
    case iPadMini3
    case iPadMini4
    case iPadAir2
    case iPadPro9_7Inch
    case iPadPro12_9Inch
    case iPadGeneration5
    case iPadPro12_9InchGeneration2
    case iPadPro10_5Inch
    case iPadGeneration6
    case iPadGeneration7
    case iPadPro11Inch
    case iPadPro12_9InchGeneration3
    case iPadPro11InchGeneration2
    case iPadPro12_9InchGeneration4
    case iPadMiniGeneration5
    case iPadAirGeneration3
    case iPadGeneration8
    case iPadGeneration9
    case iPadAirGeneration4
    case iPadPro11InchGeneration3
    case iPadPro12_9InchGeneration5
    case iPadAirGeneration5
    case iPadGeneration10
    case iPadMiniGeneration6
    case iPadPro11InchGeneration4
    case iPadPro12_9InchGeneration6
    case iPadAir11InchM2
    case iPadAir13InchM2
    case iPadAir11InchGeneration7
    case iPadAir13InchGeneration7
    case iPadGeneration11
    case iPadPro11InchM4
    case iPadPro13InchM4

    // MacBook Pro
    case macBookPro13Inch2017TwoPorts
    case macBookPro13Inch2017FourPorts
    case macBookPro15Inch2017
    case macBookPro15Inch2018To2019
    case macBookPro13Inch2018To2019FourPorts
    case macBookPro15Inch2019
    case macBookPro13Inch2019TwoPorts
    case macBookPro16Inch2019
    case macBookPro13Inch2020FourPorts
    case macBookPro13Inch2020TwoPorts
    case macBookPro13InchM12020
    case macBookPro16Inch2021
    case macBookPro14Inch2021
    case macBookPro14Inch2023
    case macBookPro16Inch2023
    case macBookPro13InchM22022
    case macBookPro14InchM3Nov2023
    case macBookPro14InchNov2023
    case macBookPro16InchNov2023
    case macBookPro14InchM42024
    case macBookPro16Inch2024
    case macBookPro14Inch2024
    case macBookPro14InchM52025
    case macBookPro16Inch2026
    case macBookPro14Inch2026

    // MacBook Air
    case macBookAirRetina13Inch2018
    case macBookAirRetina13Inch2019
    case macBookAirRetina13Inch2020
    case macBookAirM12020
    case macBookAirM22022
    case macBookAir15InchM22023
    case macBookAir13InchM32024
    case macBookAir15InchM32024
    case macBookAir13InchM42025
    case macBookAir15InchM42025
    case macBookAir13InchM52026
    case macBookAir15InchM52026

    // MacBook
    case macBookRetina12InchEarly2015
    case macBookRetina12InchEarly2016
    case macBookRetina12Inch2017

    // iMac / iMac Pro
    case iMac21_5Inch2017
    case iMacRetina4K21_5Inch2017
    case iMacRetina5K27Inch2017
    case iMacRetina5K27Inch2019
    case iMacRetina4K21_5Inch2019
    case iMacRetina5K27Inch2020
    case iMac24InchM12021
    case iMacPro2017
    case iMac24Inch2023TwoPorts
    case iMac24Inch2023FourPorts
    case iMac24Inch2024TwoPorts
    case iMac24Inch2024FourPorts

    // Mac mini
    case macMini2018
    case macMiniM12020
    case macMiniM22023
    case macMiniM2Pro2023
    case macMini2024
    case macMiniM5Pro2026
    case macMiniM62026

    // Mac Studio
    case macStudioM1Max2022
    case macStudioM1Ultra2022
    case macStudioM2Max2023
    case macStudioM2Ultra2023
    case macStudioM3Ultra2025
    case macStudioM4Max2025
    case macStudioM5Max2026
    case macStudioM5Ultra2026

    // Mac Pro (tower and rack share identifiers)
    case macPro2019
    case macPro2023

    /// 根据硬件标识查询机型。未收录的标识返回 `.unknown`。
    public init(identifier: String) {
        self = DeviceModelCatalog.entries[identifier]?.model ?? .unknown
    }

    /// 机型的显示名称。未知机型返回 `nil`。
    public var displayName: String? {
        guard let identifier = identifiers.first else { return nil }
        return DeviceModelCatalog.entries[identifier]?.name
    }

    /// 此机型对应的所有硬件标识。未知机型返回空数组。
    public var identifiers: [String] {
        DeviceModelCatalog.identifiersByModel[self] ?? []
    }
}

enum DeviceModelCatalog {
    struct Entry: Sendable {
        let name: String
        let model: DeviceModel
    }

    static let entries: [String: Entry] = loadEntries()
    static let identifiersByModel: [DeviceModel: [String]] = Dictionary(
        grouping: entries.keys.filter { entries[$0]?.model != DeviceModel.unknown }.sorted(),
        by: { entries[$0]?.model ?? .unknown }
    )

    private static func loadEntries() -> [String: Entry] {
        guard let content = loadDeviceListText() else { return [:] }

        var entries: [String: Entry] = [:]
        for rawLine in content.split(whereSeparator: \.isNewline) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { continue }

            let columns = line.split(separator: "|", omittingEmptySubsequences: false)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard (2...3).contains(columns.count), !columns[0].isEmpty, !columns[1].isEmpty else { continue }

            // Legacy resources with two columns still supply a display name.
            let model = columns.count == 3 ? DeviceModel(rawValue: columns[2]) ?? .unknown : .unknown
            entries[columns[0]] = Entry(name: columns[1], model: model)
        }
        return entries
    }

    /// 从资源中读取设备型号文本。
    ///
    /// - Returns: 设备型号映射文本；读取失败返回 `nil`。
    private static func loadDeviceListText() -> String? {
        let resourceName = "AppleDeviceList"
        let ext = "txt"

        #if SWIFT_PACKAGE
        if let url = Bundle.module.url(forResource: resourceName, withExtension: ext) {
            return try? String(contentsOf: url, encoding: .utf8)
        }
        #endif

        let candidates = [
            Bundle.main,
            Bundle(for: DeviceModelBundleToken.self)
        ]
        for bundle in candidates {
            if let url = bundle.url(forResource: resourceName, withExtension: ext),
               let text = try? String(contentsOf: url, encoding: .utf8) {
                return text
            }
        }
        return nil
    }
}

private final class DeviceModelBundleToken {}
