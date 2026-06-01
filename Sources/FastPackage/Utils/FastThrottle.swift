import Foundation

/// 节流工具：在指定时间窗口内，同一 tag 最多执行一次。
///
/// 参考 [fast_package](https://github.com/ArturoYi/fast_package) 的 `FastThrottle` 设计。
public enum FastThrottle {
    private struct Operation {
        let onExecute: () -> Void
        let onAfter: (() -> Void)?
        let workItem: DispatchWorkItem
    }

    private static var operations: [String: Operation] = [:]
    private static let lock = NSLock()

    /// 执行节流逻辑。
    ///
    /// - Parameters:
    ///   - tag: 节流操作的唯一标识。
    ///   - duration: 节流时间窗口（秒）。
    ///   - queue: 回调执行队列，默认主队列。
    ///   - onExecute: 节流开始时立即执行的回调。
    ///   - onAfter: 节流窗口结束后可选执行的回调。
    /// - Returns: 若当前 tag 正在节流中返回 `true`，否则返回 `false` 并开始新的节流。
    @discardableResult
    public static func throttle(
        tag: String,
        duration: TimeInterval,
        queue: DispatchQueue = .main,
        onExecute: @escaping () -> Void,
        onAfter: (() -> Void)? = nil
    ) -> Bool {
        lock.lock()
        if operations[tag] != nil {
            lock.unlock()
            return true
        }

        let workItem = DispatchWorkItem {
            lock.lock()
            defer { lock.unlock() }
            let removed = operations.removeValue(forKey: tag)
            removed?.onAfter?()
        }

        operations[tag] = Operation(onExecute: onExecute, onAfter: onAfter, workItem: workItem)
        lock.unlock()

        queue.async(execute: onExecute)
        queue.asyncAfter(deadline: .now() + duration, execute: workItem)
        return false
    }

    /// 取消指定 tag 的节流操作。
    public static func cancel(tag: String) {
        lock.lock()
        defer { lock.unlock() }
        operations[tag]?.workItem.cancel()
        operations.removeValue(forKey: tag)
    }

    /// 取消所有节流操作。
    public static func cancelAll() {
        lock.lock()
        defer { lock.unlock() }
        operations.values.forEach { $0.workItem.cancel() }
        operations.removeAll()
    }

    /// 当前进行中的节流操作数量。
    public static var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return operations.count
    }
}
