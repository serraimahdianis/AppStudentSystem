import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/models.dart';
import '../providers/schedules_provider.dart';
import '../utils/constants.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  final List<String> _daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchedulesProvider>().loadSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SchedulesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timetable'),
        automaticallyImplyLeading: false,
      ),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => p.refresh(),
              child: _buildTimetable(p.schedules),
            ),
    );
  }

  Widget _buildTimetable(List<Schedule> schedules) {
    if (schedules.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_busy, size: 64, color: AppColors.divider),
                  const SizedBox(height: 12),
                  Text(
                    'No schedules found for your group.',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Group schedules by day
    final Map<String, List<Schedule>> grouped = {};
    for (final day in _daysOfWeek) {
      final daySchedules = schedules.where((s) => s.dayOfWeek == day).toList();
      daySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));
      if (daySchedules.isNotEmpty) {
        grouped[day] = daySchedules;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: grouped.keys.length,
      itemBuilder: (context, index) {
        final day = grouped.keys.elementAt(index);
        final daySchedules = grouped[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                day,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ).animate().fade(duration: 400.ms, delay: (index * 100).ms).slideX(begin: -0.1),
            ...daySchedules.asMap().entries.map((entry) {
              final schedule = entry.value;
              final delay = (index * 100) + (entry.key * 50);
              return _ScheduleCard(schedule: schedule)
                  .animate()
                  .fade(duration: 400.ms, delay: delay.ms)
                  .slideY(begin: 0.1, curve: Curves.easeOutQuad);
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final Schedule schedule;

  const _ScheduleCard({required this.schedule});

  Color get _typeColor {
    switch (schedule.type) {
      case 'cours':
        return AppColors.primary;
      case 'td':
        return AppColors.secondary;
      case 'tp':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _typeColor.withAlpha(30),
                  _typeColor.withAlpha(10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _typeColor.withAlpha(40)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  schedule.typeLabel,
                  style: GoogleFonts.poppins(
                    color: _typeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.moduleName ?? 'Module',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (schedule.teacherName != null)
                  Text(
                    schedule.teacherName!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.room_outlined, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      schedule.room,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
