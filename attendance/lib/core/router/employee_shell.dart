import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/employee/presentation/home/home_screen.dart';
import '../../features/employee/presentation/calendar/calendar_screen.dart';
import '../../features/employee/presentation/leaves/leave_screen.dart';
import '../../features/employee/presentation/profile/profile_screen.dart';
import '../../features/employee/presentation/my_manager/my_manager_screen.dart';
import '../../features/employee/presentation/attendance_history/attendance_history_screen.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Employee Shell - Main navigation shell with animated bottom bar
class EmployeeShell extends StatefulWidget {
  const EmployeeShell({super.key});

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;

  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    AttendanceHistoryScreen(), // Attendance History
    LeaveScreen(),
    MyManagerScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );

    // Animate FAB on tab change
    _fabController.reset();
    _fabController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(), // Add bounce effect
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPlum.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppTheme.cardWhite,
            selectedItemColor: AppTheme.primaryPlum,
            unselectedItemColor: AppTheme.textMuted,
            selectedFontSize: ResponsiveUtils.fontSize(context, 12),
            unselectedFontSize: ResponsiveUtils.fontSize(context, 11),
            elevation: 0,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'Calendar', 1),
              _buildNavItem(Icons.history, Icons.history, 'History', 2),
              _buildNavItem(Icons.event_note_outlined, Icons.event_note, 'Leaves', 3),
              _buildNavItem(Icons.person_outline, Icons.person, 'Manager', 4),
              _buildNavItem(Icons.account_circle_outlined, Icons.account_circle, 'Profile', 5),
            ],
          ),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(isSelected ? 8 : 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryPlum.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? filledIcon : outlinedIcon,
          size: isSelected 
              ? ResponsiveUtils.iconSize(context, 26) 
              : ResponsiveUtils.iconSize(context, 24),
        ),
      )
      .animate(target: isSelected ? 1 : 0)
      .scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 200.ms,
      )
      .shake(duration: 300.ms, hz: 4, curve: Curves.easeInOut),
      label: label,
    );
  }
}
