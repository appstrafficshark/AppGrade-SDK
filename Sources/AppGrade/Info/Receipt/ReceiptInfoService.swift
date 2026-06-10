
import StoreKit
import Foundation

// MARK: - ReceiptInfoServiceProtocol
protocol ReceiptInfoServiceProtocol {
    func collect(subscription: AppGradeSubscriptionInfo) async -> ReceiptSubscriptionInfoModel
    func collect(nonRenewingPurchase: AppGradeNonRenewingPurchaseInfo) async -> ReceiptNonRenewingPurchaseInfoModel
}

// MARK: - ReceiptInfoService
final class ReceiptInfoService: NSObject {
                    
    private var continuation: CheckedContinuation<Void, Error>?
    private var logService: LogServiceProtocol
    
    init(logService: LogServiceProtocol) {
        self.logService = logService
    }
    
}

// MARK: - ReceiptInfoServiceProtocol
extension ReceiptInfoService: ReceiptInfoServiceProtocol {
    
    func collect(subscription: AppGradeSubscriptionInfo) async -> ReceiptSubscriptionInfoModel {
        let receipt = await fetchReceipt()
        return .init(receipt: receipt, info: subscription)
    }
        
    func collect(nonRenewingPurchase: AppGradeNonRenewingPurchaseInfo) async -> ReceiptNonRenewingPurchaseInfoModel {
        let receipt = await fetchReceipt()
        return .init(receipt: receipt, info: nonRenewingPurchase)
    }
    
}

// MARK: - Helpers
private extension ReceiptInfoService {
    
    func fetchReceipt() async -> String {
        if let receipt = getReceiptBase64() {
            return receipt
        }
        try await refreshReceipt()
        guard let receipt = getReceiptBase64() else {
            return "unknown"
        }
        return receipt
    }
    
    func getReceiptBase64() -> String? {
        guard let url = Bundle.main.appStoreReceiptURL,
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return data.base64EncodedString()
    }
    
    func refreshReceipt() async {
        try? await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
        }
    }
    
}

// MARK: - SKRequestDelegate
extension ReceiptInfoService: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        continuation?.resume()
        continuation = nil
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        logService.log("❌ SKReceiptRefreshRequest error: \(error.localizedDescription)", debugLog: false)
        continuation?.resume()
        continuation = nil
    }
    
}
