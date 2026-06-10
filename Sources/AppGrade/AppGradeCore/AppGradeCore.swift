
import Foundation

final class AppGradeCore {
    
    // - Configuration
    private let config: SDKConfiguration
    
    // - Service
    private let deviceService: DeviceInfoServiceProtocol
    private let networkService: NetworkInfoServiceProtocol
    private let sessionService: SessionInfoServiceProtocol
    private let attributionService: AttributionInfoServiceProtocol
    private let appExitInfoService: AppExitInfoServiceProtocol
    private let receiptInfoService: ReceiptInfoServiceProtocol
    
    // - Utilities
    private let observer = AppStateObserver()
    private let requestService: RequestServiceProtocol
    private let logService: LogServiceProtocol
    private let storageService: StorageServiceProtocol
    private let sessionId: String
    
    // - Id
    private let attributionId: String
    private let leftAppId: String
    
    init(configuration: SDKConfiguration) {
        self.config = configuration
        self.storageService = StorageService()
        self.sessionId = UUID().uuidString
        self.logService = LogService(enableLogs: configuration.enableLogs)

        self.requestService = RequestService(apiKey: configuration.apiKey, sessionId: self.sessionId, coreInfo: self.storageService.coreInfo, logService: self.logService)
        
        self.deviceService = DeviceInfoService()
        self.networkService = NetworkInfoService()
        self.sessionService = SessionInfoService()
        self.attributionService = AttributionInfoService()
        self.appExitInfoService = AppExitInfoService()
        self.receiptInfoService = ReceiptInfoService(logService: self.logService)
        
        self.attributionId = UUID().uuidString
        self.leftAppId = UUID().uuidString
        
        self.observer.onStateChanges = { [weak self] state in
            self?.handleAppState(state)
        }
    }
    
    func start() {
        logService.log("✅ SDK started", debugLog: false)
        Task {
            await collectAndSend()
            logService.log("✅ Info collected", debugLog: false)
        }
    }
    
    func updateAttributionInfo() {
        logService.log("✅ Attribution update started", debugLog: true)
        Task {
            // - Attribution Info
            let attributionInfo = await attributionService.collect()
            logService.log("✅ Attribution Info collected: \(attributionInfo)", debugLog: true)
            do {
                try await requestService.track(id: attributionId, eventType: .afterIdfa, model: attributionInfo)
                logService.log("✅ Attribution updated", debugLog: true)
            } catch {
                logService.log("Track failed ❌ \(error)", debugLog: false)
            }
        }
    }
        
    func sendSubscriptionInfo(info: AppGradeSubscriptionInfo) {
        Task {
            let info = await receiptInfoService.collect(subscription: info)
            logService.log("✅ SubscriptionInfo: \(info)", debugLog: true)
            do {
                try await requestService.track(id: nil, eventType: .userSubscribed, model: info)
                logService.log("✅ SubscriptionInfo updated", debugLog: true)
            } catch {
                logService.log("Track failed ❌ \(error)", debugLog: false)
            }
        }
    }
    
    func sendNonRenewingPurchaseInfo(info: AppGradeNonRenewingPurchaseInfo) {
        Task {
            let info = await receiptInfoService.collect(nonRenewingPurchase: info)
            logService.log("✅ NonRenewingPurchase: \(info)", debugLog: true)
            do {
                try await requestService.track(id: nil, eventType: .userPurchase, model: info)
                logService.log("✅ NonRenewingPurchase updated", debugLog: true)
            } catch {
                logService.log("Track failed ❌ \(error)", debugLog: false)
            }
        }
    }
    
}

// MARK: - Private Functions
private extension AppGradeCore {
    
    func collectAndSend() async {
        // - Device Info
        let deviceInfo = await deviceService.collect()
        logService.log("✅ Device Info collected: \(deviceInfo)", debugLog: true)
    
        // - Network Info
        let networkInfo = await networkService.collect()
        logService.log("✅ Network Info collected: \(networkInfo)", debugLog: true)
        
        // - Session Info
        let sessionInfo = await sessionService.collect(data: storageService.coreInfo)
        logService.log("✅ Session Info collected: \(sessionInfo)", debugLog: true)
        
        // - Attribution Info
        let attributionInfo = await attributionService.collect()
        logService.log("✅ Attribution Info collected: \(attributionInfo)", debugLog: true)

        do {
            try await requestService.track(id: nil, eventType: .launchApp, model: deviceInfo)
            try await requestService.track(id: nil, eventType: .launchApp, model: networkInfo)
            try await requestService.track(id: nil, eventType: .launchApp, model: sessionInfo)
            try await requestService.track(id: attributionId, eventType: .launchApp, model: attributionInfo)
        } catch {
            logService.log("Track failed ❌ \(error)", debugLog: false)
        }
    }
    
    func handleAppState(_ event: AppStateType) {
        requestService.updateSessionTime(event: event)
        switch event {
        case .background:
            logService.log("user left the app", debugLog: false)
            Task {
                // - App Exit Info
                let sessionDuration = self.sessionService.endSession()
                let networkInfo = await networkService.collect()
                let appExitInfo = await appExitInfoService.collect(networkInfo: networkInfo)
                logService.log("✅ App Exit Info collected: \(appExitInfo)", debugLog: true)
                do {
                    try await requestService.track(id: leftAppId, eventType: .leftApp, model: appExitInfo)
                } catch {
                    logService.log("Track failed ❌ \(error)", debugLog: false)
                }
            }
        case .active:
            logService.log("user returned to the app", debugLog: false)
            self.sessionService.startSession()
        }
    }
    
}
