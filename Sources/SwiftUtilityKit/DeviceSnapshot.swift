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

    /// 面向日志和反馈页的中文可读文本。
    public var text: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        func capacity(_ bytes: Int64?) -> String {
            bytes.map { formatter.string(fromByteCount: $0) } ?? "未知"
        }
        let powerMode = battery.isLowPowerModeEnabled.map { $0 ? "开启" : "关闭" } ?? "未知"
        var lines = [
            "采集时间：\(ISO8601DateFormatter().string(from: capturedAt))",
            "系统：\(systemName) \(systemVersion)",
            "机型：\(modelName) (\(modelIdentifier))",
            "应用：\(app.name)",
            "Bundle ID：\(app.bundleIdentifier)",
            "应用版本：\(app.versionWithBuild)",
            "电量：\(battery.percentageText)",
            "充电状态：\(battery.stateText)",
            "低电量模式：\(powerMode)",
            "温度状态：\(battery.thermalState.rawValue)",
            "总容量：\(capacity(storage.totalBytes))",
            "剩余容量：\(capacity(storage.freeBytes))",
            "已用容量：\(capacity(storage.usedBytes))"
        ]
        if let screen {
            lines += [
                "逻辑分辨率：\(screen.logicalWidth)x\(screen.logicalHeight) pt",
                "像素尺寸（bounds × scale）：\(screen.pixelWidth)x\(screen.pixelHeight) px",
                "屏幕缩放：\(screen.scale)，原生缩放：\(screen.nativeScale)"
            ]
        }
        return lines.joined(separator: "\n")
    }
}
