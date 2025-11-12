//
//  GameModels.swift
//  Sequence
//
//  Created by Amarjit on 12/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Core Data Models

/// Represents a position on the game grid
struct GridPosition: Hashable, Equatable, Codable {
    let row: Int
    let col: Int
    
    /// Check if this position is adjacent to another (4-directional, no diagonals)
    func isAdjacent(to other: GridPosition) -> Bool {
        let rowDiff = abs(row - other.row)
        let colDiff = abs(col - other.col)
        // Adjacent means exactly one step in one direction (not diagonal)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    /// Check if position is within grid bounds
    func isWithinBounds(gridSize: Int) -> Bool {
        return row >= 0 && row < gridSize && col >= 0 && col < gridSize
    }
    
    /// Get the direction from this position to another
    func direction(to other: GridPosition) -> Direction? {
        guard isAdjacent(to: other) else { return nil }
        
        if other.row < row { return .up }
        if other.row > row { return .down }
        if other.col < col { return .left }
        if other.col > col { return .right }
        
        return nil
    }
}

/// Cardinal directions for path visualization
enum Direction {
    case up, down, left, right
}

// MARK: - Level Model

/// Represents a puzzle level
struct Level: Codable, Identifiable {
    let id: String
    let name: String
    let gridSize: Int
    let nodes: [Int: GridPosition]
    
    init(id: String = UUID().uuidString, name: String, gridSize: Int, nodes: [Int: GridPosition]) {
        self.id = id
        self.name = name
        self.gridSize = gridSize
        self.nodes = nodes
    }
    
    /// Validate that the level is well-formed
    func validate() -> Bool {
        // Check if nodes exist
        guard nodes.keys.count > 0 else { return false }
        
        // Check if nodes are sequential starting from 1
        let sortedKeys = nodes.keys.sorted()
        guard sortedKeys.first == 1 else { return false }
        
        for i in 0..<sortedKeys.count {
            if sortedKeys[i] != i + 1 { return false }
        }
        
        // Check all positions are within bounds
        for position in nodes.values {
            if !position.isWithinBounds(gridSize: gridSize) {
                return false
            }
        }
        
        // Check no duplicate positions
        let positions = Array(nodes.values)
        let uniquePositions = Set(positions)
        guard positions.count == uniquePositions.count else { return false }
        
        return true
    }
    
    /// Get the maximum node number in this level
    var maxNodeNumber: Int {
        return nodes.keys.max() ?? 0
    }
    
    /// Get node position for a given number
    func position(for nodeNumber: Int) -> GridPosition? {
        return nodes[nodeNumber]
    }
    
    /// Get node number at a given position (if any)
    func nodeNumber(at position: GridPosition) -> Int? {
        return nodes.first(where: { $0.value == position })?.key
    }
}

// MARK: - Path Errors

/// Errors that can occur when building a path
enum PathError: Error, Equatable {
    case mustStartAtOne
    case notAdjacent
    case cellAlreadyVisited
    case skipNumber
    case outOfBounds
    
    var localizedDescription: String {
        switch self {
        case .mustStartAtOne:
            return "Path must start at node 1"
        case .notAdjacent:
            return "Can only move to adjacent cells"
        case .cellAlreadyVisited:
            return "Cannot revisit cells"
        case .skipNumber:
            return "Must visit nodes in sequence"
        case .outOfBounds:
            return "Position is outside the grid"
        }
    }
}

// MARK: - Game State

/// Manages the state of an active game/puzzle
class PathGameState: ObservableObject {
    let level: Level
    
    @Published private(set) var currentPath: [GridPosition] = []
    @Published private(set) var visitedCells: Set<GridPosition> = []
    @Published private(set) var currentNumber: Int = 0
    @Published private(set) var isComplete: Bool = false
    
    init(level: Level) {
        self.level = level
    }
    
    /// Reset the game state
    func reset() {
        currentPath = []
        visitedCells = []
        currentNumber = 0
        isComplete = false
    }
    
    /// Add a position to the path
    /// Returns a Result indicating success or the specific error
    @discardableResult
    func addPosition(_ position: GridPosition) -> Result<Void, PathError> {
        // Check bounds
        guard position.isWithinBounds(gridSize: level.gridSize) else {
            return .failure(.outOfBounds)
        }
        
        // First position must be node 1
        if currentPath.isEmpty {
            guard level.nodes[1] == position else {
                return .failure(.mustStartAtOne)
            }
            currentPath.append(position)
            visitedCells.insert(position)
            currentNumber = 1
            checkCompletion()
            return .success(())
        }
        
        // Check if already visited
        guard !visitedCells.contains(position) else {
            return .failure(.cellAlreadyVisited)
        }
        
        // Must be adjacent to last position
        guard let lastPosition = currentPath.last,
              position.isAdjacent(to: lastPosition) else {
            return .failure(.notAdjacent)
        }
        
        // Check if this position is a node
        if let nodeNumber = level.nodeNumber(at: position) {
            // Must be the next sequential node
            guard nodeNumber == currentNumber + 1 else {
                return .failure(.skipNumber)
            }
            currentNumber = nodeNumber
        }
        
        currentPath.append(position)
        visitedCells.insert(position)
        checkCompletion()
        return .success(())
    }
    
