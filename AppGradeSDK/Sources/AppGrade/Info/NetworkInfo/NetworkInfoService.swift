
import Foundation
import Network
import CoreTelephony

// MARK: - NetworkInfoServiceProtocol
protocol NetworkInfoServiceProtocol {
    func collect() async -> NetworkInfoModel
}

// MARK: - NetworkInfoService
final class NetworkInfoService: NetworkInfoServiceProtocol {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectionMonitor")
    
    private(set) var connectionChangesCount = 0
    private var currentPath: NWPath?
    
    init() {
        startMonitoring()
    }

    func collect() async -> NetworkInfoModel {
        return NetworkInfoModel(
            connectionType: getConnectionType(),
            cellularTechnology: getCellularTechnology(),
            carrierName: getCarrierName(),
            isVpnActive: isVpnActive(),
            isProxyConfigured: isProxyEnabled(),
            connectionChangesCount: connectionChangesCount)
    }
    
}

// MARK: - Private Function
private extension NetworkInfoService {
    
    func getConnectionType() -> String {
        guard let path = currentPath else { return "unknown" }
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
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.serviceCurrentRadioAccessTechnology?.values.first ?? "unknown"
    }
    
    func getCarrierName() -> String {
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
            if self.currentPath != nil {
                self.connectionChangesCount += 1
            }
            self.currentPath = path
        }
        monitor.start(queue: queue)
    }
    
}
