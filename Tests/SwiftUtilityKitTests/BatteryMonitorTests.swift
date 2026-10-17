#if canImport(Darwin) && canImport(Observation)
import Dispatch
import Foundation
import Observation
import Testing
@testable import SwiftUtilityKit
#if canImport(UIKit) && (os(iOS) || os(visionOS))
import UIKit
#endif

@MainActor
@Suite("Battery and device state monitoring")
struct BatteryMonitorTests {
    @Test("Battery values normalize unavailable and invalid levels")
    func batteryValues() {
        for level in [Float(-1), 1.1, .nan, .infinity] {
            #expect(BatterySnapshot(level: level).level == nil)
        }
        #expect(BatterySnapshot().percentageText == "未知")
        #expect(BatterySnapshot(level: 0).percentageText == "0%")
        #expect(BatterySnapshot(level: 1, state: .full).percentageText == "100%")
        #expect(BatterySnapshot(level: 0.5, state: .charging).stateText == "充电中")
    }

    @Test("Start samples immediately, lifecycle methods are idempotent, stop clears state")
    func lifecycle() {
        let source = MockBatterySource()
        let monitor = BatteryMonitor(makeSource: { source })
        #expect(monitor.batteryLevel == nil)
        #expect(monitor.isLowPowerModeEnabled == nil)
        #expect(monitor.thermalState == .unknown)
        monitor.start()
        monitor.start()
        #expect(source.startCount == 1)
        #expect(monitor.batteryPercentage == 50)
        #expect(monitor.batteryState == .unplugged)
        #expect(monitor.isLowPowerModeEnabled == false)
        #expect(monitor.thermalState == .nominal)
        monitor.stop()
        monitor.stop()
        #expect(source.stopCount == 1)
        #expect(!monitor.isMonitoring)
        #expect(monitor.snapshot == .unknown)
    }

    @Test("Battery, power mode and thermal changes participate in Observation")
    func observation() async {
        let source = MockBatterySource()
        let monitor = BatteryMonitor(makeSource: { source })
        monitor.start()
        await confirmation("Power state changes", expectedCount: 1) { changed in
            withObservationTracking {
                _ = monitor.isLowPowerModeEnabled
                _ = monitor.batteryPercentage
                _ = monitor.thermalState
            } onChange: { changed() }
            source.emit(BatterySnapshot(level: 0.8, state: .charging, isLowPowerModeEnabled: true, thermalState: .serious))
            await drainMainQueue()
        }
        #expect(monitor.batteryPercentageText == "80%")
        #expect(monitor.batteryStateText == "充电中")
        #expect(monitor.isLowPowerModeEnabled == true)
        #expect(monitor.thermalState == .serious)

        await confirmation("Identical snapshots are suppressed", expectedCount: 0) { changed in
            withObservationTracking { _ = monitor.snapshot } onChange: { changed() }
            source.emit(source.snapshot)
            await drainMainQueue()
        }
    }

    @Test("Restart rejects old callbacks and creates a new source")
    func restart() async {
        let oldSource = MockBatterySource()
        let newSource = MockBatterySource()
        var count = 0
        let monitor = BatteryMonitor(makeSource: {
            count += 1
            return count == 1 ? oldSource : newSource
        })
        monitor.start()
        oldSource.emit(BatterySnapshot(level: 0.1))
        monitor.stop()
        monitor.start()
        await drainMainQueue()
        #expect(count == 2)
        #expect(monitor.batteryPercentage == 50)

        newSource.snapshot = BatterySnapshot(level: 0.9)
        oldSource.handler?()
        await drainMainQueue()
        #expect(monitor.batteryPercentage == 50)
        newSource.handler?()
        await drainMainQueue()
        #expect(monitor.batteryPercentage == 90)
    }

    @Test("Queued notifications cannot repopulate a stopped monitor")
    func stoppedCallbacks() async {
        let source = MockBatterySource()
        let monitor = BatteryMonitor(makeSource: { source })
        monitor.start()
        source.emit(BatterySnapshot(level: 0.9))
        monitor.stop()
        source.handler?()
        await drainMainQueue()
        #expect(monitor.snapshot == .unknown)
    }

    @Test("Background notifications are handled safely on the main actor")
    func backgroundCallback() async {
        let source = MockBatterySource()
        let monitor = BatteryMonitor(makeSource: { source })
        monitor.start()
        source.snapshot = BatterySnapshot(level: 1, state: .full)
        let handler = source.handler
        await Task.detached { handler?() }.value
        await drainMainQueue()
        #expect(monitor.batteryState == .full)
    }

