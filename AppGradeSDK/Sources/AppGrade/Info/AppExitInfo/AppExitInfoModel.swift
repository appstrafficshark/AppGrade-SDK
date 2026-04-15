
import Foundation

// MARK: - SendingDeviceInfoModel
struct AppExitInfoModel: Codable {
    let info: AppExitInfo
    let networkInfo: NetworkInfoModel
    
    enum CodingKeys: String, CodingKey {
        case info
        case networkInfo = "network_info"
    }
    
}

struct AppExitInfo: Codable {
    let sessionDuration: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case sessionDuration = "session_duration"
    }
    
}
