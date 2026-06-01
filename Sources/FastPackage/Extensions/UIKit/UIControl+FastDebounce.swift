import UIKit

public extension UIControl {
    /// 为控件添加防抖事件（基于 `UIAction`，适用于按钮等 `UIControl` 子类）。
    ///
    /// 典型场景：连续快速点击时，仅在停止点击后执行最后一次。
    ///
    /// ```swift
    /// button.addDebouncedAction(duration: 0.5) { control in
    ///     print("debounced tap")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - duration: 防抖延迟（秒）。
    ///   - event: 触发事件，默认 `.touchUpInside`。
    ///   - identifier: 自定义标识；同一控件可凭此注册多个防抖动作。
    ///   - handler: 防抖结束后执行的回调，参数为当前控件。
    /// - Returns: 已注册的 `UIAction`，可用于后续移除。
    @discardableResult
    func addDebouncedAction(
        duration: TimeInterval,
        for event: UIControl.Event = .touchUpInside,
        identifier: String? = nil,
        handler: @escaping (UIControl) -> Void
    ) -> UIAction {
        let tag = FastPackageUIKitTag.control(self, event: event, kind: "debounce", identifier: identifier)
        let action = UIAction(identifier: UIAction.Identifier(tag)) { [weak self] _ in
            guard let self else { return }
            FastDebounce.debounce(tag: tag, duration: duration) {
                handler(self)
            }
        }
        addAction(action, for: event)
        return action
    }

    /// 取消该控件上指定事件的防抖等待。
    func cancelDebouncedAction(
        for event: UIControl.Event = .touchUpInside,
        identifier: String? = nil
    ) {
        let tag = FastPackageUIKitTag.control(self, event: event, kind: "debounce", identifier: identifier)
        FastDebounce.cancel(tag: tag)
    }

    /// 移除该控件上指定事件的防抖动作，并取消未执行的回调。
    func removeDebouncedAction(
        for event: UIControl.Event = .touchUpInside,
        identifier: String? = nil
    ) {
        let tag = FastPackageUIKitTag.control(self, event: event, kind: "debounce", identifier: identifier)
        FastDebounce.cancel(tag: tag)
        removeAction(identifiedBy: UIAction.Identifier(tag), for: event)
    }
}

public extension UIButton {
    /// 为按钮添加防抖点击（`.touchUpInside`）的便捷方法。
    @discardableResult
    func addDebouncedTap(
        duration: TimeInterval,
        identifier: String? = nil,
        handler: @escaping (UIButton) -> Void
    ) -> UIAction {
        addDebouncedAction(duration: duration, for: .touchUpInside, identifier: identifier) { control in
            guard let button = control as? UIButton else { return }
            handler(button)
        }
    }
}
