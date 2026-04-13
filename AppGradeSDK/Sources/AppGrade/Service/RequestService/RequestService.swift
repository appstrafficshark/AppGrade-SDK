
import Foundation

// MARK: - RequestServiceProtocol
protocol RequestServiceProtocol {
    func send(_ device: SendingDeviceInfoModel) async throws
}

// MARK: - RequestService
final class RequestService {
    
    private let apiKey: String
    private let sessionId: String
    private let coreInfo: SDKStorageData
    
    init(apiKey: String, sessionId: String, coreInfo: SDKStorageData) {
        self.apiKey = apiKey
        self.sessionId = sessionId
        self.coreInfo = coreInfo
    }
  
}
// TODO: - ???
// MARK: - RequestServiceProtocol
extension RequestService: RequestServiceProtocol {
    
    func send(_ device: SendingDeviceInfoModel) async throws {
        
        let endpoint = "https://your-api.com/device/testst"
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(device)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              200...299 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
    
}
