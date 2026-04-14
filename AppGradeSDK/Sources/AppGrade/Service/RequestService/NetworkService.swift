
import Foundation

final class NetworkService {
    
    func send(event: EventModel) async throws {
        guard let url = URL(string: AppGradeConstant.Project.endpointURL) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = event.payload
        
        request.addValue(event.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(event.coreInfo.userId, forHTTPHeaderField: "user_id")
        request.addValue("\(event.coreInfo.launchCount)", forHTTPHeaderField: "launch_counter")
        request.addValue(event.sessionId, forHTTPHeaderField: "session_id")
        request.addValue("\(event.createdAt.timeIntervalSince1970)", forHTTPHeaderField: "created_at")
        request.addValue(event.id.uuidString, forHTTPHeaderField: "event_id")
        request.addValue("\(event.updateInfo)", forHTTPHeaderField: "update_info")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }
    }
    
}
