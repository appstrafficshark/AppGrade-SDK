
import Foundation

// MARK: - RequestServiceProtocol
protocol RequestServiceProtocol {
    func track<T: Codable>(updateInfo: Bool, model: T) async throws
}

// MARK: - RequestService
final class RequestService {
    
    private let apiKey: String
    private let sessionId: String
    private let coreInfo: SDKStorageData
    
    private let logService: LogServiceProtocol
    private let queue: EventQueue
    private let dispatcher: EventDispatcher
    
    init(apiKey: String, sessionId: String, coreInfo: SDKStorageData, logService: LogServiceProtocol) {
        self.apiKey = apiKey
        self.sessionId = sessionId
        self.coreInfo = coreInfo
        
        self.logService = logService
        let storage = EventStorage()
        self.queue = EventQueue(storage: storage)
        self.dispatcher = EventDispatcher(queue: queue, network: NetworkService(), logService: self.logService)
        self.dispatcher.start()
    }
  
}
// MARK: - RequestServiceProtocol
extension RequestService: RequestServiceProtocol {
    
    func track<T: Codable>(updateInfo: Bool = false, model: T) async throws {
        do {
            let data = try JSONEncoder().encode(model)
            let event = EventModel(id: UUID(), apiKey: apiKey, coreInfo: coreInfo, sessionId: sessionId, payload: data, createdAt: Date(), updateInfo: updateInfo, retryCount: 0)
            await queue.enqueue(event)
            dispatcher.notifyNewEvent()
            
        } catch {
            logService.log("⛔️ Encoding error: \(error.localizedDescription)")
        }
    }
        
}
