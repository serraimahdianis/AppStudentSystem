import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/schedules_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'utils/constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartAttendanceApp());
}

class SmartAttendanceApp extends StatelessWidget {
  const SmartAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => SchedulesProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Attendance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _SplashRouter(),
      ),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    await context.read<AuthProvider>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 64, color: AppColors.primary),
              SizedBox(height: 16),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    if (auth.isLoggedIn) {
      return const MainNavScreen();
    }

    return const LoginScreen();
  }
}