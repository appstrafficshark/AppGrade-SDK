
import Foundation

struct EventInfoModel: Encodable {
    let device: SendingDeviceInfoModel
    let network: NetworkInfoModel
    let session: SessionInfoModel
    let attribution: AttributionInfo
    let sessionTime: Int
    var subscription: ReceiptSubscriptionInfoModel? = nil
    var nonRenewingPurchase: ReceiptNonRenewingPurchaseInfoModel? = nil

    private enum RootKeys: String, CodingKey {
        case info
        case environment
        case subscription = "subscription_info"
        case nonRenewingPurchase = "non_renewing_purchase_info"
    }

    private enum EnvironmentKeys: String, CodingKey {
        case installTs = "install_ts"
        case sessionTime = "session_time"
    }

    func encode(to encoder: Encoder) throws {
        var root = encoder.container(keyedBy: RootKeys.self)

        try root.encode(device.info, forKey: .info)

        let envEncoder = root.superEncoder(forKey: .environment)
        try device.environment.encode(to: envEncoder)
        try network.encode(to: envEncoder)
        try attribution.encode(to: envEncoder)

        var env = envEncoder.container(keyedBy: EnvironmentKeys.self)
        try env.encode(Int64(session.installTs), forKey: .installTs)
        try env.encode(sessionTime, forKey: .sessionTime)
        
        try root.encodeIfPresent(subscription, forKey: .subscription)
        try root.encodeIfPresent(nonRenewingPurchase, forKey: .nonRenewingPurchase)
    }
}
