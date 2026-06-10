
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
    public func sendSubscriptionInfo(canceledAt: Date?, expiresDate: Date, originalTransactionId: String?, productId: String, startedAt: Date, status: String, isAutorenewEnabled: Bool, isInRetryBilling: Bool, isIntroductoryActivated: Bool, isLocal: Bool, isSandbox: Bool) {
        let info = AppGradeSubscriptionInfo.init(canceledAt: canceledAt, expiresDate: expiresDate, originalTransactionId: originalTransactionId, productId: productId, startedAt: startedAt, status: status, isAutorenewEnabled: isAutorenewEnabled, isInRetryBilling: isInRetryBilling, isIntroductoryActivated: isIntroductoryActivated, isLocal: isLocal, isSandbox: isSandbox)
        core?.sendSubscriptionInfo(info: info)
    }
    
    // MARK: - In-App Purchases
    public func sendNonRenewingPurchaseInfo(productId: String, canceledAt: Date?, purchasedAt: Date, transactionId: String?, isLocal: Bool, isSandbox: Bool) {
        let info = AppGradeNonRenewingPurchaseInfo(productId: productId, canceledAt: canceledAt, purchasedAt: purchasedAt, transactionId: transactionId, isLocal: isLocal, isSandbox: isSandbox)
        core?.sendNonRenewingPurchaseInfo(info: info)
    }
    
}
