
import Foundation

// MARK: - SessionInfoModel
struct SessionInfoModel: Codable {
    let installTs: TimeInterval // ⚠️
    let firstOpenTs: TimeInterval
    let sessionTimestamps: [TimeInterval]
    let totalSessionsCount: Int
//    let sessionsPerDayAvg: Double
//    let sessionIntervalMeanSec: Double
//    let sessionIntervalStdSec: Double
//    let hourOfDayDistribution: [Int]
//    let hourOfDayEntropy: Double
//    let dayOfWeekDistribution: [Int]
//    let dayOfWeekEntropy: Double
//    let weekendRatio: Double
//    let retentionD1: Double
//    let retentionD3: Double
//    let retentionD7: Double
//    let retentionD14: Double
//    let retentionD30: Double
//    let avgSessionDurationTrend: Double
//    let engagementScore: Double
    
    enum CodingKeys: String, CodingKey {
        case installTs = "install_ts"
        case firstOpenTs = "first_open_ts"
        case sessionTimestamps = "session_timestamps"
        case totalSessionsCount = "total_sessions_count"
//        case sessionsPerDayAvg = "sessions_per_day_avg"
//        case sessionIntervalMeanSec = "session_interval_mean_sec"
//        case sessionIntervalStdSec = "session_interval_std_sec"
//        case hourOfDayDistribution = "hour_of_day_distribution"
//        case hourOfDayEntropy = "hour_of_day_entropy"
//        case dayOfWeekDistribution = "day_of_week_distribution"
//        case dayOfWeekEntropy = "day_of_week_entropy"
//        case weekendRatio = "weekend_ratio"
//        case retentionD1 = "retention_d1"
//        case retentionD3 = "retention_d3"
//        case retentionD7 = "retention_d7"
//        case retentionD14 = "retention_d14"
//        case retentionD30 = "retention_d30"
//        case avgSessionDurationTrend = "avg_session_duration_trend"
//        case engagementScore = "engagement_score"
    }
    // TODO: - ???
}
