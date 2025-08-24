# Word Collector Game

A modern iOS word collection game built with SwiftUI.

## Features

- Colorful letter grid with modern UI design
- Tap letters to form words
- Submit words for validation
- Beautiful animations and visual effects
- Sound effects when tapping letters

## Sound Setup

To enable sound effects, add your `pp.ogg` sound file to the project:

1. **Add Sound File:**
   - Drag and drop `pp.ogg` into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add to your main app target

2. **File Location:**
   - Place the sound file in the main bundle
   - The app will automatically find it at runtime

3. **Sound Format:**
   - Currently supports `.ogg` format
   - Can be easily modified to support other formats (mp3, wav, etc.)

## Game Controls

- **Tap Letters**: Select letters to form words
- **Submit Word**: Check if your word is correct
- **New Word**: Start with a new target word
- **Sound**: Each letter tap plays a sound effect

## Technical Details

- Built with SwiftUI
- Uses AVFoundation for audio playback
- Modern glassmorphism design
- Responsive layout for all screen sizes

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
