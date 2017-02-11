import UIKit
import XCTest
import GoogleBatchHelper

class Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    // TODO: not sure why it can not test... It's like black hole in the xcode build system....

    //    func testReadLine() {
    //        struct TestCase {
    //            let input: String
    //            let want: (String, Int)?
    //        }
    //
    //        let tests = [
    //            TestCase(input: "HTTP/1.1 200 OK\r\n", want: ("1.1", 200)),
    //            TestCase(input: "HTTP/2 404 Not Found", want: ("2", 404)),
    //            TestCase(input: "HTTP/2.0 500", want: ("2.0", 500)),
    //            TestCase(input: "/2.0 300", want: nil),
    //            TestCase(input: "HTTP 200 OK", want: nil),
    //            TestCase(input: "200", want: nil),
    //            TestCase(input: "", want: nil),
    //            ]
    //        for test in tests {
    //            let data = test.input.data(using: String.Encoding.utf8)!
    //            if let got = statusLine(data, start: 0, end: data.count) {
    //                XCTAssert(test.want != nil && test.want! == got,
    //                          "statusLine('\(test.want)') = \(got), want \(test.want)")
    //            } else {
    //                XCTAssertNil(test.want, "statusLine('\(test.input)') = nil, want \(test.want)")
    //            }
    //        }
    //    }
    //
    //    func testReadHeader() {
    //        struct TestCase {
    //            let input: String
    //            let want: (String, String, Int)
    //        }
    //
    //        let strings = [
    //            ("", "", ""),
    //            ("key: val\r\n", "key", "val"),
    //            ("key: val\n", "key", ""), /// malformed, without `\r`
    //            ("key: val1:val2\r\n", "key", "val1:val2"),
    //            ("Content-Type: text/plain; charset=utf-8\r\n", "Content-Type", "text/plain; charset=utf-8"),
    //            ("Content-Type:  text/plain; charset=utf-8\r\n", "Content-Type", "text/plain; charset=utf-8"),
    //            ("Content-Type:   text/plain; charset=utf-8 \r\n", "Content-Type", "text/plain; charset=utf-8 "),
    //            ]
    //        var tests = [TestCase]()
    //        for str in strings {
    //            tests.append(TestCase(input: str.0, want: (str.1, str.2, str.0.utf8.count)))
    //        }
    //
    //        for test in tests {
    //            let data = test.input.data(using: String.Encoding.utf8)!
    //            let got = readHeader(data, offset: 0)
    //            XCTAssertTrue(got == test.want, "readHeader(\"\(test.input)\") = \(got), want \(test.want)")
    //        }
    //    }
    //
    //    func testDecoder() {
    //        let bundle = Bundle(for: type(of: self))
    //        let url = bundle.url(forResource: "batch", withExtension: "txt")!
    //        do {
    //            let data = try Data(contentsOf: url)
    //            let res = BatchResponseDecoder(data: data, boundary: "batch_yd7apQt3vXA_ABLyCKneJi4")
    //            XCTAssertNotNil(res)
    //        } catch {
    //            XCTFail(error.localizedDescription)
    //        }
    //    }
    //
    //    func testResolveBoundary() {
    //        struct TestCase {
    //            let str: String
    //            let want: String?
    //        }
    //
    //        let tests = [
    //            TestCase(str: "", want: nil),
    //            TestCase(str: "boundary", want: nil),
    //            TestCase(str: "boundary=", want: ""),
    //            TestCase(str: "multipart/mixed; boundary=batch__8V5rCfdLyo_AA7YPKoEWIo", want: "batch__8V5rCfdLyo_AA7YPKoEWIo"),
    //            TestCase(str: "boundary=batch__8V5rCfdLyo_AA7YPKoEWIo", want: "batch__8V5rCfdLyo_AA7YPKoEWIo"),
    //            ]
    //        for test in tests {
    //            let got = resolveBoundary(test.str)
    //            let msg = "resolveBoundary(\(test.str) = \(got), want \(test.want)"
    //            if let got = got {
    //                XCTAssertNotNil(test.want, msg)
    //                XCTAssert(got == test.want!, msg)
    //            } else {
    //                XCTAssertNil(test.want)
    //            }
    //        }
    //    }
    //
}
