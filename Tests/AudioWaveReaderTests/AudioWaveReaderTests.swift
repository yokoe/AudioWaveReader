import XCTest
import AVFoundation
import AudioWaveReader

final class AudioWaveReaderTests: XCTestCase {
    func testExample() {
        XCTAssertNotNil(AudioWaveReader(asset: AVAsset(url: URL(fileURLWithPath: "example.mov"))))
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
