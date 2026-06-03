import XCTest
@testable import FastPackage

final class FastPackageTests: XCTestCase {
    func testVersionIsNonEmpty() {
        XCTAssertFalse(FastPackage.version.isEmpty)
    }
}

final class NullSafeExtensionTests: XCTestCase {
    func testStringNullSafeOrEmpty() {
        let value: String? = nil
        XCTAssertEqual(value.nullSafeOrEmpty, "")
        XCTAssertEqual(Optional("hello").nullSafeOrEmpty, "hello")
    }

    func testStringNullSafeWithDefault() {
        let value: String? = nil
        XCTAssertEqual(value.nullSafe("default"), "default")
        XCTAssertEqual(value.nullSafe(), "")
    }

    func testStringNullSafeThrow() {
        let value: String? = nil
        XCTAssertThrowsError(try value.nullSafeThrow()) { error in
            XCTAssertEqual(error as? NullSafeError, .nullValue(message: "String value should not be null"))
        }
        XCTAssertEqual(try Optional("ok").nullSafeThrow(), "ok")
    }

    func testStringIsNullOrEmpty() {
        XCTAssertTrue(Optional<String>.none.isNullOrEmpty)
        XCTAssertTrue(Optional("").isNullOrEmpty)
        XCTAssertFalse(Optional("a").isNullOrEmpty)
    }

    func testBoolNullSafe() {
        let value: Bool? = nil
        XCTAssertFalse(value.nullSafeOrFalse)
        XCTAssertTrue(value.nullSafeOrTrue)
        XCTAssertTrue(value.nullSafe(true))
        XCTAssertFalse(value.nullSafe(false))
    }

    func testIntNullSafeOrZero() {
        let value: Int? = nil
        XCTAssertEqual(value.nullSafeOrZero, 0)
        XCTAssertEqual(value.nullSafe(42), 42)
        XCTAssertEqual(try Optional(7).nullSafeThrow(), 7)
    }

    func testDoubleNullSafeOrZero() {
        let value: Double? = nil
        XCTAssertEqual(value.nullSafeOrZero, 0)
        XCTAssertEqual(value.nullSafe(3.5), 3.5)
    }
}

final class FastDebounceTests: XCTestCase {
    override func tearDown() {
        FastDebounce.cancelAll()
        super.tearDown()
    }

    func testDebounceExecutesOnlyLastCall() {
        let expectation = expectation(description: "debounce")
        expectation.expectedFulfillmentCount = 1

        var count = 0
        FastDebounce.debounce(tag: "test", duration: 0.1, queue: .global()) {
            count += 1
            expectation.fulfill()
        }
        FastDebounce.debounce(tag: "test", duration: 0.1, queue: .global()) {
            count += 1
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(count, 1)
    }

    func testDebounceZeroDurationExecutesImmediately() {
        var executed = false
        FastDebounce.debounce(tag: "zero", duration: 0, queue: .global()) {
            executed = true
        }
        XCTAssertTrue(executed)
    }

    func testDebounceCancel() {
        let expectation = expectation(description: "cancel")
        expectation.isInverted = true

        FastDebounce.debounce(tag: "cancel", duration: 0.2, queue: .global()) {
            expectation.fulfill()
        }
        FastDebounce.cancel(tag: "cancel")

        waitForExpectations(timeout: 0.5)
        XCTAssertEqual(FastDebounce.count, 0)
    }
}

final class FastThrottleTests: XCTestCase {
    override func tearDown() {
        FastThrottle.cancelAll()
        super.tearDown()
    }

