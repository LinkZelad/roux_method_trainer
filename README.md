# Roux Method Trainer

A comprehensive Flutter-based training application for the Roux Method of solving the Rubik's Cube. This app provides advanced tools for both beginners and experts to master Block Building, CMLL, and LSE.

![3D Cube Demo](screenshot_timer.png)

## 🚀 Key Features

### 🧊 Advanced 3D Visualization
- **Physical Rotation Animations**: High-fidelity 3D rendering with smooth, layer-by-layer rotation animations.
- **Dynamic Lighting**: Real-time shading and depth sorting for a professional 3D look.
- **Gesture Control**: Intuitive touch-based rotation to view the cube from any angle.

### 🎓 Teaching & Training
- **Teaching Mode (New)**: Guided learning for First Block (FB), Second Block (SB), and CMLL. Includes curated scenarios for common block-building challenges.
- **Full Roux Solve Demo (New)**: Watch a complete end-to-end Roux solve (FB -> SB -> CMLL -> LSE) to understand the global flow and efficient transitions.
- **Practice Trainer**: Specialized scrambles and **optimal solution analysis** for Roux sub-steps:
    - First Block (FB) & First Square (FS)
    - Second Block (SB)
    - CMLL (Random & Category-based)
    - LSE (EOLR & 4C)
- **Demo Mode**: Detailed algorithm playback with visual move indicators and playback controls.

### ⏱️ Performance Tracking
- **Smart Timer**: Specialized timer that tracks Roux-specific modes.
- **Weakness Analysis (New)**: Aggregated statistics that identify which specific CMLL cases or Roux steps are your slowest, helping you focus your practice.
- **Detailed History**: Keep track of your solves and monitor progress over time.
- **Reference Library**: Quick access to CMLL and LSE (EO, LR, 4C) algorithm sheets.

## 🛠️ Technical Implementation
- **Custom 3D Engine**: Built using Flutter `CustomPainter` and `vector_math` for efficient 3D projection without external heavy dependencies.
- **Advanced Solver**: Integrated mathematical solver that provides the shortest optimal path for FB/SB steps during practice.
- **Isolate-based Scrambling**: Heavy scramble generation and solving logic is offloaded to background isolates to ensure zero UI lag.
- **State Management**: Uses `Provider` for clean state separation and efficient UI updates.

## 📦 Getting Started

### Prerequisites
- Flutter SDK (latest stable version recommended)
- Android Studio / VS Code
- ADB for physical device testing

### Installation
1. Clone the repository:
   ```bash
   git clone git@github.com:LinkZelad/roux_method_trainer.git
   ```
2. Navigate to the project directory:
   ```bash
   cd roux_trainer
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## 📜 License
This project is licensed under the MIT License.

---
*Created by [LinkZelad](https://github.com/LinkZelad)*
