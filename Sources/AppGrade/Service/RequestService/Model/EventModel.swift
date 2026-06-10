
import Foundation

struct EventModel: Codable, Identifiable {
    let eventName: String
    /// Unique per enqueue — the queue's identity for remove/update. Distinct
    /// from `eventId` so two events sharing a server id (e.g. launch attribution
    /// and after_idfa upsert, or repeated left_app) never collide or delete each
    /// other in the offline queue.
    let id: String
    /// Server-facing `event_id`. May be shared across events on purpose so the
    /// backend upserts the same record. Optional for backward compatibility with
    /// events cached by older builds (falls back to `id`).
    let eventId: String?
    let apiKey: String
    let coreInfo: SDKStorageData
    let sessionId: String
    let payload: Data
    let createdAt: Date
    let sessionTime: TimeInterval
    
    var retryCount: Int
    /// When the event becomes eligible for the next send attempt (backoff
    /// without blocking the consumer). `nil` means "send as soon as possible".
    /// Optional so events persisted by older versions still decode.
    var nextAttemptAt: Date?
}
