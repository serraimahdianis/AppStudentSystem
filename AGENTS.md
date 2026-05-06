# AGENTS.md
Comprehensive guidelines for agentic coding agents contributing to the Smart Attendance Student Flutter application. This file ensures consistent development practices across automated and human contributors.

## Project Overview
- **Type**: Cross-platform Flutter mobile application (Android/iOS) for student attendance tracking
- **Dart SDK**: >=3.0.0 <4.0.0 (null safety enabled by default)
- **State Management**: `provider` package using `ChangeNotifier` pattern for reactive state updates
- **Backend**: NestJS API running at `http://localhost:3000` (Swagger documentation available at `http://localhost:3000/api`)
- **Key Features**:
  - Student login with JWT authentication
  - Attendance tracking via QR code scanning or manual check-in
  - Dashboard with attendance statistics and visualizations (using `fl_chart`)
  - Session calendar with `table_calendar`
  - Push notifications via `flutter_local_notifications`
  - Biometric authentication using `local_auth`
- **Core Dependencies**:
  - State: `provider: ^6.1.1`
  - Networking: `http: ^1.1.0`, `dio: ^5.4.0` (prefer `http` for simple requests, `dio` for advanced features)
  - Storage: `flutter_secure_storage: ^9.0.0` (sensitive data), `shared_preferences: ^2.2.2` (cached data)
  - UI: `google_fonts: ^6.1.0`, `fl_chart: ^0.66.2`, `shimmer: ^3.0.0`, `cached_network_image: ^3.3.1`
  - Scanners: `qr_flutter: ^4.1.0`, `mobile_scanner: ^3.5.6` (QR code scanning)
  - Biometrics: `local_auth: ^2.1.8`

## Build, Lint, and Test Commands
### Build Commands
- **Android**:
  - Debug APK: `flutter build apk --debug`
  - Release APK (split per ABI): `flutter build apk --release --split-per-abi`
  - Release APK (universal): `flutter build apk --release`
- **iOS**:
  - Debug build: `flutter build ios --debug`
  - Release build: `flutter build ios --release` (requires macOS and Xcode)
- **Web**: `flutter build web --release` (for web-based attendance portal)
- **Run Debug App**: `flutter run` (connects to running emulator/device)

### Lint & Formatting
- **Static Analysis**: `flutter analyze` (enforces `flutter_lints: ^3.0.0` rules, which include: no `print` statements, prefer `const` widgets, proper null safety, etc.)
- **Code Formatting**: `dart format .` (formats all Dart files in the project)
- **Format Check**: `dart format . --set-exit-if-changed` (CI-ready check that exits with error if unformatted code exists)
- **Strict Analysis**: No custom `analysis_options.yaml` exists; all rules are inherited from `flutter_lints`. Do not add custom analysis options unless explicitly requested.

### Testing
- **Test Framework**: `flutter_test` (included as dev dependency)
- **Run All Tests**: `flutter test`
- **Run Single Test File**: `flutter test test/services/api_service_test.dart`
- **Run Single Test Case**: `flutter test --plain-name "login success" test/auth_test.dart`
- **Test Directory Structure**: Mirror `lib/` structure in `test/` (e.g., `lib/services/api_service.dart` → `test/services/api_service_test.dart`)
- **Current State**: No `test/` directory exists yet; create it following Flutter conventions when adding tests
- **Mocking**: Use `mockito` or `mocktail` if needed (not currently a dependency; add only if required)

## Code Style Guidelines
### General Rules
- Adhere strictly to `flutter_lints` rules (no warnings or errors allowed in `flutter analyze`)
- All code must use Dart null safety (no legacy null-unsafe code)
- Prefer `final` variables for immutable state
- Avoid using `dynamic` type unless absolutely necessary; use explicit typing

### Import Order (Strict)
Imports must be grouped in the following order, with exactly one blank line between groups:
1. **Dart SDK imports**: `dart:convert`, `dart:io`, etc.
2. **Flutter framework imports**: `package:flutter/material.dart`, `package:flutter/services.dart`, etc.
3. **Third-party package imports**: `package:provider/provider.dart`, `package:http/http.dart`, etc.
4. **Local project imports**: Relative paths (e.g., `../models/student.dart`, `providers/auth_provider.dart`)
- Example:
  ```dart
  import 'dart:convert';
  
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  
  import '../models/student.dart';
  import '../utils/constants.dart';
  ```

### Naming Conventions
- **Classes/Enums/Extensions**: `PascalCase` (e.g., `SmartAttendanceApp`, `ApiService`, `Student`, `AttendanceStatus`)
- **Variables/Functions/Methods/Parameters**: `camelCase` (e.g., `_token`, `getProfile()`, `isLoggedIn`, `studentId`)
- **Private Members**: Prefix with underscore `_` (e.g., `_SplashRouter`, `_instance`, `_headers`, `_student`)
- **Static Constants**: `lowerCamelCase` (e.g., `AppColors.primary`, `AppConstants.baseUrl`, `AppTheme.lightTheme`)
- **Provider Classes**: Suffix with `Provider` (e.g., `AuthProvider`, `AttendanceProvider`)
- **Model Classes**: Use singular nouns (e.g., `Student`, `Session`, `Attendance` not `Students`)
- **Files**: `snake_case` (e.g., `api_service.dart`, `auth_provider.dart`, `app_colors.dart`)

### Formatting
- Use `dart format` for all code formatting (never manually adjust formatting)
- **Trailing Commas**: Required for multi-line constructors, function parameters, collection literals, and widget trees to improve readability and reduce merge conflicts
- **Indentation**: 2 spaces (Dart convention, enforced by `dart format`)
- **Line Length**: Prefer lines under 80 characters; `dart format` will handle wrapping where possible
- **Widget Structure**: Break large widgets into smaller helper methods or separate widgets to improve readability

