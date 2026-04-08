
import Foundation

// MARK: - RequestServiceProtocol
protocol RequestServiceProtocol {
    func send(_ device: DeviceInfo) async throws
}

// MARK: - RequestService
final class RequestService {
    
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
  
}

// MARK: - RequestServiceProtocol
extension RequestService: RequestServiceProtocol {
    
    func send(_ device: DeviceInfo) async throws {
        
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
