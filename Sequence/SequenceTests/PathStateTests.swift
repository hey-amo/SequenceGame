//
//  PathStateTests.swift
//  SequenceTests
//
//  Created by Amarjit on 13/11/2025.
//

import XCTest
@testable import Sequence


final class PathStateTests: XCTestCase {
    
    func testInitialState() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 1, col: 1)
            ]
        )
        let state = PathGameState(level: level)
        
        XCTAssertEqual(state.currentNumber, 0)
        XCTAssertEqual(state.currentPath.count, 0)
        XCTAssertEqual(state.visitedCells.count, 0)
        XCTAssertFalse(state.isComplete)
    }
    
    func testTrackCurrentNumber() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 2)
            ]
        )
        let state = PathGameState(level: level)
        
        state.addPosition(GridPosition(row: 0, col: 0))  // Node 1
        XCTAssertEqual(state.currentNumber, 1)
        
        state.addPosition(GridPosition(row: 0, col: 1))  // Empty
        XCTAssertEqual(state.currentNumber, 1, "Current number shouldn't change on empty cell")
        
        state.addPosition(GridPosition(row: 0, col: 2))  // Node 2
        XCTAssertEqual(state.currentNumber, 2)
    }
    
    func testTrackVisitedCells() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 2)
            ]
        )
        let state = PathGameState(level: level)
        
        state.addPosition(GridPosition(row: 0, col: 0))
        XCTAssertEqual(state.visitedCells.count, 1)
        XCTAssertTrue(state.visitedCells.contains(GridPosition(row: 0, col: 0)))
        
        state.addPosition(GridPosition(row: 0, col: 1))
        XCTAssertEqual(state.visitedCells.count, 2)
        XCTAssertTrue(state.visitedCells.contains(GridPosition(row: 0, col: 1)))
    }
    
    func testDetectCompletion() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 1)
            ]
        )
        let state = PathGameState(level: level)
        
        XCTAssertFalse(state.isComplete)
        
        state.addPosition(GridPosition(row: 0, col: 0))  // Node 1
        XCTAssertFalse(state.isComplete)
        
        state.addPosition(GridPosition(row: 0, col: 1))  // Node 2
        XCTAssertTrue(state.isComplete, "Should be complete when final node is reached")
    }
    
    func testReset() {
        let level = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 2)
            ]
        )
        let state = PathGameState(level: level)
        
        state.addPosition(GridPosition(row: 0, col: 0))
        state.addPosition(GridPosition(row: 0, col: 1))
        
        XCTAssertGreaterThan(state.currentPath.count, 0)
        
        state.reset()
        
        XCTAssertEqual(state.currentNumber, 0)
        XCTAssertEqual(state.currentPath.count, 0)
        XCTAssertEqual(state.visitedCells.count, 0)
        XCTAssertFalse(state.isComplete)
    }
}