    func testThrottleBlocksRepeatedCalls() {
        let expectation = expectation(description: "throttle")
        expectation.expectedFulfillmentCount = 1

        var count = 0
        XCTAssertFalse(FastThrottle.throttle(tag: "test", duration: 0.2, queue: .global()) {
            count += 1
            expectation.fulfill()
        })
        XCTAssertTrue(FastThrottle.throttle(tag: "test", duration: 0.2, queue: .global()) {
            count += 1
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1)
        XCTAssertEqual(count, 1)
    }

    func testThrottleOnAfter() {
        let executeExpectation = expectation(description: "execute")
        let afterExpectation = expectation(description: "after")

        FastThrottle.throttle(
            tag: "after",
            duration: 0.1,
            queue: .global(),
            onExecute: { executeExpectation.fulfill() },
            onAfter: { afterExpectation.fulfill() }
        )

        waitForExpectations(timeout: 1)
    }
}

final class StringURLEncodingTests: XCTestCase {
    func testUrlEncoded() {
        XCTAssertEqual("hello world".urlEncoded, "hello%20world")
        XCTAssertEqual("你好".urlEncoded, "%E4%BD%A0%E5%A5%BD")
        XCTAssertEqual("abc123".urlEncoded, "abc123")
        XCTAssertEqual("a+b=c&d".urlEncoded, "a+b=c&d")
    }

    func testUrlDecoded() {
        XCTAssertEqual("hello%20world".urlDecoded, "hello world")
        XCTAssertEqual("%E4%BD%A0%E5%A5%BD".urlDecoded, "你好")
        XCTAssertEqual("abc123".urlDecoded, "abc123")
        XCTAssertEqual("a+b%3Dc%26d".urlDecoded, "a+b=c&d")
    }

    func testUrlEncodeDecodeRoundTrip() {
        let original = "hello world 你好 test=1&a=2"
        XCTAssertEqual(original.urlEncoded.urlDecoded, original)
    }

    func testUrlEncodeEmptyString() {
        XCTAssertEqual("".urlEncoded, "")
        XCTAssertEqual("".urlDecoded, "")
    }
}

final class StringValidationTests: XCTestCase {
    // MARK: Email

    func testValidEmail() {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertTrue("user+tag@sub.domain.com".isValidEmail)
        XCTAssertTrue("user@[123.123.123.123]".isValidEmail)
        XCTAssertTrue(#""user"@domain.com"#.isValidEmail)
        XCTAssertTrue("user@domain.co.uk".isValidEmail)
    }

    func testInvalidEmail() {
        XCTAssertFalse("".isValidEmail)
        XCTAssertFalse("not-an-email".isValidEmail)
        XCTAssertFalse("@domain.com".isValidEmail)
        XCTAssertFalse("user@".isValidEmail)
        XCTAssertFalse("user@.com".isValidEmail)
        XCTAssertFalse("user @domain.com".isValidEmail)
    }

    // MARK: URL

    func testValidUrl() {
        XCTAssertTrue("https://example.com".isValidUrl)
        XCTAssertTrue("http://example.com".isValidUrl)
        XCTAssertTrue("ftp://files.example.com".isValidUrl)
        XCTAssertTrue("example.com".isValidUrl)
        XCTAssertTrue("https://sub.example.com/path?query=1".isValidUrl)
    }

    func testInvalidUrl() {
        XCTAssertFalse("".isValidUrl)
        XCTAssertFalse("not a url".isValidUrl)
        XCTAssertFalse("just text".isValidUrl)
    }

    func testValidSchemedUrl() {
        XCTAssertTrue("https://example.com".isValidSchemedUrl)
        XCTAssertTrue("http://example.com".isValidSchemedUrl)
        XCTAssertTrue("ftp://files.example.com".isValidSchemedUrl)
    }

    func testInvalidSchemedUrl() {
        XCTAssertFalse("example.com".isValidSchemedUrl)
        XCTAssertFalse("not a url".isValidSchemedUrl)
    }

    func testValidHttpsUrl() {
        XCTAssertTrue("https://example.com".isValidHttpsUrl)
        XCTAssertTrue("https://secure.example.com/path".isValidHttpsUrl)
    }

    func testInvalidHttpsUrl() {
        XCTAssertFalse("http://example.com".isValidHttpsUrl)
        XCTAssertFalse("ftp://example.com".isValidHttpsUrl)
        XCTAssertFalse("example.com".isValidHttpsUrl)
    }

    func testValidHttpUrl() {
        XCTAssertTrue("http://example.com".isValidHttpUrl)
    }

    func testInvalidHttpUrl() {
        XCTAssertFalse("https://example.com".isValidHttpUrl)
    }

    func testValidFileUrl() {
        XCTAssertTrue("file:///path/to/file".isValidFileUrl)
    }

    func testInvalidFileUrl() {
        XCTAssertFalse("https://example.com".isValidFileUrl)
        XCTAssertFalse("http://example.com".isValidFileUrl)
    }

    func testEmptyStringValidation() {
        XCTAssertFalse("".isValidEmail)
        XCTAssertFalse("".isValidUrl)
        XCTAssertFalse("".isValidSchemedUrl)
        XCTAssertFalse("".isValidHttpsUrl)
        XCTAssertFalse("".isValidHttpUrl)
        XCTAssertFalse("".isValidFileUrl)
    }
}

final class StringConversionTests: XCTestCase {
    // MARK: Bool

