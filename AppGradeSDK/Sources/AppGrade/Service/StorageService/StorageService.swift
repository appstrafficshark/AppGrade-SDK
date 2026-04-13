
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

// MARK: - Key
enum StorageServiceKey: String {
    case sdkStorageData = "sdk_storage_data"
    case sessionsKey = "sa_sessions"
    case durationsKey = "sa_durations"
    case installSource = "install_source"
}

// MARK: - StorageServiceProtocol
protocol StorageServiceProtocol {
    var coreInfo: SDKStorageData { get }
    func clear()
}

// MARK: - StorageService
final class StorageService {
            
    private let defaults = UserDefaults.standard
    
    private(set) var coreInfo: SDKStorageData
    
    init() {
        if let saved: SDKStorageData = StorageService.loadFromDefaults() {
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
        defaults.removeObject(forKey: StorageServiceKey.sdkStorageData.rawValue)
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
            defaults.set(encoded, forKey: StorageServiceKey.sdkStorageData.rawValue)
        }
    }
    
}

// MARK: - Static
extension StorageService {
    
    static func loadFromDefaults() -> SDKStorageData? {
        let defaults = UserDefaults.standard
        let storageKey = StorageServiceKey.sdkStorageData.rawValue
        guard let saved = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(SDKStorageData.self, from: saved) else {
            return nil
        }
        return decoded
    }
        
    static func load<T>(key: StorageServiceKey, defaultValue: T) -> T {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
    }

    static func save<T>(key: StorageServiceKey, value: T) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
}
