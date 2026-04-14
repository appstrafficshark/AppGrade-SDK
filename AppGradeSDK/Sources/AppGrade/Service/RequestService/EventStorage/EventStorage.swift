
import Foundation

final class EventStorage {
    
    private let url: URL
    
    init(filename: String = "events.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = dir.appendingPathComponent(filename)
    }
    
    func load() -> [EventModel] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([EventModel].self, from: data)) ?? []
    }
    
    func save(_ events: [EventModel]) {
        let data = try? JSONEncoder().encode(events)
        try? data?.write(to: url)
    }
    
}
