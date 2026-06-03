import Foundation

// MARK: - 字符串文本处理

public extension String {

    // MARK: Camel Case

    /// 将字符串转换为驼峰式（camelCase）。
    ///
    /// 空格、下划线、连字符分隔的单词会被合并，首字母小写，后续单词首字母大写。
    ///
    /// ```swift
    /// "hello test".camelCased       // "helloTest"
    /// "Hello_test-world".camelCased // "helloTestWorld"
    /// "  ABC  ".camelCased          // "abc"
    /// ```
    var camelCased: String {
        guard !isEmpty else { return "" }

        let components = self
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        guard let first = components.first else { return "" }

        let head = first.lowercased()
        let tail = components.dropFirst().map { $0.capitalized }
        return ([head] + tail).joined()
    }

    // MARK: Latinized

    /// 移除变音符号，将字符串转换为拉丁字母形式。
    ///
    /// 通过 `StringTransform` 将带重音、变音符号的字符转换为基本拉丁字母。
    ///
    /// ```swift
    /// "Hëllö".latinized  // "Hello"
    /// "café".latinized   // "cafe"
    /// "こんにちは".latinized  // "konnitiha"
    /// ```
    var latinized: String {
        applyingTransform(.stripDiacritics, reverse: false) ?? self
    }

    // MARK: Trimmed

    /// 删除首尾的空格和换行符。
    ///
    /// ```swift
    /// "  hello  ".trimmed       // "hello"
    /// "\n  test \n".trimmed     // "test"
    /// ```
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Without Spaces and New Lines

    /// 删除字符串中所有的空格和换行符。
    ///
    /// ```swift
    /// " he llo ".withoutSpacesAndNewLines  // "hello"
    /// "a\nb\tc".withoutSpacesAndNewLines   // "abc"
    /// ```
    var withoutSpacesAndNewLines: String {
        components(separatedBy: .whitespacesAndNewlines).joined()
    }

    // MARK: Regex Escaped

    /// 转义字符串中的正则表达式特殊字符。
    ///
    /// 对 `^ $ \ . * + ? ( ) [ ] { } |` 等正则元字符进行转义，
    /// 使字符串可作为正则表达式字面量安全使用。
    ///
    /// ```swift
    /// "hello ^$".regexEscaped  // "hello \\^\\$"
    /// "a.b".regexEscaped       // "a\\.b"
    /// ```
    var regexEscaped: String {
        NSRegularExpression.escapedPattern(for: self)
    }
}
