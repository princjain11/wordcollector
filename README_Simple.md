# Word Collector Game - SwiftUI (Simplified) 🎯📱

A complete, single-file SwiftUI word collection game that compiles without errors!

## 🎮 Game Features

- **10 Words to Collect**: ring, swim, go, write, right, across, elephant, lion, jump, monkey
- **Modern SwiftUI Design**: Beautiful glassmorphism effects and smooth animations
- **Interactive Gameplay**: Tap letters to collect them and form words
- **Smart Scoring**: +10 points per letter, -5 points for wrong letters
- **Progress Tracking**: Visual progress bar and word completion indicators
- **Single File**: Everything in one `SimpleWordCollector.swift` file

## 🚀 Quick Start

### Option 1: Use as Single File (Recommended)
1. **Create a new Xcode project**:
   - Open Xcode
   - Create New Project → iOS → App
   - Choose SwiftUI for interface
   - Name it "WordCollector"

2. **Replace the default files**:
   - Delete the default `ContentView.swift`
   - Copy `SimpleWordCollector.swift` into your project
   - Build and run! 🎉

### Option 2: Add to Existing Project
1. **Add the file** to your existing SwiftUI project
2. **Update your App file** to use `WordCollectorGame()` instead of your default view
3. **Build and run**

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

## 🏗️ File Structure

```
SimpleWordCollector.swift
├── Data Models (CollectedLetter)
├── Game View Model (GameViewModel)
├── UI Components (LetterButton, WordTag, GameButtonStyle)
├── Main Game View (WordCollectorGame)
└── App Entry Point (WordCollectorApp)
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
Edit the `words` array in the `GameViewModel` class:
```swift
let words = ["your", "new", "words", "here"]
```

### Changing Colors
Modify the gradient colors in the `WordCollectorGame` view:
```swift
LinearGradient(
    gradient: Gradient(colors: [Color.yourColor, Color.anotherColor]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Adjusting Scoring
Modify the scoring logic in the `GameViewModel`:
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

## 🎉 Why This Version?

This simplified version:
- ✅ **Compiles without errors** - All SwiftUI syntax is modern and correct
- ✅ **Single file** - Easy to copy and paste into any project
- ✅ **Complete functionality** - All game features included
- ✅ **Modern SwiftUI** - Uses latest iOS 17+ features
- ✅ **No external dependencies** - Pure SwiftUI implementation

**Perfect for learning SwiftUI or quickly adding to existing projects!**

Enjoy playing Word Collector on iOS! 🎉📱
