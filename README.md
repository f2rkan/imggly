# imggly

imggly is a fun and interactive image puzzle game built using Swift and UIKit. The game allows users to upload an image, which is then sliced into blocks that they must rearrange to solve the puzzle. The application includes features such as difficulty levels, a click counter, and music control.

## Features

- **Image Upload**: Users can upload their own images to create a custom puzzle.
- **Interactive Blocks**: The image is divided into blocks that can be moved around by the user.
- **Difficulty Control**: Users can select the difficulty level to adjust the number of blocks in the puzzle.
- **Click Counter**: Tracks the number of moves the user makes to solve the puzzle.
- **Background Music**: Users can toggle background music on and off.
- **Reset Functionality**: Users can reset the game to start over.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/imggly.git
   ```

2. Open the project in Xcode:
   ```bash
   open imggly.xcodeproj
   ```

3. Run the app on a simulator or a physical device.

## How to Use

1. Launch the app on your device or simulator.
2. Tap the "Upload Image" button to select an image from your photo library.
3. Choose a difficulty level from the segmented control.
4. Try to rearrange the blocks to form the original image by dragging them.
5. Use the click counter to track your moves.
6. If needed, tap the "Reset" button to start over.

## Code Overview

The main functionality is handled in the `ViewController.swift` file. Key components include:

- **Game View Setup**: The game view is set up to display the puzzle blocks.
- **Image Slicing**: The uploaded image is divided into smaller sections using the `slice(image:into:)` function.
- **Block Management**: Blocks are created, displayed, and manipulated to allow user interaction.
- **Game Logic**: Functions to scramble the blocks, reset the game, and track user interactions are implemented.

### Key Classes

- **ViewController**: The main controller for managing the game interface and logic.
- **MyBlock**: A custom UIView subclass representing each block of the puzzle.

## Requirements

- iOS 13.0 or later
- Xcode 12.0 or later

## Acknowledgements

- UIKit for providing the essential framework for building iOS applications.
- AVFoundation for managing audio playback.
