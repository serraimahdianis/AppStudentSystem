# Smart Attendance - Student App

A cross-platform Flutter mobile application for students to track attendance, view schedules, and receive notifications. Built with Material 3 design and integrated with a NestJS backend.

## 📱 Features

### Core Features
- **JWT Authentication** - Secure student login with Student ID and password
- **Attendance Tracking** - View attendance history with filters by subject and status
- **Dashboard** - Visual statistics with attendance rates and per-module breakdown
- **Session Management** - View upcoming and completed sessions with calendar view
- **QR Code Integration** - Unique student QR code for attendance marking
- **Push Notifications** - Attendance alerts, session updates, and exclusion warnings
- **Biometric Authentication** - Local auth support (fingerprint/face recognition)
- **Offline Support** - Cached data with SharedPreferences
- **Pull-to-Refresh** - Refresh data on dashboard and list screens
- **Exclusion Detection** - Automatic detection after 3 unexcused or 5 total absences

### Attendance Status
| Status | Color | Description |
|--------|-------|-------------|
| Present | 🟢 Green `#10B981` | Student attended the session |
| Late | 🟡 Yellow `#F59E0B` | Student arrived late |
| Absent | 🔴 Red `#EF4444` | Student did not attend |
| Excluded | 🟠 Orange `#F97316` | Student excluded after policy violation |

## 🛠 Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter >=3.0.0 <4.0.0
- **State Management**: `provider: ^6.1.1` (ChangeNotifier pattern)
- **HTTP Client**: `http: ^1.1.0`, `dio: ^5.4.0`
- **Local Storage**: `flutter_secure_storage: ^9.0.0` (encrypted), `shared_preferences: ^2.2.2` (cached data)
- **UI Components**:
  - `google_fonts: ^6.1.0` (Poppins font)
  - `fl_chart: ^0.66.2` (Charts and graphs)
  - `shimmer: ^3.0.0` (Loading effects)
  - `cached_network_image: ^3.3.1`
  - `table_calendar: ^3.0.9` (Calendar view)
  - `percent_indicator: ^4.2.3` (Circular indicators)
  - `lottie: ^3.0.0` (Animations)
- **QR Code**: `qr_flutter: ^4.1.0`, `mobile_scanner: ^3.5.6`
- **Notifications**: `flutter_local_notifications: ^17.0.0`
- **Biometrics**: `local_auth: ^2.1.8`
- **Other**: `intl: ^0.19.0`, `flutter_svg: ^2.0.9`

### Backend (NestJS)
- **Framework**: NestJS with TypeScript
- **API Base URL**: `http://localhost:3000`
- **Swagger Docs**: `http://localhost:3000/api`
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT with Passport

## 📋 Prerequisites

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0 <4.0.0
- Android Studio / Xcode (for mobile deployment)
- NestJS backend running (see backend setup)
- Android/iOS device or emulator
- For physical devices: computer and device on same network

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd smart_attendance_student
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend URL

Edit `lib/utils/constants.dart` and update the `baseUrl`:

**For emulator/simulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';  // Android emulator
static const String baseUrl = 'http://localhost:3000/api';  // iOS simulator
```

**For physical device:**
```dart
static const String baseUrl = 'http://192.168.1.100:3000/api';  // Your computer's IP
```

**For local development (web/desktop):**
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

### 4. Run the App
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just run (will prompt for device selection)
flutter run
```

## 📁 Project Structure

```
smart_attendance_student/
├── lib/
│   ├── main.dart                 # App entry point with MultiProvider
│   ├── models/                   # Data models
│   │   ├── models.dart           # Barrel file exporting all models
│   │   ├── student.dart          # Student model with fromJson/toJson
│   │   ├── attendance.dart       # Attendance model
│   │   ├── session.dart          # Session model
│   │   ├── module.dart           # Module model
│   │   └── notification.dart     # Notification model
│   ├── providers/                # State management (ChangeNotifier)
│   │   ├── auth_provider.dart    # Authentication state + token management
│   │   └── attendance_provider.dart # Attendance/session state
│   ├── screens/                  # UI screens
│   │   ├── login_screen.dart     # Login form with validation
│   │   ├── main_nav_screen.dart  # Bottom navigation host
│   │   ├── dashboard_screen.dart # Dashboard with charts & stats
│   │   ├── attendance_screen.dart # Attendance history with filters
│   │   ├── sessions_screen.dart  # Session list with calendar view
│   │   ├── profile_screen.dart   # Student profile management
│   │   ├── qr_code_screen.dart   # QR code display
│   │   └── notifications_screen.dart # Notification list
│   ├── services/                 # API services
│   │   └── api_service.dart      # HTTP client singleton with error handling
│   ├── utils/                    # Utilities
│   │   ├── constants.dart        # AppColors, AppTheme, AppConstants
│   │   └── helpers.dart          # Helper functions
│   └── widgets/                  # Reusable widgets
│       ├── attendance_card.dart   # Attendance list item
│       ├── session_card.dart      # Session list item
│       ├── module_card.dart       # Module display card
│       └── ...                   # Other reusable components
│
├── test/                         # Unit and widget tests
│   ├── services/                 # API service tests
│   ├── providers/                # Provider tests
│   └── widgets/                  # Widget tests
│
├── assets/
│   └── images/                   # Image assets
│
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
│
├── pubspec.yaml                  # Dependencies and project config
├── analysis_options.yaml         # (Optional) Custom lint rules
├── AGENTS.md                     # Contributor guidelines for coding agents
└── README.md                     # This file
```

