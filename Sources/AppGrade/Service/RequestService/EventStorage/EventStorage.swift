
import Foundation

final class EventStorage {

    private let url: URL

    init(filename: String = "events.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = dir.appendingPathComponent(filename)
    }

    func load() -> [EventModel] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        guard !data.isEmpty else { return [] }
        do {
            let model = try JSONDecoder().decode([EventModel].self, from: data)
            return model.map { event in
                var new = event
                new.retryCount = 0
                new.nextAttemptAt = nil
                return new
            }
        } catch {
            print("[AppGradeSDK] --- ⚠️ Failed to decode cached events: \(error.localizedDescription)")
            return []
        }
    }

    func save(_ events: [EventModel]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        try? data.write(to: url, options: .atomic)
    }

}
