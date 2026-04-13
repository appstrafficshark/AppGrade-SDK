
import Foundation

final class AppGradeCore {
    
    private let config: SDKConfiguration
    private let deviceService: DeviceInfoServiceProtocol
    private let requestService: RequestServiceProtocol
    private let logService: LogServiceProtocol
    private let storageService: StorageServiceProtocol
    private let sessionId: String
    
    init(configuration: SDKConfiguration) {
       
        self.config = configuration
        self.storageService = StorageService()
        self.sessionId = UUID().uuidString + "_\(storageService.coreInfo.userId)"
        self.requestService = RequestService(apiKey: configuration.apiKey)
        self.logService = LogService(enableLogs: configuration.enableLogs)
       
        self.deviceService = DeviceInfoService()
    }
    
    func start() {
        logService.log("SDK started")
        Task {
            await collectAndSend()
        }
    }
    
    private func collectAndSend() async {
        let deviceInfo = await deviceService.collect()
        
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
