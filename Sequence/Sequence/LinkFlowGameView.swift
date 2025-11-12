//
//  LinkFlowGameView.swift
//  Sequence
//
//  Created by Amarjit on 12/11/2025.
//


import Foundation
import SwiftUI

// MARK: - Main Game View

struct LinkFlowGameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button("Reset") {
                    viewModel.resetLevel()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                Spacer()
                
                Text(viewModel.currentLevelName)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button("←") {
                        viewModel.previousLevel()
                    }
                    .disabled(viewModel.currentLevelIndex == 0)
                    
                    Button("→") {
                        viewModel.nextLevel()
                    }
                    .disabled(viewModel.currentLevelIndex == viewModel.totalLevels - 1)
                }
                .font(.title2)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(1...viewModel.maxNodeNumber, id: \.self) { number in
                    Circle()
                        .fill(number <= viewModel.currentNumber ? 
                              viewModel.colorForNode(number) : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                }
            }
            
            // Game Grid
            PuzzleGridView(gameState: viewModel.gameState)
                .aspectRatio(1, contentMode: .fit)
                .padding()
            
            Spacer()
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                viewModel.showCompletion()
            }
        }
        .overlay {
            if viewModel.showingCompletion {
                CompletionOverlay(
                    levelName: viewModel.currentLevelName,
                    onNext: {
                        viewModel.nextLevelAfterCompletion()
                    },
                    onReplay: {
                        viewModel.replayLevel()
                    },
                    hasNextLevel: viewModel.hasNextLevel
                )
            }
        }
    }
}

// MARK: - Game View Model

/// Centralized view model that manages game state and level progression
class GameViewModel: ObservableObject {
    @Published private(set) var gameState: PathGameState
    @Published private(set) var showingCompletion = false
    
    private let levelManager = LevelManager()
    
    // Computed properties for UI bindings
    var currentLevelIndex: Int {
        levelManager.currentLevelIndex
    }
    
    var totalLevels: Int {
        levelManager.levels.count
    }
    
    var currentLevelName: String {
        gameState.level.name
    }
    
    var maxNodeNumber: Int {
        gameState.level.maxNodeNumber
    }
    
    var currentNumber: Int {
        gameState.currentNumber
    }
    
    var isComplete: Bool {
        gameState.isComplete
    }
    
    var hasNextLevel: Bool {
        currentLevelIndex < totalLevels - 1
    }
    
    init() {
        // Initialize with first level
        guard let firstLevel = levelManager.currentLevel else {
            fatalError("LevelManager must have at least one level")
        }
        self.gameState = PathGameState(level: firstLevel)
    }
    
    // MARK: - Public Methods
    
    func resetLevel() {
        gameState.reset()
        showingCompletion = false
    }
    
    func nextLevel() {
        levelManager.nextLevel()
        loadCurrentLevel()
    }
    
    func previousLevel() {
        levelManager.previousLevel()
        loadCurrentLevel()
    }
    
    func showCompletion() {
        showingCompletion = true
    }
    
    func nextLevelAfterCompletion() {
        levelManager.nextLevel()
        loadCurrentLevel()
        showingCompletion = false
    }
    
    func replayLevel() {
        gameState.reset()
        showingCompletion = false
    }
    
    func colorForNode(_ number: Int) -> Color {
        gameState.level.colorForNode(number)
    }
    
    // MARK: - Private Methods
    
    private func loadCurrentLevel() {
        guard let level = levelManager.currentLevel else { return }
        gameState = PathGameState(level: level)
        showingCompletion = false
    }
}

// MARK: - Puzzle Grid View

struct PuzzleGridView: View {
    @ObservedObject var gameState: PathGameState
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = geometry.size.width / CGFloat(gameState.level.gridSize)
            
            ZStack {
                // Grid background
                GridBackgroundView(gridSize: gameState.level.gridSize, cellSize: cellSize)
                
                // Path fill (visited cells)
                PathFillView(
                    visitedCells: gameState.visitedCells,
                    cellSize: cellSize,
                    level: gameState.level
                )
                
                // Path line
                PathLineView(
                    path: gameState.currentPath,
                    cellSize: cellSize,
                    color: gameState.level.colorForNode(1)
                )
                
                // Number nodes
                NumberNodesView(
                    level: gameState.level,
                    cellSize: cellSize,
                    currentNumber: gameState.currentNumber
                )
            }
            .contentShape(Rectangle()) // Make entire area draggable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChanged(value.location, cellSize: cellSize)
                    }
                    .onEnded { _ in
                        handleDragEnded()
                    }
            )
        }
    }
    
    private func handleDragChanged(_ location: CGPoint, cellSize: CGFloat) {
        guard let gridPos = GridPosition.from(
            point: location,
            cellSize: cellSize,
            gridSize: gameState.level.gridSize
        ) else { return }
        
        // If dragging over an existing position in the path, clear everything after it
        if let index = gameState.currentPath.firstIndex(of: gridPos) {
            if index < gameState.currentPath.count - 1 {
                gameState.clearPathAfter(gridPos)
            }
            return
        }
        
        // Try to add the position
        let result = gameState.addPosition(gridPos)
        
        // Optional: Could add haptic feedback here for errors
        if case .failure = result {
            // Could trigger haptic feedback or animation
        }
    }
    
    private func handleDragEnded() {
        // Drag ended - could add completion check or cleanup here if needed
    }
}

