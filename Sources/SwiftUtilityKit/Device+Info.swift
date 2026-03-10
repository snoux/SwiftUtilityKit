import Foundation

#if canImport(UIKit)
import UIKit
#if canImport(Darwin)
import Darwin
#endif

/// 设备与应用信息工具。
///
/// 说明：仅在可导入 UIKit 的平台（如 iOS）可用。
public enum DeviceInfo {
    /// 系统名称（如 `iOS`）。
    public static var systemName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(visionOS)
        return "visionOS"
        #else
        return "AppleOS"
        #endif
    }

    /// 系统版本号（如 `18.2`）。
    public static var systemVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    /// 设备机型标识（如 `iPhone16,2`）。
    public static var modelIdentifier: String {
        utilityModelIdentifier
    }

    /// 设备机型名称（如 `iPhone 15 Pro Max`）。
    ///
    /// 当映射表未命中时返回原始机型标识。
    public static var modelName: String {
        #if targetEnvironment(simulator)
        let model = utilityDeviceMap[modelIdentifier] ?? modelIdentifier
        return "Simulator (\(model))"
        #else
        return utilityDeviceMap[modelIdentifier] ?? modelIdentifier
        #endif
    }

    /// 当前 App 版本号（`CFBundleShortVersionString`）。
    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    /// 当前 App 构建号（`CFBundleVersion`）。
    public static var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }

    /// 当前 App 版本号 + 构建号（如 `1.2.3(45)`）。
    public static var appVersionWithBuild: String {
        let version = appVersion
        let build = appBuild
        if version.isEmpty { return build }
        if build.isEmpty { return version }
        return "\(version)(\(build))"
    }

    /// 逻辑分辨率（point）。
    @MainActor
    public static var logicalResolution: CGSize {
        UIScreen.main.bounds.size
    }

    /// 物理分辨率（pixel）。
    @MainActor
    public static var pixelResolution: CGSize {
        UIScreen.main.utilityPixelResolution
    }

    /// 逻辑分辨率字符串（如 `393x852 pt`）。
    @MainActor
    public static var logicalResolutionText: String {
        "\(Int(logicalResolution.width))x\(Int(logicalResolution.height)) pt"
    }

    /// 物理分辨率字符串（如 `1179x2556 px`）。
    @MainActor
    public static var pixelResolutionText: String {
        "\(Int(pixelResolution.width))x\(Int(pixelResolution.height)) px"
    }

    /// 屏幕缩放倍数（`UIScreen.main.scale`）。
    @MainActor
    public static var screenScale: CGFloat {
        UIScreen.main.scale
    }

    /// 原生屏幕缩放倍数（`UIScreen.main.nativeScale`）。
    @MainActor
    public static var nativeScale: CGFloat {
        UIScreen.main.nativeScale
    }

    private static var utilityModelIdentifier: String {
        #if targetEnvironment(simulator)
        if let simulatorIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
           !simulatorIdentifier.isEmpty {
            return simulatorIdentifier
        }
        #endif

        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce(into: "") { partial, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            partial.append(String(UnicodeScalar(UInt8(value))))
        }
    }

    fileprivate static let utilityDeviceMap: [String: String] = loadDeviceMap()

    private static func loadDeviceMap() -> [String: String] {
        guard let content = loadDeviceListText() else {
            return [:]
        }

        var result: [String: String] = [:]
        content.split(whereSeparator: \.isNewline).forEach { rawLine in
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { return }

            let parts = line.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { return }

            let key = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
            let value = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty, !value.isEmpty else { return }
            result[key] = value
        }
        return result
    }

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
            Bundle(for: DeviceInfoBundleToken.self)
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

private final class DeviceInfoBundleToken {}

public extension UIDevice {
    /// 设备机型标识（如 `iPhone16,2`）。
    var utilityModelIdentifier: String {
        #if targetEnvironment(simulator)
        if let simulatorIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"],
           !simulatorIdentifier.isEmpty {
            return simulatorIdentifier
        }
        #endif

        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce(into: "") { partial, element in
            guard let value = element.value as? Int8, value != 0 else { return }
            partial.append(String(UnicodeScalar(UInt8(value))))
        }
        return identifier
    }

    /// 设备机型名称（如 `iPhone 15 Pro Max`）。
    ///
    /// 当映射表未命中时返回机型标识。
    var utilityModelName: String {
        let identifier = utilityModelIdentifier

        #if targetEnvironment(simulator)
        let model = DeviceInfo.utilityDeviceMap[identifier] ?? identifier
        return "Simulator (\(model))"
        #else
        return DeviceInfo.utilityDeviceMap[identifier] ?? identifier
        #endif
    }
}

public extension UIScreen {
    /// 屏幕物理分辨率（pixel）。
    var utilityPixelResolution: CGSize {
        CGSize(width: bounds.width * scale, height: bounds.height * scale)
    }
}
#endif
