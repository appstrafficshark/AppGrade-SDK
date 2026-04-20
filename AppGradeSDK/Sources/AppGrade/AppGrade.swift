
import Foundation
import UIKit

public class AppGrade {

    public static let shared = AppGrade()
    
    private var configuration: SDKConfiguration?
    private var core: AppGradeCore?
    
    private init() {}
    
    // MARK: - Initialization
    public func configure(apiKey: String, enableLogs: Bool = false) {
        let config = SDKConfiguration(apiKey: apiKey, enableLogs: enableLogs)
        self.configuration = config
        self.core = AppGradeCore(configuration: config)
        core?.start()
    }
    
    // MARK: - Attribution
    public func updateAttributionInfo() {
        core?.updateAttributionInfo()
    }
    
    // MARK: - Subscriptions
    public func sendSubscriptionInfo(info: AppGradeSubscriptionInfo) {
        core?.sendSubscriptionInfo(info: info)
    }
    
    // MARK: - In-App Purchases
    public func sendNonRenewingPurchaseInfo(info: AppGradeNonRenewingPurchaseInfo) {
        core?.sendNonRenewingPurchaseInfo(info: info)
    }
    
}
