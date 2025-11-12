//
//  SequenceTests.swift
//  SequenceTests
//
//  Created by Amarjit on 12/11/2025.
//

import XCTest
@testable import Sequence

final class SequenceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here
    }

    override func tearDownWithError() throws {
        // Put teardown code here
    }

    func testHashing() {
       let pos1 = GridPosition(row: 2, col: 3)
       let pos2 = GridPosition(row: 2, col: 3)
       
       var set = Set<GridPosition>()
       set.insert(pos1)
       set.insert(pos2)
       
       XCTAssertEqual(set.count, 1, "Identical positions should hash to same value")
    }
}
