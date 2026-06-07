import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'widgets/header_section.dart';
import 'widgets/mark_attendance_card.dart';
import 'widgets/stats_grid.dart';
import 'widgets/monthly_chart.dart';
import '../../notifications/notifications_screen.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/splash/splash_screen.dart';

/// Home Screen - Employee Dashboard
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveUtils.constrainedContent(
          context: context,
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user info and actions
              HeaderSection(
                onNotificationTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
                onLogoutTap: () async {
                  // Show logout confirmation
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    // Clear auth state
                    final authService = AuthService();
                    await authService.logout();
                    
                    // Small delay to ensure state is cleared
                    await Future.delayed(const Duration(milliseconds: 100));
                    
                    if (context.mounted) {
                      // Navigate to splash and remove all routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const SplashScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              
              // Mark Attendance Card
              const MarkAttendanceCard(),
              const SizedBox(height: 24),

              // Stats Grid
              const StatsGrid(),
              const SizedBox(height: 24),

              // Monthly Activity Chart
              const MonthlyChart(),
              const SizedBox(height: 24),
            ]
            .animate(interval: 100.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
        ),
      ),
    );
  }
}
