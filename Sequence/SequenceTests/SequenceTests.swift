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
    
    func testEquality() {
           let pos1 = GridPosition(row: 2, col: 3)
           let pos2 = GridPosition(row: 2, col: 3)
           let pos3 = GridPosition(row: 2, col: 4)
           
           XCTAssertEqual(pos1, pos2)
           XCTAssertNotEqual(pos1, pos3)
       }
    
    func testAdjacentPositions() {
        let center = GridPosition(row: 3, col: 3)
        
        // Adjacent positions (up, down, left, right)
        XCTAssertTrue(center.isAdjacent(to: GridPosition(row: 2, col: 3)), "Above should be adjacent")
        XCTAssertTrue(center.isAdjacent(to: GridPosition(row: 4, col: 3)), "Below should be adjacent")
        XCTAssertTrue(center.isAdjacent(to: GridPosition(row: 3, col: 2)), "Left should be adjacent")
        XCTAssertTrue(center.isAdjacent(to: GridPosition(row: 3, col: 4)), "Right should be adjacent")
    }

    func testNonAdjacentPositions() {
        let center = GridPosition(row: 3, col: 3)
        
        // Diagonal positions should NOT be adjacent
        XCTAssertFalse(center.isAdjacent(to: GridPosition(row: 2, col: 2)), "Diagonal should not be adjacent")
        XCTAssertFalse(center.isAdjacent(to: GridPosition(row: 4, col: 4)), "Diagonal should not be adjacent")
        XCTAssertFalse(center.isAdjacent(to: GridPosition(row: 2, col: 4)), "Diagonal should not be adjacent")
        XCTAssertFalse(center.isAdjacent(to: GridPosition(row: 4, col: 2)), "Diagonal should not be adjacent")
        
        // Distant positions
        XCTAssertFalse(center.isAdjacent(to: GridPosition(row: 3, col: 5)), "Two steps away should not be adjacent")
        XCTAssertFalse(center.isAdjacent(to: GridPosition(row: 1, col: 3)), "Two steps away should not be adjacent")
    }
    
    func testSelfNotAdjacent() {
        let pos = GridPosition(row: 3, col: 3)
        XCTAssertFalse(pos.isAdjacent(to: pos), "Position should not be adjacent to itself")
    }
    
    func testWithinBounds() {
        let gridSize = 6
        
        XCTAssertTrue(GridPosition(row: 0, col: 0).isWithinBounds(gridSize: gridSize))
        XCTAssertTrue(GridPosition(row: 5, col: 5).isWithinBounds(gridSize: gridSize))
        XCTAssertTrue(GridPosition(row: 3, col: 3).isWithinBounds(gridSize: gridSize))
        
        XCTAssertFalse(GridPosition(row: -1, col: 0).isWithinBounds(gridSize: gridSize))
        XCTAssertFalse(GridPosition(row: 0, col: -1).isWithinBounds(gridSize: gridSize))
        XCTAssertFalse(GridPosition(row: 6, col: 0).isWithinBounds(gridSize: gridSize))
        XCTAssertFalse(GridPosition(row: 0, col: 6).isWithinBounds(gridSize: gridSize))
    }
}
