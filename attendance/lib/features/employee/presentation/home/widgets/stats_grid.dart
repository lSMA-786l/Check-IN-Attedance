import 'package:flutter/material.dart';
import '../../../../../core/widgets/stat_card.dart';
import '../../../../../data/mock/mock_data.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/responsive_utils.dart';

/// Stats Grid - Responsive grid of statistics
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.statistics;
    final crossAxisCount = ResponsiveUtils.gridCrossAxisCount(
      context,
      mobile: 2,
      tablet: 4,
      desktop: 4,
    );

    return Padding(
      padding: ResponsiveUtils.horizontalPadding(context, mobile: 20),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: ResponsiveUtils.spacing(context, 12),
        crossAxisSpacing: ResponsiveUtils.spacing(context, 12),
        childAspectRatio: ResponsiveUtils.responsive<double>(
          context: context,
          mobile: 1.1,
          tablet: 1.0,
          desktop: 1.15,
        ),
        children: [
          StatCard(
            icon: Icons.calendar_today,
            label: 'Present Days',
            value: stats['presentDays'].toString(),
            iconColor: AppTheme.statusGreen,
          ),
          StatCard(
            icon: Icons.access_time,
            label: 'Total Hours',
            value: stats['totalHours'].toString(),
            iconColor: AppTheme.statusBlue,
          ),
          StatCard(
            icon: Icons.percent,
            label: 'Attendance',
            value: '${stats['attendancePercentage']}%',
            iconColor: AppTheme.statusAmber,
          ),
          StatCard(
            icon: Icons.event_busy,
            label: 'Leaves Taken',
            value: stats['leavesTaken'].toString(),
            iconColor: AppTheme.statusCrimson,
          ),
        ],
      ),
    );
  }
}
