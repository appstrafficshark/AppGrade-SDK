
import Foundation

// MARK: - AppExitInfoServiceProtocol
protocol AppExitInfoServiceProtocol {
    func collect(sessionDuration: TimeInterval, networkInfo: NetworkInfoModel) async -> AppExitInfoModel
}

// MARK: - AppExitInfoService
final class AppExitInfoService: AppExitInfoServiceProtocol {
    
    func collect(sessionDuration: TimeInterval, networkInfo: NetworkInfoModel) async -> AppExitInfoModel {
        return AppExitInfoModel.init(info: .init(sessionDuration: sessionDuration), networkInfo: networkInfo)
    }
    
}

