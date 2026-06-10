
import Foundation

// MARK: - AppGradeNonRenewingPurchaseInfo
public struct AppGradeNonRenewingPurchaseInfo: Codable {
    let productId: String
    let canceledAt: Date?
    let purchasedAt: Date
    let transactionId: String?
    let isLocal: Bool
    let isSandbox: Bool
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case canceledAt = "canceled_at"
        case purchasedAt = "purchased_at"
        case transactionId = "transaction_id"
        case isLocal = "is_local"
        case isSandbox = "is_sandbox"
    }
    
    init(productId: String, canceledAt: Date?, purchasedAt: Date, transactionId: String?, isLocal: Bool, isSandbox: Bool) {
        self.productId = productId
        self.canceledAt = canceledAt
        self.purchasedAt = purchasedAt
        self.transactionId = transactionId
        self.isLocal = isLocal
        self.isSandbox = isSandbox
    }
    
}
