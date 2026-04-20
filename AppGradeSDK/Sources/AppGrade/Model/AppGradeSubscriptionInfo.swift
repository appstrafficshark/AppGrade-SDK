
import Foundation

// MARK: - AppGradeSubscriptionInfo
public struct AppGradeSubscriptionInfo: Codable {
    let canceledAt: Date?
    let expiresDate: Date
    let originalTransactionId: String?
    let productId: String
    let startedAt: Date
    let status: String
    let isAutorenewEnabled: Bool
    let isInRetryBilling: Bool
    let isIntroductoryActivated: Bool
    let isLocal: Bool
    let isSandbox: Bool
    
    enum CodingKeys: String, CodingKey {
        case canceledAt = "canceled_at"
        case expiresDate = "expires_date"
        case originalTransactionId = "original_transaction_id"
        case productId = "product_id"
        case startedAt = "started_at"
        case status = "status"
        case isAutorenewEnabled = "is_autorenew_enabled"
        case isInRetryBilling = "is_in_retry_billing"
        case isIntroductoryActivated = "is_introductory_activated"
        case isLocal = "is_local"
        case isSandbox = "is_sandbox"
    }
    
}
