import Foundation

// MARK: - 字符串验证

public extension String {

    // MARK: Email

    /// 验证字符串是否为有效的电子邮件地址。
    ///
    /// 正则表达式遵循 RFC 标准，支持：
    /// - 标准格式（`user@domain.com`）
    /// - 子域名（`user@subdomain.domain.com`）
    /// - 加号地址（`user+tag@domain.com`）
    /// - IP 域名（`user@[123.123.123.123]`）
    /// - 引号本地部分（`"user"@domain.com`）
    ///
    /// ```swift
    /// "test@example.com".isValidEmail     // true
    /// "user+tag@sub.domain.com".isValidEmail  // true
    /// "not-an-email".isValidEmail         // false
    /// ```
    var isValidEmail: Bool {
        guard !isEmpty else { return false }

        let pattern = #"^(?:[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }

        let range = NSRange(location: 0, length: utf16.count)
        let match = regex.firstMatch(in: self, options: [], range: range)
        return match != nil && match!.range.length == utf16.count
    }

    // MARK: URL

    /// 验证字符串是否为任意有效 URL（可带或不带协议）。
    ///
    /// ```swift
    /// "https://example.com".isValidUrl  // true
    /// "example.com".isValidUrl          // true
    /// "not a url".isValidUrl            // false
    /// ```
    var isValidUrl: Bool {
        guard !isEmpty else { return false }

        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(location: 0, length: utf16.count)
        guard let match = detector?.firstMatch(in: self, options: [], range: range) else {
            return false
        }
        return match.range.length == utf16.count
    }

    /// 验证字符串是否为带有明确协议的 URL（如 `http://`、`ftp://` 等）。
    ///
    /// ```swift
    /// "https://example.com".isValidSchemedUrl  // true
    /// "ftp://files.example.com".isValidSchemedUrl  // true
    /// "example.com".isValidSchemedUrl          // false
    /// ```
    var isValidSchemedUrl: Bool {
        guard isValidUrl, let url = URL(string: self) else { return false }
        return url.scheme != nil
    }

    /// 验证字符串是否为仅 HTTPS 协议的 URL。
    ///
    /// ```swift
    /// "https://example.com".isValidHttpsUrl  // true
    /// "http://example.com".isValidHttpsUrl   // false
    /// ```
    var isValidHttpsUrl: Bool {
        guard isValidUrl, let url = URL(string: self) else { return false }
        return url.scheme?.lowercased() == "https"
    }

    /// 验证字符串是否为仅 HTTP 协议的 URL。
    ///
    /// ```swift
    /// "http://example.com".isValidHttpUrl  // true
    /// "https://example.com".isValidHttpUrl // false
    /// ```
    var isValidHttpUrl: Bool {
        guard isValidUrl, let url = URL(string: self) else { return false }
        return url.scheme?.lowercased() == "http"
    }

    /// 验证字符串是否为文件 URL（`file://` 协议）。
    ///
    /// ```swift
    /// "file:///path/to/file".isValidFileUrl  // true
    /// "https://example.com".isValidFileUrl   // false
    /// ```
    var isValidFileUrl: Bool {
        guard isValidUrl, let url = URL(string: self) else { return false }
        return url.isFileURL
    }
}
