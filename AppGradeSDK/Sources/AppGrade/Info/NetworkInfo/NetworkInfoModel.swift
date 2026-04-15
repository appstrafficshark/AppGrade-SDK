
import Foundation

// MARK: - NetworkInfoModel
struct NetworkInfoModel: Codable {
    let connectionType: String
    let cellularTechnology: String
    let carrierName: String
    let isVpnActive: Bool
    let isProxyConfigured: Bool
    let connectionChangesCount: Int // ⚠️
    
    enum CodingKeys: String, CodingKey {
        case connectionType = "connection_type"
        case cellularTechnology = "cellular_technology"
        case carrierName = "carrier_name"
        case isVpnActive = "is_vpn_active"
        case isProxyConfigured = "is_proxy_configured"
        case connectionChangesCount = "connection_changes_count"
    }
    
}
