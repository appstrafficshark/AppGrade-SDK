
import UIKit

// MARK: - AppStateType
enum AppStateType {
    case background
    case active
}

// MARK: - AppStateObserver
final class AppStateObserver {
    
    var onStateChanges: ((AppStateType) -> Void)?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func didEnterBackground() {
        onStateChanges?(.background)
    }
    
    @objc private func didBecomeActive() {
        onStateChanges?(.active)
    }
    
}
