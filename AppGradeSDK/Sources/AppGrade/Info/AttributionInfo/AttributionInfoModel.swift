
import Foundation

// MARK: - AttributionInfo
struct AttributionInfo: Codable {
    let installSource: String?
    let ctitSec: Double?
    let idfa: String?
    let gaid: String? // всегда nil на iOS
    let idfv: String?
    let skanConversionValue: Int?
    let isOrganic: Bool
    
    enum CodingKeys: String, CodingKey {
        case installSource = "install_source"
        case ctitSec = "ctit_sec"
        case idfa
        case gaid
        case idfv
        case skanConversionValue = "skan_conversion_value"
        case isOrganic = "is_organic"
    }
}
