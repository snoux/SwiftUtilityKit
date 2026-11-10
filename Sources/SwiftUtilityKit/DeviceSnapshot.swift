import Foundation

/// 设备诊断快照。采集后不随系统状态变化，可用于日志、反馈附件和测试报告。
public struct DeviceSnapshot: Codable, Equatable, Sendable {
    public struct Screen: Codable, Equatable, Sendable {
        public let logicalWidth: Double
        public let logicalHeight: Double
        public let pixelWidth: Double
        public let pixelHeight: Double
        public let scale: Double
        public let nativeScale: Double

        public init(
            logicalWidth: Double, logicalHeight: Double,
            pixelWidth: Double, pixelHeight: Double,
            scale: Double, nativeScale: Double
        ) {
            self.logicalWidth = logicalWidth
            self.logicalHeight = logicalHeight
            self.pixelWidth = pixelWidth
            self.pixelHeight = pixelHeight
            self.scale = scale
            self.nativeScale = nativeScale
        }
    }

    public struct Storage: Codable, Equatable, Sendable {
        public let totalBytes: Int64?
        public let freeBytes: Int64?
        public var usedBytes: Int64? {
            guard let totalBytes, let freeBytes else { return nil }
            return max(totalBytes - freeBytes, 0)
        }

        public init(totalBytes: Int64?, freeBytes: Int64?) {
            self.totalBytes = totalBytes.flatMap { $0 >= 0 ? $0 : nil }
            self.freeBytes = freeBytes.flatMap { $0 >= 0 ? $0 : nil }
        }

        private enum CodingKeys: String, CodingKey {
            case totalBytes, freeBytes
        }

        public init(from decoder: any Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.init(
                totalBytes: try values.decodeIfPresent(Int64.self, forKey: .totalBytes),
                freeBytes: try values.decodeIfPresent(Int64.self, forKey: .freeBytes)
            )
        }
    }

    public let capturedAt: Date
    public let systemName: String
    public let systemVersion: String
    public let modelIdentifier: String
    public let modelName: String
    public let app: AppSnapshot
    public let screen: Screen?
    public let battery: BatterySnapshot
    public let storage: Storage

    /// 根据快照保存的硬件标识解析机型。
    public var model: DeviceModel { DeviceModel(identifier: modelIdentifier) }

    public init(
        capturedAt: Date = Date(), systemName: String, systemVersion: String,
        modelIdentifier: String, modelName: String, app: AppSnapshot,
        screen: Screen? = nil, battery: BatterySnapshot = BatterySnapshot(),
        storage: Storage = Storage(totalBytes: nil, freeBytes: nil)
    ) {
        self.capturedAt = capturedAt
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.modelIdentifier = modelIdentifier
        self.modelName = modelName
        self.app = app
        self.screen = screen
        self.battery = battery
        self.storage = storage
    }

    /// JSON 的采集时间使用 ISO 8601 字符串；缺失的可选值不输出。
    public func jsonData(prettyPrinted: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = prettyPrinted ? [.prettyPrinted, .sortedKeys] : [.sortedKeys]
        return try encoder.encode(self)
    }

    public func jsonString(prettyPrinted: Bool = true) throws -> String {
        String(decoding: try jsonData(prettyPrinted: prettyPrinted), as: UTF8.self)
    }

    /// 使用系统首选语言生成日志和反馈页的可读文本。
    public var text: String { text(locale: nil) }

    /// 使用指定语言和地区生成诊断文本。传入 nil 时跟随系统设置。
    public func text(locale: Locale?) -> String {
        let localization = SDKLocalization(locale: locale)
        let unknown = localization.text("common.unknown")
        let byteFormat = ByteCountFormatStyle(style: .file).locale(locale ?? .current)
        func capacity(_ bytes: Int64?) -> String {
            bytes.map { $0.formatted(byteFormat) } ?? unknown
        }
        func line(_ field: String, _ value: String) -> String {
            localization.format("diagnostic.line", localization.text("diagnostic.\(field)"), value)
        }
        let powerMode = battery.isLowPowerModeEnabled.map {
            localization.text($0 ? "common.enabled" : "common.disabled")
        } ?? unknown
        var lines = [
            line("capturedAt", ISO8601DateFormatter().string(from: capturedAt)),
            line("system", "\(systemName) \(systemVersion)"),
            line("model", "\(modelName) (\(modelIdentifier))"),
            line("app", app.name),
            line("bundleID", app.bundleIdentifier),
            line("version", app.versionWithBuild),
            line("batteryLevel", battery.percentageText(locale: locale)),
            line("batteryState", battery.stateText(locale: locale)),
            line("lowPowerMode", powerMode),
            line("thermalState", battery.thermalState.rawValue),
            line("totalStorage", capacity(storage.totalBytes)),
            line("freeStorage", capacity(storage.freeBytes)),
            line("usedStorage", capacity(storage.usedBytes))
        ]
        if let screen {
            lines += [
                line("logicalResolution", "\(screen.logicalWidth)x\(screen.logicalHeight) pt"),
                line("pixelResolution", "\(screen.pixelWidth)x\(screen.pixelHeight) px"),
                line("screenScale", String(screen.scale)),
                line("nativeScale", String(screen.nativeScale))
            ]
        }
        return lines.joined(separator: "\n")
    }
}
