
import Foundation

// MARK: - SessionInfoModel
struct SessionInfoModel: Codable {
    let installTs: TimeInterval // ⚠️
    let firstOpenTs: TimeInterval
    let totalSessionsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case installTs = "install_ts"
        case firstOpenTs = "first_open_ts"
        case totalSessionsCount = "total_sessions_count"
    }
    
}
