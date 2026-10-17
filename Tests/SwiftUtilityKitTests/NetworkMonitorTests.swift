#if canImport(Network) && canImport(Observation)
import Dispatch
import Network
import Observation
import Testing
@testable import SwiftUtilityKit

@MainActor
@Suite("Network monitoring")
struct NetworkMonitorTests {
    @Test("Initial state is unknown and monitoring is explicit")
    func initialState() {
        let source = MockNetworkPathMonitor()
        let monitor = NetworkMonitor(makeMonitor: { source })

        #expect(!monitor.isMonitoring)
        #expect(monitor.status == .unknown)
        #expect(monitor.isConnected == nil)
        #expect(monitor.connectionType == .unknown)
        #expect(monitor.interfaces.isEmpty)
        #expect(source.startCount == 0)
    }

    @Test("System path states map without reporting a pending path as connected")
    func pathStates() {
        let connected = NetworkSnapshot(pathStatus: .satisfied) { $0 == .wifi }
        #expect(connected.status == .satisfied)
        #expect(connected.isConnected == true)
        #expect(connected.connectionType == .wifi)

        let disconnected = NetworkSnapshot(pathStatus: .unsatisfied) { $0 == .wifi }
        #expect(disconnected.status == .unsatisfied)
        #expect(disconnected.isConnected == false)
        #expect(disconnected.connectionType == .none)
        #expect(disconnected.interfaces.isEmpty)

        let pending = NetworkSnapshot(pathStatus: .requiresConnection) { $0 == .cellular }
        #expect(pending.status == .requiresConnection)
        #expect(pending.isConnected == false)
        #expect(pending.connectionType == .none)
        #expect(pending.interfaces.isEmpty)
    }

    @Test("Interface mapping covers Wi-Fi, cellular, Ethernet and other paths")
    func interfaceTypes() {
        let cases: [(NWInterface.InterfaceType, NetworkConnectionType, NetworkInterfaceType)] = [
            (.wifi, .wifi, .wifi),
            (.cellular, .cellular, .cellular),
            (.wiredEthernet, .wiredEthernet, .wiredEthernet),
            (.loopback, .other, .other),
            (.other, .other, .other)
        ]
        for (systemType, connectionType, interfaceType) in cases {
            let snapshot = NetworkSnapshot(pathStatus: .satisfied) { $0 == systemType }
            #expect(snapshot.connectionType == connectionType)
            #expect(snapshot.interfaces == [interfaceType])
        }

        let unrecognized = NetworkSnapshot(pathStatus: .satisfied) { _ in false }
        #expect(unrecognized.connectionType == .other)
    }

    @Test("Multiple active interfaces are preserved")
    func multipleInterfaces() {
        let snapshot = NetworkSnapshot(pathStatus: .satisfied) {
            $0 == .wifi || $0 == .cellular
        }
        #expect(snapshot.isConnected == true)
        #expect(snapshot.connectionType == .multiple)
        #expect(snapshot.interfaces == [.wifi, .cellular])
    }

    @Test("Starting and stopping are idempotent, and stopping clears the snapshot")
    func lifecycle() async {
        let source = MockNetworkPathMonitor()
        let monitor = NetworkMonitor(makeMonitor: { source })
        monitor.start()
        monitor.start()
        #expect(source.startCount == 1)
        #expect(monitor.isMonitoring)
        #expect(monitor.isConnected == nil)

        source.emit(.init(status: .satisfied, interfaces: [.wifi]))
        await drainMainQueue()
        #expect(monitor.isConnected == true)

        monitor.stop()
        monitor.stop()
        #expect(source.cancelCount == 1)
        #expect(!monitor.isMonitoring)
        #expect(monitor.snapshot == .unknown)
    }

    @Test("Wi-Fi, cellular and disconnected transitions arrive in order")
    func transitions() async {
        let source = MockNetworkPathMonitor()
        let monitor = NetworkMonitor(makeMonitor: { source })
        monitor.start()

        for snapshot in [
            NetworkSnapshot(status: .satisfied, interfaces: [.wifi]),
            NetworkSnapshot(status: .satisfied, interfaces: [.cellular]),
            NetworkSnapshot(status: .unsatisfied, interfaces: [])
        ] {
            source.emit(snapshot)
            await drainMainQueue()
            #expect(monitor.snapshot == snapshot)
        }

        source.emit(.init(status: .satisfied, interfaces: [.wifi]))
        source.emit(.init(status: .satisfied, interfaces: [.cellular]))
        await drainMainQueue()
        #expect(monitor.connectionType == .cellular)
    }

