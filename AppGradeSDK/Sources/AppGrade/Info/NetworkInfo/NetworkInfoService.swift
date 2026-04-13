
import Foundation

//NetworkInfoService

import Network
import CoreTelephony

final class ConnectionService {
    
    static let shared = ConnectionService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "ConnectionMonitor")
    
    private(set) var connectionChangesCount = 0
    private var currentPath: NWPath?
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            if self.currentPath != nil {
                self.connectionChangesCount += 1
            }
            self.currentPath = path
        }
        
        monitor.start(queue: queue)
    }
    
    // MARK: - Public
    
    func getConnectionInfo() -> NetworkInfoModel {
        return NetworkInfoModel(
            connectionType: getConnectionType(),
            cellularTechnology: getCellularTechnology(),
            carrierName: getCarrierName(),
            isVpnActive: isVpnActive(),
            isProxyConfigured: isProxyEnabled(),
            connectionChangesCount: connectionChangesCount
        )
    }
    
    private func getConnectionType() -> String {
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
    
    private func getCellularTechnology() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        return networkInfo.serviceCurrentRadioAccessTechnology?.values.first
    }
    
    
    private func getCarrierName() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
//        return networkInfo.serviceSubscriberCellularProviders?.values.first?.carrierName
        return networkInfo.subscriberCellularProvider?.carrierName
    }
    
    private func isVpnActive() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scoped = settings["__SCOPED__"] as? [String: Any] else {
            return false
        }
        
        return scoped.keys.contains { key in
            key.contains("tap") || key.contains("tun") || key.contains("ppp")
        }
    }
    
    private func isProxyEnabled() -> Bool {
        guard let settings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return false
        }
        
        let httpProxy = settings["HTTPEnable"] as? Int ?? 0
        let httpsProxy = settings["HTTPSEnable"] as? Int ?? 0
        
        return httpProxy == 1 || httpsProxy == 1
    }
}
