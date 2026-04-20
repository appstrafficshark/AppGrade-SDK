
import Foundation

// MARK: - SendingDeviceInfoModel
struct AppExitInfoModel: Codable {
    let networkInfo: NetworkInfoModel
    
    enum CodingKeys: String, CodingKey {
        case networkInfo = "network_info"
    }
    
}

