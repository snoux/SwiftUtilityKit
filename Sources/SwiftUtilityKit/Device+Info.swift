import Foundation

#if os(macOS) || (canImport(UIKit) && !os(watchOS))
#if canImport(UIKit)
import UIKit
#endif
#if canImport(Darwin)
import Darwin
#endif

/// 设备与应用信息工具。
///
/// 支持原生 macOS 和 UIKit 平台（watchOS 除外）。
/// 屏幕接口适用于支持 UIScreen 的 UIKit 平台。电池数据来自 macOS 内置电池或 UIDevice。
public enum DeviceInfo {
    /// 系统名称（如 `iOS`）。
    public static var systemName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(tvOS)
        return "tvOS"
        #elseif os(macOS)
        return "macOS"
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

    /// 设备机型标识（如 `iPhone19,4`、`Mac14,7`），读取失败返回空字符串。
    public static var modelIdentifier: String {
        utilityModelIdentifier
    }

    /// 当前机型。模拟器能读取具体硬件标识时，返回所模拟的机型。
    public static var currentModel: DeviceModel {
        DeviceModel(identifier: modelIdentifier)
    }

    /// 设备机型名称（如 `iPhone 15 Pro Max`）。
    ///
    /// 当映射表未命中时返回原始机型标识。
    public static var modelName: String {
        #if targetEnvironment(simulator)
        let model = resolvedModelName(for: modelIdentifier)
        return "Simulator (\(model))"
        #else
        return resolvedModelName(for: modelIdentifier)
        #endif
    }

    static func resolvedModelName(for identifier: String) -> String {
        DeviceModelCatalog.entries[identifier]?.name ?? identifier
    }

    /// 当前 App 版本号（`CFBundleShortVersionString`）。
    public static var appVersion: String {
        AppInfo.version
    }

    /// 当前 App 构建号（`CFBundleVersion`）。
    public static var appBuild: String {
        AppInfo.build
    }

    /// 当前 App 版本号 + 构建号（如 `1.2.3(45)`）。
    public static var appVersionWithBuild: String {
        AppInfo.versionWithBuild
    }

    #if canImport(UIKit) && !os(visionOS)
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
    #endif

    /// 一次读取电量、充电、低电量模式和温度状态。
    @MainActor
    public static var batterySnapshot: BatterySnapshot { BatterySnapshot.capture() }

    #if os(macOS) || (canImport(UIKit) && !os(tvOS))
    /// 电池电量（0...1），不可用时返回 `nil`（如模拟器）。
    @MainActor
    public static var batteryLevel: Float? {
        #if os(macOS)
        return batterySnapshot.level
        #else
        let value = withBatteryMonitoringEnabled { device in
            device.batteryLevel
        }
        guard value >= 0 else { return nil }
        return value
        #endif
    }

    /// 电池百分比（0...100），不可用时返回 `nil`。
    @MainActor
    public static var batteryPercentage: Double? {
        guard let level = batteryLevel else { return nil }
        return Double(level * 100)
    }

    /// 本地化的电池百分比文本。
    @MainActor
    public static var batteryPercentageText: String {
        batterySnapshot.percentageText
    }

    #if os(macOS)
    /// 内置电池状态。接电但未充电时，可通过 `batterySnapshot` 读取接电和充电标记。
    @MainActor
    public static var batteryState: BatteryState { batterySnapshot.state }
    #else
    /// UIKit 平台的电池状态（`UIDevice.BatteryState`）。
    @MainActor
    public static var batteryState: UIDevice.BatteryState {
        withBatteryMonitoringEnabled { device in
            device.batteryState
        }
    }
    #endif

    /// 本地化的电池状态文本。
    @MainActor
    public static var batteryStateText: String {
        batterySnapshot.stateText
    }
    #endif

    /// 设备总容量（字节）。
    public static var totalDiskSpace: Int64? {
        fileSystemAttribute(.systemSize)
    }

    /// 设备剩余容量（字节）。
    public static var freeDiskSpace: Int64? {
        fileSystemAttribute(.systemFreeSize)
    }

    /// 设备已用容量（字节）。
    public static var usedDiskSpace: Int64? {
        guard let total = totalDiskSpace, let free = freeDiskSpace else { return nil }
        return max(total - free, 0)
    }

    /// 设备总容量文本（如 `256 GB`），不可用时返回 `未知`。
    public static var totalDiskSpaceText: String {
        byteCountText(totalDiskSpace)
    }

