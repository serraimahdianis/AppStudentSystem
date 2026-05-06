import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance_student/models/models.dart';

void main() {
  group('DashboardData Model Tests', () {
    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'attendanceRate': 85.5,
        'totalPresent': 10,
        'totalAbsent': 2,
        'totalLate': 1,
        'totalSessions': 13,
        'nextSession': {
          '_id': 's1',
          'teacherId': 't1',
          'moduleId': {'_id': 'm1', 'name': 'Mathematics'},
          'date': '2026-05-10',
          'startTime': '08:00',
          'endTime': '09:30',
          'type': 'cours',
          'group': '2A',
          'status': 'planned',
          'isReplacement': false
        },
        'moduleStats': [
          {
            'module': {'_id': 'm1', 'name': 'Mathematics', 'teacherId': 't1', 'year': 'L2'},
            'totalSessions': 5,
            'present': 4,
            'absent': 1,
            'late': 0,
            'isExcluded': false,
            'attendanceRate': 80.0
          }
        ],
        'weeklyData': []
      };

      final data = DashboardData.fromJson(json);

      expect(data.attendanceRate, 85.5);
      expect(data.totalPresent, 10);
      expect(data.nextSession?.moduleName, 'Mathematics');
      expect(data.moduleStats.length, 1);
      expect(data.moduleStats.first.module.name, 'Mathematics');
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        'attendanceRate': 0,
        'totalPresent': 0,
        'totalAbsent': 0,
        'totalLate': 0,
        'totalSessions': 0,
        'moduleStats': [],
        'weeklyData': []
      };

      final data = DashboardData.fromJson(json);

      expect(data.attendanceRate, 0.0);
      expect(data.nextSession, isNull);
    });
  });
}