    func testBoolTrue() {
        XCTAssertEqual("true".bool, true)
        XCTAssertEqual("TRUE".bool, true)
        XCTAssertEqual("True".bool, true)
        XCTAssertEqual("1".bool, true)
    }

    func testBoolFalse() {
        XCTAssertEqual("false".bool, false)
        XCTAssertEqual("FALSE".bool, false)
        XCTAssertEqual("False".bool, false)
        XCTAssertEqual("0".bool, false)
    }

    func testBoolInvalid() {
        XCTAssertNil("".bool)
        XCTAssertNil("abc".bool)
        XCTAssertNil("yes".bool)
        XCTAssertNil("no".bool)
        XCTAssertNil("2".bool)
    }

    // MARK: Int

    func testIntValid() {
        XCTAssertEqual("42".int, 42)
        XCTAssertEqual("-7".int, -7)
        XCTAssertEqual("0".int, 0)
    }

    func testIntInvalid() {
        XCTAssertNil("3.14".int)
        XCTAssertNil("abc".int)
        XCTAssertNil("".int)
    }

    // MARK: Float

    func testFloatValid() {
        let val1: Float? = "3.14".float()
        XCTAssertNotNil(val1)
        XCTAssertEqual(val1!, 3.14, accuracy: 0.001)

        let val2: Float? = "-2.5".float()
        XCTAssertNotNil(val2)
        XCTAssertEqual(val2!, -2.5, accuracy: 0.001)

        let val3: Float? = "0".float()
        XCTAssertNotNil(val3)
        XCTAssertEqual(val3!, 0, accuracy: 0.001)
    }

    func testFloatInvalid() {
        XCTAssertNil("abc".float())
        XCTAssertNil("".float())
    }

    func testFloatLocalized() {
        let localeFR = Locale(identifier: "fr_FR")
        let val: Float? = "3,14".float(locale: localeFR)
        XCTAssertNotNil(val)
        XCTAssertEqual(val!, 3.14, accuracy: 0.001)
    }

    // MARK: Double

    func testDoubleValid() {
        let val1: Double? = "3.14159".double()
        XCTAssertNotNil(val1)
        XCTAssertEqual(val1!, 3.14159, accuracy: 0.00001)

        let val2: Double? = "-2.5".double()
        XCTAssertNotNil(val2)
        XCTAssertEqual(val2!, -2.5, accuracy: 0.00001)

        let val3: Double? = "0".double()
        XCTAssertNotNil(val3)
        XCTAssertEqual(val3!, 0, accuracy: 0.00001)
    }

    func testDoubleInvalid() {
        XCTAssertNil("abc".double())
        XCTAssertNil("".double())
    }

    func testDoubleLocalized() {
        let localeFR = Locale(identifier: "fr_FR")
        let val: Double? = "3,14159".double(locale: localeFR)
        XCTAssertNotNil(val)
        XCTAssertEqual(val!, 3.14159, accuracy: 0.00001)
    }

    // MARK: CGFloat

