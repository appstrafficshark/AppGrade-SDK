
import Foundation

// MARK: - SessionInfoServiceProtocol
protocol SessionInfoServiceProtocol {
    func collect(data: SDKStorageData) async -> SessionInfoModel
    func endSession() -> TimeInterval
}

// MARK: - SessionInfoService
final class SessionInfoService: SessionInfoServiceProtocol {
            
    private var sessionStart: TimeInterval?
    
    init(sessionStart: TimeInterval? = nil) {
        self.startSession()
    }
    
    func collect(data: SDKStorageData) async -> SessionInfoModel {
        let sessions: [TimeInterval] = StorageService.load(key: .sessionsKey, defaultValue: [])
        let total = sessions.count
        return .init(installTs: data.firstLaunchDate.timeIntervalSince1970,
                     firstOpenTs: data.firstLaunchDate.timeIntervalSince1970,
                     sessionTimestamps: sessions,
                     totalSessionsCount: total)
    }
        
}

// MARK: - Session
extension SessionInfoService {
    
    private func startSession() {
        let now = Date().timeIntervalSince1970
        sessionStart = now
        var sessions: [TimeInterval] = StorageService.load(key: .sessionsKey, defaultValue: [])
        sessions.append(now)
        StorageService.save(key: .sessionsKey, value: sessions)
    }
    
    func endSession() -> TimeInterval {
        guard let start = sessionStart else { return 0 }
        let duration = Date().timeIntervalSince1970 - start
        var durations: [TimeInterval] = StorageService.load(key: .durationsKey, defaultValue: [])
        durations.append(duration)
        StorageService.save(key: .durationsKey, value: durations)
        sessionStart = nil
        return duration
    }
    
}
