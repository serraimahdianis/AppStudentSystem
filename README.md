# 🎓 Smart Attendance - Student App

A modern cross-platform Flutter application designed for university students to manage attendance, track schedules, access attendance statistics, and receive real-time notifications.

The system is part of a Smart Attendance Management Solution based on RFID technology and powered by a NestJS backend with MongoDB.

---

# ✨ Features

## 🔐 Authentication
- Secure JWT Authentication
- Login using Student ID and Password
- Persistent Login Sessions
- Biometric Authentication (Fingerprint / Face ID)

---

## 📊 Dashboard
- Global Attendance Rate
- Per-Module Statistics
- Attendance Progress Visualization
- Quick Overview Cards

---

## 📅 Attendance Management
- View Attendance History
- Filter by Subject or Status
- Present / Late / Absent Tracking
- Automatic Exclusion Detection

---

## 🗓 Sessions & Schedule
- Weekly Timetable
- Upcoming Sessions
- Completed Sessions
- Calendar View Integration

---

## 📱 QR Code System
- Unique Student QR Code
- QR-based Attendance Scanning
- Fast Verification Process

---

## 🔔 Notifications
- Attendance Alerts
- Session Updates
- Exclusion Warnings
- Real-Time System Notifications

---

## 💾 Offline Support
- Local Data Caching
- SharedPreferences Integration
- Fast Loading Experience
- Pull-to-Refresh Synchronization

---

# 📌 Attendance Status

| Status | Description |
|--------|-------------|
| 🟢 Present | Student attended the session |
| 🟡 Late | Student arrived late |
| 🔴 Absent | Student did not attend |
| 🟠 Excluded | Student excluded after policy violation |

---

# 🛠 Technology Stack

## 📱 Frontend
- Flutter
- Provider (State Management)
- Dio & HTTP
- Material 3 Design
- Flutter Secure Storage
- Shared Preferences
- FL Chart
- Table Calendar

---

## ⚙ Backend
- NestJS
- TypeScript
- MongoDB
- Mongoose
- JWT Authentication
- Swagger API Documentation

---

# 📂 Project Structure

```text
lib/
├── main.dart
├── models/
├── providers/
├── screens/
├── services/
├── utils/
├── widgets/
└── assets/
