
import UIKit

// MARK: - Model
struct SDKStorageData: Codable {
    var userId: String
    var launchCount: Int
    var firstLaunchDate: Date
    
    var isFirstLaunch: Bool {
        return launchCount <= 1
    }
}

// MARK: - StorageServiceProtocol
protocol StorageServiceProtocol {
    var coreInfo: SDKStorageData { get }
    func clear()
}

// MARK: - StorageService
final class StorageService {
            
    private let defaults = UserDefaults.standard
    private let storageKey = "sdk_storage_data"
    
    private(set) var coreInfo: SDKStorageData
    
    init() {
        if let saved: SDKStorageData = loadFromDefaults() {
            self.coreInfo = saved
        } else {
            let now = Date()
            self.coreInfo = SDKStorageData(userId: UIDevice.deviceId, launchCount: 0, firstLaunchDate: now)
        }
        incrementLaunchCount()
        saveToDefaults()
    }
    
}

// MARK: - StorageServiceProtocol
extension StorageService: StorageServiceProtocol {
    
    func clear() {
        defaults.removeObject(forKey: storageKey)
        coreInfo = SDKStorageData(userId: UIDevice.deviceId, launchCount: 0, firstLaunchDate: Date())
    }
    
}

// MARK: - Helpers
private extension StorageService {
    
    private func incrementLaunchCount() {
        if coreInfo.launchCount == 0 {
            coreInfo.firstLaunchDate = Date()
        }
        coreInfo.launchCount += 1
    }
    
    private func saveToDefaults() {
        if let encoded = try? JSONEncoder().encode(coreInfo) {
            defaults.set(encoded, forKey: storageKey)
        }
    }
    
}

func loadFromDefaults() -> SDKStorageData? {
    let defaults = UserDefaults.standard
    let storageKey = "sdk_storage_data"
    guard let saved = defaults.data(forKey: storageKey),
          let decoded = try? JSONDecoder().decode(SDKStorageData.self, from: saved) else {
        return nil
    }
    return decoded
}
