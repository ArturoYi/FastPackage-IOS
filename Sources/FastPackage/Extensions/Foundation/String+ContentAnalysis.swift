import Foundation

// MARK: - 字符串内容分析与查询

public extension String {

    // MARK: Lines

    /// 将字符串按换行符拆分为行数组。
    ///
    /// 换行符支持 `\n`、`\r\n`、`\r`。
    ///
    /// ```swift
    /// "line1\nline2\r\nline3".lines()  // ["line1", "line2", "line3"]
    /// "hello".lines()                   // ["hello"]
    /// "".lines()                        // []
    /// ```
    func lines() -> [String] {
        guard !isEmpty else { return [] }
        // 先统一处理 \r\n 为 \n，避免 components(separatedBy:) 在 \r 和 \n 之间产生空元素
        let normalized = replacingOccurrences(of: "\r\n", with: "\n")
        return normalized.components(separatedBy: CharacterSet.newlines)
    }

    // MARK: Words

    /// 将字符串按空格和标点符号拆分为单词数组。
    ///
    /// ```swift
    /// "hello world".words()         // ["hello", "world"]
    /// "hello, world!".words()       // ["hello", "world"]
    /// "".words()                    // []
    /// ```
    func words() -> [String] {
        guard !isEmpty else { return [] }
        var result: [String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: [.byWords, .localized]) { substring, _, _, _ in
            if let word = substring {
                result.append(word)
            }
        }
        return result
    }

    // MARK: Word Count

    /// 返回单词数量。
    ///
    /// ```swift
    /// "hello world".wordCount()  // 2
    /// "hello, world!".wordCount()  // 2
    /// "".wordCount()             // 0
    /// ```
    func wordCount() -> Int {
        words().count
    }

    // MARK: Unicode Array

    /// 返回字符串中每个字符的 Unicode 标量值数组。
    ///
    /// ```swift
    /// "abc".unicodeArray()  // [97, 98, 99]
    /// "你好".unicodeArray()  // [20320, 22909]
    /// "".unicodeArray()     // []
    /// ```
    func unicodeArray() -> [Int] {
        unicodeScalars.map { Int($0.value) }
    }
}
