
import Foundation

final class AppGradeCore {
    
    private let config: SDKConfiguration
    private let deviceService: DeviceInfoServiceProtocol
    private let requestService: RequestServiceProtocol
    private let logService: LogServiceProtocol
    private let storageService: StorageServiceProtocol
    
    init(configuration: SDKConfiguration) {
        self.config = configuration
        self.requestService = RequestService(apiKey: configuration.apiKey)
        self.logService = LogService(enableLogs: configuration.enableLogs)
        self.storageService = StorageService()
        self.deviceService = DeviceInfoService()
    }
    
    func start() {
        logService.log("SDK started")
        Task {
            await collectAndSend()
        }
    }
    
    private func collectAndSend() async {
        let deviceInfo = deviceService.collect()
        
        logService.log("Device info collected")
        
        logService.log("Device info: \(deviceInfo)")
        
        do {
            try await requestService.send(deviceInfo)
            logService.log("Device info sent ✅")
        } catch {
            logService.log("Send failed ❌ \(error)")
        }
    }
    
}
