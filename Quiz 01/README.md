# Quiz1 - Simple Dice App

This is a beginner-friendly Flutter project for **Quiz 1**: a Simple Dice App.

## Features
- Shows a dice image (1-6) on screen.
- Tap the dice or the "ROLL DICE" button to roll a random number (1-6).
- Uses `setState()` to update the image.
- Light theme only.
- Font family set to `Poppins` in `pubspec.yaml`. To use the Poppins font:
  1. Download `Poppins-Regular.ttf` and place it in `assets/fonts/`
  2. Run `flutter pub get` so Flutter includes the font.

## Project Structure
```
Quiz1/
├── assets/
│   ├── fonts/
│   │   └── (add Poppins-Regular.ttf here if you want the Poppins font)
│   └── images/
│       ├── 1.png
│       ├── 2.png
│       ├── 3.png
│       ├── 4.png
│       ├── 5.png
│       └── 6.png
├── lib/
│   └── main.dart
├── pubspec.yaml
└── README.md
```

## How to run
1. Open project in VS Code or Android Studio.
2. Run `flutter pub get`.
3. Connect a device or start an emulator.
4. Run `flutter run`.

## Notes
- Dice images included are simple placeholder images with numbers. You can replace them with real dice graphics (1.png - 6.png) inside `assets/images/`.
- If you prefer the exact Poppins font, download it and place it in `assets/fonts/` as described above.

Good luck with your quiz! 🎲
