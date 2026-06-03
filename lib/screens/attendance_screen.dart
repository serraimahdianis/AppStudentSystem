import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/attendance_provider.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = context.watch<AttendanceProvider>();
    final history = attendanceProvider.history;
    final isLoading = attendanceProvider.isLoading;
    final selectedStatus = attendanceProvider.selectedStatus;
    final fullHistory = attendanceProvider.fullHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ─── Monthly Summary ───────────────────────
          if (fullHistory.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          label: 'Present',
                          value: '${fullHistory.where((a) => a.isPresent).length}',
                          icon: Icons.check_circle_outline,
                        ),
                        _SummaryItem(
                          label: 'Late',
                          value: '${fullHistory.where((a) => a.isLate).length}',
                          icon: Icons.access_time,
                        ),
                        _SummaryItem(
                          label: 'Absent',
                          value: '${fullHistory.where((a) => a.isAbsent).length}',
                          icon: Icons.cancel_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fade(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),

          // ─── Filters ────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    value: selectedStatus,
                    hint: 'All Status',
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Status')),
                      DropdownMenuItem(
                          value: 'present', child: Text('Present')),
                      DropdownMenuItem(value: 'absent', child: Text('Absent')),
                      DropdownMenuItem(value: 'late', child: Text('Late')),
                    ],
                    onChanged: (v) {
                      context.read<AttendanceProvider>().setStatus(v);
                    },
                  ),
                ),
              ],
            ),
          ),
          // ─── List ────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.history,
                                size: 60, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No attendance records found',
                              style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            context.read<AttendanceProvider>().refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: history.length,
                          itemBuilder: (_, i) =>
                              AttendanceTile(attendance: history[i])
                                  .animate().fade(duration: 300.ms, delay: (i * 50).ms)
                                  .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButton<String?>(
        value: value,
        hint: Text(hint, style: GoogleFonts.poppins(fontSize: 13)),
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppColors.textSecondary),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
