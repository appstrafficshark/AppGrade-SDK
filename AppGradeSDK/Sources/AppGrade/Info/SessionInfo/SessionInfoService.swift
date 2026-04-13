
import Foundation

// MARK: - SessionInfoServiceProtocol
protocol SessionInfoServiceProtocol {
    func collect(data: SDKStorageData) async -> SessionInfoModel
    func endSession() -> TimeInterval
}

// MARK: - SessionInfoService
final class SessionInfoService: SessionInfoServiceProtocol {
    
    private let defaults = UserDefaults.standard
    
    private let sessionsKey = "sa_sessions"
    private let durationsKey = "sa_durations"
    
    private var sessionStart: TimeInterval?
    
    init(sessionStart: TimeInterval? = nil) {
        self.startSession()
    }
    
    func collect(data: SDKStorageData) async -> SessionInfoModel {
        let sessions = loadSessions()
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
        var sessions = loadSessions()
        sessions.append(now)
        saveSessions(sessions)
    }
    
    func endSession() -> TimeInterval {
        guard let start = sessionStart else { return 0 }
        let duration = Date().timeIntervalSince1970 - start
        var durations = loadDurations()
        durations.append(duration)
        saveDurations(durations)
        sessionStart = nil
        return duration
    }
    
}

// MARK: - Private
private extension SessionInfoService {
        
    func loadSessions() -> [TimeInterval] {
        defaults.array(forKey: sessionsKey) as? [TimeInterval] ?? []
    }
    
    func saveSessions(_ sessions: [TimeInterval]) {
        defaults.set(sessions, forKey: sessionsKey)
    }
    
    func loadDurations() -> [TimeInterval] {
        defaults.array(forKey: durationsKey) as? [TimeInterval] ?? []
    }
    
    func saveDurations(_ durations: [TimeInterval]) {
        defaults.set(durations, forKey: durationsKey)
    }
    
}
