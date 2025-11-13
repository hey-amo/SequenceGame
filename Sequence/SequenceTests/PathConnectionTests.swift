//
//  PathConnectionTests.swift
//  SequenceTests
//
//  Created by Amarjit on 13/11/2025.
//

import XCTest
@testable import Sequence


final class PathConnectionTests: XCTestCase {
    
    var simpleLevel: Level!
    var gameState: PathGameState!
    
    override func setUp() {
        super.setUp()
        // Create a simple 6x6 level
        // 1 at (0,0), 2 at (0,2), 3 at (2,2)
        simpleLevel = Level(
            name: "Test",
            gridSize: 6,
            nodes: [
                1: GridPosition(row: 0, col: 0),
                2: GridPosition(row: 0, col: 2),
                3: GridPosition(row: 2, col: 2)
            ]
        )
        gameState = PathGameState(level: simpleLevel)
    }
    
    // MARK: - Valid Connections
    
    func testMustStartAtNodeOne() {
        let result = gameState.addPosition(GridPosition(row: 0, col: 0))
        XCTAssertTrue(result.isSuccess, "Should be able to start at node 1")
        XCTAssertEqual(gameState.currentNumber, 1)
    }
    
    func testCannotStartAtWrongNode() {
        let result = gameState.addPosition(GridPosition(row: 0, col: 2))
        if case .failure(let error) = result {
            XCTAssertEqual(error, .mustStartAtOne)
        } else {
            XCTFail("Should not be able to start at node 2")
        }
    }
    
    func testConnectToAdjacentEmptyCell() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // Start at 1
        
        let result = gameState.addPosition(GridPosition(row: 0, col: 1))  // Move right
        XCTAssertTrue(result.isSuccess, "Should be able to move to adjacent empty cell")
        XCTAssertEqual(gameState.currentPath.count, 2)
    }
    
    func testConnectToNextSequentialNode() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // Node 1
        gameState.addPosition(GridPosition(row: 0, col: 1))  // Empty cell
        
        let result = gameState.addPosition(GridPosition(row: 0, col: 2))  // Node 2
        XCTAssertTrue(result.isSuccess, "Should be able to connect to next node")
        XCTAssertEqual(gameState.currentNumber, 2)
    }
    
    func testCompletePathToFinalNode() {
        // Path: 1 → right → 2 → down → down → 3
        gameState.addPosition(GridPosition(row: 0, col: 0))  // 1
        gameState.addPosition(GridPosition(row: 0, col: 1))  // empty
        gameState.addPosition(GridPosition(row: 0, col: 2))  // 2
        gameState.addPosition(GridPosition(row: 1, col: 2))  // empty
        gameState.addPosition(GridPosition(row: 2, col: 2))  // 3
        
        XCTAssertEqual(gameState.currentNumber, 3)
        XCTAssertTrue(gameState.isComplete, "Path should be complete")
    }
    
    // MARK: - Invalid Connections
    
    func testCannotSkipNumbers() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // Node 1
        gameState.addPosition(GridPosition(row: 1, col: 0))  // Empty
        gameState.addPosition(GridPosition(row: 2, col: 0))  // Empty
        gameState.addPosition(GridPosition(row: 2, col: 1))  // Empty
        
        // Try to jump to node 3 without passing through node 2
        let result = gameState.addPosition(GridPosition(row: 2, col: 2))  // Node 3
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, .skipNumber)
        } else {
            XCTFail("Should not be able to skip node 2")
        }
    }
    
    func testCannotConnectToNonAdjacentCell() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // Start at 1
        
        // Try to jump two spaces
        let result = gameState.addPosition(GridPosition(row: 0, col: 2))
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, .notAdjacent)
        } else {
            XCTFail("Should not be able to jump to non-adjacent cell")
        }
    }
    
    func testCannotConnectDiagonally() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // Start at 1
        
        // Try diagonal move
        let result = gameState.addPosition(GridPosition(row: 1, col: 1))
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, .notAdjacent)
        } else {
            XCTFail("Should not be able to move diagonally")
        }
    }
    
    func testCannotRevisitCell() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // 1
        gameState.addPosition(GridPosition(row: 0, col: 1))  // empty
        gameState.addPosition(GridPosition(row: 0, col: 2))  // 2
        
        // Try to go back to previously visited cell
        let result = gameState.addPosition(GridPosition(row: 0, col: 1))
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, .cellAlreadyVisited)
        } else {
            XCTFail("Should not be able to revisit a cell")
        }
    }
    
    func testCannotGoOutOfBounds() {
        gameState.addPosition(GridPosition(row: 0, col: 0))  // Start at 1
        
        // Try to go off grid (negative)
        let result = gameState.addPosition(GridPosition(row: -1, col: 0))
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, .outOfBounds)
        } else {
            XCTFail("Should not be able to go out of bounds")
        }
    }
}