    #if canImport(CoreGraphics)
    func testCGFloatValid() {
        let val1: CGFloat? = "3.14".cgFloat()
        XCTAssertNotNil(val1)
        XCTAssertEqual(Double(val1!), 3.14, accuracy: 0.001)

        let val2: CGFloat? = "-2.5".cgFloat()
        XCTAssertNotNil(val2)
        XCTAssertEqual(Double(val2!), -2.5, accuracy: 0.001)
    }

    func testCGFloatInvalid() {
        XCTAssertNil("abc".cgFloat())
        XCTAssertNil("".cgFloat())
    }

    func testCGFloatLocalized() {
        let localeFR = Locale(identifier: "fr_FR")
        let val: CGFloat? = "3,14".cgFloat(locale: localeFR)
        XCTAssertNotNil(val)
        XCTAssertEqual(Double(val!), 3.14, accuracy: 0.001)
    }
    #endif
}

final class StringOtherConversionTests: XCTestCase {
    // MARK: UTF-8 Data

    func testUTF8Data() {
        let data = "hello".utf8Data
        XCTAssertNotNil(data)
        XCTAssertEqual(data, Data([0x68, 0x65, 0x6C, 0x6C, 0x6F]))
    }

    func testUTF8DataEmpty() {
        XCTAssertEqual("".utf8Data, Data())
    }

    func testUTF8DataChinese() {
        let data = "你好".utf8Data
        XCTAssertNotNil(data)
        // "你好" in UTF-8 is E4 BD A0 E5 A5 BD
        XCTAssertEqual(data, Data([0xE4, 0xBD, 0xA0, 0xE5, 0xA5, 0xBD]))
    }

    // MARK: URL

    func testURLValid() {
        XCTAssertNotNil("https://example.com".url)
        XCTAssertEqual("https://example.com".url?.absoluteString, "https://example.com")
    }

    func testURLInvalid() {
        XCTAssertNil("".url)
    }

    // MARK: NSString

    func testNSString() {
        let nsStr = "hello".nsString
        XCTAssertTrue(nsStr.isKind(of: NSString.self))
        XCTAssertEqual(nsStr, "hello")
    }

    // MARK: Characters

    func testCharacters() {
        XCTAssertEqual("abc".characters, ["a", "b", "c"])
        XCTAssertEqual("".characters, [])
        XCTAssertEqual("hello".characters, ["h", "e", "l", "l", "o"])
    }

    func testCharactersEmoji() {
        XCTAssertEqual("👍👎".characters.count, 2)
    }
}

final class StringTextProcessingTests: XCTestCase {
    // MARK: Camel Case

    func testCamelCasedBasic() {
        XCTAssertEqual("hello test".camelCased, "helloTest")
        XCTAssertEqual("Hello test".camelCased, "helloTest")
    }

    func testCamelCasedWithUnderscore() {
        XCTAssertEqual("hello_test_world".camelCased, "helloTestWorld")
    }

    func testCamelCasedWithHyphen() {
        XCTAssertEqual("hello-test-world".camelCased, "helloTestWorld")
    }

    func testCamelCasedMixed() {
        XCTAssertEqual("Hello_test-world".camelCased, "helloTestWorld")
    }

    func testCamelCasedSingleWord() {
        XCTAssertEqual("hello".camelCased, "hello")
        XCTAssertEqual("Hello".camelCased, "hello")
    }

    func testCamelCasedEmpty() {
        XCTAssertEqual("".camelCased, "")
    }

    func testCamelCasedWithLeadingTrailingSpaces() {
        XCTAssertEqual("  hello world  ".camelCased, "helloWorld")
    }

    // MARK: Latinized

    func testLatinizedAccents() {
        XCTAssertEqual("Hëllö".latinized, "Hello")
        XCTAssertEqual("café".latinized, "cafe")
        XCTAssertEqual("naïve".latinized, "naive")
    }

    func testLatinizedAlreadyPlain() {
        XCTAssertEqual("hello".latinized, "hello")
    }

    func testLatinizedEmpty() {
        XCTAssertEqual("".latinized, "")
    }

    // MARK: Trimmed

    func testTrimmed() {
        XCTAssertEqual("  hello  ".trimmed, "hello")
        XCTAssertEqual("\n  test \n".trimmed, "test")
        XCTAssertEqual("hello".trimmed, "hello")
    }

