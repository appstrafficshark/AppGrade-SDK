
import Foundation

// MARK: - AppExitInfoServiceProtocol
protocol AppExitInfoServiceProtocol {
    func collect(networkInfo: NetworkInfoModel) async -> AppExitInfoModel
}

// MARK: - AppExitInfoService
final class AppExitInfoService: AppExitInfoServiceProtocol {
    
    func collect(networkInfo: NetworkInfoModel) async -> AppExitInfoModel {
        return AppExitInfoModel.init(networkInfo: networkInfo)
    }
    
}