    /// 设备剩余容量文本（如 `120 GB`），不可用时返回 `未知`。
    public static var freeDiskSpaceText: String {
        byteCountText(freeDiskSpace)
    }

    /// 设备已用容量文本（如 `136 GB`），不可用时返回 `未知`。
    public static var usedDiskSpaceText: String {
        byteCountText(usedDiskSpace)
    }

    /// 一次采集设备诊断信息；返回值可导出 JSON 或可读文本。
    ///
    /// 屏幕像素尺寸沿用 `bounds × scale` 的语义；macOS / visionOS 不采集屏幕。
    /// 存储信息来自沙箱所在文件系统。无内置电池的 Mac 仍提供低电量模式和温度状态。
    @MainActor
    public static func snapshot() -> DeviceSnapshot {
        #if os(macOS) || os(visionOS)
        let screenSnapshot: DeviceSnapshot.Screen? = nil
        #else
        let screen = UIScreen.main
        let logical = screen.bounds.size
        let scale = screen.scale
        let screenSnapshot = DeviceSnapshot.Screen(
            logicalWidth: Double(logical.width), logicalHeight: Double(logical.height),
            pixelWidth: Double(logical.width * scale), pixelHeight: Double(logical.height * scale),
            scale: Double(scale), nativeScale: Double(screen.nativeScale)
        )
        #endif
        let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return DeviceSnapshot(
            systemName: systemName,
            systemVersion: systemVersion,
            modelIdentifier: modelIdentifier,
            modelName: modelName,
            app: AppInfo.snapshot(),
            screen: screenSnapshot,
            battery: batterySnapshot,
            storage: DeviceSnapshot.Storage(
                totalBytes: (attributes?[.systemSize] as? NSNumber)?.int64Value,
                freeBytes: (attributes?[.systemFreeSize] as? NSNumber)?.int64Value
            )
        )
    }

    private static var utilityModelIdentifier: String {
        #if os(macOS)
        // uname.machine reports the CPU architecture on macOS, not the Mac model.
        var size = 0
        guard sysctlbyname("hw.model", nil, &size, nil, 0) == 0,
              size > 0, size <= 4096 else { return "" }
        var bytes = [UInt8](repeating: 0, count: size)
        let status = bytes.withUnsafeMutableBytes { buffer in
            sysctlbyname("hw.model", buffer.baseAddress, &size, nil, 0)
        }
        guard status == 0, size <= bytes.count else { return "" }
        return String(decoding: bytes.prefix(size).prefix(while: { $0 != 0 }), as: UTF8.self)
        #else
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
        #endif
    }

    #if canImport(UIKit) && !os(tvOS)
    @MainActor
    /// 临时开启电池监控后执行闭包。
    ///
    /// - Parameter block: 使用 `UIDevice` 的执行闭包。
    /// - Returns: 闭包返回值。
    private static func withBatteryMonitoringEnabled<T>(_ block: (UIDevice) -> T) -> T {
        let device = UIDevice.current
        BatteryMonitoringLeasePool.shared.acquire()
        defer { BatteryMonitoringLeasePool.shared.release() }
        return block(device)
    }
    #endif

    /// 读取文件系统属性（容量等）。
    ///
    /// - Parameter key: 文件系统属性键。
    /// - Returns: 属性值（字节），读取失败返回 `nil`。
    private static func fileSystemAttribute(_ key: FileAttributeKey) -> Int64? {
        guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
              let number = attrs[key] as? NSNumber else {
            return nil
        }
        return number.int64Value
    }

    /// 将字节数格式化为可读文本。
    ///
    /// - Parameter bytes: 字节数。
    /// - Returns: 本地化的可读文本。
    private static func byteCountText(_ bytes: Int64?) -> String {
        guard let bytes else { return SDKLocalization().text("common.unknown") }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#if canImport(UIKit)
public extension UIDevice {
    /// 当前机型，可与 `DeviceModel` 枚举值直接比较。
    var utilityModel: DeviceModel {
        DeviceModel(identifier: utilityModelIdentifier)
    }

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
        let model = DeviceInfo.resolvedModelName(for: identifier)
        return "Simulator (\(model))"
        #else
        return DeviceInfo.resolvedModelName(for: identifier)
        #endif
    }
}

#if !os(visionOS)
public extension UIScreen {
    /// 屏幕物理分辨率（pixel）。
    var utilityPixelResolution: CGSize {
        CGSize(width: bounds.width * scale, height: bounds.height * scale)
    }
}
#endif
#endif
#endif