    func testTrimmedEmpty() {
        XCTAssertEqual("   ".trimmed, "")
        XCTAssertEqual("".trimmed, "")
    }

    // MARK: Without Spaces and New Lines

    func testWithoutSpacesAndNewLines() {
        XCTAssertEqual(" he llo ".withoutSpacesAndNewLines, "hello")
        XCTAssertEqual("a\nb\tc".withoutSpacesAndNewLines, "abc")
        XCTAssertEqual("hello".withoutSpacesAndNewLines, "hello")
    }

    func testWithoutSpacesAndNewLinesEmpty() {
        XCTAssertEqual("   ".withoutSpacesAndNewLines, "")
        XCTAssertEqual("".withoutSpacesAndNewLines, "")
    }

    // MARK: Regex Escaped

    func testRegexEscaped() {
        XCTAssertEqual("hello ^$".regexEscaped, "hello \\^\\$")
        XCTAssertEqual("a.b".regexEscaped, "a\\.b")
        XCTAssertEqual("a*b".regexEscaped, "a\\*b")
        XCTAssertEqual("a+b".regexEscaped, "a\\+b")
        XCTAssertEqual("a?b".regexEscaped, "a\\?b")
        XCTAssertEqual("a|b".regexEscaped, "a\\|b")
        XCTAssertEqual("a(b)".regexEscaped, "a\\(b\\)")
        XCTAssertEqual("a[b]".regexEscaped, "a\\[b]")
        XCTAssertEqual("a{b}".regexEscaped, "a\\{b\\}")
    }

    func testRegexEscapedPlainString() {
        XCTAssertEqual("hello".regexEscaped, "hello")
    }

    func testRegexEscapedEmpty() {
        XCTAssertEqual("".regexEscaped, "")
    }
}

final class StringContentAnalysisTests: XCTestCase {
    // MARK: Lines

    func testLines() {
        XCTAssertEqual("line1\nline2\r\nline3".lines(), ["line1", "line2", "line3"])
        XCTAssertEqual("hello".lines(), ["hello"])
        XCTAssertEqual("".lines(), [])
    }

    func testLinesMultipleNewlines() {
        XCTAssertEqual("a\n\nb".lines(), ["a", "", "b"])
    }

    // MARK: Words

    func testWords() {
        XCTAssertEqual("hello world".words(), ["hello", "world"])
        XCTAssertEqual("hello, world!".words(), ["hello", "world"])
        XCTAssertEqual("".words(), [])
    }

    func testWordsSingleWord() {
        XCTAssertEqual("hello".words(), ["hello"])
    }

    func testWordsWithPunctuation() {
        let words = "one, two; three: four.".words()
        XCTAssertEqual(words, ["one", "two", "three", "four"])
    }

    // MARK: Word Count

    func testWordCount() {
        XCTAssertEqual("hello world".wordCount(), 2)
        XCTAssertEqual("hello, world!".wordCount(), 2)
        XCTAssertEqual("".wordCount(), 0)
        XCTAssertEqual("single".wordCount(), 1)
    }

    // MARK: Unicode Array

    func testUnicodeArray() {
        XCTAssertEqual("abc".unicodeArray(), [97, 98, 99])
        XCTAssertEqual("你好".unicodeArray(), [20320, 22909])
        XCTAssertEqual("".unicodeArray(), [])
    }

    func testUnicodeArrayEmoji() {
        let scalars = "👍".unicodeArray()
        XCTAssertEqual(scalars, [0x1F44D])
    }
}

final class StringSearchOperationsTests: XCTestCase {
    // MARK: Contains

    func testContainsCaseSensitive() {
        XCTAssertTrue("Hello World".contains("World"))
        XCTAssertFalse("Hello World".contains("world"))
    }

    func testContainsCaseInsensitive() {
        XCTAssertTrue("Hello World".contains("world", caseSensitive: false))
        XCTAssertTrue("Hello World".contains("HELLO", caseSensitive: false))
    }

