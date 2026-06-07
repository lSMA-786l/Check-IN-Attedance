import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/attendance_service.dart';
import '../../../../../core/utils/responsive_utils.dart';

/// Mark Attendance Card - Hero action button with persistent state
class MarkAttendanceCard extends StatefulWidget {
  const MarkAttendanceCard({super.key});

  @override
  State<MarkAttendanceCard> createState() => _MarkAttendanceCardState();
}

class _MarkAttendanceCardState extends State<MarkAttendanceCard> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();
  bool _isLoading = false;
  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Listen to attendance service changes
    _attendanceService.addListener(_onAttendanceChanged);
  }

  void _onAttendanceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _attendanceService.removeListener(_onAttendanceChanged);
    super.dispose();
  }

  Future<String> _fetchLocation() async {
    // Simulate location fetching with delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // In a real app, use geolocator package:
    // Position position = await Geolocator.getCurrentPosition();
    // List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    
    // For now, return a simulated location
    final locations = [
      'Tech Park, Hinjewadi, Pune',
      'Cyber Towers, HITEC City, Hyderabad',
      'Prestige Tech Park, Bangalore',
      'DLF Cyber City, Gurgaon',
      'Spaze iTech Park, Sector 49, Gurgaon',
      'Raheja Mindspace, Madhapur, Hyderabad',
    ];
    locations.shuffle();
    return locations.first;
  }

  Future<void> _handleCheckIn() async {
    if (_attendanceService.isCheckedIn) {
      // Show confirmation dialog for check-out
      final shouldCheckOut = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.statusAmber),
              SizedBox(width: 12),
              Text('Check Out'),
            ],
          ),
          content: const Text('Are you sure you want to check out now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCrimson,
              ),
              child: const Text('Check Out'),
            ),
          ],
        ),
      );

      if (shouldCheckOut != true) return;

      // Check out
      await _attendanceService.checkOut();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Checked out successfully!'),
              ],
            ),
            backgroundColor: AppTheme.statusCrimson,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      // Check in
      setState(() {
        _isLoading = true;
      });

      try {
        final location = await _fetchLocation();
        await _attendanceService.checkIn(location);
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSuccessModal();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch location. Please try again.'),
              backgroundColor: AppTheme.statusCrimson,
            ),
          );
        }
      }
    }
  }

  void _showSuccessModal() {
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
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.statusGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.statusGreen,
                size: 60,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text(
              'Checked In Successfully!',
              style: TextStyle(
                color: AppTheme.textDarkHeading,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            Text(
              DateFormat('h:mm a').format(DateTime.now()),
              style: const TextStyle(
                color: AppTheme.textBody,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: AppTheme.statusGreen, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _attendanceService.checkInLocation ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _formattedDuration {
    final duration = _attendanceService.getDuration();
    if (duration == null) return '00:00:00';
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isCheckedIn = _attendanceService.isCheckedIn;
    final location = _attendanceService.checkInLocation ?? 'Location not available';

    return Container(
      margin: ResponsiveUtils.horizontalPadding(context, mobile: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: ResponsiveUtils.borderRadius(context, 24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPlum.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: ResponsiveUtils.padding(context, mobile: 24, tablet: 28, desktop: 32),
      child: Column(
        children: [
          // Header with Live Clock and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, d MMMM').format(_currentTime),
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('h:mm:ss a').format(_currentTime),
                    style: TextStyle(
                      color: AppTheme.textDarkHeading,
                      fontSize: ResponsiveUtils.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCheckedIn
                      ? AppTheme.statusGreen.withValues(alpha: 0.12)
                      : AppTheme.statusAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isCheckedIn ? AppTheme.statusGreen : AppTheme.statusAmber,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 600.ms).fadeOut(delay: 600.ms),
                    const SizedBox(width: 8),
                    Text(
                      isCheckedIn ? 'ON DUTY' : 'OFF DUTY',
                      style: TextStyle(
                        color: isCheckedIn ? AppTheme.statusGreen : AppTheme.statusAmber,
                        fontSize: ResponsiveUtils.fontSize(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Main Action Area
          Row(
            children: [
              // Check In/Out Button
              GestureDetector(
                onTap: _isLoading ? null : _handleCheckIn,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: ResponsiveUtils.size(context, 140),
                  height: ResponsiveUtils.size(context, 140),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCheckedIn
                          ? [AppTheme.statusCrimson, AppTheme.statusCrimson.withValues(alpha: 0.8)]
                          : [AppTheme.primaryPlum, AppTheme.primaryPlum.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isCheckedIn ? AppTheme.statusCrimson : AppTheme.primaryPlum).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple effect when not checked in
                      if (!isCheckedIn && !_isLoading)
                        ...List.generate(3, (index) {
                          return Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryPlum.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fadeOut(duration: 1500.ms, delay: (index * 500).ms)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.3, 1.3),
                            duration: 1500.ms,
                            delay: (index * 500).ms,
                          );
                        }),
                      
                      // Button Content
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCheckedIn ? Icons.logout : Icons.login,
                                  color: Colors.white,
                                  size: ResponsiveUtils.iconSize(context, 40),
                                ).animate(
                                  onPlay: (controller) => controller.repeat(reverse: true),
                                ).scale(
                                  duration: 1000.ms,
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.1, 1.1),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.fontSize(context, 14),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),

              const SizedBox(width: 24),

              // Stats (Live Time & Location)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCheckedIn) ...[
                      const Text(
                        'Live Duration',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formattedDuration,
                        style: TextStyle(
                          color: AppTheme.textDarkHeading,
                          fontSize: ResponsiveUtils.fontSize(context, 24),
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primaryPlum.withValues(alpha: 0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Location',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoading ? 'Fetching location...' : location,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textBody,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
