import Foundation

// MARK: - 字符串前缀/后缀、切片与 NSRange 转换

public extension String {

    // MARK: Prefix / Suffix Operations

    /// 返回不带指定前缀的新字符串。如果前缀不存在，返回原字符串。
    ///
    /// ```swift
    /// "prefixHello".removingPrefix("prefix")  // "Hello"
    /// "Hello".removingPrefix("prefix")        // "Hello"
    /// "".removingPrefix("prefix")             // ""
    /// ```
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// 返回不带指定后缀的新字符串。如果后缀不存在，返回原字符串。
    ///
    /// ```swift
    /// "HelloSuffix".removingSuffix("Suffix")  // "Hello"
    /// "Hello".removingSuffix("Suffix")        // "Hello"
    /// "".removingSuffix("Suffix")             // ""
    /// ```
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    /// 如果前缀不存在，则添加前缀。如果已存在，返回原字符串。
    ///
    /// ```swift
    /// "Hello".withPrefix("Mr. ")  // "Mr. Hello"
    /// "Mr. Hello".withPrefix("Mr. ")  // "Mr. Hello"
    /// ```
    func withPrefix(_ prefix: String) -> String {
        hasPrefix(prefix) ? self : prefix + self
    }

    /// 如果后缀不存在，则添加后缀。如果已存在，返回原字符串。
    ///
    /// ```swift
    /// "Hello".withSuffix(".jpg")  // "Hello.jpg"
    /// "Hello.jpg".withSuffix(".jpg")  // "Hello.jpg"
    /// ```
    func withSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? self : self + suffix
    }

    // MARK: Slice Operations

    /// 从指定索引开始提取指定长度的子字符串（非变异）。
    ///
    /// - Parameters:
    ///   - index: 起始索引（0-based）。超出范围或长度为 0 时返回空字符串。
    ///   - length: 子字符串长度。
    /// - Returns: 提取的子字符串。
    ///
    /// ```swift
    /// "Hello World".slicing(from: 0, length: 5)   // "Hello"
    /// "Hello".slicing(from: 1, length: 3)         // "ell"
    /// "Hello".slicing(from: 10, length: 2)        // ""
    /// ```
    func slicing(from index: Int, length: Int) -> String {
        guard index >= 0, length > 0, index < count else { return "" }
        let start = self.index(startIndex, offsetBy: index, limitedBy: endIndex) ?? endIndex
        let end = self.index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
        return String(self[start..<end])
    }

    /// 从指定索引开始提取指定长度的子字符串（变异版本）。
    ///
    /// - Parameters:
    ///   - index: 起始索引（0-based）。超出范围或长度为 0 时清空字符串。
    ///   - length: 子字符串长度。
    ///
    /// ```swift
    /// var s = "Hello World"
    /// s.slice(from: 0, length: 5)  // s == "Hello"
    /// ```
    mutating func slice(from index: Int, length: Int) {
        self = slicing(from: index, length: length)
    }

    /// 从 `start` 索引提取到 `end` 索引之间的子字符串（变异版本）。
    ///
    /// - Parameters:
    ///   - start: 起始索引（0-based，包含）。
    ///   - end: 结束索引（0-based，不包含）。
    ///
    /// ```swift
    /// var s = "Hello World"
    /// s.slice(from: 0, to: 5)  // s == "Hello"
    /// ```
    mutating func slice(from start: Int, to end: Int) {
        guard start >= 0, end >= start else {
            self = ""
            return
        }
        let length = end - start
        self = slicing(from: start, length: length)
    }

    /// 从指定索引处开始切片到末尾（变异版本）。
    ///
    /// - Parameter index: 起始索引（0-based）。
    ///
    /// ```swift
    /// var s = "Hello World"
    /// s.slice(at: 6)  // s == "World"
    /// ```
    mutating func slice(at index: Int) {
        guard index >= 0, index < count else {
            self = ""
            return
        }
        let start = self.index(startIndex, offsetBy: index)
        self = String(self[start..<endIndex])
    }

    // MARK: NSRange Conversion

    /// 将 `NSRange` 转换为 `Range<String.Index>`。
    ///
    /// - Parameter nsRange: 要转换的 `NSRange`。
    /// - Returns: 对应的 `Range<String.Index>`，超出范围时返回 `nil`。
    ///
    /// ```swift
    /// let nsRange = NSRange(location: 0, length: 5)
    /// "Hello".range(from: nsRange)  // Range covering "Hello"
    /// ```
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        Range(nsRange, in: self)
    }

    /// 将 `Range<String.Index>` 转换为 `NSRange`。
    ///
    /// - Parameter range: 要转换的 `Range<String.Index>`。
    /// - Returns: 对应的 `NSRange`。
    ///
    /// ```swift
    /// let range = "Hello".startIndex..<"Hello".endIndex
    /// "Hello".nsRange(from: range)  // NSRange(location: 0, length: 5)
    /// ```
    func nsRange(from range: Range<String.Index>) -> NSRange {
        NSRange(range, in: self)
    }

    /// 返回覆盖整个字符串的 `NSRange`。
    ///
    /// ```swift
    /// "Hello".fullNSRange  // NSRange(location: 0, length: 5)
    /// "".fullNSRange       // NSRange(location: 0, length: 0)
    /// ```
    var fullNSRange: NSRange {
        NSRange(location: 0, length: utf16.count)
    }
}
