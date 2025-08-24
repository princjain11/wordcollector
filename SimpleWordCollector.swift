import SwiftUI
import AVFoundation

// MARK: - Data Models
struct CollectedLetter: Identifiable, Equatable {
    let id = UUID()
    let letter: String
    let gridIndex: Int
    let wordIndex: Int
    
    static func == (lhs: CollectedLetter, rhs: CollectedLetter) -> Bool {
        lhs.gridIndex == rhs.gridIndex
    }
}

// MARK: - Game View Model
class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var score: Int = 0
    @Published var currentWordIndex: Int = 0
    @Published var currentWord: String = ""
    @Published var collectedLetters: [CollectedLetter] = []
    @Published var letterGrid: [String] = []
    @Published var showGameOver: Bool = false
    @Published var wrongLetterIndices: Set<Int> = []
    @Published var showGreatPopup: Bool = false
    @Published var showWrongPopup: Bool = false
    @Published var tappedLetters: [String] = [] // Track all tapped letters
    @Published var isTargetWord: Bool = false // Track if submitted word is target word
    
    // MARK: - Game Data
    // Dictionary of meaningful words for validation
    let meaningfulWords = Set([
        "ring", "sing", "wing", "king", "bring", "spring", "string", "thing", "swing", "cling",
        "dream", "cream", "stream", "team", "beam", "seam", "gleam", "scream",
        "swim", "dim", "him", "rim", "trim", "grim", "prim", "slim",
        "boy", "toy", "joy", "coy", "ploy", "destroy", "enjoy",
        "doctor", "actor", "factor", "tractor", "reactor", "extractor",
        "song", "long", "strong", "wrong", "belong", "along", "among",
        "happy", "sappy", "snappy", "scrappy", "nappy", "zappy",
        "world", "word", "sword", "lord", "cord", "ford", "board",
        "music", "basic", "magic", "tragic", "comic", "atomic",
        "friend", "end", "bend", "send", "lend", "mend", "trend",
        "school", "cool", "pool", "tool", "fool", "stool", "rule",
        "family", "silly", "willy", "chilly", "hilly", "billy",
        "nature", "mature", "capture", "rapture", "sculpture",
        "beauty", "duty", "cute", "mute", "lute", "flute", "route",
        "wisdom", "kingdom", "freedom", "seldom", "random",
        "courage", "rage", "age", "sage", "wage", "stage", "page",
        "success", "access", "process", "progress", "express",
        "freedom", "kingdom", "wisdom", "seldom", "random",
        "peace", "piece", "cease", "lease", "grease", "increase",
        "love", "dove", "glove", "above", "prove", "move", "rove",
        "hope", "rope", "cope", "scope", "slope", "grope",
        "faith", "bait", "wait", "gait", "trait", "strait",
        "trust", "rust", "dust", "must", "just", "adjust", "robust",
        "honor", "sonor", "donor", "minor", "senior", "junior",
        "pride", "ride", "side", "wide", "hide", "guide", "slide",
        "grace", "race", "face", "pace", "space", "place", "trace",
        "power", "tower", "flower", "shower", "hour", "sour",
        "magic", "tragic", "basic", "music", "comic", "atomic",
        "wonder", "under", "thunder", "blunder", "plunder",
        "mystery", "history", "story", "glory", "victory",
        "adventure", "future", "nature", "capture", "rapture"
    ])
    
    // Words to collect (shuffled for random order)
    private var words: [String] = [
        "ring", "dream", "swim", "boy", "doctor", "song"
    ].shuffled()
    
    private var tapCounter: Int = 0 // Track tap sequence
    
    var currentWordDisplay: String {
        var display = ""
        for (index, _) in currentWord.enumerated() {
            if let collectedLetter = collectedLetters.first(where: { $0.wordIndex == index }) {
                display += collectedLetter.letter.uppercased()
            } else {
                display += " " // Use space instead of underscore
            }
        }
        return display
    }
    
    var tappedLettersDisplay: String {
        return tappedLetters.map { $0.uppercased() }.joined(separator: " ")
    }
    
    var progress: Double {
        Double(currentWordIndex) / Double(words.count)
    }
    
    init() {
        initializeGame()
    }
    
    func initializeGame() {
        currentWordIndex = 0
        score = 0
        currentWord = words[currentWordIndex]
        collectedLetters = []
        wrongLetterIndices = []
        tappedLetters = []
        generateLetterGrid()
    }
    
    private func generateLetterGrid() {
        letterGrid.removeAll()
        
        // Add letters from current word (ensuring uniqueness)
        var uniqueLetters = Set<String>()
        for letter in currentWord {
            uniqueLetters.insert(String(letter))
        }
        
        // Add unique letters from current word first
        for letter in uniqueLetters {
            letterGrid.append(letter)
        }
        
        // Calculate how many additional random letters to add
        let targetGridSize = min(10, max(8, currentWord.count + 2))
        let additionalLettersNeeded = targetGridSize - letterGrid.count
        
        // Add additional random letters if needed
        if additionalLettersNeeded > 0 {
            let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            var availableLetters = Set(alphabet.map { String($0) })
            
            // Remove letters already in the word
            for letter in uniqueLetters {
                availableLetters.remove(letter.uppercased())
            }
            
            // Add random letters
            for _ in 0..<additionalLettersNeeded {
                if let randomLetter = availableLetters.randomElement() {
                    letterGrid.append(randomLetter)
                    availableLetters.remove(randomLetter)
                }
            }
        }
        
        // Shuffle the grid for randomness
        letterGrid.shuffle()
    }
    
    func collectLetter(at gridIndex: Int) {
        let letter = letterGrid[gridIndex]
        
        // Check if this letter is correct for the current word
        let currentWordArray = Array(currentWord)
        var isCorrect = false
        var wordIndex = -1
        
        // Find if this letter exists in the current word
        for (index, wordLetter) in currentWordArray.enumerated() {
            if String(wordLetter).uppercased() == letter.uppercased() {
                // Check if this position is already filled
                let isPositionFilled = collectedLetters.contains { $0.wordIndex == index }
                if !isPositionFilled {
                    isCorrect = true
                    wordIndex = index
                    break
                }
            }
        }
        
        if isCorrect {
            // Correct letter - add to collected letters
            let collectedLetter = CollectedLetter(
                letter: letter,
                gridIndex: gridIndex,
                wordIndex: wordIndex
            )
            collectedLetters.append(collectedLetter)
            score += 2
            
            // Add to tapped letters for display
            tappedLetters.append(letter)
        } else {
            // Wrong letter - show feedback and lose points
            score = max(0, score - 5)
            wrongLetterIndices.insert(gridIndex)
            
            // Add to tapped letters even if wrong
            tappedLetters.append(letter)
            
            // Remove wrong letter feedback after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.wrongLetterIndices.remove(gridIndex)
            }
        }
    }
    
    func submitWord() {
        let submittedWord = tappedLetters.joined(separator: "")
        
        if submittedWord == currentWord {
            // Correct target word
            showGreatPopup = true
            score += 10
            isTargetWord = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showGreatPopup = false
                self.completeWord()
            }
        } else if meaningfulWords.contains(submittedWord.lowercased()) {
            // Correct meaningful word (but not target)
            showGreatPopup = true
            score += 5
            isTargetWord = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showGreatPopup = false
                // Clear tapped letters for meaningful words too
                self.tappedLetters.removeAll()
            }
        } else {
            // Wrong word
            showWrongPopup = true
            score = max(0, score - 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showWrongPopup = false
                // Clear tapped letters when word is wrong
                self.tappedLetters.removeAll()
            }
        }
    }
    
    func isLetterCollected(at gridIndex: Int) -> Bool {
        collectedLetters.contains { $0.gridIndex == gridIndex }
    }
    
    func isWrongLetter(at gridIndex: Int) -> Bool {
        wrongLetterIndices.contains(gridIndex)
    }
    
    // REMOVED: isWordComplete() function - no longer needed
    
    private func completeWord() {
        let wordScore = currentWord.count * 10
        score += wordScore
        
        currentWordIndex += 1
        
        if currentWordIndex >= words.count {
            showGameOver = true
        } else {
            currentWord = words[currentWordIndex]
            collectedLetters = []
            wrongLetterIndices = []
            tappedLetters = []
            generateLetterGrid()
        }
    }
    
    // Function to reshuffle words for new game
    private func reshuffleWords() {
        words = words.shuffled()
        print("🔄 Words reshuffled: \(words)")
    }
    
    func newWord() {
        // Reshuffle words for variety
        reshuffleWords()
        
        // Reset game state for new word
        collectedLetters.removeAll()
        wrongLetterIndices.removeAll()
        tappedLetters.removeAll()
        
        // Move to next word or restart
        if currentWordIndex < words.count - 1 {
            currentWordIndex += 1
        } else {
            // All words completed, restart from beginning
            currentWordIndex = 0
            print("🎯 All words completed! Starting over...")
        }
        
        currentWord = words[currentWordIndex]
        print("🎯 New word: \(currentWord)")
        
        // Generate new letter grid for new word
        generateLetterGrid()
    }
    
    func resetGame() {
        // Reshuffle words for new game
        reshuffleWords()
        
        // Reset all game state
        score = 0
        currentWordIndex = 0
        currentWord = words[currentWordIndex]
        collectedLetters.removeAll()
        wrongLetterIndices.removeAll()
        tappedLetters.removeAll()
        showGameOver = false
        showGreatPopup = false
        showWrongPopup = false
        isTargetWord = false
        
        print("🔄 Game reset! New word order: \(words)")
        print("🎯 Starting with: \(currentWord)")
        
        // Generate new letter grid
        generateLetterGrid()
    }
}

