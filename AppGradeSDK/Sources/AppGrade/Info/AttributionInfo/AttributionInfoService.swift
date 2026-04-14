
import UIKit
import AdSupport
import AppTrackingTransparency
import StoreKit
import AdServices

// MARK: - AttributionInfoServiceProtocol
protocol AttributionInfoServiceProtocol {
    func collect() async -> AttributionInfo
}

// MARK: - AttributionInfoService
final class AttributionInfoService: AttributionInfoServiceProtocol {
    
    func collect() async -> AttributionInfo {
        let installSource = await getInstallSource()
        return AttributionInfo(
            installSource: installSource,
            idfa: getIDFA(),
            gaid: nil,
            idfv: UIDevice.current.identifierForVendor?.uuidString,
            skanConversionValue: getSKAN(),
            isOrganic: installSource == InstallSourceType.organic.installSource
        )
    }
    
}

// MARK: - Private Function
private extension AttributionInfoService {
           
    func getInstallSource() async -> String {
        let installSource: String = StorageService.load(key: .installSource, defaultValue: "")
        guard installSource == "" else { return installSource }
        
        guard let requestUrl = URL(string: "https://api-adservices.apple.com/api/v1/"),
              let token = try? AAAttribution.attributionToken()
        else {
            return InstallSourceType.organic.installSource
        }
        do {
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data(token.utf8)
            request.timeoutInterval = 10
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else {
                return InstallSourceType.organic.installSource
            }
            
            let campaignId = jsonResponse["campaignId"] as? Int
            
            if let campaignId, campaignId != 1234567890 {
                return InstallSourceType.campaignId("\(campaignId)").installSource
            } else {
                return InstallSourceType.organic.installSource
            }
        } catch {
            return InstallSourceType.organic.installSource
        }
    }
    
    func getIDFA() -> String {
        let status = ATTrackingManager.trackingAuthorizationStatus
        switch status {
        case .notDetermined, .restricted:
            return "ATT_notDetermined"
        case .denied:
            return "ATT_denied"
        case .authorized:
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString ?? "unknown"
        }        
    }
    
    // TODO: - ???
    func getSKAN() -> Int? {
        return nil
    }
    
}
