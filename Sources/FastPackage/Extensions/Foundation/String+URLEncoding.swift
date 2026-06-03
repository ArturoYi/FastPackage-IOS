import Foundation

// MARK: - URL 编码/解码

public extension String {
    /// URL 字符串的百分比编码。
    ///
    /// 对 `String` 进行 URL Query 允许的字符集编码，保留 `alphanumerics` 以外的字符。
    /// 等价于 `addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`。
    ///
    /// ```swift
    /// "hello world".urlEncoded  // "hello%20world"
    /// "你好".urlEncoded          // "%E4%BD%A0%E5%A5%BD"
    /// ```
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }

    /// 解码百分比编码字符串。
    ///
    /// 将百分比编码的 `String` 还原为原始字符串。
    /// 等价于 `removingPercentEncoding`。
    ///
    /// ```swift
    /// "hello%20world".urlDecoded  // "hello world"
    /// "%E4%BD%A0%E5%A5%BD".urlDecoded  // "你好"
    /// ```
    var urlDecoded: String {
        removingPercentEncoding ?? self
    }
}