struct WordCollectorGame: View {
    @StateObject private var gameViewModel = GameViewModel()
    @State private var audioPlayer: AVAudioPlayer?
    
    // Function to play tap sound
    private func playTapSound() {
        print("🔊 ===== SOUND DEBUG START =====")
        print("🔊 Attempting to play sound...")
        
        // Test 1: Check if function is being called
        print("✅ Function called successfully")
        
        // Test 2: Check bundle path
        print("📁 Bundle path: \(Bundle.main.bundlePath)")
        
        // Test 3: List all files in bundle
        if let resourcePath = Bundle.main.resourcePath {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("📋 All bundle files: \(files)")
                
                // Check specifically for audio files
                let audioFiles = files.filter { $0.hasSuffix(".wav") || $0.hasSuffix(".mp3") || $0.hasSuffix(".m4a") }
                print("🎵 Audio files found: \(audioFiles)")
                
            } catch {
                print("❌ Could not list bundle contents: \(error)")
            }
        }
        
        // Test 4: Try to find jj.wav specifically
        guard let soundURL = Bundle.main.url(forResource: "jj", withExtension: "wav") else {
            print("❌ jj.wav not found in bundle")
            
            // Try alternative names
            let alternativeNames = ["jj", "JJ", "sound", "tap", "click"]
            for name in alternativeNames {
                if let url = Bundle.main.url(forResource: name, withExtension: "wav") {
                    print("✅ Found alternative: \(name).wav at \(url)")
                }
            }
            
            print("🔊 ===== SOUND DEBUG END =====")
            return
        }
        
