import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class SessionsProvider extends ChangeNotifier {
  List<Session> _upcoming = [];
  List<Session> _completed = [];
  bool _isLoadingUpcoming = false;
  bool _isLoadingCompleted = false;
  String? _error;

  List<Session> get upcoming => _upcoming;
  List<Session> get completed => _completed;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingCompleted => _isLoadingCompleted;
  String? get error => _error;

  final _api = ApiService();

  Future<void> loadUpcoming({bool silent = false}) async {
    if (!silent) {
      _isLoadingUpcoming = true;
      _error = null;
      notifyListeners();
    }
    try {
      _upcoming = await _api.getMySessions(status: 'planned');
    } catch (e) {
      _error = 'Failed to load upcoming sessions';
    } finally {
      _isLoadingUpcoming = false;
      notifyListeners();
    }
  }

  Future<void> loadCompleted({bool silent = false}) async {
    if (!silent) {
      _isLoadingCompleted = true;
      _error = null;
      notifyListeners();
    }
    try {
      _completed = await _api.getMySessions(status: 'closed');
    } catch (e) {
      _error = 'Failed to load completed sessions';
    } finally {
      _isLoadingCompleted = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      loadUpcoming(silent: true),
      loadCompleted(silent: true),
    ]);
  }
}
