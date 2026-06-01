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
