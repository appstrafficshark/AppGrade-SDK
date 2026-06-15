
import Foundation

struct EventModel: Codable, Identifiable {
    let eventName: String
    let id: String
    let eventId: String?
    let apiKey: String
    let coreInfo: SDKStorageData
    let sessionId: String
    let payload: Data
    let createdAt: Date
    let sessionTime: TimeInterval
    
    var retryCount: Int
    var nextAttemptAt: Date?
}
