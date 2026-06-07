import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/mock/mock_data.dart';
import '../../../../../core/utils/responsive_utils.dart';

/// Monthly Activity Chart with animations
class MonthlyChart extends StatefulWidget {
  const MonthlyChart({super.key});

  @override
  State<MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<MonthlyChart> {
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    // Delay to trigger animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showChart = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get last 7 days of data for the chart
    final records = MockData.attendanceRecords.take(7).toList();
    final spots = <FlSpot>[];

    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      final hours = record.hoursWorked ?? 0.0;
      spots.add(FlSpot(i.toDouble(), hours));
    }

    return Container(
      margin: ResponsiveUtils.horizontalPadding(context, mobile: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: ResponsiveUtils.borderRadius(context, 20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPlum.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: ResponsiveUtils.padding(context, mobile: 20, tablet: 24, desktop: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Activity',
                style: TextStyle(
                  color: AppTheme.textDarkHeading,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.statusGreen.withValues(alpha: 0.15),
                      AppTheme.statusGreen.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: AppTheme.statusGreen),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: AppTheme.statusGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).scale(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: ResponsiveUtils.responsive<double>(
              context: context,
              mobile: 200,
              tablet: 250,
              desktop: 300,
            ),
            child: AnimatedOpacity(
              opacity: _showChart ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.textMuted.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= records.length) return const SizedBox();
                          final date = records[index].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              ['S', 'M', 'T', 'W', 'T', 'F', 'S'][date.weekday % 7],
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (records.length - 1).toDouble(),
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.4,
                      color: AppTheme.primaryPlum,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.primaryPlum,
                            strokeWidth: 2,
                            strokeColor: AppTheme.cardWhite,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primaryPlum.withValues(alpha: 0.2),
                            AppTheme.primaryPlum.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