### Error Handling
- **API Service Layer** (`lib/services/api_service.dart`):
  - Throw `Exception` with descriptive messages for failed HTTP requests (e.g., `throw Exception('Failed to load profile: ${response.statusCode}')`)
  - Handle network errors (e.g., `SocketException`) and wrap in meaningful exceptions
- **Provider Layer**:
  - Use `try/catch` blocks for async operations
  - Set `_error` state variable with user-friendly messages
  - Call `notifyListeners()` after all state changes (including error state)
  - Clear error state when starting new operations
- **UI Layer**:
  - Display error messages from provider's `_error` state
  - Use `CircularProgressIndicator` for loading states
  - Handle empty states gracefully (e.g., no attendance records)

### State Management
- Use `ChangeNotifierProvider` for state injection
- Wrap the root app with `MultiProvider` for global state (see `lib/main.dart`)
- **Access Patterns**:
  - Reactive: `context.watch<AuthProvider>()` (rebuilds on `notifyListeners()`)
  - One-time: `context.read<AuthProvider>()` (no rebuild, use in callbacks)
- **Navigation Flow**:
  - After successful login, screens should navigate using `Navigator.of(context).pushAndRemoveUntil()` to `MainNavScreen()`
  - This replaces the entire navigation stack, preventing back navigation to login
  - Always check `mounted` before calling `Navigator` in async methods
- **Do Not**:
  - Use `context.watch` inside build methods for one-time operations (causes unnecessary rebuilds)
  - Call `notifyListeners()` in constructors or `initState` without proper async handling
  - Rely solely on `_SplashRouter` watching auth state for login navigation (may fail during async)

### Model Classes
- Follow the structure in `lib/models/models.dart`:
  - `final` fields for immutability
  - Required named parameters in constructors
  - `factory fromJson(Map<String, dynamic> json)` for API deserialization
  - `Map<String, dynamic> toJson()` for serialization
  - Handle null values with `??` operators (e.g., `json['fullName'] ?? ''`)
  - Use `DateTime.tryParse` for safe date parsing

### API Integration
- **Base Configuration**: All API settings in `lib/utils/constants.dart` (`AppConstants` class)
- **Base URL**: Default is `http://192.168.1.100:3000/api` → update to `http://localhost:3000/api` for local development (backend runs at `http://localhost:3000`, Swagger docs at `http://localhost:3000/api`)
- **Verified Endpoints** (mapped from running NestJS backend logs):
  | Endpoint Constant | Method | Path | Purpose |
  |-------------------|--------|------|---------|
  | `loginEndpoint` | POST | `/auth/student/login` | Student login (returns `token` + `student` on success) |
  | `profileEndpoint` | GET | `/students/:id` | Get student profile by ID (replace undocumented `/students/me`) |
  | `attendanceEndpoint` | GET | `/attendance/student/:studentId` | Get student attendance records (replace `/attendance/me`) |
  | `sessionsEndpoint` | GET | `/sessions` | Get all sessions (no `/sessions/my` endpoint exists) |
  | `sessionByIdEndpoint` | GET | `/sessions/:id` | Get single session details |
  | `attendanceScanEndpoint` | POST | `/attendance/scan` | Record attendance via QR code scan |
  | `modulesEndpoint` | GET | `/modules/teacher/:teacherId` | Get modules by teacher (no `/modules/my` endpoint exists) |
- **Removed Endpoints**: The following paths are not present in the current backend and must not be used:
  `/students/me`, `/students/me/dashboard`, `/students/me/qrcode`, `/attendance/me/calendar`, `/notifications`
- **Headers**: Authenticated requests include `Authorization: Bearer <token>` (handled automatically in `ApiService._headers`)
- **Token Management**: Store JWT in `FlutterSecureStorage` (key: `AppConstants.tokenKey`), cache user data in `SharedPreferences` (key: `AppConstants.studentKey`)
- **Response Handling**: Backend returns JSON with either:
  - Success: `{ "student": {}, "token": "", "attendances": [], "modules": [], ... }` (service maps to model objects)
  - Error: `{ "message": "error description" }` (service returns error message or throws `Exception`)
- **API Service**: All HTTP calls centralized in `lib/services/api_service.dart` using singleton pattern (`ApiService()` factory)

## Agent-Specific Rules
- **No Existing Rules**: No Cursor rules (`.cursorrules`, `.cursor/rules/`) or GitHub Copilot rules (`.github/copilot-instructions.md`) exist in this repository
- **Lint Compliance**: Always run `flutter analyze` after modifying Dart files to ensure no new warnings/errors (inherits `flutter_lints: ^3.0.0` rules)
- **Test Creation**: When adding features, create corresponding tests in `test/` directory following the mirroring structure (e.g., `lib/services/api_service.dart` → `test/services/api_service_test.dart`). No `test/` directory exists yet.
- **Sensitive Data**: Never commit auth tokens, API keys, or hardcoded URLs; use `AppConstants` for configurable values. Runtime token storage uses `FlutterSecureStorage`.
- **API Changes**: When modifying backend endpoints, update both `AppConstants` (endpoint paths) and corresponding `ApiService` methods (request/response handling)
- **UI Consistency**: All UI components must use the Material 3 theme defined in `lib/utils/constants.dart` (`AppTheme.lightTheme`) with `AppColors` for consistent coloring
- **Dependencies**: Only add new dependencies to `pubspec.yaml` if explicitly required; run `flutter pub get` after modifying `pubspec.yaml`
- **State Management**: All state classes must extend `ChangeNotifier`, call `notifyListeners()` after every state change, and use `MultiProvider` at root (see `lib/main.dart`)