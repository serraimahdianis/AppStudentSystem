import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/attendance_provider.dart';
import 'main_nav_screen.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'qr_code_screen.dart';
import 'notifications_screen.dart';
import '../services/socket/socket_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _socketService = SocketService();
  bool _hasActiveSession = false;
  String _activeModuleName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
      context.read<AttendanceProvider>().loadHistory(silent: true);

      final student = context.read<AuthProvider>().student;
      if (student != null && student.group.isNotEmpty) {
        _socketService.connect();
        _socketService.joinGroup(student.group);
      }

      _socketService.onSessionStarted = ({
        required String sessionId,
        required String moduleId,
        required String moduleName,
        required String group,
        required String startTime,
      }) {
        if (!mounted) return;
        setState(() {
          _hasActiveSession = true;
          _activeModuleName = moduleName;
        });
      };

      _socketService.onSessionEnded = (String sessionId) {
        if (!mounted) return;
        setState(() {
          _hasActiveSession = false;
          _activeModuleName = '';
        });
      };

      _socketService.onFraudAlert = ({
        required String sessionId,
        required String reason,
        required double riskScore,
      }) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fraud alert: $reason'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      };
    });
  }

  @override
  void dispose() {
    final student = context.read<AuthProvider>().student;
    if (student != null && student.group.isNotEmpty) {
      _socketService.leaveGroup(student.group);
    }
    _socketService.onSessionStarted = null;
    _socketService.onSessionEnded = null;
    _socketService.onFraudAlert = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final student = auth.student;
    final stats = dashboard.data;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => dashboard.refresh(),
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello ${student?.fullName.split(' ').first ?? 'Student'} 👋',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _greeting(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // QR Code Button
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QrCodeScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_2, color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Notifications
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Active Session Banner
            if (_hasActiveSession)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withAlpha(51),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 4, height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance session is active!',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              _activeModuleName,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withAlpha(204),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QrCodeScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Show QR',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (dashboard.isLoading && stats == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (dashboard.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          dashboard.error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => dashboard.loadDashboard(),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              // Overall Attendance Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(220),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: AppColors.cardShadow, blurRadius: 15, offset: Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 50.0,
                              lineWidth: 10.0,
                              percent: (stats?.attendanceRate ?? 0) / 100,
                              center: Text(
                                "${(stats?.attendanceRate ?? 0).toInt()}%",
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              progressColor: AppColors.primary,
                              backgroundColor: AppColors.background,
                              circularStrokeCap: CircularStrokeCap.round,
                              animation: true,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Attendance Rate',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  Text(
                                    '${stats?.totalSessions ?? 0} Total Sessions',
                                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _miniStat(Icons.check_circle, AppColors.success, '${stats?.totalPresent ?? 0} Present'),
                                      const SizedBox(width: 12),
                                      _miniStat(Icons.cancel, AppColors.error, '${stats?.totalAbsent ?? 0} Absent'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fade(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad),
                ),
              ),

              // Module Performance Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Module Performance'),
                      const SizedBox(height: 12),
                      if (stats != null && stats.moduleStats.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: stats.moduleStats.length,
                          itemBuilder: (context, index) {
                            final m = stats.moduleStats[index];
                            return _buildModuleCard(m);
                          },
                        )
                      else
                        const Center(child: Text('No module data available')),
                    ],
                  ),
                ),
              ),


              // Recent Activity Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Recent History',
                        actionLabel: 'See All',
                        onAction: () {
                          final nav = context.findAncestorStateOfType<MainNavScreenState>();
                          nav?.switchToTab(1);
                        },
                      ),
                      const SizedBox(height: 12),
                      Consumer<AttendanceProvider>(
                        builder: (context, attendance, child) {
                          final history = attendance.history.take(3).toList();
                          if (history.isEmpty) return const Center(child: Text('No recent activity'));
                          return Column(
                            children: history.map((a) => AttendanceTile(attendance: a)).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _miniStat(IconData icon, Color color, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildModuleCard(ModuleAttendanceStats m) {
    final bool isGood = m.attendanceRate >= 75;
    final bool isWarn = m.attendanceRate >= 50 && m.attendanceRate < 75;
    final Color statColor = isGood ? AppColors.success : (isWarn ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statColor.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statColor.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statColor.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  m.module.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700, 
                    fontSize: 14,
                    color: AppColors.primaryDark,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isGood ? Icons.check_circle_outline : (isWarn ? Icons.error_outline : Icons.cancel_outlined),
                color: statColor,
                size: 18,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${m.attendanceRate.toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: statColor,
                    ),
                  ),
                  Text(
                    '${m.present}/${m.totalSessions}',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: m.attendanceRate / 100,
                  backgroundColor: Colors.white.withAlpha(150),
                  valueColor: AlwaysStoppedAnimation<Color>(statColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

