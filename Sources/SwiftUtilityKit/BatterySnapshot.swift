import Foundation

public enum BatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full

    /// 按系统首选语言显示电池状态。
    public var text: String { localizedName() }

    /// 返回指定语言的状态标签，默认使用系统首选语言。
    public func localizedName(locale: Locale? = nil) -> String {
        let key = self == .unknown ? "common.unknown" : "battery.\(rawValue)"
        return SDKLocalization(locale: locale).text(key)
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
    /// 系统报告内置电池是否接入外部电源。无法读取时为 `nil`。
    public let isConnectedToPower: Bool?
    /// 系统报告内置电池是否正在充电。无法读取时为 `nil`。
    public let isCharging: Bool?

    public var percentage: Double? { level.map { Double($0 * 100) } }
    public var percentageText: String { percentageText(locale: nil) }
    public var stateText: String { stateText(locale: nil) }

    /// 格式化电量。默认使用系统地区格式和首选语言。
    public func percentageText(locale: Locale?) -> String {
        guard let percentage else { return SDKLocalization(locale: locale).text("common.unknown") }
        return (percentage / 100).formatted(.percent.precision(.fractionLength(0)).locale(locale ?? .current))
    }

    /// 返回指定语言的电池状态。传入 nil 时使用系统首选语言。
    public func stateText(locale: Locale?) -> String {
        if state == .unknown, isConnectedToPower == true, isCharging == false {
            return SDKLocalization(locale: locale).text("battery.connectedNotCharging")
        }
        return state.localizedName(locale: locale)
    }

    public init(
        level: Float? = nil,
        state: BatteryState = .unknown,
        isLowPowerModeEnabled: Bool? = nil,
        thermalState: DeviceThermalState = .unknown
    ) {
        self.init(
            level: level, state: state, isLowPowerModeEnabled: isLowPowerModeEnabled,
            thermalState: thermalState, isConnectedToPower: nil, isCharging: nil
        )
    }

    public init(
        level: Float? = nil,
        state: BatteryState = .unknown,
        isLowPowerModeEnabled: Bool? = nil,
        thermalState: DeviceThermalState = .unknown,
        isConnectedToPower: Bool?,
        isCharging: Bool?
    ) {
        self.level = level.flatMap { $0.isFinite && (0...1).contains($0) ? $0 : nil }
        self.state = state
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
        self.thermalState = thermalState
        self.isConnectedToPower = isConnectedToPower
        self.isCharging = isCharging
    }

    private enum CodingKeys: String, CodingKey {
        case level, state, isLowPowerModeEnabled, thermalState
        case isConnectedToPower, isCharging
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            level: try values.decodeIfPresent(Float.self, forKey: .level),
            state: try values.decode(BatteryState.self, forKey: .state),
            isLowPowerModeEnabled: try values.decodeIfPresent(Bool.self, forKey: .isLowPowerModeEnabled),
            thermalState: try values.decode(DeviceThermalState.self, forKey: .thermalState),
            isConnectedToPower: try values.decodeIfPresent(Bool.self, forKey: .isConnectedToPower),
            isCharging: try values.decodeIfPresent(Bool.self, forKey: .isCharging)
        )
    }

    static let unknown = BatterySnapshot()
}
