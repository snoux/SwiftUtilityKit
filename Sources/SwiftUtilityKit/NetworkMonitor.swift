#if canImport(Network) && canImport(Observation)
import Dispatch
import Network
import Observation

/// 系统网络路径状态，不表示某个互联网服务一定可以访问。
public enum NetworkStatus: Equatable, Sendable {
    case unknown
    case satisfied
    case unsatisfied
    case requiresConnection
}

/// 当前可用网络路径使用的接口类型。
public enum NetworkInterfaceType: Hashable, Sendable {
    case wifi
    case cellular
    case wiredEthernet
    case other
}

/// 当前网络类型；多种接口同时可用时为 `multiple`。
public enum NetworkConnectionType: Equatable, Sendable {
    case unknown
    case none
    case wifi
    case cellular
    case wiredEthernet
    case other
    case multiple
}

/// 一次完整的网络状态快照。
public struct NetworkSnapshot: Equatable, Sendable {
    public let status: NetworkStatus
    public let interfaces: Set<NetworkInterfaceType>

    /// 是否存在可用网络路径；首次检测前或停止监听后为 `nil`。
    ///
    /// `true` 不保证互联网或业务服务器可访问，仍应以实际请求结果为准。
    public var isConnected: Bool? {
        switch status {
        case .unknown: nil
        case .satisfied: true
        case .unsatisfied, .requiresConnection: false
        }
    }

    public var connectionType: NetworkConnectionType {
        switch status {
        case .unknown:
            return .unknown
        case .unsatisfied, .requiresConnection:
            return .none
        case .satisfied:
            guard interfaces.count <= 1 else { return .multiple }
            switch interfaces.first {
            case .wifi: return .wifi
            case .cellular: return .cellular
            case .wiredEthernet: return .wiredEthernet
            case .other, nil: return .other
            }
        }
    }

    static let unknown = NetworkSnapshot(status: .unknown, interfaces: [])

    init(status: NetworkStatus, interfaces: Set<NetworkInterfaceType>) {
        self.status = status
        self.interfaces = status == .satisfied ? interfaces : []
    }

    init(pathStatus: NWPath.Status, usesInterfaceType: (NWInterface.InterfaceType) -> Bool) {
        let status: NetworkStatus
        switch pathStatus {
        case .satisfied: status = .satisfied
        case .unsatisfied: status = .unsatisfied
        case .requiresConnection: status = .requiresConnection
        @unknown default: status = .unknown
        }

        let mappings: [(NWInterface.InterfaceType, NetworkInterfaceType)] = [
            (.wifi, .wifi),
            (.cellular, .cellular),
            (.wiredEthernet, .wiredEthernet),
            (.loopback, .other),
            (.other, .other)
        ]
        let interfaces = Set(mappings.compactMap { systemType, interfaceType in
            usesInterfaceType(systemType) ? interfaceType : nil
        })
        self.init(status: status, interfaces: interfaces)
    }
}

/// 基于系统网络路径的状态监听，不依赖 UIKit 或 Combine。
///
/// SwiftUI 中使用 `@State` 持有实例，调用 `start()` 后读取属性即可自动刷新。
/// 全 App 共享时应在根部持有，通过 `.environment(monitor)` 注入。
@MainActor
@Observable
public final class NetworkMonitor {
    public private(set) var snapshot: NetworkSnapshot = .unknown
    public private(set) var isMonitoring = false

    public var status: NetworkStatus { snapshot.status }
    public var isConnected: Bool? { snapshot.isConnected }
    public var connectionType: NetworkConnectionType { snapshot.connectionType }
    public var interfaces: Set<NetworkInterfaceType> { snapshot.interfaces }

    @ObservationIgnored private var pathMonitor: (any NetworkPathMonitoring)?
    @ObservationIgnored private var generation: UInt64 = 0
    @ObservationIgnored private let makeMonitor: () -> any NetworkPathMonitoring

    /// 创建实例；不会自动开始监听。
    public convenience init() {
        self.init(makeMonitor: { SystemNetworkPathMonitor() })
    }

    init(makeMonitor: @escaping () -> any NetworkPathMonitoring) {
        self.makeMonitor = makeMonitor
    }

    /// 开始监听，重复调用不会创建多个底层监视器。
    public func start() {
        guard !isMonitoring else { return }
        generation &+= 1
        let currentGeneration = generation
        let monitor = makeMonitor()
        pathMonitor = monitor
        isMonitoring = true

        monitor.start { [weak self] snapshot in
            // Serial path callbacks enter the main queue in the same order.
            DispatchQueue.main.async { [weak self] in
                guard let self,
                      self.isMonitoring,
                      self.generation == currentGeneration,
                      self.snapshot != snapshot else { return }
                self.snapshot = snapshot
            }
        }
    }

    /// 停止监听并清除快照；之后可再次调用 `start()`。
    public func stop() {
        guard isMonitoring else { return }
        generation &+= 1
        isMonitoring = false
        pathMonitor?.cancel()
        pathMonitor = nil
        snapshot = .unknown
    }

    isolated deinit {
        pathMonitor?.cancel()
    }
}

@MainActor
protocol NetworkPathMonitoring: AnyObject {
    func start(handler: @escaping @Sendable (NetworkSnapshot) -> Void)
    func cancel()
}

@MainActor
private final class SystemNetworkPathMonitor: NetworkPathMonitoring {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "SwiftUtilityKit.NetworkMonitor")

    func start(handler: @escaping @Sendable (NetworkSnapshot) -> Void) {
        monitor.pathUpdateHandler = { path in
            handler(NetworkSnapshot(pathStatus: path.status, usesInterfaceType: path.usesInterfaceType))
        }
        monitor.start(queue: queue)
    }

    func cancel() {
        monitor.pathUpdateHandler = nil
        monitor.cancel()
    }
}
#endif
