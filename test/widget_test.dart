// This is a basic Flutter widget test for Smart Attendance App.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_attendance_student/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartAttendanceApp());

    // Verify that the app builds successfully
    expect(find.byType(SmartAttendanceApp), findsOneWidget);
  });
}
