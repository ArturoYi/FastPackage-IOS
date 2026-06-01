import Foundation

/// 速率限制工具：每个时间窗口内首次调用立即执行，窗口内的后续调用会被缓存并在下一窗口执行。
///
/// 参考 [fast_package](https://github.com/ArturoYi/fast_package) 的 `FastRateLimit` 设计。
public enum FastRateLimit {
    private final class Operation {
        var callback: (() -> Void)?
        var onAfter: (() -> Void)?
        let timer: DispatchSourceTimer

        init(timer: DispatchSourceTimer) {
            self.timer = timer
        }
    }

    private static var operations: [String: Operation] = [:]
    private static let lock = NSLock()

    /// 执行速率限制逻辑。
    ///
    /// - Parameters:
    ///   - tag: 速率限制操作的唯一标识。
    ///   - duration: 时间窗口大小（秒）。
    ///   - queue: 回调执行队列，默认主队列。
    ///   - onExecute: 首次调用或新窗口开始时执行的回调。
    ///   - onAfter: 窗口结束后，若期间有缓存调用则执行此回调。
    /// - Returns: 若当前 tag 正在限制中返回 `true`，否则返回 `false` 并开始新周期。
    @discardableResult
    public static func rateLimit(
        tag: String,
        duration: TimeInterval,
        queue: DispatchQueue = .main,
        onExecute: @escaping () -> Void,
        onAfter: (() -> Void)? = nil
    ) -> Bool {
        lock.lock()

        if let operation = operations[tag] {
            operation.callback = onExecute
            operation.onAfter = onAfter
            lock.unlock()
            return true
        }

        let timer = DispatchSource.makeTimerSource(queue: queue)
        let operation = Operation(timer: timer)

        timer.schedule(deadline: .now() + duration, repeating: duration)
        timer.setEventHandler {
            lock.lock()
            guard let current = operations[tag] else {
                lock.unlock()
                return
            }

            if let callback = current.callback {
                let after = current.onAfter
                current.callback = nil
                current.onAfter = nil
                lock.unlock()
                callback()
                after?()
            } else {
                current.timer.cancel()
                operations.removeValue(forKey: tag)
                lock.unlock()
                onAfter?()
            }
        }

        operations[tag] = operation
        timer.resume()
        lock.unlock()

        queue.async(execute: onExecute)
        return false
    }

    /// 取消指定 tag 的速率限制操作。
    public static func cancel(tag: String) {
        lock.lock()
        defer { lock.unlock() }
        operations[tag]?.timer.cancel()
        operations.removeValue(forKey: tag)
    }

    /// 取消所有速率限制操作。
    public static func cancelAll() {
        lock.lock()
        defer { lock.unlock() }
        operations.values.forEach { $0.timer.cancel() }
        operations.removeAll()
    }

    /// 当前进行中的速率限制操作数量。
    public static var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return operations.count
    }
}
