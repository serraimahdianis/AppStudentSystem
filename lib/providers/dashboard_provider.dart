import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardData? _data;
  bool _isLoading = false;
  String? _error;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final _api = ApiService();

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      _data = await _api.getDashboardStats();
      debugPrint('Dashboard Stats Received: ${_data?.totalPresent} present, ${_data?.totalSessions} total');
      
      // Get all closed sessions to calculate TRUE rates (including absences)
      final attendance = await _api.getMyAttendance();
      final closedSessions = await _api.getMySessions(status: 'closed');
      debugPrint('Data Received: ${attendance.length} scans, ${closedSessions.length} total sessions');

      if (closedSessions.isNotEmpty) {
        // Map attendance to sessions
        final Map<String, Attendance> attendanceMap = {
          for (var a in attendance) a.sessionId: a
        };

        // Create the "Full History" list including absences
        final fullHistory = closedSessions.map((session) {
          return attendanceMap[session.id] ?? Attendance(
            id: 'absent-${session.id}',
            sessionId: session.id,
            session: session,
            studentId: '',
            status: 'absent',
            scanTime: session.date,
          );
        }).toList();

        final stats = _calculateModuleStats(fullHistory);
        final weeklyTrend = _calculateWeeklyTrend(fullHistory);
        
        // Merge backend stats with frontend TRUE calculations
        final totalSessions = closedSessions.length;
        final presentCount = attendance.where((a) => a.isPresent || a.isLate).length;
        final trueRate = totalSessions > 0 ? (presentCount / totalSessions) * 100 : 0.0;

        _data = DashboardData(
          attendanceRate: trueRate,
          totalPresent: attendance.where((a) => a.isPresent).length,
          totalAbsent: totalSessions - attendance.length,
          totalLate: attendance.where((a) => a.isLate).length,
          totalSessions: totalSessions,
          nextSession: _data?.nextSession,
          moduleStats: stats,
          weeklyData: weeklyTrend,
        );
        debugPrint('Dashboard Data TRUE Enriched: ${_data?.moduleStats.length} modules | Rate: ${_data?.attendanceRate.toStringAsFixed(1)}%');
      }

      _error = null;
    } catch (e) {
      debugPrint('DASHBOARD ERROR: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _calculateWeeklyTrend(List<Attendance> attendance) {
    final Map<String, int> dailyCounts = {};
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Initialize last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      dailyCounts[key] = 0;
    }

    for (var a in attendance) {
      if (a.isPresent || a.isLate) {
        final key = '${a.scanTime.year}-${a.scanTime.month}-${a.scanTime.day}';
        if (dailyCounts.containsKey(key)) {
          dailyCounts[key] = (dailyCounts[key] ?? 0) + 1;
        }
      }
    }

    return dailyCounts.entries.map((e) {
      final parts = e.key.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return {
        'day': days[date.weekday - 1],
        'count': e.value,
      };
    }).toList();
  }

  List<ModuleAttendanceStats> _calculateModuleStats(List<Attendance> attendance) {
    final Map<String, List<Attendance>> grouped = {};
    for (var a in attendance) {
      final moduleId = a.session?.moduleId ?? 'unknown';
      grouped.putIfAbsent(moduleId, () => []).add(a);
    }

    return grouped.entries.map((entry) {
      final list = entry.value;
      final present = list.where((a) => a.isPresent).length;
      final late = list.where((a) => a.isLate).length;
      final absent = list.where((a) => a.isAbsent).length;
      final total = list.length;
      final rate = total > 0 ? ((present + late) / total) * 100 : 0.0;
      
      final firstSession = list.first.session;

      return ModuleAttendanceStats(
        module: Module(
          id: entry.key,
          name: firstSession?.moduleName ?? 'Module',
          teacherId: firstSession?.teacherId ?? '',
          teacherName: firstSession?.teacherName,
          year: '',
          createdAt: DateTime.now(),
        ),
        totalSessions: total,
        present: present,
        absent: absent,
        late: late,
        isExcluded: rate < 50 && total > 3, // Example logic: exclude if < 50% after 3 sessions
        attendanceRate: rate,
      );
    }).toList();
  }

  Future<void> refresh() => loadDashboard(silent: true);
}
