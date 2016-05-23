import XCTest
@testable import SQL

class SQLTests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
    }
}

extension SQLTests {
    static var allTests: [(String, SQLTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}