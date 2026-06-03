import Foundation

/// 空安全相关错误。
public enum NullSafeError: Error, Equatable, LocalizedError {
    case nullValue(message: String)

    public var errorDescription: String? {
        switch self {
        case let .nullValue(message):
            return message
        }
    }
}

// MARK: - String

public extension Optional where Wrapped == String {
    /// 为 `nil` 时返回空字符串。
    var nullSafeOrEmpty: String { self ?? "" }

    /// 为 `nil` 时返回指定默认值，若未指定则返回空字符串。
    func nullSafe(_ value: String? = nil) -> String {
        self ?? value ?? ""
    }

    /// 为 `nil` 时抛出错误。
    func nullSafeThrow(message: String = "String value should not be null") throws -> String {
        guard let self else {
            throw NullSafeError.nullValue(message: message)
        }
        return self
    }

    /// 是否为 `nil` 或空字符串。
    var isNullOrEmpty: Bool {
        guard let self else { return true }
        return self.isEmpty
    }
}

// MARK: - Bool

public extension Optional where Wrapped == Bool {
    /// 为 `nil` 时返回 `false`。
    var nullSafeOrFalse: Bool { self ?? false }

    /// 为 `nil` 时返回 `true`。
    var nullSafeOrTrue: Bool { self ?? true }

    /// 为 `nil` 时返回指定默认值，若未指定则返回 `false`。
    func nullSafe(_ value: Bool? = nil) -> Bool {
        self ?? value ?? false
    }

    /// 为 `nil` 时抛出错误。
    func nullSafeThrow(message: String = "Bool value should not be null") throws -> Bool {
        guard let self else {
            throw NullSafeError.nullValue(message: message)
        }
        return self
    }
}

// MARK: - BinaryInteger

public extension Optional where Wrapped: BinaryInteger {
    /// 为 `nil` 时返回 `0`。
    var nullSafeOrZero: Wrapped { self ?? 0 }

    /// 为 `nil` 时返回指定默认值，若未指定则返回 `0`。
    func nullSafe(_ value: Wrapped? = nil) -> Wrapped {
        self ?? value ?? 0
    }

    /// 为 `nil` 时抛出错误。
    func nullSafeThrow(message: String = "Value should not be null") throws -> Wrapped {
        guard let self else {
            throw NullSafeError.nullValue(message: message)
        }
        return self
    }
}

// MARK: - FloatingPoint

public extension Optional where Wrapped: FloatingPoint {
    /// 为 `nil` 时返回 `0`。
    var nullSafeOrZero: Wrapped { self ?? 0 }

    /// 为 `nil` 时返回指定默认值，若未指定则返回 `0`。
    func nullSafe(_ value: Wrapped? = nil) -> Wrapped {
        self ?? value ?? 0
    }

    /// 为 `nil` 时抛出错误。
    func nullSafeThrow(message: String = "Value should not be null") throws -> Wrapped {
        guard let self else {
            throw NullSafeError.nullValue(message: message)
        }
        return self
    }
}
