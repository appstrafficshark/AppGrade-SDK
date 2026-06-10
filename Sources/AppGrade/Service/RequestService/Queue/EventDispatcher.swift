
import Foundation

actor EventDispatcher {

    private let queue: EventQueue
    private let network: NetworkService
    private let logService: LogServiceProtocol

    private var isRunning = false
    /// Guards against reentrancy: while a send is in flight (awaiting the
    /// network) another `process()` must not pick up the same head event.
    private var isSending = false

    /// How often the loop re-checks the queue (and re-evaluates backoff).
    private let pollInterval: Duration = .milliseconds(500)
    /// Upper bound for exponential backoff between retries. Kept modest so that
    /// when connectivity returns mid-session a cached event retries within ~1 min
    /// (on a fresh launch the backoff is reset, so retry is immediate).
    private let maxBackoff: TimeInterval = 60

    init(queue: EventQueue, network: NetworkService, logService: LogServiceProtocol) {
        self.queue = queue
        self.network = network
        self.logService = logService
    }

    nonisolated func start() {
        Task { await self.run() }
    }

    nonisolated func notifyNewEvent() {
        Task { await self.process() }
    }

    private func run() async {
        guard !isRunning else { return }
        isRunning = true
        await loop()
    }

    private func loop() async {
        while isRunning {
            await process()
            try? await Task.sleep(for: pollInterval)
        }
    }

    private func process() async {
        // Only one send at a time. Reentrant calls (loop tick / notify) bail out
        // instead of double-sending the same event. Set the flag BEFORE any
        // `await` so a reentrant call can't slip in during the suspension.
        guard !isSending else { return }
        isSending = true
        defer { isSending = false }

        guard let event = await queue.nextEligible() else { return }

        do {
            try await network.send(event: event)
            logService.log("✅ Sent \(event.eventName) event_id=\(event.eventId ?? event.id) retry=\(event.retryCount)", debugLog: true)
            await queue.remove(id: event.id)
        } catch {
            await handleFailure(event, error: error)
        }
    }

    private func handleFailure(_ event: EventModel, error: Error) async {
        // Permanent server rejection (4xx, except 408/429): the payload will
        // never be accepted, so drop it. Everything else — offline, timeout,
        // 5xx — is transient: keep the event forever and retry with backoff.
        if isPermanent(error) {
            logService.log("🗑 Dropping rejected \(event.eventName) event_id=\(event.eventId ?? event.id) error=\(error.localizedDescription)", debugLog: false)
            await queue.remove(id: event.id)
            return
        }

        var updated = event
        updated.retryCount += 1
        let delay = min(pow(2.0, Double(min(updated.retryCount, 16))), maxBackoff)
        updated.nextAttemptAt = Date().addingTimeInterval(delay)
        await queue.update(updated)

        logService.log("❌ Send failed \(event.eventName) event_id=\(event.eventId ?? event.id) retry=\(updated.retryCount), next in \(Int(delay))s error=\(error.localizedDescription)", debugLog: false)
    }

    private func isPermanent(_ error: Error) -> Bool {
        guard case let NetworkService.SendError.http(status) = error else {
            // Transport errors (no connection, timeout, DNS, …) are transient.
            return false
        }
        // 4xx are client errors and won't succeed on retry — except 408
        // (Request Timeout) and 429 (Too Many Requests), which are transient.
        return (400..<500).contains(status) && status != 408 && status != 429
    }

}
