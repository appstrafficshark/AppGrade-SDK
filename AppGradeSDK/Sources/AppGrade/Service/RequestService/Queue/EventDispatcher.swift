
import Foundation

final class EventDispatcher {
    
    private let queue: EventQueue
    private let network: NetworkService
    private let logService: LogServiceProtocol
    private var isRunning = false
    
    init(queue: EventQueue, network: NetworkService, logService: LogServiceProtocol) {
        self.queue = queue
        self.network = network
        self.logService = logService
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        Task {
            await loop()
        }
    }
    
    func notifyNewEvent() {
        Task {
            await process()
        }
    }
    
    private func loop() async {
        while isRunning {
            await process()
            try? await Task.sleep(for: .milliseconds(300))
        }
    }
    
    private func process() async {
        guard let event = await queue.peek() else { return }
        do {
            try await network.send(event: event)
            logService.log("✅ Sent event id=\(event.id); retry=\(event.retryCount)", debugLog: true)
            await queue.remove(id: event.id)
        } catch {
            logService.log("❌ Failed id=\(event.id) retry=\(event.retryCount) error=\(error.localizedDescription)", debugLog: false)
            await handleFailure(event)
        }
    }
    
    private func handleFailure(_ event: EventModel) async {
        var updated = event
        updated.retryCount += 1
        
        if updated.retryCount > AppGradeConstant.Project.maxRetries {
            await queue.remove(id: event.id)
            return
        }
        
        await queue.update(updated)
        
        let delay = pow(2.0, Double(updated.retryCount))
        let ns = UInt64(delay * 1_000_000_000)
        
        try? await Task.sleep(nanoseconds: ns)
    }
    
}
