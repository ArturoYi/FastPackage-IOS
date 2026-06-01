import UIKit

enum FastPackageUIKitTag {
    static func control(_ control: UIControl, event: UIControl.Event, kind: String, identifier: String?) -> String {
        if let identifier { return "fastPackage.\(kind).control.\(identifier)" }
        return "fastPackage.\(kind).control.\(ObjectIdentifier(control)).\(event.rawValue)"
    }

    static func view(_ view: UIView, kind: String, identifier: String?) -> String {
        if let identifier { return "fastPackage.\(kind).view.\(identifier)" }
        return "fastPackage.\(kind).view.\(ObjectIdentifier(view))"
    }
}

enum FastPackageAssociatedStorage {
    private static var tapGesturesKey: UInt8 = 0

    static func tapGesture(for view: UIView, identifier: String) -> UITapGestureRecognizer? {
        tapGestures(on: view)?[identifier]
    }

    static func setTapGesture(_ gesture: UITapGestureRecognizer, on view: UIView, identifier: String) {
        var gestures = tapGestures(on: view) ?? [:]
        gestures[identifier] = gesture
        objc_setAssociatedObject(
            view,
            &tapGesturesKey,
            gestures,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    static func removeTapGesture(on view: UIView, identifier: String) {
        guard var gestures = tapGestures(on: view) else { return }
        gestures.removeValue(forKey: identifier)
        objc_setAssociatedObject(
            view,
            &tapGesturesKey,
            gestures.isEmpty ? nil : gestures,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    private static func tapGestures(on view: UIView) -> [String: UITapGestureRecognizer]? {
        objc_getAssociatedObject(view, &tapGesturesKey) as? [String: UITapGestureRecognizer]
    }
}

enum FastPackageTapGestureFactory {
    static func make(
        numberOfTapsRequired: Int,
        handler: @escaping (UITapGestureRecognizer) -> Void
    ) -> UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = numberOfTapsRequired
        let target = TapGestureActionTarget(handler: handler)
        objc_setAssociatedObject(
            gesture,
            &TapGestureActionTarget.associationKey,
            target,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        gesture.addTarget(target, action: #selector(TapGestureActionTarget.invoke(_:)))
        return gesture
    }
}

private final class TapGestureActionTarget: NSObject {
    static var associationKey: UInt8 = 0

    private let handler: (UITapGestureRecognizer) -> Void

    init(handler: @escaping (UITapGestureRecognizer) -> Void) {
        self.handler = handler
    }

    @objc func invoke(_ sender: UITapGestureRecognizer) {
        handler(sender)
    }
}
