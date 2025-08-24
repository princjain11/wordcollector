import SwiftUI

struct WordCollectorGame: View {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        headerView
                        
                        // Game info
                        gameInfoView
                        
                        // Letter grid
                        letterGridView
                        
                        // Controls
                        controlsView
                        
                        // Word list removed as requested
                    }
                    .padding()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $gameViewModel.showGameOver) {
            gameOverView
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Word Collector")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(radius: 3)
            
            HStack {
                Text("Score:")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("\(gameViewModel.score)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(radius: 10)
        )
    }
    
    // MARK: - Game Info View
    private var gameInfoView: some View {
        HStack(spacing: 20) {
            // Current word section removed as requested
            
            // Progress
            VStack(spacing: 10) {
                Text("Progress:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                ProgressView(value: gameViewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .scaleEffect(y: 2)
                    .frame(height: 20)
            }
        }
    }
    
    // MARK: - Letter Grid View
    private var letterGridView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 6), spacing: 15) {
            ForEach(Array(gameViewModel.letterGrid.enumerated()), id: \.offset) { index, letter in
                LetterButton(
                    letter: letter,
                    isCollected: gameViewModel.isLetterCollected(at: index),
                    action: {
                        gameViewModel.collectLetter(at: index)
                    }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(radius: 10)
        )
    }
    
    // MARK: - Controls View
    private var controlsView: some View {
        HStack(spacing: 20) {
            Button("New Word") {
                gameViewModel.newWord()
            }
            .buttonStyle(GameButtonStyle(backgroundColor: .blue))
            
            Button("Reset Game") {
                gameViewModel.resetGame()
            }
            .buttonStyle(GameButtonStyle(backgroundColor: .red))
        }
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Text("🎉 Game Complete! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Final Score: \(gameViewModel.score)")
                .font(.title)
                .foregroundColor(.primary)
            
            Button("Play Again") {
                gameViewModel.resetGame()
                gameViewModel.showGameOver = false
            }
            .buttonStyle(GameButtonStyle(backgroundColor: .blue))
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
        .presentationDetents([.medium])
    }
}

// MARK: - Letter Button
struct LetterButton: View {
    let letter: String
    let isCollected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(letter.uppercased())
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isCollected ? Color.green : Color.blue)
                )
                .shadow(radius: 5)
        }
        .disabled(isCollected)
        .scaleEffect(isCollected ? 0.9 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCollected)
    }
}

// MARK: - Game Button Style
struct GameButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(backgroundColor)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    WordCollectorGame()
}
