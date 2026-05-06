# Smart Attendance Student - Project Context

This file provides essential context and instructions for AI agents and developers working on the Smart Attendance Student Flutter application.

## 🚀 Project Overview
- **Purpose**: A cross-platform mobile application for students to track attendance, view schedules, and manage their profile within the Smart Attendance ecosystem.
- **Frontend**: Flutter (>=3.0.0 <4.0.0) with Dart.
- **Backend**: NestJS API (typically running at `http://localhost:3000`).
- **State Management**: `provider` package using the `ChangeNotifier` pattern.
- **Key Features**:
  - JWT-based authentication.
  - QR code scanning for attendance marking.
  - Interactive dashboard with attendance statistics (`fl_chart`).
  - Session calendar and history.
  - Push notifications and biometric authentication support.

## 🛠 Building and Running
### Installation
1.  **Get dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Configure API**:
    Update `baseUrl` in `lib/utils/constants.dart` if the backend is not on `localhost:3000`.

### Running the App
- **Debug mode**:
  ```bash
  flutter run
  ```
- **Release build (Android)**:
  ```bash
  flutter build apk --release
  ```

### Testing and Linting
- **Run tests**:
  ```bash
  flutter test
  ```
- **Static analysis**:
  ```bash
  flutter analyze
  ```
- **Code formatting**:
  ```bash
  dart format .
  ```

## 🏗 Architecture and Conventions
### State Management
- Use `Provider` and `ChangeNotifier` for reactive state.
- Global providers are initialized in `lib/main.dart` via `MultiProvider`.
- Access patterns: `context.watch<T>()` for UI updates, `context.read<T>()` for one-time actions (like button presses).

### API Integration
- **ApiService**: Centralized singleton in `lib/services/api_service.dart`.
- **Authentication**: JWT tokens are stored securely using `flutter_secure_storage`. Non-sensitive user data is cached in `shared_preferences`.
- **Endpoints**: Defined in `AppConstants` (`lib/utils/constants.dart`).

### Coding Style
- **Linter**: Follows `flutter_lints`. No `print()` statements; use `debugPrint()` or logging if necessary.
- **Naming**:
  - `PascalCase`: Classes, Enums, Extensions.
  - `camelCase`: Variables, Functions, Parameters.
  - `snake_case`: Files and Directories.
  - `_privateMember`: Prefix private members with an underscore.
- **Imports**: Group imports in this order:
  1.  Dart SDK (`dart:...`)
  2.  Flutter Framework (`package:flutter/...`)
  3.  Third-party packages (`package:...`)
  4.  Local project files (Relative paths)

### Project Structure
- `lib/models/`: Data models with `fromJson`/`toJson`.
- `lib/providers/`: Business logic and state management.
- `lib/screens/`: UI screens and navigation logic.
- `lib/services/`: External service integrations (API, Storage).
- `lib/utils/`: Constants, themes, and helper functions.
- `lib/widgets/`: Reusable UI components.

## 📝 Contribution Guidelines
- **Tests**: Mirror the `lib/` structure in the `test/` directory. Always add tests for new features or bug fixes.
- **Documentation**: Keep `README.md` and `AGENTS.md` updated with significant changes to features or architecture.
- **Clean Code**: Keep widgets small and modular. Prefer `final` for immutable variables. Ensure all code is null-safe.
