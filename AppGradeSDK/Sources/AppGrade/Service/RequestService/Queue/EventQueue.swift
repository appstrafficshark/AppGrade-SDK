
import Foundation

actor EventQueue {
    
    private var events: [EventModel]
    private let storage: EventStorage
    
    init(storage: EventStorage) {
        self.storage = storage
        self.events = storage.load()
    }
    
    func enqueue(_ event: EventModel) {
        events.append(event)
        persist()
    }
    
    func peek() -> EventModel? {
        events.first
    }
    
    func remove(id: UUID) {
        events.removeAll { $0.id == id }
        persist()
    }
    
    func update(_ event: EventModel) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = event
        persist()
    }
    
    private func persist() {
        storage.save(events)
    }
    
}
