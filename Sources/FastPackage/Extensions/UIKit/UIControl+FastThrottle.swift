import UIKit

public extension UIControl {
    /// 为控件添加节流事件（基于 `UIAction`，适用于按钮等 `UIControl` 子类）。
    ///
    /// 典型场景：防止按钮重复提交，时间窗口内仅首次点击生效。
    ///
    /// ```swift
    /// button.addThrottledAction(duration: 1.0) { control in
    ///     submitForm()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - duration: 节流窗口（秒）。
    ///   - event: 触发事件，默认 `.touchUpInside`。
    ///   - identifier: 自定义标识；同一控件可凭此注册多个节流动作。
    ///   - onExecute: 节流窗口内首次触发时执行的回调。
    ///   - onAfter: 节流窗口结束后的可选回调。
    /// - Returns: 已注册的 `UIAction`，可用于后续移除。
    @discardableResult
    func addThrottledAction(
        duration: TimeInterval,
        for event: UIControl.Event = .touchUpInside,
        identifier: String? = nil,
        onExecute: @escaping (UIControl) -> Void,
        onAfter: ((UIControl) -> Void)? = nil
    ) -> UIAction {
        let tag = FastPackageUIKitTag.control(self, event: event, kind: "throttle", identifier: identifier)
        let action = UIAction(identifier: UIAction.Identifier(tag)) { [weak self] _ in
            guard let self else { return }
            FastThrottle.throttle(tag: tag, duration: duration, onExecute: {
                onExecute(self)
            }, onAfter: {
                onAfter?(self)
            })
        }
        addAction(action, for: event)
        return action
    }

    /// 取消该控件上指定事件的节流状态。
    func cancelThrottledAction(
        for event: UIControl.Event = .touchUpInside,
        identifier: String? = nil
    ) {
        let tag = FastPackageUIKitTag.control(self, event: event, kind: "throttle", identifier: identifier)
        FastThrottle.cancel(tag: tag)
    }

    /// 移除该控件上指定事件的节流动作，并重置节流状态。
    func removeThrottledAction(
        for event: UIControl.Event = .touchUpInside,
        identifier: String? = nil
    ) {
        let tag = FastPackageUIKitTag.control(self, event: event, kind: "throttle", identifier: identifier)
        FastThrottle.cancel(tag: tag)
        removeAction(identifiedBy: UIAction.Identifier(tag), for: event)
    }
}

public extension UIButton {
    /// 为按钮添加节流点击（`.touchUpInside`）的便捷方法。
    @discardableResult
    func addThrottledTap(
        duration: TimeInterval,
        identifier: String? = nil,
        onExecute: @escaping (UIButton) -> Void,
        onAfter: ((UIButton) -> Void)? = nil
    ) -> UIAction {
        addThrottledAction(duration: duration, for: .touchUpInside, identifier: identifier, onExecute: { control in
            guard let button = control as? UIButton else { return }
            onExecute(button)
        }, onAfter: { control in
            guard let button = control as? UIButton else { return }
            onAfter?(button)
        })
    }
}
