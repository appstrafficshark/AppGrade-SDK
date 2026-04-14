
import Foundation

struct EventModel: Codable, Identifiable {
    let id: UUID
    let apiKey: String
    let coreInfo: SDKStorageData
    let sessionId: String
    let payload: Data
    let createdAt: Date
    let updateInfo: Bool
    
    var retryCount: Int
}
