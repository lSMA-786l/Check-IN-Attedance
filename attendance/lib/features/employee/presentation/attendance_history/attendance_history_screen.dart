import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../core/services/attendance_service.dart';
import '../../../../data/models/attendance_model.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Attendance History Screen - View all attendance records
class AttendanceHistoryScreen extends StatelessWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceService = AttendanceService();
    final history = attendanceService.attendanceHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
      ),
      body: ResponsiveUtils.constrainedContent(
        context: context,
        child: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: AppTheme.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No attendance records yet',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check in to start tracking your attendance',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ).animate().fadeIn(),
            )
          : ListView.builder(
              padding: ResponsiveUtils.padding(context, mobile: 20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                return _AttendanceCard(record: record)
                    .animate()
                    .fadeIn(delay: (index * 50).ms)
                    .slideX(begin: 0.2, end: 0);
              },
            ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceModel record;

  const _AttendanceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPlum.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(record.date),
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM d, y').format(record.date),
                          style: const TextStyle(
                            color: AppTheme.textDarkHeading,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    StatusBadge(
                      text: record.status,
                      type: StatusType.success,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.login,
                        label: 'Check In',
                        value: record.checkIn != null
                            ? DateFormat('h:mm a').format(record.checkIn!)
                            : 'N/A',
                        color: AppTheme.statusGreen,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.textMuted.withValues(alpha: 0.2),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon: Icons.logout,
                        label: 'Check Out',
                        value: record.checkOut != null
                            ? DateFormat('h:mm a').format(record.checkOut!)
                            : 'N/A',
                        color: AppTheme.statusCrimson,
                      ),
                    ),
                  ],
                ),
                if (record.hoursWorked != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPlum.withValues(alpha: 0.1),
                          AppTheme.primaryPlum.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppTheme.primaryPlum,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Hours: ',
                          style: TextStyle(
                            color: AppTheme.textBody,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${record.hoursWorked!.toStringAsFixed(1)} hrs',
                          style: const TextStyle(
                            color: AppTheme.primaryPlum,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (record.location != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.statusGreen.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.location!,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
            Center(
              child: Text(
                DateFormat('MMMM d, y').format(record.date),
                style: const TextStyle(
                  color: AppTheme.textDarkHeading,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _DetailRow('Status', record.status),
            if (record.checkIn != null)
              _DetailRow('Check In', DateFormat('h:mm:ss a').format(record.checkIn!)),
            if (record.checkOut != null)
              _DetailRow('Check Out', DateFormat('h:mm:ss a').format(record.checkOut!)),
            if (record.hoursWorked != null)
              _DetailRow('Hours Worked', '${record.hoursWorked!.toStringAsFixed(2)} hrs'),
            if (record.location != null)
              _DetailRow('Location', record.location!),
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
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textDarkHeading,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textBody,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textDarkHeading,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
