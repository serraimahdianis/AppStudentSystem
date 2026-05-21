import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/models.dart';

typedef UnauthorizedCallback = void Function();

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _cachedStudentId;
  UnauthorizedCallback? onUnauthorized;

  // ─── Token Management ──────────────────────────────────────────

  Future<String?> get token async {
    _token ??= await _storage.read(key: AppConstants.tokenKey);
    return _token;
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> studentJson) async {
    debugPrint('Saving Auth Data: Token and Student Profile...');
    _token = token;
    await _storage.write(key: AppConstants.tokenKey, value: token);
    
    // Cache the ID specifically for stats/attendance queries
    final String? id = studentJson['_id'] ?? studentJson['id'];
    if (id != null) {
      _cachedStudentId = id;
      await _storage.write(key: AppConstants.studentIdKey, value: id);
      debugPrint('Student ID Cached: $id');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.studentKey, jsonEncode(studentJson));
  }

  Future<void> clearAuthData() async {
    debugPrint('Clearing Auth Data...');
    _token = null;
    _cachedStudentId = null;
    await _storage.delete(key: AppConstants.tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.studentKey);
  }

  Future<bool> get isLoggedIn async {
    final t = await token;
    return t != null && t.isNotEmpty;
  }

  Future<String?> _getStudentId() async {
    if (_cachedStudentId != null) return _cachedStudentId;

    // Try Secure Storage first (fastest/most direct)
    _cachedStudentId = await _storage.read(key: AppConstants.studentIdKey);
    if (_cachedStudentId != null) return _cachedStudentId;

    // Fallback to SharedPreferences (where full student object is)
    final prefs = await SharedPreferences.getInstance();
    final studentData = prefs.getString(AppConstants.studentKey);
    if (studentData != null) {
      try {
        final student = jsonDecode(studentData);
        _cachedStudentId = student['_id'] ?? student['id'];
        return _cachedStudentId;
      } catch (e) {
        debugPrint('Error decoding cached student data: $e');
      }
    }
    return null;
  }

  // ─── Request Helpers ───────────────────────────────────────────

  Future<Map<String, String>> _getHeaders({bool authenticated = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final t = await token;
      if (t != null) {
        headers['Authorization'] = 'Bearer $t';
      }
    }
    return headers;
  }

  String _buildUrl(String endpoint) {
    final base = AppConstants.baseUrl.endsWith('/') 
        ? AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 1) 
        : AppConstants.baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint('API Response: [${response.statusCode}] ${response.request?.url}');
    
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) return {};
      throw Exception('Empty response with status: ${response.statusCode}');
    }

    try {
      final dynamic data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        // Handle 401 Unauthorized specifically
        if (response.statusCode == 401) {
          clearAuthData();
          onUnauthorized?.call();
          throw Exception('Session expired. Please login again.');
        }
        
        final message = data is Map ? data['message'] : 'Request failed with status: ${response.statusCode}';
        debugPrint('API Error Detail: $message');
        throw Exception(message is List ? message.join(', ') : message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      debugPrint('JSON Decode Error: $e');
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  // ─── JWT Parsing ───────────────────────────────────────────────

  Map<String, dynamic> _parseJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw Exception('Invalid token parts');
      final payload = parts[1];
      final String decoded = utf8.decode(base64Url.decode(base64.normalize(payload)));
      return jsonDecode(decoded);
    } catch (e) {
      debugPrint('JWT Parse Error: $e');
      throw Exception('Failed to process authentication token');
    }
  }

  // ─── Auth Endpoints ────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String studentId, String password) async {
    final url = _buildUrl(AppConstants.loginEndpoint);
    debugPrint('Attempting Login: $url');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(authenticated: false),
        body: jsonEncode({
          'studentId': studentId,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint('Login RAW Response: ${response.body}');
      final data = _handleResponse(response);
      
      // Handle both 'token' and 'access_token'
      final String? tokenValue = data['token'] ?? data['access_token'];
      if (tokenValue == null) {
        debugPrint('Login Error: Token not found in response');
        throw Exception('Invalid response: Token missing');
      }

      Map<String, dynamic>? studentJson = data['student'];
      
      // If student data is missing, extract ID from JWT and fetch profile
      if (studentJson == null) {
        debugPrint('Student object missing in response. Decoding JWT payload...');
        final payload = _parseJwt(tokenValue);
        final String? id = payload['sub'];
        if (id == null) throw Exception('Invalid token: User ID (sub) missing');
        
        debugPrint('Extracted Student ID from JWT: $id. Fetching full profile...');
        
        // Temporarily set token for the profile request
        _token = tokenValue;
        
        final student = await getProfile(id: id);
        studentJson = student.toJson();
      }

      await _saveAuthData(tokenValue, studentJson);
      return {'success': true, 'student': studentJson};
      
    } on SocketException {
      throw Exception('Network unreachable. Please check your connection.');
    } on http.ClientException {
      throw Exception('Server unreachable. Please check if the backend is running.');
    } catch (e) {
      debugPrint('CRITICAL LOGIN ERROR: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await clearAuthData();
  }

  // ─── Student Profile ──────────────────────────────────────────

  Future<Student> getProfile({String? id}) async {
    final studentId = id ?? await _getStudentId();
    if (studentId == null) throw Exception('Authentication required');

    final url = _buildUrl('${AppConstants.profileEndpoint}/$studentId');
    debugPrint('Fetching Profile: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return Student.fromJson(data['student'] ?? data);
  }

  // ─── Attendance ───────────────────────────────────────────────

  Future<List<Attendance>> getMyAttendance() async {
    final id = await _getStudentId();
    if (id == null) throw Exception('Authentication required');

    final uri = Uri.parse(_buildUrl('${AppConstants.attendanceEndpoint}/$id'));
    debugPrint('Fetching Attendance: $uri');

    final response = await http.get(uri, headers: await _getHeaders());
    final data = _handleResponse(response);
    
    List list;
    if (data is Map && data.containsKey('attendances')) {
      list = data['attendances'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    
    return list.map((e) => Attendance.fromJson(e)).toList();
  }

  // ─── Sessions ────────────────────────────────────────────────

  Future<List<Session>> getMySessions({String? status, String? date}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (date != null) params['date'] = date;

    final uri = Uri.parse(_buildUrl(AppConstants.sessionsEndpoint))
        .replace(queryParameters: params.isNotEmpty ? params : null);

    debugPrint('Fetching Sessions: $uri');

    final response = await http.get(uri, headers: await _getHeaders());
    final data = _handleResponse(response);
    
    List list;
    if (data is Map && data.containsKey('sessions')) {
      list = data['sessions'] as List;
    } else if (data is List) {
      list = data;
    } else {
      list = [];
    }
    
    return list.map((e) => Session.fromJson(e)).toList();
  }

  Future<Session> getSessionById(String sessionId) async {
    final url = _buildUrl('${AppConstants.sessionByIdEndpoint}/$sessionId');
    debugPrint('Fetching Session Detail: $url');

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return Session.fromJson(data['session'] ?? data);
  }

  // ─── Attendance Scan ─────────────────────────────────────────

  Future<Map<String, dynamic>> scanAttendance({
    required String sessionId,
    required String studentId,
    String? nonce,
  }) async {
    final url = _buildUrl(AppConstants.attendanceScanEndpoint);
    debugPrint('Submitting Attendance Scan: $url');

    final body = <String, dynamic>{
      'sessionId': sessionId,
      'studentId': studentId,
      'scanTime': DateTime.now().toIso8601String(),
      'status': 'present',
    };
    if (nonce != null && nonce.isNotEmpty) {
      body['nonce'] = nonce;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );

    final data = _handleResponse(response);
    return {'success': true, 'attendance': data['attendance'] ?? data};
  }

  // ─── Dashboard Stats ──────────────────────────────────────────

  Future<DashboardData> getDashboardStats() async {
    final id = await _getStudentId();
    if (id == null) throw Exception('Authentication required');

    final uri = Uri.parse(_buildUrl(AppConstants.attendanceStatsEndpoint))
        .replace(queryParameters: {'studentId': id});

    debugPrint('Fetching Dashboard Stats: $uri');

    final response = await http.get(
      uri,
      headers: await _getHeaders(),
    );

    final data = _handleResponse(response);
    return DashboardData.fromJson(data['stats'] ?? data);
  }
}
