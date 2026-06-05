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
      debugPrint('Dashboard Stats Received: ${_data?.totalPresent} present, ${_data?.totalSessions} total, ${_data?.moduleStats.length} modules');
      _error = null;
    } catch (e) {
      debugPrint('DASHBOARD ERROR: $e');
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDashboard(silent: true);
}
