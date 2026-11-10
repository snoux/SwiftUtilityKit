#if os(macOS)
import Foundation
import IOKit.ps

enum MacBatteryPower {
    static func snapshot(
        isLowPowerModeEnabled: Bool?, thermalState: DeviceThermalState
    ) -> BatterySnapshot {
        let descriptions: [[String: Any]]
        if let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
           let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [AnyObject] {
            descriptions = sources.compactMap { source in
                IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any]
            }
        } else {
            descriptions = []
        }
        return snapshot(from: descriptions, isLowPowerModeEnabled: isLowPowerModeEnabled, thermalState: thermalState)
    }

    static func snapshot(
        from descriptions: [[String: Any]],
        isLowPowerModeEnabled: Bool? = nil,
        thermalState: DeviceThermalState = .unknown
    ) -> BatterySnapshot {
        guard let battery = descriptions.first(where: {
            $0[kIOPSTypeKey] as? String == kIOPSInternalBatteryType &&
                $0[kIOPSIsPresentKey] as? Bool != false
        }) else {
            return BatterySnapshot(isLowPowerModeEnabled: isLowPowerModeEnabled, thermalState: thermalState)
        }

        let level: Float?
        if let current = battery[kIOPSCurrentCapacityKey] as? Int,
           let maximum = battery[kIOPSMaxCapacityKey] as? Int,
           maximum > 0, (0...maximum).contains(current) {
            level = Float(current) / Float(maximum)
        } else {
            level = nil
        }

        let isConnectedToPower: Bool? = switch battery[kIOPSPowerSourceStateKey] as? String {
        case kIOPSACPowerValue: true
        case kIOPSBatteryPowerValue: false
        default: nil
        }
        let isCharging = battery[kIOPSIsChargingKey] as? Bool
        let isCharged = battery[kIOPSIsChargedKey] as? Bool
        let state: BatteryState
        if isCharging == true {
            state = .charging
        } else if isConnectedToPower == false {
            state = .unplugged
        } else if isConnectedToPower == true, isCharged == true {
            state = .full
        } else {
            state = .unknown
        }

        return BatterySnapshot(
            level: level, state: state, isLowPowerModeEnabled: isLowPowerModeEnabled,
            thermalState: thermalState, isConnectedToPower: isConnectedToPower, isCharging: isCharging
        )
    }
}

@MainActor
final class MacBatteryPowerObservation {
    private final class Callback {
        let handler: @Sendable () -> Void

        init(handler: @escaping @Sendable () -> Void) {
            self.handler = handler
        }
    }

    private let callback: Callback
    private let source: CFRunLoopSource

    init?(handler: @escaping @Sendable () -> Void) {
        let callback = Callback(handler: handler)
        let context = Unmanaged.passUnretained(callback).toOpaque()
        guard let source = IOPSNotificationCreateRunLoopSource({ context in
            guard let context else { return }
            Unmanaged<Callback>.fromOpaque(context).takeUnretainedValue().handler()
        }, context)?.takeRetainedValue() else { return nil }

        self.callback = callback
        self.source = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
    }

    isolated deinit {
        // Invalidate on the same run loop's actor before releasing the callback context.
        withExtendedLifetime(callback) {
            CFRunLoopSourceInvalidate(source)
        }
    }
}
#endif
