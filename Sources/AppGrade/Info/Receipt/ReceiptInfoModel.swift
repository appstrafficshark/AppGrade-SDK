
import Foundation

// MARK: - ReceiptSubscriptionInfoModel
struct ReceiptSubscriptionInfoModel: Codable {
    let receipt: String
    let info: AppGradeSubscriptionInfo
}

// MARK: - ReceiptNonRenewingPurchaseInfoModel
struct ReceiptNonRenewingPurchaseInfoModel: Codable {
    let receipt: String
    let info: AppGradeNonRenewingPurchaseInfo
}
