//
//  LevelValidationTests.swift
//  SequenceTests
//
//  Created by Amarjit on 13/11/2025.
//

import XCTest
@testable import Sequence

final class LevelValidationTests: XCTestCase {
    
    func testValidLevel() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 5, col: 5),
                3: GridPosition(row: 2, col: 3)
            ]
        )
        
        XCTAssertTrue(level.validate(), "Valid level should pass validation")
    }
    
    func testLevelMustStartAtOne() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                2: GridPosition(row: 0, col: 0),
                3: GridPosition(row: 5, col: 5)
            ]
        )
        
        XCTAssertFalse(level.validate(), "Level must start with node 1")
    }
    
    func testLevelNodesAreSequential() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 1, col: 1),
                4: GridPosition(row: 2, col: 2)  // Skip 3
            ]
        )
        
        XCTAssertFalse(level.validate(), "Level nodes must be sequential")
    }
    
    func testLevelNodesWithinBounds() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 6, col: 6)  // Out of bounds
            ]
        )
        
        XCTAssertFalse(level.validate(), "All nodes must be within grid bounds")
    }
    
    func testLevelNoDuplicatePositions() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 0)  // Duplicate position
            ]
        )
        
        XCTAssertFalse(level.validate(), "Nodes cannot share the same position")
    }
    
    func testEmptyLevel() {
        let level = Level(name: "Test", gridSize: 6, nodes: [:])
        XCTAssertFalse(level.validate(), "Empty level should not be valid")
    }
}