// MARK: - Grid Background

struct GridBackgroundView: View {
    let gridSize: Int
    let cellSize: CGFloat
    
    var body: some View {
        Canvas { context, size in
            // Draw grid lines
            let gridPath = Path { path in
                // Vertical lines
                for i in 0...gridSize {
                    let x = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                
                // Horizontal lines
                for i in 0...gridSize {
                    let y = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            
            context.stroke(
                gridPath,
                with: .color(.gray.opacity(0.3)),
                lineWidth: 1
            )
        }
        .background(Color.white)
    }
}

// MARK: - Path Fill View

struct PathFillView: View {
    let visitedCells: Set<GridPosition>
    let cellSize: CGFloat
    let level: Level
    
    var body: some View {
        Canvas { context, _ in
            for position in visitedCells {
                let rect = CGRect(
                    x: CGFloat(position.col) * cellSize + 2,
                    y: CGFloat(position.row) * cellSize + 2,
                    width: cellSize - 4,
                    height: cellSize - 4
                )
                
                let roundedRect = RoundedRectangle(cornerRadius: 4)
                    .path(in: rect)
                
                context.fill(
                    roundedRect,
                    with: .color(level.colorForNode(1).opacity(0.3))
                )
            }
        }
    }
}

// MARK: - Path Line View

struct PathLineView: View {
    let path: [GridPosition]
    let cellSize: CGFloat
    let color: Color
    
    var body: some View {
        Canvas { context, _ in
            guard path.count > 1 else { return }
            
            let linePath = Path { pathBuilder in
                let firstPoint = path[0].toPoint(cellSize: cellSize)
                pathBuilder.move(to: firstPoint)
                
                for i in 1..<path.count {
                    let point = path[i].toPoint(cellSize: cellSize)
                    pathBuilder.addLine(to: point)
                }
            }
            
            context.stroke(
                linePath,
                with: .color(color),
                style: StrokeStyle(
                    lineWidth: 8,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
    }
}

// MARK: - Number Nodes View

struct NumberNodesView: View {
    let level: Level
    let cellSize: CGFloat
    let currentNumber: Int
    
    var body: some View {
        ForEach(Array(level.nodes.keys.sorted()), id: \.self) { number in
            if let position = level.nodes[number] {
                NumberNodeView(
                    number: number,
                    position: position,
                    cellSize: cellSize,
                    color: level.colorForNode(number),
                    isActive: number == 1 || number == currentNumber + 1,
                    isCompleted: number <= currentNumber
                )
            }
        }
    }
}

// MARK: - Individual Number Node

struct NumberNodeView: View {
    let number: Int
    let position: GridPosition
    let cellSize: CGFloat
    let color: Color
    let isActive: Bool
    let isCompleted: Bool
    
    var body: some View {
        let point = position.toPoint(cellSize: cellSize)
        
        ZStack {
            // Outer glow for active nodes
            if isActive && !isCompleted {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
            }
            
            // Main circle
            Circle()
                .fill(isCompleted ? color : Color.white)
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
            
            // Border
            Circle()
                .stroke(color, lineWidth: 3)
                .frame(width: cellSize * 0.5, height: cellSize * 0.5)
            
            // Number text
            Text("\(number)")
                .font(.system(size: cellSize * 0.25, weight: .bold))
                .foregroundColor(isCompleted ? .white : color)
        }
        .position(point)
    }
}

// MARK: - Completion Overlay

struct CompletionOverlay: View {
    let levelName: String
    let onNext: () -> Void
    let onReplay: () -> Void
    let hasNextLevel: Bool
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Prevent dismissing on background tap
                }
            
            // Completion card
            VStack(spacing: 25) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }
                
                // Title
                Text("Level Complete!")
                    .font(.system(size: 32, weight: .bold))
                
                Text(levelName)
                    .font(.title3)
                    .foregroundColor(.gray)
                
                // Buttons
                VStack(spacing: 12) {
                    if hasNextLevel {
                        Button(action: onNext) {
                            HStack {
                                Text("Next Level")
                                    .font(.headline)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button(action: onReplay) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Replay")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(radius: 20)
            )
            .padding(40)
        }
    }
}

// MARK: - Preview

#Preview {
    LinkFlowGameView()
}
