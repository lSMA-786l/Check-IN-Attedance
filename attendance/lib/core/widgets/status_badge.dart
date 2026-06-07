import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status Badge Widget
/// Displays colored badges for status indicators (Present, Pending, Approved, etc.)
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case StatusType.success:
        backgroundColor = AppTheme.statusGreen.withValues(alpha: 0.1);
        textColor = AppTheme.statusGreen;
        break;
      case StatusType.warning:
        backgroundColor = AppTheme.statusAmber.withValues(alpha: 0.1);
        textColor = AppTheme.statusAmber;
        break;
      case StatusType.error:
        backgroundColor = AppTheme.statusCrimson.withValues(alpha: 0.1);
        textColor = AppTheme.statusCrimson;
        break;
      case StatusType.info:
        backgroundColor = AppTheme.statusBlue.withValues(alpha: 0.1);
        textColor = AppTheme.statusBlue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

enum StatusType {
  success, // Green - Present, Approved, Low Priority
  warning, // Amber - Pending, Medium Priority
  error,   // Crimson - Absent, Rejected, High Priority
  info,    // Blue - In Progress, Info
}