        print("✅ jj.wav found at: \(soundURL)")
        
        // Test 5: Check if file exists at path
        let fileExists = FileManager.default.fileExists(atPath: soundURL.path)
        print("📁 File exists at path: \(fileExists)")
        
        // Test 6: Try to create audio player
        do {
            print("🎵 Creating audio player...")
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            print("✅ Audio player created successfully")
            
            // Test 7: Configure audio session
            print("🎵 Configuring audio session...")
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured")
            
            // Test 8: Prepare audio
            print("🎵 Preparing audio...")
            audioPlayer?.prepareToPlay()
            print("✅ Audio prepared")
            
            // Test 9: Play audio
            print("🎵 Playing audio...")
            let playResult = audioPlayer?.play() ?? false
            print("✅ Play result: \(playResult)")
            
            // Test 10: Check audio player properties
            print("🎵 Audio player info:")
            print("   - Duration: \(audioPlayer?.duration ?? 0) seconds")
            print("   - Volume: \(audioPlayer?.volume ?? 0)")
            print("   - Is playing: \(audioPlayer?.isPlaying ?? false)")
            
            print("🎵 jj.wav sound played successfully!")
            
        } catch {
            print("❌ Error playing sound: \(error.localizedDescription)")
            print("🔍 Detailed error: \(error)")
        }
        
