
import Foundation

final class AppGradeCore {
    
    private let config: SDKConfiguration
    
    private let deviceService: DeviceInfoServiceProtocol
    private let networkService: NetworkInfoServiceProtocol
    private let sessionService: SessionInfoServiceProtocol
    private let attributionService: AttributionInfoServiceProtocol
    
    private let requestService: RequestServiceProtocol
    private let logService: LogServiceProtocol
    private let storageService: StorageServiceProtocol
    private let sessionId: String
    
    init(configuration: SDKConfiguration) {
       
        self.config = configuration
        self.storageService = StorageService()
        self.sessionId = UUID().uuidString + "_\(storageService.coreInfo.userId)"
        self.logService = LogService(enableLogs: configuration.enableLogs)

        self.requestService = RequestService(apiKey: configuration.apiKey, sessionId: self.sessionId, coreInfo: self.storageService.coreInfo)
        
        self.deviceService = DeviceInfoService()
        self.networkService = NetworkInfoService()
        self.sessionService = SessionInfoService()
        self.attributionService = AttributionInfoService()
    }
    
    func start() {
        logService.log("SDK started")
        Task {
            await collectAndSend()
        }
    }
    
    private func collectAndSend() async {
        // - Device Info
        let deviceInfo = await deviceService.collect()
        logService.log("✅ Device Info collected")
        logService.log("Device Info: \(deviceInfo)")
    
        // - Network Info
        let networkInfo = await networkService.collect()
        logService.log("✅ Network Info collected")
        logService.log("Network Info: \(networkInfo)")
        
        // - Session Info
        let sessionInfo = await sessionService.collect(data: storageService.coreInfo)
        logService.log("✅ Session Info collected")
        logService.log("Session Info: \(networkInfo)")

        do {
            try await requestService.send(deviceInfo)
            logService.log("Device info sent ✅")
        } catch {
            logService.log("Send failed ❌ \(error)")
        }
    }
    
}
