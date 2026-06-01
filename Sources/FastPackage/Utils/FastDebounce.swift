import Foundation

/// 防抖工具：在指定延迟内多次触发时，仅执行最后一次。
///
/// 参考 [fast_package](https://github.com/ArturoYi/fast_package) 的 `FastDebounce` 设计。
public enum FastDebounce {
    private struct Operation {
        let callback: () -> Void
        let workItem: DispatchWorkItem
    }

    private static var operations: [String: Operation] = [:]
    private static let lock = NSLock()

    /// 执行防抖逻辑。
    ///
    /// - Parameters:
    ///   - tag: 防抖操作的唯一标识。
    ///   - duration: 防抖延迟时间（秒）。为 `0` 时立即执行。
    ///   - queue: 回调执行队列，默认主队列。
    ///   - onExecute: 延迟结束后执行的回调。
    public static func debounce(
        tag: String,
        duration: TimeInterval,
        queue: DispatchQueue = .main,
        onExecute: @escaping () -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }

        if duration == 0 {
            operations[tag]?.workItem.cancel()
            operations.removeValue(forKey: tag)
            onExecute()
            return
        }

        operations[tag]?.workItem.cancel()
        operations.removeValue(forKey: tag)

        let workItem = DispatchWorkItem {
            lock.lock()
            defer { lock.unlock() }
            operations.removeValue(forKey: tag)
            onExecute()
        }

        operations[tag] = Operation(callback: onExecute, workItem: workItem)
        queue.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    /// 立即执行指定 tag 的回调（不会取消定时器）。
    public static func fire(tag: String, queue: DispatchQueue = .main) {
        lock.lock()
        let callback = operations[tag]?.callback
        lock.unlock()
        guard let callback else { return }
        queue.async(execute: callback)
    }

    /// 取消指定 tag 的防抖操作。
    public static func cancel(tag: String) {
        lock.lock()
        defer { lock.unlock() }
        operations[tag]?.workItem.cancel()
        operations.removeValue(forKey: tag)
    }

    /// 取消所有防抖操作。
    public static func cancelAll() {
        lock.lock()
        defer { lock.unlock() }
        operations.values.forEach { $0.workItem.cancel() }
        operations.removeAll()
    }

    /// 当前进行中的防抖操作数量。
    public static var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return operations.count
    }
}