    func testContainsEmpty() {
        XCTAssertFalse("".contains("a"))
        XCTAssertTrue("hello".contains(""))
    }

    // MARK: Count

    func testCountOf() {
        XCTAssertEqual("hello hello".count(of: "hello"), 2)
        XCTAssertEqual("aaa".count(of: "aa"), 1)
        XCTAssertEqual("hello".count(of: "x"), 0)
    }

    func testCountOfCaseInsensitive() {
        XCTAssertEqual("Hello HELLO hello".count(of: "hello", caseSensitive: false), 3)
    }

    func testCountOfEmpty() {
        XCTAssertEqual("".count(of: "a"), 0)
        XCTAssertEqual("hello".count(of: ""), 0)
    }

    // MARK: Starts With

    func testStartsWithCaseSensitive() {
        XCTAssertTrue("Hello World".starts(with: "Hello"))
        XCTAssertFalse("Hello World".starts(with: "hello"))
    }

    func testStartsWithCaseInsensitive() {
        XCTAssertTrue("Hello World".starts(with: "hello", caseSensitive: false))
    }

    func testStartsWithEmptyPrefix() {
        XCTAssertTrue("hello".starts(with: ""))
    }

    func testStartsWithLongerPrefix() {
        XCTAssertFalse("hi".starts(with: "hello"))
    }

    // MARK: Ends With

    func testEndsWithCaseSensitive() {
        XCTAssertTrue("Hello World".ends(with: "World"))
        XCTAssertFalse("Hello World".ends(with: "world"))
    }

    func testEndsWithCaseInsensitive() {
        XCTAssertTrue("Hello World".ends(with: "world", caseSensitive: false))
    }

    func testEndsWithEmptySuffix() {
        XCTAssertTrue("hello".ends(with: ""))
    }

    func testEndsWithLongerSuffix() {
        XCTAssertFalse("hi".ends(with: "hello"))
    }

    // MARK: Matches (Pattern)

    func testMatchesPattern() {
        XCTAssertTrue("abc123".matches(pattern: "^[a-z]+\\d+$"))
        XCTAssertFalse("abc".matches(pattern: "^[a-z]+\\d+$"))
        XCTAssertFalse("".matches(pattern: "^[a-z]+\\d+$"))
    }

    func testMatchesPatternInvalid() {
        XCTAssertFalse("test".matches(pattern: "["))
    }

    // MARK: Matches (Regex)

    func testMatchesRegex() {
        let regex = try! NSRegularExpression(pattern: "^[a-z]+\\d+$")
        XCTAssertTrue("abc123".matches(regex: regex))
        XCTAssertFalse("abc".matches(regex: regex))
    }
}

final class StringSliceAndRangeTests: XCTestCase {
    // MARK: Prefix / Suffix

    func testRemovingPrefix() {
        XCTAssertEqual("prefixHello".removingPrefix("prefix"), "Hello")
        XCTAssertEqual("Hello".removingPrefix("prefix"), "Hello")
        XCTAssertEqual("".removingPrefix("prefix"), "")
        XCTAssertEqual("pre".removingPrefix("prefix"), "pre")
    }

    func testRemovingSuffix() {
        XCTAssertEqual("HelloSuffix".removingSuffix("Suffix"), "Hello")
        XCTAssertEqual("Hello".removingSuffix("Suffix"), "Hello")
        XCTAssertEqual("".removingSuffix("Suffix"), "")
        XCTAssertEqual("Suf".removingSuffix("Suffix"), "Suf")
    }

    func testWithPrefix() {
        XCTAssertEqual("Hello".withPrefix("Mr. "), "Mr. Hello")
        XCTAssertEqual("Mr. Hello".withPrefix("Mr. "), "Mr. Hello")
    }

    func testWithSuffix() {
        XCTAssertEqual("Hello".withSuffix(".jpg"), "Hello.jpg")
        XCTAssertEqual("Hello.jpg".withSuffix(".jpg"), "Hello.jpg")
    }

    // MARK: Slice (non-mutating)

