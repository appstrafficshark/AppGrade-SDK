
import Foundation

// MARK: - LogServiceProtocol
protocol LogServiceProtocol {
    func log(_ message: String)
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
    
    func log(_ message: String) {
        guard enableLogs else { return }
        print("[AppGradeSDK] --- \(message)")
    }
    
}
