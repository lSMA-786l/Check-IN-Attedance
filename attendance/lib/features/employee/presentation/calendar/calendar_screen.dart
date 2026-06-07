import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/models/attendance_model.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Enhanced Calendar Screen with statistics and insights
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Color _getMarkerColor(String status) {
    switch (status) {
      case 'PRESENT':
        return AppTheme.statusGreen;
      case 'ABSENT':
        return AppTheme.statusCrimson;
      case 'HALF_DAY':
        return AppTheme.statusAmber;
      case 'LEAVE':
        return AppTheme.statusBlue;
      default:
        return Colors.transparent;
    }
  }

  AttendanceModel? _getAttendanceForDay(DateTime day) {
    try {
      return MockData.attendanceRecords.firstWhere(
        (record) =>
            record.date.year == day.year &&
            record.date.month == day.month &&
            record.date.day == day.day,
      );
    } catch (e) {
      return null;
    }
  }

  int get _currentStreak {
    int streak = 0;
    DateTime date = DateTime.now();
    while (true) {
      final attendance = _getAttendanceForDay(date);
      if (attendance == null || (attendance.status != 'PRESENT' && attendance.status != 'HALF_DAY')) {
        break;
      }
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Map<String, int> get _monthlyStats {
    final now = DateTime.now();
    int present = 0;
    int absent = 0;
    int halfDay = 0;
    int leave = 0;

    for (final record in MockData.attendanceRecords) {
      if (record.date.month == now.month && record.date.year == now.year) {
        switch (record.status) {
          case 'PRESENT':
            present++;
            break;
          case 'ABSENT':
            absent++;
            break;
          case 'HALF_DAY':
            halfDay++;
            break;
          case 'LEAVE':
            leave++;
            break;
        }
      }
    }

    return {
      'present': present,
      'absent': absent,
      'halfDay': halfDay,
      'leave': leave,
    };
  }

  void _showAttendanceDetails(AttendanceModel attendance) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            Center(
              child: Text(
                DateFormat('MMMM d, y').format(attendance.date),
                style: const TextStyle(
                  color: AppTheme.textDarkHeading,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 20),
            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    color: AppTheme.textBody,
                    fontSize: 16,
                  ),
                ),
                StatusBadge(
                  text: attendance.status.replaceAll('_', ' '),
                  type: attendance.status == 'PRESENT' || attendance.status == 'HALF_DAY'
                      ? StatusType.success
                      : attendance.status == 'ABSENT'
                          ? StatusType.error
                          : StatusType.info,
                ),
              ],
            ).animate().fadeIn(delay: 100.ms),
            if (attendance.checkIn != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Check-in Time',
                    style: TextStyle(
                      color: AppTheme.textBody,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(attendance.checkIn!),
                    style: const TextStyle(
                      color: AppTheme.textDarkHeading,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ],
            if (attendance.checkOut != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Check-out Time',
                    style: TextStyle(
                      color: AppTheme.textBody,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('h:mm a').format(attendance.checkOut!),
                    style: const TextStyle(
                      color: AppTheme.textDarkHeading,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ],
            if (attendance.hoursWorked != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Hours',
                    style: TextStyle(
                      color: AppTheme.textBody,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${attendance.hoursWorked!.toStringAsFixed(1)} hrs',
                    style: const TextStyle(
                      color: AppTheme.textDarkHeading,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ],
            if (attendance.location != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.statusGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attendance.location!,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _monthlyStats;
    final streak = _currentStreak;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        centerTitle: true,
      ),
      body: ResponsiveUtils.constrainedContent(
        context: context,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
          children: [
            // Calendar
            Container(
              margin: ResponsiveUtils.padding(context, mobile: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPlum.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primaryPlum.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppTheme.primaryPlum,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.statusGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      color: AppTheme.textDarkHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    final attendance = _getAttendanceForDay(selectedDay);
                    if (attendance != null && attendance.status != 'WEEK_OFF') {
                      _showAttendanceDetails(attendance);
                    }
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final attendance = _getAttendanceForDay(date);
                      if (attendance != null && attendance.status != 'WEEK_OFF') {
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getMarkerColor(attendance.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            // Monthly Statistics
            Padding(
              padding: ResponsiveUtils.horizontalPadding(context, mobile: 16),
              child: ResponsiveUtils.responsive<Widget>(
                context: context,
                mobile: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.check_circle_outline,
                            label: 'Present',
                            value: '${stats['present']}',
                            color: AppTheme.statusGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.access_time,
                            label: 'Half Day',
                            value: '${stats['halfDay']}',
                            color: AppTheme.statusAmber,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.cancel_outlined,
                            label: 'Absent',
                            value: '${stats['absent']}',
                            color: AppTheme.statusCrimson,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.event_note,
                            label: 'Leaves',
                            value: '${stats['leave']}',
                            color: AppTheme.statusBlue,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
                  ],
                ),
                tablet: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_outline,
                        label: 'Present',
                        value: '${stats['present']}',
                        color: AppTheme.statusGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.access_time,
                        label: 'Half Day',
                        value: '${stats['halfDay']}',
                        color: AppTheme.statusAmber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.cancel_outlined,
                        label: 'Absent',
                        value: '${stats['absent']}',
                        color: AppTheme.statusCrimson,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.event_note,
                        label: 'Leaves',
                        value: '${stats['leave']}',
                        color: AppTheme.statusBlue,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms),
              ),
            ),

            const SizedBox(height: 20),

            // Attendance Streak
            Container(
              margin: ResponsiveUtils.horizontalPadding(context, mobile: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.statusGreen.withValues(alpha: 0.15),
                    AppTheme.statusGreen.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.statusGreen.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.statusGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.statusGreen,
                      size: 32,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).scale(duration: 1000.ms),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Streak',
                          style: TextStyle(
                            color: AppTheme.textBody,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '$streak',
                              style: const TextStyle(
                                color: AppTheme.statusGreen,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'days',
                              style: TextStyle(
                                color: AppTheme.textBody,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (streak > 5)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.statusGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🎉 Great!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    ).shimmer(duration: 1500.ms),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).scale(),

            const SizedBox(height: 20),

            // Legend
            Container(
              margin: ResponsiveUtils.horizontalPadding(context, mobile: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPlum.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Legend',
                    style: TextStyle(
                      color: AppTheme.textDarkHeading,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LegendItem(color: AppTheme.statusGreen, label: 'Present'),
                      _LegendItem(color: AppTheme.statusAmber, label: 'Half Day'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LegendItem(color: AppTheme.statusCrimson, label: 'Absent'),
                      _LegendItem(color: AppTheme.statusBlue, label: 'Leave'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textBody,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