    @Test("Queued callbacks cannot update a stopped monitor")
    func stoppedCallbacks() async {
        let source = MockNetworkPathMonitor()
        let monitor = NetworkMonitor(makeMonitor: { source })
        monitor.start()
        source.emit(.init(status: .satisfied, interfaces: [.wifi]))
        monitor.stop()
        source.emit(.init(status: .satisfied, interfaces: [.cellular]))
        await drainMainQueue()
        #expect(monitor.snapshot == .unknown)
    }

    @Test("Restart creates a fresh source and rejects callbacks from the old session")
    func restart() async {
        let oldSource = MockNetworkPathMonitor()
        let newSource = MockNetworkPathMonitor()
        var creationCount = 0
        let monitor = NetworkMonitor(makeMonitor: {
            creationCount += 1
            return creationCount == 1 ? oldSource : newSource
        })

        monitor.start()
        oldSource.emit(.init(status: .satisfied, interfaces: [.wifi]))
        monitor.stop()
        monitor.start()
        #expect(creationCount == 2)
        #expect(newSource.startCount == 1)
        await drainMainQueue()
        #expect(monitor.snapshot == .unknown)

        newSource.emit(.init(status: .satisfied, interfaces: [.cellular]))
        await drainMainQueue()
        oldSource.emit(.init(status: .unsatisfied, interfaces: []))
        await drainMainQueue()
        #expect(monitor.connectionType == .cellular)
    }

    @Test("Computed properties participate in Observation and identical snapshots do not notify")
    func observation() async {
        let source = MockNetworkPathMonitor()
        let monitor = NetworkMonitor(makeMonitor: { source })
        monitor.start()

        await confirmation("Network type changes", expectedCount: 1) { changed in
            withObservationTracking {
                _ = monitor.connectionType
            } onChange: {
                changed()
            }
            source.emit(.init(status: .satisfied, interfaces: [.wifi]))
            await drainMainQueue()
        }

        await confirmation("Duplicate snapshots are suppressed", expectedCount: 0) { changed in
            withObservationTracking {
                _ = monitor.snapshot
            } onChange: {
                changed()
            }
            source.emit(.init(status: .satisfied, interfaces: [.wifi]))
            await drainMainQueue()
        }
    }

    @Test("Background callbacks safely publish on the main actor")
    func backgroundCallback() async {
        let source = MockNetworkPathMonitor()
        let monitor = NetworkMonitor(makeMonitor: { source })
        monitor.start()
        let handler = source.handler
        await Task.detached {
            handler?(.init(status: .satisfied, interfaces: [.cellular]))
        }.value
        await drainMainQueue()
        #expect(monitor.connectionType == .cellular)
    }

    @Test("Releasing the monitor cancels the source without a retain cycle")
    func cleanup() async {
        let source = MockNetworkPathMonitor()
        var monitor: NetworkMonitor? = NetworkMonitor(makeMonitor: { source })
        let isReleased = { [weak monitor] in monitor == nil }
        monitor?.start()
        source.emit(.init(status: .satisfied, interfaces: [.wifi]))
        monitor = nil
        await drainMainQueue()
        #expect(isReleased())
        #expect(source.cancelCount == 1)
    }

    @Test("Public initializer supports system monitoring and restart")
    func systemMonitorLifecycle() {
        let monitor = NetworkMonitor()
        monitor.start()
        monitor.stop()
        monitor.start()
        #expect(monitor.isMonitoring)
        monitor.stop()
        #expect(monitor.snapshot == .unknown)
    }

    private func drainMainQueue() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                continuation.resume()
            }
        }
    }
}

@MainActor
private final class MockNetworkPathMonitor: NetworkPathMonitoring {
    private(set) var startCount = 0
    private(set) var cancelCount = 0
    private(set) var handler: (@Sendable (NetworkSnapshot) -> Void)?

    func start(handler: @escaping @Sendable (NetworkSnapshot) -> Void) {
        startCount += 1
        self.handler = handler
    }

    func cancel() {
        cancelCount += 1
        // Keep the handler to simulate callbacks already in flight at cancellation.
    }

    func emit(_ snapshot: NetworkSnapshot) {
        handler?(snapshot)
    }
}
#endif