## 🔌 API Integration

### Base Configuration
All API settings are centralized in `lib/utils/constants.dart` (`AppConstants` class).

### Verified Backend Endpoints
These endpoints are verified from the running NestJS backend:

| Endpoint Constant | Method | Path | Purpose | Response |
|-------------------|--------|------|---------|----------|
| `loginEndpoint` | POST | `/auth/student/login` | Student login | `{ token, student }` |
| `profileEndpoint` | GET | `/students/:id` | Get student profile by ID | `{ student }` |
| `attendanceEndpoint` | GET | `/attendance/student/:studentId` | Get attendance records | `{ attendances[] }` |
| `sessionsEndpoint` | GET | `/sessions` | Get all sessions | `{ sessions[] }` |
| `sessionByIdEndpoint` | GET | `/sessions/:id` | Get single session details | `{ session }` |
| `attendanceScanEndpoint` | POST | `/attendance/scan` | Record attendance via QR | `{ attendance }` |
| `modulesEndpoint` | GET | `/modules/teacher/:teacherId` | Get modules by teacher | `{ modules[] }` |

> **⚠️ Important**: The following endpoints are NOT available in the current backend and must NOT be used:
> - `/students/me` (use `/students/:id` instead)
> - `/students/me/dashboard`
> - `/students/me/qrcode`
> - `/attendance/me/calendar`
> - `/notifications`
> - `/sessions/my` (use `/sessions` instead)
> - `/modules/my` (use `/modules/teacher/:teacherId` instead)

### Authentication Flow
1. Student enters Student ID and password on login screen
2. App sends POST request to `/auth/student/login`
3. Backend returns JWT token + student object
4. Token stored securely in `FlutterSecureStorage` (encrypted)
5. Student data cached in `SharedPreferences`
6. Token automatically attached to all subsequent API requests via `Authorization: Bearer <token>` header
7. App checks auth status on startup using stored token

### API Response Format

**Success Response:**
```json
{
  "student": {
    "_id": "ObjectId",
    "fullName": "John Doe",
    "email": "john@email.com",
    "studentId": "ST1001",
    "rfidCode": "...",
    "qrCode": "ST1001-UNIQUE-CODE",
    "group": "2A",
    "year": "2",
    "speciality": "Informatique"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Error Response:**
```json
{
  "message": "error description"
}
```

### Token Storage
- **Secure Storage** (`FlutterSecureStorage`): JWT token (key: `AppConstants.tokenKey = 'auth_token'`)
- **Cached Data** (`SharedPreferences`): Student object (key: `AppConstants.studentKey = 'student_data'`)

## 🎨 Design System

### Color Palette
| Color Name | Hex Code | Usage |
|------------|----------|-------|
| Primary | `#4F46E5` | Main brand color, buttons, active icons |
| Primary Light | `#818CF8` | Secondary brand, gradients |
| Primary Dark | `#3730A3` | Darker variant, pressed states |
| Secondary | `#06B6D4` | Accent color |
| Success/Present | `#10B981` | Present status, success messages |
| Warning/Late | `#F59E0B` | Late status, warnings |
| Error/Absent | `#EF4444` | Absent status, error messages |
| Excluded | `#F97316` | Exclusion warning |
| Background | `#F5F5FF` | Scaffold background |
| Surface | `#FFFFFF` | Card and sheet backgrounds |
| Text Primary | `#1E1B4B` | Primary text color |
| Text Secondary | `#6B7280` | Secondary text, captions |
| Divider | `#E5E7EB` | Divider lines |

