import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider extends ChangeNotifier {
  Student? _student;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  Student? get student => _student;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  final _api = ApiService();

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loggedIn = await _api.isLoggedIn;
      if (loggedIn) {
        final prefs = await SharedPreferences.getInstance();
        final storedStudent = prefs.getString(AppConstants.studentKey);
        if (storedStudent != null) {
          _student = Student.fromJson(jsonDecode(storedStudent));
        }
        _isLoggedIn = true;
        // Refresh profile in background
        _refreshProfile();
      }
    } catch (e) {
      _isLoggedIn = false;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String studentId, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.login(studentId, password);
      if (result['success']) {
        _student = Student.fromJson(result['student']);
        _isLoggedIn = true;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return _isLoggedIn;
  }

  Future<void> logout() async {
    await _api.logout();
    _student = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> _refreshProfile() async {
    try {
      final profile = await _api.getProfile();
      _student = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.studentKey, jsonEncode(profile.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
      // If student not found (404), logout to clear invalid session
      if (e.toString().contains('not found') || e.toString().contains('404')) {
        logout();
      }
    }
  }
}