    /// Check if a position can be added (useful for UI validation)
    func canAddPosition(_ position: GridPosition) -> Bool {
        switch addPosition(position) {
        case .success:
            // Roll back the change since this is just a check
            if let last = currentPath.last, last == position {
                currentPath.removeLast()
                visitedCells.remove(position)
                if let nodeNum = level.nodeNumber(at: position) {
                    currentNumber = nodeNum - 1
                }
            }
            return true
        case .failure:
            return false
        }
    }
    
    /// Remove the last position from the path (for undo/drag release)
    func removeLastPosition() {
        guard let last = currentPath.popLast() else { return }
        visitedCells.remove(last)
        
        // If we removed a node, decrement currentNumber
        if let nodeNumber = level.nodeNumber(at: last) {
            currentNumber = nodeNumber - 1
        }
        
        isComplete = false
    }
    
    /// Clear path back to a specific position (useful for drag gestures)
    func clearPathAfter(_ position: GridPosition) {
        guard let index = currentPath.firstIndex(of: position) else { return }
        
        let removedPositions = currentPath.suffix(from: index + 1)
        currentPath = Array(currentPath.prefix(through: index))
        
        for pos in removedPositions {
            visitedCells.remove(pos)
            if let nodeNumber = level.nodeNumber(at: pos) {
                currentNumber = min(currentNumber, nodeNumber - 1)
            }
        }
        
        isComplete = false
    }
    
    private func checkCompletion() {
        isComplete = currentNumber == level.maxNodeNumber
    }
}

// MARK: - Level Storage & Management

/// Manages level data and user progress
class LevelManager: ObservableObject {
    @Published var levels: [Level] = []
    @Published var currentLevelIndex: Int = 0
    
    var currentLevel: Level? {
        guard currentLevelIndex < levels.count else { return nil }
        return levels[currentLevelIndex]
    }
    
    init() {
        loadDefaultLevels()
    }
    
    /// Load built-in levels
    private func loadDefaultLevels() {
        levels = [
            // Level 1: Simple 3-node tutorial
            Level(
                name: "Tutorial",
                gridSize: 4,
                nodes: [
                    1: GridPosition(row: 0, col: 0),
                    2: GridPosition(row: 0, col: 3),
                    3: GridPosition(row: 3, col: 3)
                ]
            ),
            
            // Level 2: Based on your first image
            Level(
                name: "Classic",
                gridSize: 6,
                nodes: [
                    1: GridPosition(row: 0, col: 0),
                    2: GridPosition(row: 5, col: 5),
                    3: GridPosition(row: 4, col: 1),
                    4: GridPosition(row: 2, col: 1),
                    5: GridPosition(row: 3, col: 5),
                    6: GridPosition(row: 3, col: 2),
                    7: GridPosition(row: 1, col: 5),
                    8: GridPosition(row: 2, col: 3)
                ]
            ),
            
            // Level 3: Zigzag pattern
            Level(
                name: "Zigzag",
                gridSize: 5,
                nodes: [
                    1: GridPosition(row: 0, col: 0),
                    2: GridPosition(row: 0, col: 4),
                    3: GridPosition(row: 2, col: 4),
                    4: GridPosition(row: 2, col: 0),
                    5: GridPosition(row: 4, col: 0),
                    6: GridPosition(row: 4, col: 4)
                ]
            ),
            
            // Level 4: Corner challenge
            Level(
                name: "Corners",
                gridSize: 6,
                nodes: [
                    1: GridPosition(row: 0, col: 0),
                    2: GridPosition(row: 0, col: 5),
                    3: GridPosition(row: 5, col: 5),
                    4: GridPosition(row: 5, col: 0),
                    5: GridPosition(row: 2, col: 2)
                ]
            )
        ]
    }
    
    func nextLevel() {
        if currentLevelIndex < levels.count - 1 {
            currentLevelIndex += 1
        }
    }
    
    func previousLevel() {
        if currentLevelIndex > 0 {
            currentLevelIndex -= 1
        }
    }
    
    func addLevel(_ level: Level) {
        levels.append(level)
    }
}

// MARK: - UI Helper Extensions

extension GridPosition {
    /// Convert grid position to CGPoint in view coordinates
    func toPoint(cellSize: CGFloat) -> CGPoint {
        return CGPoint(
            x: CGFloat(col) * cellSize + cellSize / 2,
            y: CGFloat(row) * cellSize + cellSize / 2
        )
    }
    
    /// Create grid position from a point in view coordinates
    static func from(point: CGPoint, cellSize: CGFloat, gridSize: Int) -> GridPosition? {
        let col = Int(point.x / cellSize)
        let row = Int(point.y / cellSize)
        
        let position = GridPosition(row: row, col: col)
        guard position.isWithinBounds(gridSize: gridSize) else { return nil }
        
        return position
    }
}

extension Level {
    /// Get a color for a specific node number
    func colorForNode(_ nodeNumber: Int) -> Color {
        let colors: [Color] = [
            .blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan
        ]
        let index = (nodeNumber - 1) % colors.count
        return colors[index]
    }
}

// MARK: - Result Extension

extension Result {
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var error: Failure? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
