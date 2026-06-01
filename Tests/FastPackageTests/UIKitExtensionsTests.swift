#if canImport(UIKit)
import UIKit
import XCTest
@testable import FastPackage

final class UIControlDebounceTests: XCTestCase {
    override func tearDown() {
        FastDebounce.cancelAll()
        super.tearDown()
    }

    func testUIButtonDebouncedTapExecutesOnce() {
        let button = UIButton()
        let expectation = expectation(description: "debounced tap")
        expectation.expectedFulfillmentCount = 1

        var count = 0
        button.addDebouncedTap(duration: 0.15) { _ in
            count += 1
            expectation.fulfill()
        }

        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(count, 1)
    }

    func testUIControlRemoveDebouncedAction() {
        let button = UIButton()
        let expectation = expectation(description: "removed")
        expectation.isInverted = true

        button.addDebouncedTap(duration: 0.2) { _ in
            expectation.fulfill()
        }
        button.removeDebouncedAction(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 0.5)
    }
}

final class UIControlThrottleTests: XCTestCase {
    override func tearDown() {
        FastThrottle.cancelAll()
        super.tearDown()
    }

    func testUIButtonThrottledTapExecutesOnce() {
        let button = UIButton()
        let expectation = expectation(description: "throttled tap")
        expectation.expectedFulfillmentCount = 1

        var count = 0
        button.addThrottledTap(duration: 0.2) { _ in
            count += 1
            expectation.fulfill()
        }

        button.sendActions(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)

        waitForExpectations(timeout: 1)
        XCTAssertEqual(count, 1)
    }

    func testUIControlRemoveThrottledAction() {
        let button = UIButton()
        var count = 0

        button.addThrottledTap(duration: 1.0) { _ in
            count += 1
        }
        button.removeThrottledAction(for: .touchUpInside)
        button.sendActions(for: .touchUpInside)

        XCTAssertEqual(count, 0)
    }
}

final class UIViewTapExtensionsTests: XCTestCase {
    override func tearDown() {
        FastDebounce.cancelAll()
        FastThrottle.cancelAll()
        super.tearDown()
    }

    func testUIViewAddDebouncedTapAddsGesture() {
        let view = UIView()
        let gesture = view.addDebouncedTapGesture(duration: 0.2) { _ in }
        XCTAssertTrue(view.isUserInteractionEnabled)
        XCTAssertTrue(view.gestureRecognizers?.contains(gesture) == true)
    }

    func testUIViewRemoveDebouncedTapRemovesGesture() {
        let view = UIView()
        view.addDebouncedTapGesture(duration: 0.2) { _ in }
        view.removeDebouncedTapGesture()
        XCTAssertTrue(view.gestureRecognizers?.isEmpty ?? true)
    }

    func testUIViewAddThrottledTapAddsGesture() {
        let view = UIView()
        let gesture = view.addThrottledTapGesture(duration: 0.2) { _ in }
        XCTAssertTrue(view.isUserInteractionEnabled)
        XCTAssertTrue(view.gestureRecognizers?.contains(gesture) == true)
    }
}
#endif
