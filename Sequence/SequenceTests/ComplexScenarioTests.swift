//
//  ComplexScenarioTests.swift
//  SequenceTests
//
//  Created by Amarjit on 13/11/2025.
//

import XCTest

@testable import Sequence

final class ComplexScenarioTests: XCTestCase {
    
    func testWindingPath() {
        // Create a level that requires a winding path
        let level = Level(
            name: "Test",
            gridSize: 4,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 3),
                3: GridPosition(row: 3, col: 3),
                4: GridPosition(row: 3, col: 0)
            ]
        )
        let state = PathGameState(level: level)
        
        // Create a path that goes: right, right, right, down, down, down, left, left, left
        state.addPosition(GridPosition(row: 0, col: 0))  // 1
        state.addPosition(GridPosition(row: 0, col: 1))
        state.addPosition(GridPosition(row: 0, col: 2))
        state.addPosition(GridPosition(row: 0, col: 3))  // 2
        state.addPosition(GridPosition(row: 1, col: 3))
        state.addPosition(GridPosition(row: 2, col: 3))
        state.addPosition(GridPosition(row: 3, col: 3))  // 3
        state.addPosition(GridPosition(row: 3, col: 2))
        state.addPosition(GridPosition(row: 3, col: 1))
        state.addPosition(GridPosition(row: 3, col: 0))  // 4
        
        XCTAssertTrue(state.isComplete)
        XCTAssertEqual(state.currentPath.count, 10)
    }
    
    func testCannotBacktrack() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 2, col: 2),
                2: GridPosition(row: 2, col: 5)
            ]
        )
        let state = PathGameState(level: level)
        
        // Start and move right
        state.addPosition(GridPosition(row: 2, col: 2))  // 1
        state.addPosition(GridPosition(row: 2, col: 3))
        state.addPosition(GridPosition(row: 2, col: 4))
        
        // Try to backtrack left (should fail - cell already visited)
        let result = state.addPosition(GridPosition(row: 2, col: 3))
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, .cellAlreadyVisited)
        } else {
            XCTFail("Should not be able to backtrack over visited cells")
        }
    }
    
    func testNavigateAroundObstacle() {
        let level = Level(
            name: "Test",
            gridSize: 5,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 4)
            ]
        )
        let state = PathGameState(level: level)
        
        // Path must go around if we create our own "obstacle" by visiting cells
        state.addPosition(GridPosition(row: 0, col: 0))  // 1
        state.addPosition(GridPosition(row: 1, col: 0))  // Go down first
        state.addPosition(GridPosition(row: 1, col: 1))  // Then right
        state.addPosition(GridPosition(row: 0, col: 1))  // Back up
        
        // Now we cannot go through (0,1) again, must continue right
        let result = state.addPosition(GridPosition(row: 0, col: 2))
        XCTAssertTrue(result.isSuccess)
        
        // Continue to node 2
        state.addPosition(GridPosition(row: 0, col: 3))
        state.addPosition(GridPosition(row: 0, col: 4))  // 2
        
        XCTAssertTrue(state.isComplete)
    }
}
