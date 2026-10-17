import Foundation

public enum BatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full

    public var text: String {
        switch self {
        case .unknown: "未知"
        case .unplugged: "未充电"
        case .charging: "充电中"
        case .full: "已充满"
        }
    }
}

/// 系统报告的温度压力等级，不是摄氏温度。
public enum DeviceThermalState: String, Codable, Sendable {
    case unknown
    case nominal
    case fair
    case serious
    case critical
}

/// 电池和设备功耗状态；不可获取的值保留为 `nil` / `unknown`。
public struct BatterySnapshot: Codable, Equatable, Sendable {
    public let level: Float?
    public let state: BatteryState
    public let isLowPowerModeEnabled: Bool?
    public let thermalState: DeviceThermalState

    public var percentage: Double? { level.map { Double($0 * 100) } }
    public var percentageText: String {
        guard let percentage else { return "未知" }
        return String(format: "%.0f%%", percentage)
    }
    public var stateText: String { state.text }

    public init(
        level: Float? = nil,
        state: BatteryState = .unknown,
        isLowPowerModeEnabled: Bool? = nil,
        thermalState: DeviceThermalState = .unknown
    ) {
        self.level = level.flatMap { $0.isFinite && (0...1).contains($0) ? $0 : nil }
        self.state = state
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
        self.thermalState = thermalState
    }

    private enum CodingKeys: String, CodingKey {
        case level, state, isLowPowerModeEnabled, thermalState
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            level: try values.decodeIfPresent(Float.self, forKey: .level),
            state: try values.decode(BatteryState.self, forKey: .state),
            isLowPowerModeEnabled: try values.decodeIfPresent(Bool.self, forKey: .isLowPowerModeEnabled),
            thermalState: try values.decode(DeviceThermalState.self, forKey: .thermalState)
        )
    }

    static let unknown = BatterySnapshot()
}
