
import Foundation

final class AppGradeCore {
    
    private let config: SDKConfiguration
    
    private let deviceService: DeviceInfoServiceProtocol
    private let networkService: NetworkInfoServiceProtocol
    private let sessionService: SessionInfoServiceProtocol
    private let attributionService: AttributionInfoServiceProtocol
    private let appExitInfoService: AppExitInfoServiceProtocol
    
    private let observer = AppStateObserver()
    private let requestService: RequestServiceProtocol
    private let logService: LogServiceProtocol
    private let storageService: StorageServiceProtocol
    private let sessionId: String
    
    init(configuration: SDKConfiguration) {
        self.config = configuration
        self.storageService = StorageService()
        self.sessionId = UUID().uuidString + "_\(storageService.coreInfo.userId)"
        self.logService = LogService(enableLogs: configuration.enableLogs)

        self.requestService = RequestService(apiKey: configuration.apiKey, sessionId: self.sessionId, coreInfo: self.storageService.coreInfo, logService: self.logService)
        
        self.deviceService = DeviceInfoService()
        self.networkService = NetworkInfoService()
        self.sessionService = SessionInfoService()
        self.attributionService = AttributionInfoService()
        self.appExitInfoService = AppExitInfoService()
        
        self.observer.onStateChanges = { [weak self] state in
            self?.handleAppState(state)
        }
    }
    
    func start() {
        logService.log("✅ SDK started")
        Task {
            await collectAndSend()
            logService.log("✅ Info collected")
        }
    }
    
    func updateAttributionInfo() {
        logService.log("✅ Attribution update started")
        Task {
            // - Attribution Info
            let attributionInfo = await attributionService.collect()
            logService.log("✅ Attribution Info collected: \(attributionInfo)")
            do {
                try await requestService.track(updateInfo: true, model: attributionInfo)
                logService.log("✅ Attribution updated")
            } catch {
                logService.log("Track failed ❌ \(error)")
            }
        }
    }
        
}

// MARK: - Private Functions
private extension AppGradeCore {
    
    func collectAndSend() async {
        // - Device Info
        let deviceInfo = await deviceService.collect()
        logService.log("✅ Device Info collected: \(deviceInfo)")
    
        // - Network Info
        let networkInfo = await networkService.collect()
        logService.log("✅ Network Info collected: \(networkInfo)")
        
        // - Session Info
        let sessionInfo = await sessionService.collect(data: storageService.coreInfo)
        logService.log("✅ Session Info collected: \(networkInfo)")
        
        // - Attribution Info
        let attributionInfo = await attributionService.collect()
        logService.log("✅ Attribution Info collected: \(attributionInfo)")

        do {
            try await requestService.track(updateInfo: false, model: deviceInfo)
            try await requestService.track(updateInfo: false, model: networkInfo)
            try await requestService.track(updateInfo: false, model: sessionInfo)
            try await requestService.track(updateInfo: false, model: attributionInfo)
        } catch {
            logService.log("Track failed ❌ \(error)")
        }
    }
    
    func handleAppState(_ event: AppStateType) {
        switch event {
        case .background:
            logService.log("user left the app")
            Task {
                // - App Exit Info
                let sessionDuration = self.sessionService.endSession()
                let networkInfo = await networkService.collect()
                let appExitInfo = await appExitInfoService.collect(sessionDuration: sessionDuration, networkInfo: networkInfo)
                logService.log("✅ App Exit Info collected: \(appExitInfo)")
                do {
                    try await requestService.track(updateInfo: true, model: appExitInfo)
                } catch {
                    logService.log("Track failed ❌ \(error)")
                }
            }
        case .active:
            logService.log("user returned to the app")
            self.sessionService.startSession()
        }
    }
    
}
