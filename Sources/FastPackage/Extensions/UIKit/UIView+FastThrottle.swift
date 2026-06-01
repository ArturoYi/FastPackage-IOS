import UIKit

public extension UIView {
    /// 为视图添加节流点击手势。
    ///
    /// 适用于列表 Cell、卡片等需要防止连续点击的场景。
    ///
    /// ```swift
    /// cellContentView.addThrottledTapGesture(duration: 1.0) { view in
    ///     onItemSelected()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - duration: 节流窗口（秒）。
    ///   - numberOfTapsRequired: 点击次数，默认 `1`。
    ///   - identifier: 自定义标识，默认可在同一视图上区分多个手势。
    ///   - isUserInteractionEnabled: 是否自动开启用户交互，默认 `true`。
    ///   - onExecute: 节流窗口内首次点击执行的回调。
    ///   - onAfter: 节流窗口结束后的可选回调。
    /// - Returns: 已添加的手势识别器。
    @discardableResult
    func addThrottledTapGesture(
        duration: TimeInterval,
        numberOfTapsRequired: Int = 1,
        identifier: String? = nil,
        isUserInteractionEnabled: Bool = true,
        onExecute: @escaping (UIView) -> Void,
        onAfter: ((UIView) -> Void)? = nil
    ) -> UITapGestureRecognizer {
        let storageKey = identifier ?? "default"
        let tag = FastPackageUIKitTag.view(self, kind: "throttle", identifier: identifier)

        if let existing = FastPackageAssociatedStorage.tapGesture(for: self, identifier: storageKey) {
            removeGestureRecognizer(existing)
        }

        if isUserInteractionEnabled {
            self.isUserInteractionEnabled = true
        }

        let gesture = FastPackageTapGestureFactory.make(numberOfTapsRequired: numberOfTapsRequired) { [weak self] _ in
            guard let self else { return }
            FastThrottle.throttle(tag: tag, duration: duration, onExecute: {
                onExecute(self)
            }, onAfter: {
                onAfter?(self)
            })
        }
        addGestureRecognizer(gesture)
        FastPackageAssociatedStorage.setTapGesture(gesture, on: self, identifier: storageKey)
        return gesture
    }

    /// 取消该视图上节流点击手势的状态。
    func cancelThrottledTapGesture(identifier: String? = nil) {
        let tag = FastPackageUIKitTag.view(self, kind: "throttle", identifier: identifier)
        FastThrottle.cancel(tag: tag)
    }

    /// 移除该视图上的节流点击手势，并重置节流状态。
    func removeThrottledTapGesture(identifier: String? = nil) {
        let storageKey = identifier ?? "default"
        let tag = FastPackageUIKitTag.view(self, kind: "throttle", identifier: identifier)
        FastThrottle.cancel(tag: tag)
        if let gesture = FastPackageAssociatedStorage.tapGesture(for: self, identifier: storageKey) {
            removeGestureRecognizer(gesture)
            FastPackageAssociatedStorage.removeTapGesture(on: self, identifier: storageKey)
        }
    }
}
