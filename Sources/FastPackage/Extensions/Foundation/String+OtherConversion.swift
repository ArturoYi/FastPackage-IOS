import Foundation

// MARK: - 字符串其他转换

public extension String {

    // MARK: UTF-8 Data

    /// 将字符串编码为 UTF-8 `Data`。
    ///
    /// ```swift
    /// "hello".utf8Data  // Optional(Data([0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    /// ```
    var utf8Data: Data? {
        data(using: .utf8)
    }

    // MARK: URL

    /// 根据字符串创建 `URL`。
    ///
    /// ```swift
    /// "https://example.com".url  // Optional(URL)
    /// "not a url".url            // nil
    /// ```
    var url: URL? {
        URL(string: self)
    }

    // MARK: NSString

    /// 桥接到 `NSString`。
    ///
    /// ```swift
    /// "hello".nsString  // NSString
    /// ```
    var nsString: NSString {
        self as NSString
    }

    // MARK: Characters

    /// 将字符串转换为 `[Character]` 数组。
    ///
    /// ```swift
    /// "abc".characters  // ["a", "b", "c"]
    /// "".characters     // []
    /// ```
    var characters: [Character] {
        Array(self)
    }
}