        print("🔊 ===== SOUND DEBUG END =====")
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.8),
                        Color.blue.opacity(0.6),
                        Color.indigo.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated background pattern
                GeometryReader { geometry in
                    ForEach(0..<20, id: \.self) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: CGFloat.random(in: 50...150))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            .animation(
                                Animation.easeInOut(duration: Double.random(in: 3...8))
                                    .repeatForever(autoreverses: true),
                                value: index
                            )
                    }
                }
                
                ScrollView {
                    VStack(spacing: 25) {
                        headerView
                        gameInfoView
                        
                        Spacer(minLength: 30)
                        
                        letterGridView
                        controlsView
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $gameViewModel.showGameOver) {
            gameOverView
        }
        .overlay(
            Group {
                if gameViewModel.showGreatPopup {
                    greatPopupView
                }
                if gameViewModel.showWrongPopup {
                    wrongPopupView
                }
            }
        )
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            // Header removed - no title or progress line
        }
    }
    
    private var gameInfoView: some View {
        VStack(spacing: 25) {
            // Title
            Text("TAPPED LETTERS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(2)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        // Rainbow gradient background
                        LinearGradient(
                            colors: [
                                Color.red.opacity(0.9),
                                Color.orange.opacity(0.9),
                                Color.yellow.opacity(0.9),
                                Color.green.opacity(0.9),
                                Color.blue.opacity(0.9),
                                Color.purple.opacity(0.9),
                                Color.pink.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Enhanced shimmer effect overlay
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear,
                                Color.white.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Animated rainbow border
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.red,
                                        Color.orange,
                                        Color.yellow,
                                        Color.green,
                                        Color.blue,
                                        Color.purple,
                                        Color.pink
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.purple.opacity(0.8),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            
            // Colorful Tapped Letters Display
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(Array(gameViewModel.tappedLetters.enumerated()), id: \.offset) { index, letter in
                    Text(letter.uppercased())
                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            ZStack {
                                // Dynamic color based on letter
                                let colors: [Color] = [
                                    .blue, .purple, .pink, .orange, .red, .green, .indigo, .teal
                                ]
                                let colorIndex = abs(letter.hashValue) % colors.count
                                let letterColor = colors[colorIndex]
                                
                                // Main gradient background
                                LinearGradient(
                                    colors: [
                                        letterColor.opacity(0.9),
                                        letterColor.opacity(0.7),
                                        letterColor.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                
                                // Shimmer effect
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.clear,
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.7),
                                            Color.white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                        .shadow(
                            color: Color.blue.opacity(0.4),
                            radius: 6,
                            x: 0,
                            y: 3
                        )
                }
            }
            .frame(minHeight: 100)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            .padding(.vertical, 25)
            .background(
                ZStack {
                    // Main glassmorphism background
                    RoundedRectangle(cornerRadius: 35)
                        .fill(.ultraThinMaterial)
                    
                    // Enhanced gradient overlay
                    RoundedRectangle(cornerRadius: 35)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Multiple border layers for depth
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                    
                    // Inner glow effect
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: Color.white.opacity(0.25),
                radius: 25,
                x: 0,
                y: 12
            )
            .overlay(
                // Subtle corner highlights
                RoundedRectangle(cornerRadius: 35)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
    }
    
    private var letterGridView: some View {
        VStack(spacing: 15) {
            Text("LETTER GRID")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .tracking(1)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(Array(gameViewModel.letterGrid.enumerated()), id: \.offset) { index, letter in
                    LetterButton(
                        letter: letter,
                        isCollected: gameViewModel.isLetterCollected(at: index),
                        isWrongLetter: gameViewModel.isWrongLetter(at: index)
                    ) {
                        gameViewModel.collectLetter(at: index)
                        playTapSound() // Play sound on tap
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 10)
        .background(
            ZStack {
                // Modern glassmorphism effect
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear,
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Border glow
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(
            color: Color.white.opacity(0.15),
            radius: 20,
            x: 0,
            y: 10
        )
    }
    
    private var controlsView: some View {
        VStack(spacing: 20) {
            // Test Sound Button (for debugging)
            Button(action: {
                playTapSound()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("TEST SOUND")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.9),
                                Color.orange.opacity(0.7),
                                Color.orange.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.orange.opacity(0.5),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Submit Button
            Button(action: {
                gameViewModel.submitWord()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("SUBMIT WORD")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 65)
                .background(
                    ZStack {
                        // Main gradient background
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.95),
                                Color.green.opacity(0.85),
                                Color.green.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Enhanced pattern overlay
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(
                    color: Color.green.opacity(0.8),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(gameViewModel.tappedLetters.isEmpty)
            .scaleEffect(gameViewModel.tappedLetters.isEmpty ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: gameViewModel.tappedLetters.isEmpty)
            
            // New Word Button
            Button(action: {
                gameViewModel.newWord()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("NEW WORD")
                        .font(.system(size: 20, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 65)
                .background(
                    ZStack {
                        // Main gradient background
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.9),
                                Color.blue.opacity(0.7),
                                Color.blue.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Enhanced pattern overlay
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(
                    color: Color.blue.opacity(0.6),
                    radius: 20,
                    x: 0,
                    y: 10
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 25)
    }
    
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Text("🎉 GAME COMPLETE! 🎉")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Text("FINAL SCORE")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(gameViewModel.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 2)
                    )
            )
            
            Button("PLAY AGAIN") {
                gameViewModel.showGameOver = false
                gameViewModel.resetGame()
            }
            .buttonStyle(ModernButtonStyle(color: .green))
        }
        .padding(40)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(30)
    }
    
    private var greatPopupView: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    gameViewModel.showGreatPopup = false
                }
            
            // Main popup
            VStack(spacing: 25) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.green.opacity(0.9),
                                    Color.green.opacity(0.7),
                                    Color.green.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: Color.green.opacity(0.6),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Title
                Text("🎉 GREAT JOB! 🎉")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .tracking(2)
                
                // Message
                Text(gameViewModel.isTargetWord ? "You completed the word!" : "You found a meaningful word!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Score info
                HStack(spacing: 15) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text("+\(gameViewModel.isTargetWord ? "10" : "5")")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Score: \(gameViewModel.score)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // OK button
                Button("CONTINUE") {
                    gameViewModel.showGreatPopup = false
                }
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.9),
                                Color.blue.opacity(0.7),
                                Color.blue.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.blue.opacity(0.5),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 35)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                    
                    // Enhanced gradient overlay
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Multiple border layers
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                }
            )
            .shadow(
                color: Color.white.opacity(0.2),
                radius: 30,
                x: 0,
                y: 15
            )
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameViewModel.showGreatPopup)
    }
    
    private var wrongPopupView: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    gameViewModel.showWrongPopup = false
                }
            
            // Main popup
            VStack(spacing: 25) {
                // Error icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.red.opacity(0.9),
                                    Color.red.opacity(0.7),
                                    Color.red.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(
                            color: Color.red.opacity(0.6),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Title
                Text("❌ WRONG WORD! ❌")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .tracking(2)
                
                // Message
                Text("That's not a valid word. Try again!")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Penalty info
                HStack(spacing: 15) {
                    HStack(spacing: 8) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                        
                        Text("-2")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Text("Score: \(gameViewModel.score)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                
                // Try again button
                Button("TRY AGAIN") {
                    gameViewModel.showWrongPopup = false
                }
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(
                    ZStack {
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.9),
                                Color.orange.opacity(0.7),
                                Color.orange.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: Color.orange.opacity(0.5),
                    radius: 15,
                    x: 0,
                    y: 8
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 35)
            .background(
                ZStack {
                    // Main background
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.ultraThinMaterial)
                    
                    // Enhanced gradient overlay
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Multiple border layers
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                }
            )
            .shadow(
                color: Color.white.opacity(0.2),
                radius: 30,
                x: 0,
                y: 15
            )
        }
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: gameViewModel.showWrongPopup)
    }
}

struct LetterButton: View {
    let letter: String
    let isCollected: Bool
    let isWrongLetter: Bool
    let action: () -> Void
    
    // Modern color palette
    private let colors: [Color] = [
        .blue, .purple, .pink, .orange, .red, .green, .indigo, .teal
    ]
    
    private var backgroundColor: Color {
        if isWrongLetter {
            return .red.opacity(0.8)
        } else if isCollected {
            return .green.opacity(0.8)
        } else {
            let index = abs(letter.hashValue) % colors.count
            return colors[index]
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(letter.uppercased())
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    ZStack {
                        // Main gradient background
                        LinearGradient(
                            colors: [
                                backgroundColor.opacity(0.9),
                                backgroundColor.opacity(0.7),
                                backgroundColor.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Shimmer effect
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: backgroundColor.opacity(0.6),
                    radius: 12,
                    x: 0,
                    y: 6
                )
                .scaleEffect(isCollected ? 1.1 : 1.0)
                .rotation3DEffect(
                    .degrees(isCollected ? 360 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isCollected)
        .animation(.easeInOut(duration: 0.3), value: isWrongLetter)
    }
}

struct ModernButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    // Modern gradient background
                    LinearGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.7),
                            color.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle pattern overlay
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.2),
                            Color.clear,
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: color.opacity(0.5),
                radius: 15,
                x: 0,
                y: 8
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    WordCollectorGame()
}




