
import Foundation

actor EventQueue {

    private let maxEvents = 1000

    private var events: [EventModel]
    private let storage: EventStorage

    init(storage: EventStorage) {
        self.storage = storage
        self.events = storage.load()
    }

    func enqueue(_ event: EventModel) {
        events.append(event)
        if events.count > maxEvents {
            events.removeFirst(events.count - maxEvents)
        }
        persist()
    }

    /// First event that is due for a send attempt (skips events still in backoff).
    func nextEligible(now: Date = Date()) -> EventModel? {
        events.first { ($0.nextAttemptAt ?? .distantPast) <= now }
    }

    func peek() -> EventModel? {
        events.first
    }

    func remove(id: String) {
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
