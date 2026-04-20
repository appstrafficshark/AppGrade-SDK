
import Foundation

// MARK: - AttributionInfo
struct AttributionInfo: Codable {
    let installSource: String
    let idfa: String
    let gaid: String? // always nil on iOS
    let idfv: String
    let isOrganic: Bool
    
    enum CodingKeys: String, CodingKey {
        case installSource = "install_source"
        case idfa
        case gaid
        case idfv
        case isOrganic = "is_organic"
    }
}

// MARK: - InstallSourceType
enum InstallSourceType {
    case organic
    case campaignId(String)
    
    var installSource: String {
        switch self {
        case .organic:
            return "organic"
        case .campaignId(let id):
            return id
        }
    }
}

