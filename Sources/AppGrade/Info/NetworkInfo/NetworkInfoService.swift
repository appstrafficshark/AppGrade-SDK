
import Foundation
import Network
import CoreTelephony
import UIKit

// MARK: - NetworkInfoServiceProtocol
protocol NetworkInfoServiceProtocol {
    func collect() async -> NetworkInfoModel
}

// MARK: - NetworkInfoService
final class NetworkInfoService: NetworkInfoServiceProtocol {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectionMonitor")

    private var _connectionChangesCount = 0
    private var _currentPath: NWPath?
    private var hasPath = false
    private var pathWaiters: [CheckedContinuation<Void, Never>] = []

    /// Safety cap so `collect()` never blocks forever if the monitor stays silent.
    private let firstPathTimeout: TimeInterval = 2.0

    init() {
        startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    func collect() async -> NetworkInfoModel {
        await waitForFirstPath()

        let (path, changes) = queue.sync { (_currentPath, _connectionChangesCount) }

        return NetworkInfoModel(
            connectionType: connectionType(for: path),
            cellularTechnology: getCellularTechnology(),
            carrierName: getCarrierName(),
            isVpnActive: isVpnActive(),
            isProxyConfigured: isProxyEnabled(),
            connectionChangesCount: changes)
    }

}

// MARK: - Private Function
private extension NetworkInfoService {

    func connectionType(for path: NWPath?) -> String {
        guard let path else { return "unknown" }
        if path.usesInterfaceType(.wifi) {
            return "wifi"
        } else if path.usesInterfaceType(.cellular) {
            return "cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            return "ethernet"
        } else {
            return "unknown"
        }
    }

    func isVpnActive() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = settings["__SCOPED__"] as? [String: Any] else {
            return false
        }
        return scoped.keys.contains { key in
            key.contains("tap") || key.contains("tun") || key.contains("ppp")
        }
    }

    func getCellularTechnology() -> String {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return "unsupported"
        }
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.serviceCurrentRadioAccessTechnology?.values.first ?? "unknown"
    }

    func getCarrierName() -> String {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return "unsupported"
        }
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.serviceSubscriberCellularProviders?.values.first?.carrierName ?? "unknown"
    }

    func isProxyEnabled() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return false
        }

        let httpProxy = settings["HTTPEnable"] as? Int ?? 0
        let httpsProxy = settings["HTTPSEnable"] as? Int ?? 0

        return httpProxy == 1 || httpsProxy == 1
    }

}

// MARK: - Monitoring
private extension NetworkInfoService {

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if self._currentPath != nil {
                self._connectionChangesCount += 1
            }
            self._currentPath = path

            if !self.hasPath {
                self.hasPath = true
                self.resumeWaiters()
            }
        }
        monitor.start(queue: queue)
    }

    func waitForFirstPath() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            queue.async {
                if self.hasPath {
                    continuation.resume()
                    return
                }
                self.pathWaiters.append(continuation)
                self.queue.asyncAfter(deadline: .now() + self.firstPathTimeout) {
                    self.resumeWaiters()
                }
            }
        }
    }

    func resumeWaiters() {
        guard !pathWaiters.isEmpty else { return }
        let waiters = pathWaiters
        pathWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }

}
