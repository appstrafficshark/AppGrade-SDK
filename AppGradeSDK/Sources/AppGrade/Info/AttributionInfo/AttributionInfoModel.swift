
import Foundation

// MARK: - AttributionInfo
struct AttributionInfo: Codable {
    let installSource: String
//    let ctitSec: Double? // ⚠️
    let idfa: String
    let gaid: String? // always nil on iOS
    let idfv: String
    let skanConversionValue: String // ⚠️
    let isOrganic: Bool
    
    enum CodingKeys: String, CodingKey {
        case installSource = "install_source"
//        case ctitSec = "ctit_sec"
        case idfa
        case gaid
        case idfv
        case skanConversionValue = "skan_conversion_value"
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

