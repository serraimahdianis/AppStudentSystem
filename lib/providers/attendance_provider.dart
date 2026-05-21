import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Attendance> _history = [];
  List<Attendance> _fullHistory = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;

  List<Attendance> get history {
    if (_selectedStatus == null) return _history;
    return _history.where((a) => a.status == _selectedStatus).toList();
  }

  List<Attendance> get fullHistory => _fullHistory;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;

  final _api = ApiService();

  Future<void> loadHistory({String? status, bool silent = false}) async {
    if (status != null) _selectedStatus = status;
    
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      // Get real scans
      final attendanceList = await _api.getMyAttendance();
      
      // Get all closed sessions (historical classes)
      final closedSessions = await _api.getMySessions(status: 'closed');
      
      // Merge Logic:
      // For every closed session, if the student has a scan record, use it.
      // If not, they were 'absent' for that session.
      final Map<String, Attendance> attendanceMap = {
        for (var a in attendanceList) a.sessionId: a
      };
      
      _history = closedSessions.map((session) {
        if (attendanceMap.containsKey(session.id)) {
          final a = attendanceMap[session.id]!;
          // Ensure session object is attached for UI
          return Attendance(
            id: a.id,
            sessionId: a.sessionId,
            session: session,
            studentId: a.studentId,
            status: a.status,
            scanTime: a.scanTime,
          );
        } else {
          // Student was absent for this historical session
          return Attendance(
            id: 'absent-${session.id}',
            sessionId: session.id,
            session: session,
            studentId: '', 
            status: 'absent',
            scanTime: session.date,
          );
        }
      }).toList();

      // Sort by session date descending (newest first)
      _history.sort((a, b) => (b.session?.date ?? b.scanTime).compareTo(a.session?.date ?? a.scanTime));
      _fullHistory = List.from(_history);
      
      _error = null;
    } catch (e) {
      debugPrint('Attendance Load Error: $e');
      _error = 'Failed to load session history';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> refresh() => loadHistory(silent: true);
}

