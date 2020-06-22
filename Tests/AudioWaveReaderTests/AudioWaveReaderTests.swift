import XCTest
@testable import AudioWaveReader

final class AudioWaveReaderTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AudioWaveReader().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
