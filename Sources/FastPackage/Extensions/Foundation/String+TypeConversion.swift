import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

// MARK: - 字符串类型转换

public extension String {

    // MARK: Bool

    /// 将字符串解析为 `Bool` 值。
    ///
    /// 支持以下字符串形式：
    /// - `"true"` / `"false"`（不区分大小写）
    /// - `"1"` / `"0"`
    ///
    /// ```swift
    /// "true".bool     // Optional(true)
    /// "1".bool        // Optional(true)
    /// "false".bool    // Optional(false)
    /// "abc".bool      // nil
    /// ```
    var bool: Bool? {
        switch lowercased() {
        case "true", "1": return true
        case "false", "0": return false
        default: return nil
        }
    }

    // MARK: Int

    /// 将字符串转换为 `Int` 值。
    ///
    /// ```swift
    /// "42".int        // Optional(42)
    /// "-7".int        // Optional(-7)
    /// "3.14".int      // nil
    /// "abc".int       // nil
    /// ```
    var int: Int? {
        Int(self)
    }

    // MARK: Float

    /// 将字符串转换为 `Float` 值，支持本地化格式。
    ///
    /// 默认使用当前区域设置解析，可指定自定义 `Locale`。
    ///
    /// ```swift
    /// "3.14".float()              // Optional(3.14)
    /// "3,14".float(locale: Locale(identifier: "fr_FR"))  // Optional(3.14)
    /// "abc".float()               // nil
    /// ```
    func float(locale: Locale = .current) -> Float? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.number(from: self)?.floatValue
    }

    // MARK: Double

    /// 将字符串转换为 `Double` 值，支持本地化格式。
    ///
    /// 默认使用当前区域设置解析，可指定自定义 `Locale`。
    ///
    /// ```swift
    /// "3.14159".double()              // Optional(3.14159)
    /// "3,14159".double(locale: Locale(identifier: "fr_FR"))  // Optional(3.14159)
    /// "abc".double()                  // nil
    /// ```
    func double(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        return formatter.number(from: self)?.doubleValue
    }

    // MARK: CGFloat

    /// 将字符串转换为 `CGFloat` 值，支持本地化格式。
    ///
    /// 默认使用当前区域设置解析，可指定自定义 `Locale`。
    ///
    /// - Note: 仅在 Apple 平台可用（`import CoreGraphics`）。
    ///
    /// ```swift
    /// "3.14".cgFloat()              // Optional(3.14)
    /// "3,14".cgFloat(locale: Locale(identifier: "fr_FR"))  // Optional(3.14)
    /// "abc".cgFloat()               // nil
    /// ```
    #if canImport(CoreGraphics)
    func cgFloat(locale: Locale = .current) -> CGFloat? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        guard let number = formatter.number(from: self) else { return nil }
        return CGFloat(number.doubleValue)
    }
    #endif
}
