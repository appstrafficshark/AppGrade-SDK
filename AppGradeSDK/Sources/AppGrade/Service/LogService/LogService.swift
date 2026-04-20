
import Foundation

// MARK: - LogServiceProtocol
protocol LogServiceProtocol {
    func log(_ message: String, debugLog: Bool)
}

// MARK: - LogService
final class LogService {
    
    private let enableLogs: Bool
    
    init(enableLogs: Bool) {
        self.enableLogs = enableLogs
    }
    
}

// MARK: - LogServiceProtocol
extension LogService: LogServiceProtocol {
    
    func log(_ message: String, debugLog: Bool) {
        guard enableLogs, !debugLog else { return }
        print("[AppGradeSDK] --- \(message)")
    }
    
}
