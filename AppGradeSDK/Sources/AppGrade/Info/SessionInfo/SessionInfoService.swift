
import Foundation

// MARK: - SessionInfoService
final class SessionInfoService {
    
    static let shared = SessionInfoService()
    
    private let defaults = UserDefaults.standard
    
    private let sessionsKey = "sa_sessions"
    private let durationsKey = "sa_durations"
    private let installKey = "sa_install_ts"
    private let firstOpenKey = "sa_first_open_ts"
    
    private var sessionStart: TimeInterval?
    
    private init() {
        setupInstall()
    }
    
    // MARK: - Public API
    
    func startSession() {
        let now = Date().timeIntervalSince1970
        
        sessionStart = now
        
        var sessions = loadSessions()
        sessions.append(now)
        saveSessions(sessions)
    }
    
    func endSession() {
        guard let start = sessionStart else { return }
        
        let duration = Date().timeIntervalSince1970 - start
        
        var durations = loadDurations()
        durations.append(duration)
        saveDurations(durations)
        
        sessionStart = nil
    }
    
    func getAnalytics() -> SessionInfoModel {
        let sessions = loadSessions()
        let durations = loadDurations()
        
        let installTs = defaults.double(forKey: installKey)
        let firstOpenTs = defaults.double(forKey: firstOpenKey)
        
        let total = sessions.count
        
        let days = max(1, Int((Date().timeIntervalSince1970 - installTs) / 86400))
        let avgPerDay = Double(total) / Double(days)
        
        let intervals = zip(sessions.dropFirst(), sessions).map { $0 - $1 }
        
        let mean = mean(intervals)
        let std = std(intervals, mean: mean)
        
        let hourDist = buildHourDistribution(sessions)
        let dayDist = buildDayDistribution(sessions)
        
        return SessionInfoModel(
            installTs: installTs,
            firstOpenTs: firstOpenTs,
            sessionTimestamps: sessions,
            totalSessionsCount: total,
            sessionsPerDayAvg: avgPerDay,
            sessionIntervalMeanSec: mean,
            sessionIntervalStdSec: std,
            hourOfDayDistribution: hourDist,
            hourOfDayEntropy: entropy(hourDist),
            dayOfWeekDistribution: dayDist,
            dayOfWeekEntropy: entropy(dayDist),
            weekendRatio: weekendRatio(sessions),
            retentionD1: retention(days: 1, sessions: sessions),
            retentionD3: retention(days: 3, sessions: sessions),
            retentionD7: retention(days: 7, sessions: sessions),
            retentionD14: retention(days: 14, sessions: sessions),
            retentionD30: retention(days: 30, sessions: sessions),
            avgSessionDurationTrend: durationTrend(durations),
            engagementScore: engagementScore(total: total, avg: avgPerDay)
        )
    }
}

// MARK: - Private
private extension SessionInfoService {
    
    func setupInstall() {
        let now = Date().timeIntervalSince1970
        
        if defaults.object(forKey: installKey) == nil {
            defaults.set(now, forKey: installKey)
        }
        
        if defaults.object(forKey: firstOpenKey) == nil {
            defaults.set(now, forKey: firstOpenKey)
        }
    }
    
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

// MARK: - Calculations
private extension SessionInfoService {
    
    func mean(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }
    
    func std(_ values: [Double], mean: Double) -> Double {
        guard !values.isEmpty else { return 0 }
        let variance = values.map { pow($0 - mean, 2) }.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }
    
    func buildHourDistribution(_ sessions: [TimeInterval]) -> [Int] {
        var result = Array(repeating: 0, count: 24)
        
        for ts in sessions {
            let hour = Calendar.current.component(.hour, from: Date(timeIntervalSince1970: ts))
            result[hour] += 1
        }
        
        return result
    }
    
    func buildDayDistribution(_ sessions: [TimeInterval]) -> [Int] {
        var result = Array(repeating: 0, count: 7)
        
        for ts in sessions {
            let day = Calendar.current.component(.weekday, from: Date(timeIntervalSince1970: ts)) - 1
            result[day] += 1
        }
        
        return result
    }
    
    func entropy(_ distribution: [Int]) -> Double {
        let total = Double(distribution.reduce(0, +))
        guard total > 0 else { return 0 }
        
        return distribution.reduce(0) { result, count in
            let p = Double(count) / total
            return p > 0 ? result - p * log2(p) : result
        }
    }
    
    func weekendRatio(_ sessions: [TimeInterval]) -> Double {
        guard !sessions.isEmpty else { return 0 }
        
        let weekendCount = sessions.filter {
            let day = Calendar.current.component(.weekday, from: Date(timeIntervalSince1970: $0))
            return day == 1 || day == 7
        }.count
        
        return Double(weekendCount) / Double(sessions.count)
    }
    
    func retention(days: Int, sessions: [TimeInterval]) -> Double {
        guard let first = sessions.first else { return 0 }
        
        let target = first + Double(days * 86400)
        return sessions.contains { $0 >= target } ? 1.0 : 0.0
    }
    
    func durationTrend(_ durations: [TimeInterval]) -> Double {
        guard durations.count > 1 else { return 0 }
        
        let firstHalf = durations.prefix(durations.count / 2)
        let secondHalf = durations.suffix(durations.count / 2)
        
        let avg1 = mean(Array(firstHalf))
        let avg2 = mean(Array(secondHalf))
        
        return avg2 - avg1
    }
    
    func engagementScore(total: Int, avg: Double) -> Double {
        let score = (Double(total) * 0.4 + avg * 0.6) / 10.0
        return min(1.0, score)
    }
}
