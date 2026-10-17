#if canImport(Darwin) && canImport(Observation)
import Dispatch
import Foundation
import Observation
#if canImport(UIKit) && (os(iOS) || os(visionOS))
import UIKit
#endif

/// 持续监听电量、充电状态、低电量模式和温度压力等级。
///
/// SwiftUI 中使用 `@State` 持有。无 UIKit 电池接口的平台仍监听低电量模式
/// 和温度状态，但电量为 `nil`、充电状态为 `unknown`。
@MainActor
@Observable
public final class BatteryMonitor {
    public private(set) var snapshot: BatterySnapshot = .unknown
    public private(set) var isMonitoring = false

    public var batteryLevel: Float? { snapshot.level }
    public var batteryPercentage: Double? { snapshot.percentage }
    public var batteryPercentageText: String { snapshot.percentageText }
    public var batteryState: BatteryState { snapshot.state }
    public var batteryStateText: String { snapshot.stateText }
    public var isLowPowerModeEnabled: Bool? { snapshot.isLowPowerModeEnabled }
    public var thermalState: DeviceThermalState { snapshot.thermalState }

    @ObservationIgnored private var source: (any BatteryStateSource)?
    @ObservationIgnored private var generation: UInt64 = 0
    @ObservationIgnored private let makeSource: () -> any BatteryStateSource

    public convenience init() {
        self.init(makeSource: { SystemBatteryStateSource() })
    }

    init(makeSource: @escaping () -> any BatteryStateSource) {
        self.makeSource = makeSource
    }

    /// 开始监听并立即读取当前值；重复调用安全。
    public func start() {
        guard !isMonitoring else { return }
        generation &+= 1
        let currentGeneration = generation
        let source = makeSource()
        self.source = source
        isMonitoring = true
        source.start { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self,
                      self.isMonitoring,
                      self.generation == currentGeneration,
                      let snapshot = self.source?.snapshot,
                      self.snapshot != snapshot else { return }
                self.snapshot = snapshot
            }
        }
        snapshot = source.snapshot
    }

    /// 停止监听并清除快照，之后可重新启动。
    public func stop() {
        guard isMonitoring else { return }
        generation &+= 1
        isMonitoring = false
        source?.stop()
        source = nil
        snapshot = .unknown
    }

    isolated deinit {
        source?.stop()
    }
}

@MainActor
protocol BatteryStateSource: AnyObject {
    var snapshot: BatterySnapshot { get }
    func start(handler: @escaping @Sendable () -> Void)
    func stop()
}

@MainActor
final class SystemBatteryStateSource: BatteryStateSource {
    private let center: NotificationCenter
    private var observers: [any NSObjectProtocol] = []
    private var isActive = false

    init(center: NotificationCenter = .default) {
        self.center = center
    }

    var snapshot: BatterySnapshot { BatterySnapshot.capture() }

    func start(handler: @escaping @Sendable () -> Void) {
        guard !isActive else { return }
        isActive = true
        #if canImport(UIKit) && (os(iOS) || os(visionOS))
        BatteryMonitoringLeasePool.shared.acquire()
        #endif

        // Access thermalState before registering, as required by ProcessInfo.
        _ = ProcessInfo.processInfo.thermalState
        var names: [Notification.Name] = [
            .NSProcessInfoPowerStateDidChange,
            ProcessInfo.thermalStateDidChangeNotification
        ]
        #if canImport(UIKit) && (os(iOS) || os(visionOS))
        names += [UIDevice.batteryLevelDidChangeNotification, UIDevice.batteryStateDidChangeNotification]
        #endif
        observers = names.map { name in
            center.addObserver(forName: name, object: nil, queue: nil) { _ in handler() }
        }
    }

    func stop() {
        guard isActive else { return }
        isActive = false
        observers.forEach { center.removeObserver($0) }
        observers.removeAll()
        #if canImport(UIKit) && (os(iOS) || os(visionOS))
        BatteryMonitoringLeasePool.shared.release()
        #endif
    }

    isolated deinit {
        stop()
    }
}

/// Coordinates the process-wide UIDevice flag across readers and monitor instances.
@MainActor
final class BatteryMonitoringLeasePool {
    private let getEnabled: () -> Bool
    private let setEnabled: (Bool) -> Void
    private var count = 0
    private var originalState = false

    #if canImport(UIKit) && (os(iOS) || os(visionOS))
    static let shared = BatteryMonitoringLeasePool(
        getEnabled: { UIDevice.current.isBatteryMonitoringEnabled },
        setEnabled: { UIDevice.current.isBatteryMonitoringEnabled = $0 }
    )
    #endif

    init(getEnabled: @escaping () -> Bool, setEnabled: @escaping (Bool) -> Void) {
        self.getEnabled = getEnabled
        self.setEnabled = setEnabled
    }

    func acquire() {
        if count == 0 {
            originalState = getEnabled()
            if !originalState { setEnabled(true) }
        }
        count += 1
    }

    func release() {
        guard count > 0 else { return }
        count -= 1
        if count == 0 && getEnabled() != originalState {
            setEnabled(originalState)
        }
    }
}

extension BatterySnapshot {
    @MainActor
    static func capture() -> BatterySnapshot {
        let process = ProcessInfo.processInfo
        let thermalState: DeviceThermalState
        switch process.thermalState {
        case .nominal: thermalState = .nominal
        case .fair: thermalState = .fair
        case .serious: thermalState = .serious
        case .critical: thermalState = .critical
        @unknown default: thermalState = .unknown
        }

        #if canImport(UIKit) && (os(iOS) || os(visionOS))
        BatteryMonitoringLeasePool.shared.acquire()
        defer { BatteryMonitoringLeasePool.shared.release() }
        let device = UIDevice.current
        let state: BatteryState
        switch device.batteryState {
        case .unknown: state = .unknown
        case .unplugged: state = .unplugged
        case .charging: state = .charging
        case .full: state = .full
        @unknown default: state = .unknown
        }
        return BatterySnapshot(
            level: device.batteryLevel,
            state: state,
            isLowPowerModeEnabled: process.isLowPowerModeEnabled,
            thermalState: thermalState
        )
        #else
        return BatterySnapshot(
            isLowPowerModeEnabled: process.isLowPowerModeEnabled,
            thermalState: thermalState
        )
        #endif
    }
}
#endif