    func testSlicingFromLength() {
        XCTAssertEqual("Hello World".slicing(from: 0, length: 5), "Hello")
        XCTAssertEqual("Hello".slicing(from: 1, length: 3), "ell")
        XCTAssertEqual("Hello".slicing(from: 1, length: 10), "ello")
    }

    func testSlicingOutOfBounds() {
        XCTAssertEqual("Hello".slicing(from: 10, length: 2), "")
        XCTAssertEqual("Hello".slicing(from: -1, length: 2), "")
    }

    func testSlicingZeroOrNegativeLength() {
        XCTAssertEqual("Hello".slicing(from: 0, length: 0), "")
        XCTAssertEqual("Hello".slicing(from: 0, length: -1), "")
    }

    func testSlicingEmpty() {
        XCTAssertEqual("".slicing(from: 0, length: 1), "")
    }

    // MARK: Slice (mutating)

    func testSliceFromLength() {
        var s = "Hello World"
        s.slice(from: 0, length: 5)
        XCTAssertEqual(s, "Hello")
    }

    func testSliceFromTo() {
        var s = "Hello World"
        s.slice(from: 0, to: 5)
        XCTAssertEqual(s, "Hello")
    }

    func testSliceFromToInvalidRange() {
        var s = "Hello"
        s.slice(from: 3, to: 1)
        XCTAssertEqual(s, "")
    }

    func testSliceAt() {
        var s = "Hello World"
        s.slice(at: 6)
        XCTAssertEqual(s, "World")
    }

    func testSliceAtOutOfBounds() {
        var s = "Hello"
        s.slice(at: 10)
        XCTAssertEqual(s, "")
        var s2 = "Hello"
        s2.slice(at: -1)
        XCTAssertEqual(s2, "")
    }

    // MARK: NSRange Conversion

    func testRangeFromNSRange() {
        let nsRange = NSRange(location: 0, length: 5)
        let range = "Hello World".range(from: nsRange)
        XCTAssertNotNil(range)
        XCTAssertEqual("Hello World"[range!], "Hello")
    }

    func testRangeFromNSRangeOutOfBounds() {
        let nsRange = NSRange(location: 100, length: 5)
        XCTAssertNil("Hello".range(from: nsRange))
    }

    func testNSRangeFromRange() {
        let str = "Hello"
        let range = str.startIndex..<str.endIndex
        let nsRange = str.nsRange(from: range)
        XCTAssertEqual(nsRange.location, 0)
        XCTAssertEqual(nsRange.length, 5)
    }

    func testFullNSRange() {
        XCTAssertEqual("Hello".fullNSRange, NSRange(location: 0, length: 5))
        XCTAssertEqual("".fullNSRange, NSRange(location: 0, length: 0))
    }

    func testFullNSRangeChinese() {
        let nsRange = "你好".fullNSRange
        XCTAssertEqual(nsRange.location, 0)
        XCTAssertEqual(nsRange.length, 2)
    }
}

final class FastRateLimitTests: XCTestCase {
    override func tearDown() {
        FastRateLimit.cancelAll()
        super.tearDown()
    }

    func testRateLimitCachesSubsequentCalls() {
        let firstExpectation = expectation(description: "first")
        let cachedExpectation = expectation(description: "cached")

        var results: [Int] = []
        XCTAssertFalse(FastRateLimit.rateLimit(tag: "test", duration: 0.15, queue: .global()) {
            results.append(1)
            firstExpectation.fulfill()
        })
        XCTAssertTrue(FastRateLimit.rateLimit(tag: "test", duration: 0.15, queue: .global()) {
            results.append(2)
            cachedExpectation.fulfill()
        })

        waitForExpectations(timeout: 1)
        XCTAssertEqual(results, [1, 2])
    }

    func testRateLimitCancel() {
        FastRateLimit.rateLimit(tag: "cancel", duration: 1, queue: .global()) {}
        XCTAssertEqual(FastRateLimit.count, 1)
        FastRateLimit.cancel(tag: "cancel")
        XCTAssertEqual(FastRateLimit.count, 0)
    }
}
