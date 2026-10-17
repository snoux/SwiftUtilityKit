import Foundation

/// 可跨平台保存、编码的应用信息。
public struct AppSnapshot: Codable, Equatable, Sendable {
    public let name: String
    public let bundleIdentifier: String
    public let version: String
    public let build: String

    public var versionWithBuild: String {
        if version.isEmpty { return build }
        if build.isEmpty { return version }
        return "\(version)(\(build))"
    }

    public init(name: String, bundleIdentifier: String, version: String, build: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.version = version
        self.build = build
    }

    init(infoDictionary: [String: Any], bundleIdentifier: String? = nil) {
        let displayName = infoDictionary["CFBundleDisplayName"] as? String ?? ""
        self.init(
            name: displayName.isEmpty ? infoDictionary["CFBundleName"] as? String ?? "" : displayName,
            bundleIdentifier: bundleIdentifier ?? infoDictionary["CFBundleIdentifier"] as? String ?? "",
            version: infoDictionary["CFBundleShortVersionString"] as? String ?? "",
            build: infoDictionary["CFBundleVersion"] as? String ?? ""
        )
    }
}

/// 仅依赖 Foundation 的应用信息入口，支持 iOS、macOS 等平台。
public enum AppInfo {
    /// 本地化显示名称，缺失时回退到 `CFBundleName`。
    public static var name: String { snapshot().name }
    public static var bundleIdentifier: String { snapshot().bundleIdentifier }
    public static var version: String { snapshot().version }
    public static var build: String { snapshot().build }
    public static var versionWithBuild: String { snapshot().versionWithBuild }

    /// 读取指定 Bundle，字段缺失时返回空字符串。
    public static func snapshot(bundle: Bundle = .main) -> AppSnapshot {
        var values = bundle.infoDictionary ?? [:]
        values.merge(bundle.localizedInfoDictionary ?? [:]) { _, localized in localized }
        return AppSnapshot(infoDictionary: values, bundleIdentifier: bundle.bundleIdentifier)
    }
}
