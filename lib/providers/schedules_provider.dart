import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class SchedulesProvider extends ChangeNotifier {
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final _api = ApiService();

  Future<void> loadSchedules({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final allSchedules = await _api.getAllSchedules();
      final student = await _getStudentFromCache();
      
      if (student != null) {
        _schedules = allSchedules.where((s) {
          bool matchYear = s.year == student.year;
          // Include schedules where group is null, empty, or "Whole Year" (general lectures)
          bool matchGroup = (s.group == null || s.group!.isEmpty || 
              s.group == 'Whole Year' || s.group == student.group);
          bool matchSpeciality = (s.speciality == null || s.speciality!.isEmpty || s.speciality == student.speciality);
          return matchYear && matchGroup && matchSpeciality;
        }).toList();
      } else {
        _schedules = [];
      }
    } catch (e) {
      _error = 'Failed to load schedules: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadSchedules(silent: true);
  }

  Future<Student?> _getStudentFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.studentKey);
    if (data != null) {
      try {
        return Student.fromJson(jsonDecode(data));
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
