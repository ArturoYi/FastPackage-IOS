import UIKit

public extension UIView {
    /// 为视图添加防抖点击手势。
    ///
    /// 适用于卡片、列表 Cell、自定义可点击区域等任意 `UIView`。
    ///
    /// ```swift
    /// cardView.addDebouncedTapGesture(duration: 0.3) { view in
    ///     navigateToDetail()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - duration: 防抖延迟（秒）。
    ///   - numberOfTapsRequired: 点击次数，默认 `1`。
    ///   - identifier: 自定义标识，默认可在同一视图上区分多个手势。
    ///   - isUserInteractionEnabled: 是否自动开启用户交互，默认 `true`。
    ///   - handler: 防抖结束后执行的回调。
    /// - Returns: 已添加的手势识别器。
    @discardableResult
    func addDebouncedTapGesture(
        duration: TimeInterval,
        numberOfTapsRequired: Int = 1,
        identifier: String? = nil,
        isUserInteractionEnabled: Bool = true,
        handler: @escaping (UIView) -> Void
    ) -> UITapGestureRecognizer {
        let storageKey = identifier ?? "default"
        let tag = FastPackageUIKitTag.view(self, kind: "debounce", identifier: identifier)

        if let existing = FastPackageAssociatedStorage.tapGesture(for: self, identifier: storageKey) {
            removeGestureRecognizer(existing)
        }

        if isUserInteractionEnabled {
            self.isUserInteractionEnabled = true
        }

        let gesture = FastPackageTapGestureFactory.make(numberOfTapsRequired: numberOfTapsRequired) { [weak self] _ in
            guard let self else { return }
            FastDebounce.debounce(tag: tag, duration: duration) {
                handler(self)
            }
        }
        addGestureRecognizer(gesture)
        FastPackageAssociatedStorage.setTapGesture(gesture, on: self, identifier: storageKey)
        return gesture
    }

    /// 取消该视图上防抖点击手势的等待。
    func cancelDebouncedTapGesture(identifier: String? = nil) {
        let tag = FastPackageUIKitTag.view(self, kind: "debounce", identifier: identifier)
        FastDebounce.cancel(tag: tag)
    }

    /// 移除该视图上的防抖点击手势，并取消未执行的回调。
    func removeDebouncedTapGesture(identifier: String? = nil) {
        let storageKey = identifier ?? "default"
        let tag = FastPackageUIKitTag.view(self, kind: "debounce", identifier: identifier)
        FastDebounce.cancel(tag: tag)
        if let gesture = FastPackageAssociatedStorage.tapGesture(for: self, identifier: storageKey) {
            removeGestureRecognizer(gesture)
            FastPackageAssociatedStorage.removeTapGesture(on: self, identifier: storageKey)
        }
    }
}
