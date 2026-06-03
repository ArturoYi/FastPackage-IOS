import Foundation

// MARK: - 字符串搜索操作

public extension String {

    // MARK: Contains

    /// 检查字符串是否包含指定的子字符串。
    ///
    /// - Parameters:
    ///   - substring: 要搜索的子字符串。
    ///   - caseSensitive: 是否区分大小写，默认为 `true`。
    /// - Returns: 是否包含。
    ///
    /// ```swift
    /// "Hello World".contains("world")                     // false
    /// "Hello World".contains("world", caseSensitive: false) // true
    /// "".contains("a")                                    // false
    /// ```
    func contains(_ substring: String, caseSensitive: Bool = true) -> Bool {
        if caseSensitive {
            return range(of: substring) != nil
        } else {
            return range(of: substring, options: .caseInsensitive) != nil
        }
    }

    // MARK: Count of Occurrences

    /// 统计子字符串在字符串中出现的次数。
    ///
    /// - Parameters:
    ///   - substring: 要统计的子字符串。
    ///   - caseSensitive: 是否区分大小写，默认为 `true`。
    /// - Returns: 出现次数。
    ///
    /// ```swift
    /// "hello hello".count(of: "hello")  // 2
    /// "aaa".count(of: "aa")             // 1
    /// "".count(of: "a")                 // 0
    /// ```
    func count(of substring: String, caseSensitive: Bool = true) -> Int {
        guard !isEmpty, !substring.isEmpty else { return 0 }
        var count = 0
        var searchRange = startIndex..<endIndex
        let options: NSString.CompareOptions = caseSensitive ? [] : .caseInsensitive

        while let foundRange = range(of: substring, options: options, range: searchRange) {
            count += 1
            searchRange = foundRange.upperBound..<endIndex
        }
        return count
    }

    // MARK: Starts With

    /// 检查字符串是否以指定前缀开头。
    ///
    /// - Parameters:
    ///   - prefix: 前缀字符串。
    ///   - caseSensitive: 是否区分大小写，默认为 `true`。
    /// - Returns: 是否以该前缀开头。
    ///
    /// ```swift
    /// "Hello World".starts(with: "hello")                     // false
    /// "Hello World".starts(with: "hello", caseSensitive: false) // true
    /// ```
    func starts(with prefix: String, caseSensitive: Bool = true) -> Bool {
        guard !prefix.isEmpty else { return true }
        guard count >= prefix.count else { return false }

        let end = index(startIndex, offsetBy: prefix.count)
        let start = self[startIndex..<end]
        return caseSensitive ? (start == prefix) : (start.caseInsensitiveCompare(prefix) == .orderedSame)
    }

    // MARK: Ends With

    /// 检查字符串是否以指定后缀结尾。
    ///
    /// - Parameters:
    ///   - suffix: 后缀字符串。
    ///   - caseSensitive: 是否区分大小写，默认为 `true`。
    /// - Returns: 是否以该后缀结尾。
    ///
    /// ```swift
    /// "Hello World".ends(with: "world")                     // false
    /// "Hello World".ends(with: "world", caseSensitive: false) // true
    /// ```
    func ends(with suffix: String, caseSensitive: Bool = true) -> Bool {
        guard !suffix.isEmpty else { return true }
        guard count >= suffix.count else { return false }

        let start = index(endIndex, offsetBy: -suffix.count)
        let end = self[start..<endIndex]
        return caseSensitive ? (end == suffix) : (end.caseInsensitiveCompare(suffix) == .orderedSame)
    }

    // MARK: Matches (Pattern)

    /// 使用正则表达式模式检查字符串是否匹配。
    ///
    /// - Parameter pattern: 正则表达式模式字符串。
    /// - Returns: 是否匹配。
    ///
    /// ```swift
    /// "abc123".matches(pattern: "^[a-z]+\\d+$")  // true
    /// "abc".matches(pattern: "^[a-z]+\\d+$")     // false
    /// ```
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    // MARK: Matches (Regex)

    /// 使用 `NSRegularExpression` 对象检查字符串是否匹配。
    ///
    /// - Parameters:
    ///   - regex: `NSRegularExpression` 对象。
    ///   - options: 匹配选项，默认为空。
    /// - Returns: 是否匹配。
    ///
    /// ```swift
    /// let regex = try! NSRegularExpression(pattern: "^[a-z]+\\d+$")
    /// "abc123".matches(regex: regex)  // true
    /// ```
    func matches(regex: NSRegularExpression, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: options, range: range) != nil
    }
}
