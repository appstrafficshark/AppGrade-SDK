
import Foundation

final class NetworkService {

    /// Error carrying the HTTP status so the dispatcher can decide whether a
    /// failure is permanent (drop) or transient (keep & retry).
    enum SendError: Error {
        case http(status: Int)
    }

    func send(event: EventModel) async throws {
        guard let url = URL(string: AppGradeConstant.Project.endpointURL) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = event.payload
        
//        print(">>> \n\(String(data: event.payload, encoding: String.Encoding.utf8)!)\n")
        
        request.addValue(event.apiKey, forHTTPHeaderField: "api_key")
        request.addValue(event.coreInfo.userId, forHTTPHeaderField: "user_id")
        request.addValue(event.eventName, forHTTPHeaderField: "event_name")
        request.addValue("\(event.coreInfo.launchCount)", forHTTPHeaderField: "launch_counter")
        request.addValue(event.sessionId, forHTTPHeaderField: "session_id")
        request.addValue("\(event.createdAt.timeIntervalSince1970)", forHTTPHeaderField: "created_at")
        request.addValue(event.eventId ?? event.id, forHTTPHeaderField: "event_id")
        request.addValue("\(event.sessionTime)", forHTTPHeaderField: "session_time") 
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200...299).contains(http.statusCode) else {
            throw SendError.http(status: http.statusCode)
        }
    }
    
}
