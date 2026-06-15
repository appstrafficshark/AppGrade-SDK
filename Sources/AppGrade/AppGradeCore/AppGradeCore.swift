
import Foundation

final class AppGradeCore {

    // - Configuration
    private let config: SDKConfiguration

    // - Service
    private let deviceService: DeviceInfoServiceProtocol
    private let networkService: NetworkInfoServiceProtocol
    private let sessionService: SessionInfoServiceProtocol
    private let attributionService: AttributionInfoServiceProtocol
    private let receiptInfoService: ReceiptInfoServiceProtocol

    // - Utilities
    private let observer = AppStateObserver()
    private let requestService: RequestServiceProtocol
    private let logService: LogServiceProtocol
    private let storageService: StorageServiceProtocol
    private let sessionId: String

    // - Id
    private let launchAppId: String
    private let userSubscribedId: String
    private let userPurchaseId: String
    private let leftAppId: String

    private var deviceInfo: SendingDeviceInfoModel?
    private var networkInfo: NetworkInfoModel?
    private var sessionInfo: SessionInfoModel?
    private var attributionInfo: AttributionInfo?
    private var subscriptionInfo: ReceiptSubscriptionInfoModel?
    private var purchaseInfo: ReceiptNonRenewingPurchaseInfoModel?

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
        self.receiptInfoService = ReceiptInfoService(logService: self.logService)

        self.launchAppId = UUID().uuidString
        self.userSubscribedId = UUID().uuidString
        self.userPurchaseId = UUID().uuidString
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
            let attribution = await attributionService.collect()
            attributionInfo = attribution
            logService.log("✅ Attribution Info collected: \(attribution)", debugLog: true)
            await send(id: launchAppId, eventType: .afterIdfa)
            logService.log("✅ Attribution updated", debugLog: true)
        }
    }

    func sendSubscriptionInfo(info: AppGradeSubscriptionInfo) {
        Task {
            let receipt = await receiptInfoService.collect(subscription: info)
            subscriptionInfo = receipt
            logService.log("✅ SubscriptionInfo: \(receipt)", debugLog: true)
            await send(id: userSubscribedId, eventType: .userSubscribed)
            logService.log("✅ SubscriptionInfo updated", debugLog: true)
        }
    }
    
    func sendNonRenewingPurchaseInfo(info: AppGradeNonRenewingPurchaseInfo) {
        Task {
            let receipt = await receiptInfoService.collect(nonRenewingPurchase: info)
            purchaseInfo = receipt
            logService.log("✅ NonRenewingPurchase: \(receipt)", debugLog: true)
            await send(id: userPurchaseId, eventType: .userPurchase)
            logService.log("✅ NonRenewingPurchase updated", debugLog: true)
        }
    }

}

// MARK: - Private Functions
private extension AppGradeCore {

    func collectAndSend() async {
        // - Device Info
        let device = await deviceService.collect()
        deviceInfo = device
        logService.log("✅ Device Info collected: \(device)", debugLog: true)

        // - Network Info
        let network = await networkService.collect()
        networkInfo = network
        logService.log("✅ Network Info collected: \(network)", debugLog: true)

        // - Session Info
        let session = await sessionService.collect(data: storageService.coreInfo)
        sessionInfo = session
        logService.log("✅ Session Info collected: \(session)", debugLog: true)

        // - Attribution Info
        let attribution = await attributionService.collect()
        attributionInfo = attribution
        logService.log("✅ Attribution Info collected: \(attribution)", debugLog: true)

        await send(id: launchAppId, eventType: .launchApp)
    }

    func handleAppState(_ event: AppStateType) {
        requestService.updateSessionTime(event: event)
        switch event {
        case .background:
            logService.log("user left the app", debugLog: false)
            Task {
                _ = self.sessionService.endSession()
                let network = await self.networkService.collect()
                self.networkInfo = network
                logService.log("✅ App Exit Info collected: \(network)", debugLog: true)
                await self.send(id: self.leftAppId, eventType: .leftApp)
            }
        case .active:
            logService.log("user returned to the app", debugLog: false)
            self.sessionService.startSession()
        }
    }

    func makePayload() async -> EventInfoModel {
        let device: SendingDeviceInfoModel
        if let deviceInfo { device = deviceInfo } else { device = await deviceService.collect() }
        deviceInfo = device

        let network: NetworkInfoModel
        if let networkInfo { network = networkInfo } else { network = await networkService.collect() }
        networkInfo = network

        let session: SessionInfoModel
        if let sessionInfo { session = sessionInfo } else { session = await sessionService.collect(data: storageService.coreInfo) }
        sessionInfo = session

        let attribution: AttributionInfo
        if let attributionInfo { attribution = attributionInfo } else { attribution = await attributionService.collect() }
        attributionInfo = attribution

        let sessionTime = Int(requestService.currentSessionTime())
        return EventInfoModel(device: device,
                              network: network,
                              session: session,
                              attribution: attribution,
                              sessionTime: max(0, sessionTime),
                              subscription: subscriptionInfo,
                              nonRenewingPurchase: purchaseInfo)
    }

    /// Sends one event carrying the full snapshot payload.
    func send(id: String, eventType: EventType) async {
        let payload = await makePayload()
        do {
            try await requestService.track(id: id, eventType: eventType, model: payload)
        } catch {
            logService.log("Track failed ❌ \(error)", debugLog: false)
        }
    }

}
