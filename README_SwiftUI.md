# Word Collector Game - SwiftUI Version 🎯📱

A modern iOS word collection game built with SwiftUI where players collect letters to form words from a grid of random letters.

## 🎮 Game Features

- **10 Words to Collect**: ring, swim, go, write, right, across, elephant, lion, jump, monkey
- **Modern SwiftUI Design**: Beautiful glassmorphism effects and smooth animations
- **Interactive Gameplay**: Tap letters to collect them and form words
- **Smart Scoring**: +10 points per letter, -5 points for wrong letters
- **Progress Tracking**: Visual progress bar and word completion indicators
- **Responsive Design**: Optimized for both iPhone and iPad

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS 14.0+ (for development)

### Installation

1. **Clone or Download** the project files
2. **Open Xcode** and select "Open a project or file"
3. **Navigate** to the project folder and select `WordCollector.xcodeproj`
4. **Select your target device** (iPhone Simulator or physical device)
5. **Build and Run** the project (⌘+R)

### Alternative Setup (without Xcode project)
If you prefer to create a new Xcode project manually:

1. Create a new **iOS App** project in Xcode
2. Choose **SwiftUI** for interface and **Swift** for language
3. Copy the Swift files into your project:
   - `WordCollectorApp.swift` → Replace your default App file
   - `WordCollectorGame.swift` → Add to your project
   - `GameViewModel.swift` → Add to your project
4. Build and run

## 📱 How to Play

1. **Objective**: Collect letters from the grid to form the current word displayed at the top
2. **Gameplay**: 
   - Tap letters in the grid to collect them
   - Only collect letters that are needed for the current word
   - Letters must be collected in the correct order
   - Wrong letters will reduce your score
3. **Scoring**: 
   - +10 points per letter in the completed word
   - -5 points for tapping wrong letters
4. **Progress**: Complete all 10 words to finish the game

## 🏗️ Project Structure

```
WordCollector/
├── WordCollectorApp.swift      # Main app entry point
├── WordCollectorGame.swift     # Main game view
├── GameViewModel.swift         # Game logic and state management
└── WordCollector.xcodeproj/   # Xcode project file
```

## 🎨 SwiftUI Features Used

- **@StateObject** and **@Published** for reactive state management
- **LazyVGrid** for efficient letter grid layout
- **LinearGradient** and **.ultraThinMaterial** for modern design
- **Animation** and **transition** effects
- **Sheet** presentation for game over screen
- **Custom ButtonStyle** for consistent button appearance

## 🔧 Customization

### Adding New Words
Edit the `words` array in `GameViewModel.swift`:
```swift
let words = ["your", "new", "words", "here"]
```

### Changing Colors
Modify the gradient colors in `WordCollectorGame.swift`:
```swift
LinearGradient(
    gradient: Gradient(colors: [Color.yourColor, Color.anotherColor]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Adjusting Scoring
Modify the scoring logic in `GameViewModel.swift`:
```swift
let wordScore = currentWord.count * 10  // Change multiplier
score = max(0, score - 5)               // Change penalty
```

## 📱 Device Support

- **iPhone**: All screen sizes (iPhone SE to iPhone 15 Pro Max)
- **iPad**: Portrait and landscape orientations
- **iOS Versions**: iOS 17.0 and later

## 🎯 Game Mechanics

- **Letter Grid**: Randomly generated grid with letters from the current word plus random letters
- **Smart Collection**: System ensures letters are collected in the correct order
- **Visual Feedback**: Collected letters turn green, wrong letters show red briefly
- **Word Completion**: Progress is shown with underscores and revealed letters
- **Game Over**: Celebration screen when all words are completed

## 🚀 Performance Features

- **LazyVGrid**: Efficient rendering of large letter grids
- **State Management**: Optimized with @Published properties
- **Memory Management**: Proper use of weak references and cleanup
- **Smooth Animations**: 60fps animations with proper easing

## 🔍 Troubleshooting

### Common Issues

1. **Build Errors**: Ensure you're using Xcode 15.0+ and iOS 17.0+ deployment target
2. **Simulator Issues**: Try resetting the simulator (Device → Erase All Content and Settings)
3. **Performance**: If running on older devices, reduce animation complexity

### Debug Tips

- Use Xcode's **Debug View Hierarchy** to inspect UI elements
- Check the **Console** for any runtime errors
- Use **Breakpoints** in GameViewModel for debugging game logic

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve the game!

---

Enjoy playing Word Collector on iOS! 🎉📱
