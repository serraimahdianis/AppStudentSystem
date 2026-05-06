import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/sessions_provider.dart';
import '../providers/attendance_provider.dart';
import '../models/models.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import 'qr_code_screen.dart';
import 'notifications_screen.dart';
import 'sessions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboard();
      context.read<AttendanceProvider>().loadHistory(silent: true);
    });
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
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
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
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
                                  _miniStat(Icons.check_circle, AppColors.success, '${stats?.totalPresent ?? 0}'),
                                  const SizedBox(width: 12),
                                  _miniStat(Icons.cancel, AppColors.error, '${stats?.totalAbsent ?? 0}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
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

              // Weekly Activity Chart
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Weekly activity'),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (stats != null && stats.weeklyData.isNotEmpty 
                                ? stats.weeklyData.map((e) => _toInt(e['count'])).reduce((a, b) => a > b ? a : b).toDouble() 
                                : 0) + 1,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (stats == null || value.toInt() >= stats.weeklyData.length) return const Text('');
                                    return Text(
                                      stats.weeklyData[value.toInt()]['day'].toString().substring(0, 3),
                                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: stats?.weeklyData.asMap().entries.map((e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: _toInt(e.value['count']).toDouble(),
                                  color: AppColors.primary,
                                  width: 12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            )).toList() ?? [],
                          ),
                        ),
                      ),
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
                        onAction: () => DefaultTabController.of(context).animateTo(1),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            m.module.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: m.attendanceRate / 100,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      m.attendanceRate >= 80 ? AppColors.success : (m.attendanceRate >= 50 ? AppColors.warning : AppColors.error),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${m.attendanceRate.toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: m.attendanceRate >= 80 ? AppColors.success : (m.attendanceRate >= 50 ? AppColors.warning : AppColors.error),
                ),
              ),
            ],
          ),
          Text(
            '${m.present} of ${m.totalSessions} sessions',
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
