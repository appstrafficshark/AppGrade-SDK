
import Foundation

// MARK: - RequestServiceProtocol
protocol RequestServiceProtocol {
    func track<T: Codable>(id: String?, eventType: EventType, model: T) async throws
    func updateSessionTime(event: AppStateType) 
}

// MARK: - RequestService
final class RequestService {
    
    private let apiKey: String
    private let sessionId: String
    private let coreInfo: SDKStorageData
    
    private let sessionStart: TimeInterval
    private var sessionInactiveStart: TimeInterval?
    private var sessionInactiveTime: TimeInterval = 0
    
    private let logService: LogServiceProtocol
    private let queue: EventQueue
    private let dispatcher: EventDispatcher
    
    init(apiKey: String, sessionId: String, coreInfo: SDKStorageData, logService: LogServiceProtocol) {
        self.apiKey = apiKey
        self.sessionId = sessionId
        self.coreInfo = coreInfo
        self.sessionStart = Date().timeIntervalSince1970
        
        self.logService = logService
        let storage = EventStorage()
        self.queue = EventQueue(storage: storage)
        self.dispatcher = EventDispatcher(queue: queue, network: NetworkService(), logService: self.logService)
        self.dispatcher.start()
    }
  
}

// MARK: - RequestServiceProtocol
extension RequestService: RequestServiceProtocol {
    
    func track<T: Codable>(id: String? = nil, eventType: EventType, model: T) async throws {
        do {
            let data = try JSONEncoder().encode(model)
            let duration = Date().timeIntervalSince1970 - sessionStart - sessionInactiveTime
            let event = EventModel(eventName: eventType.rawValue, id: id ?? UUID().uuidString, apiKey: apiKey, coreInfo: coreInfo, sessionId: sessionId, payload: data, createdAt: Date(), sessionTime: duration, retryCount: 0)
            await queue.enqueue(event)
            dispatcher.notifyNewEvent()
        } catch {
            logService.log("⛔️ Encoding error: \(error.localizedDescription)", debugLog: false)
        }
    }
            
    func updateSessionTime(event: AppStateType) {
        switch event {
        case .background:
            self.sessionInactiveStart = Date().timeIntervalSince1970
        case .active:
            guard let sessionInactiveStart else { return }
            let duration = Date().timeIntervalSince1970 - sessionInactiveStart
            self.sessionInactiveTime += duration
        }
    }
    
}