    @Test("Releasing a monitor stops its source without a retain cycle")
    func cleanup() async {
        let source = MockBatterySource()
        var monitor: BatteryMonitor? = BatteryMonitor(makeSource: { source })
        let isReleased = { [weak monitor] in monitor == nil }
        monitor?.start()
        source.handler?()
        monitor = nil
        await drainMainQueue()
        #expect(isReleased())
        #expect(source.stopCount == 1)
    }

    @Test("System source observes power and thermal notifications and removes observers")
    func notificationLifecycle() async {
        let center = NotificationCenter()
        let source = SystemBatteryStateSource(center: center)
        #if canImport(UIKit) && (os(iOS) || os(visionOS))
        let expectedCount = 4
        #else
        let expectedCount = 2
        #endif
        await confirmation("Only active notifications are delivered", expectedCount: expectedCount) { changed in
            source.start { changed() }
            center.post(name: .NSProcessInfoPowerStateDidChange, object: nil)
            center.post(name: ProcessInfo.thermalStateDidChangeNotification, object: nil)
            #if canImport(UIKit) && (os(iOS) || os(visionOS))
            center.post(name: UIDevice.batteryLevelDidChangeNotification, object: nil)
            center.post(name: UIDevice.batteryStateDidChangeNotification, object: nil)
            #endif
            source.stop()
            center.post(name: .NSProcessInfoPowerStateDidChange, object: nil)
        }
    }

    @Test("Shared leases keep monitoring enabled until the last user releases it")
    func sharedLeases() {
        var enabled = false
        var transitions: [Bool] = []
        let pool = BatteryMonitoringLeasePool(getEnabled: { enabled }, setEnabled: {
            enabled = $0
            transitions.append($0)
        })
        pool.acquire()
        pool.acquire()
        pool.release()
        #expect(enabled)
        pool.acquire()
        pool.release()
        #expect(enabled)
        pool.release()
        #expect(!enabled)
        #expect(transitions == [true, false])
    }

    @Test("Lease pool preserves pre-existing monitoring and resamples subsequent sessions")
    func originalMonitoringState() {
        var enabled = true
        let pool = BatteryMonitoringLeasePool(getEnabled: { enabled }, setEnabled: { enabled = $0 })
        pool.acquire()
        pool.release()
        #expect(enabled)
        enabled = false
        pool.acquire()
        #expect(enabled)
        pool.release()
        #expect(!enabled)
    }

    @Test("System monitor samples power state on supported Apple platforms")
    func systemSampling() {
        let monitor = BatteryMonitor()
        monitor.start()
        #expect(monitor.isLowPowerModeEnabled != nil)
        #expect(monitor.thermalState != .unknown)
        #if !canImport(UIKit) || os(tvOS) || os(watchOS)
        #expect(monitor.batteryLevel == nil)
        #expect(monitor.batteryState == .unknown)
        #endif
        monitor.stop()
    }

    #if canImport(UIKit) && (os(iOS) || os(visionOS))
    @Test("Multiple live monitors and one-shot DeviceInfo reads share monitoring ownership")
    func liveSharedMonitoring() {
        let original = UIDevice.current.isBatteryMonitoringEnabled
        let first = BatteryMonitor()
        let second = BatteryMonitor()
        first.start()
        second.start()
        first.stop()
        #expect(UIDevice.current.isBatteryMonitoringEnabled)
        _ = DeviceInfo.batteryLevel
        _ = DeviceInfo.snapshot()
        #expect(UIDevice.current.isBatteryMonitoringEnabled)
        second.stop()
        #expect(UIDevice.current.isBatteryMonitoringEnabled == original)
    }
    #endif

    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }
}

@MainActor
private final class MockBatterySource: BatteryStateSource {
    var snapshot = BatterySnapshot(level: 0.5, state: .unplugged, isLowPowerModeEnabled: false, thermalState: .nominal)
    private(set) var startCount = 0
    private(set) var stopCount = 0
    private(set) var handler: (@Sendable () -> Void)?

    func start(handler: @escaping @Sendable () -> Void) {
        startCount += 1
        self.handler = handler
    }

    func stop() { stopCount += 1 }

    func emit(_ snapshot: BatterySnapshot) {
        self.snapshot = snapshot
        handler?()
    }
}
#endif
