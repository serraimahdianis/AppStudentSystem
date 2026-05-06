import 'package:flutter_test/flutter_test.dart';
import 'package:smart_attendance_student/services/api_service.dart';

void main() {
  group('ApiService Unit Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('ApiService should be a singleton', () {
      final instance1 = ApiService();
      final instance2 = ApiService();
      expect(instance1, same(instance2));
    });

    // Note: We can't easily test private methods without reflection or making them public,
    // but we can verify the service is correctly initialized.
    test('ApiService starts with no token', () async {
      // This might depend on the environment, but in a clean test it should be null
      // or at least handle the lack of one gracefully.
      expect(await apiService.isLoggedIn, isFalse);
    });
  });
}
