
import UIKit
import AdSupport
import AppTrackingTransparency
import StoreKit

final class AttributionInfoService {
    
    static let shared = AttributionInfoService()
    
    private let defaults = UserDefaults.standard
    
    private let installTimeKey = "attr_install_time"
    private let firstOpenKey = "attr_first_open_time"
    
    private init() {
        setupInstallTime()
    }
}

private extension AttributionInfoService {
    
    func setupInstallTime() {
        let now = Date().timeIntervalSince1970
        
        if defaults.object(forKey: installTimeKey) == nil {
            defaults.set(now, forKey: installTimeKey)
        }
        
        if defaults.object(forKey: firstOpenKey) == nil {
            defaults.set(now, forKey: firstOpenKey)
        }
    }
}

extension AttributionInfoService {
    
    func getAttribution() -> AttributionInfo {
        return AttributionInfo(
            installSource: getInstallSource(),
            ctitSec: getCTIT(),
            idfa: getIDFA(),
            gaid: nil,
            idfv: UIDevice.current.identifierForVendor?.uuidString,
            skanConversionValue: getSKAN(),
            isOrganic: isOrganic()
        )
    }
}

extension AttributionInfoService {
    
    private func getInstallSource() -> String? {
        // iOS напрямую НЕ даёт источник установки
        // варианты:
        // - AppsFlyer / Adjust / Firebase
        // - или deep link
        
        return "unknown"
    }
    
    private func getCTIT() -> Double? {
        let install = defaults.double(forKey: installTimeKey)
        let firstOpen = defaults.double(forKey: firstOpenKey)
        
        guard install > 0, firstOpen > 0 else { return nil }
        
        return firstOpen - install
    }
    
    private func getIDFA() -> String? {
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        guard status == .authorized else { return nil }
        
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    private func getSKAN() -> Int? {
        if #available(iOS 14.0, *) {
            return UserDefaults.standard.integer(forKey: "skan_cv")
        }
        return nil
    }
    
    private func isOrganic() -> Bool {
        let source = getInstallSource()
        return source == nil || source == "unknown" || source == "organic"
    }
    
}