### Typography
- **Font Family**: Poppins (loaded via google_fonts package)
- **Theme**: Material 3 (useMaterial3: true)
- **Text Styles**: Defined in `AppTheme.lightTheme` using `GoogleFonts.poppinsTextTheme()`

## 🔧 Build Commands

### Android
```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (split per ABI - smaller downloads)
flutter build apk --release --split-per-abi

# Release APK (universal - works on all devices)
flutter build apk --release
```

### iOS (requires macOS and Xcode)
```bash
# Debug build
flutter build ios --debug

# Release build (for App Store)
flutter build ios --release
```

### Web
```bash
# Production build for web deployment
flutter build web --release
```

### Run in Debug Mode
```bash
# Run with hot reload support
flutter run

# Run on specific device
flutter run -d <device-id>

# Run with verbose logging
flutter run -v
```

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/services/api_service_test.dart

# Run a single test case by name
flutter test --plain-name "login success" test/auth_test.dart

# Run with coverage
flutter test --coverage
```

### Test Directory Structure
Mirror the `lib/` structure in `test/`:
```
lib/services/api_service.dart        → test/services/api_service_test.dart
lib/providers/auth_provider.dart     → test/providers/auth_provider_test.dart
lib/widgets/attendance_card.dart     → test/widgets/attendance_card_test.dart
```

> **Note**: No `test/` directory exists yet. Create it following Flutter conventions when adding tests.

### Mocking
Use `mockito` or `mocktail` for mocking dependencies (add to dev_dependencies if needed).

## 📝 Code Style & Linting

### Static Analysis
```bash
# Run flutter analyze (enforces flutter_lints rules)
flutter analyze

# Check for unused imports, deprecated APIs, etc.
flutter analyze --no-pub
```

### Code Formatting
```bash
# Format all Dart files
dart format .

# Check formatting without modifying (CI-ready)
dart format . --set-exit-if-changed

# Format specific files
dart format lib/main.dart lib/utils/constants.dart
```

### Code Style Rules
- **Lint Rules**: Follow `flutter_lints: ^3.0.0` (no warnings/errors allowed)
- **Null Safety**: All code must use Dart null safety (no legacy null-unsafe code)
- **Immutability**: Prefer `final` variables for immutable state
- **Explicit Typing**: Avoid using `dynamic` type unless absolutely necessary

### Import Order (Strict)
Imports must be grouped in this order, with exactly one blank line between groups:
1. **Dart SDK imports**: `dart:convert`, `dart:io`, etc.
2. **Flutter framework imports**: `package:flutter/material.dart`, etc.
3. **Third-party package imports**: `package:provider/provider.dart`, etc.
4. **Local project imports**: Relative paths

Example:
```dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/student.dart';
import '../utils/constants.dart';
```

### Naming Conventions
- **Classes/Enums/Extensions**: `PascalCase` (e.g., `SmartAttendanceApp`, `ApiService`)
- **Variables/Functions/Methods**: `camelCase` (e.g., `_token`, `getProfile()`)
- **Private Members**: Prefix with underscore `_` (e.g., `_instance`, `_headers`)
- **Static Constants**: `lowerCamelCase` (e.g., `AppColors.primary`)
- **Provider Classes**: Suffix with `Provider` (e.g., `AuthProvider`)
- **Model Classes**: Singular nouns (e.g., `Student`, not `Students`)
- **Files**: `snake_case` (e.g., `api_service.dart`, `auth_provider.dart`)

## 🔐 Security

- **JWT Tokens**: Stored in `FlutterSecureStorage` (encrypted on device)
- **Cached Data**: Non-sensitive data only in `SharedPreferences`
- **No Hardcoded Secrets**: All configurable values in `AppConstants`
- **No `print()` Statements**: Use proper logging (enforced by flutter_lints)
- **Network Security**: Use HTTPS in production
- **Biometric Auth**: Local authentication support for additional security

## 🤝 Contributing

### For Human Contributors
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the code style guidelines in `AGENTS.md`
4. Run `flutter analyze` and `flutter test` before committing
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### For Agentic Coding Agents
Please read `AGENTS.md` first for comprehensive guidelines on:
- Code style and naming conventions
- State management patterns (ChangeNotifier + Provider)
- API integration rules and verified endpoints
- Build/test commands
- Error handling patterns
- Model class structure

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

For questions or support, please contact the development team.

---

**Backend Repository**: [NestJS Smart Attendance API](<backend-repo-url>)  
**API Documentation**: http://localhost:3000/api (when backend is running)  
**Issue Tracker**: https://github.com/your-org/smart_attendance_student/issues
#   A p p S t u d e n t S y s t e m  
 