import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Enhanced Stat Card Widget with gradients and animations
class StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.iconColor ?? AppTheme.primaryPlum;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isHovered
                ? [
                    color.withValues(alpha: 0.15),
                    color.withValues(alpha: 0.05),
                  ]
                : [
                    AppTheme.cardWhite,
                    AppTheme.cardWhite,
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered 
                ? color.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.08),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? color.withValues(alpha: 0.15)
                  : AppTheme.primaryPlum.withValues(alpha: 0.04),
              blurRadius: _isHovered ? 20 : 10,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        padding: ResponsiveUtils.padding(context, mobile: 16, tablet: 18, desktop: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon with animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(ResponsiveUtils.spacing(context, 12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: _isHovered ? 0.2 : 0.15),
                    color.withValues(alpha: _isHovered ? 0.15 : 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: ResponsiveUtils.borderRadius(context, 14),
                boxShadow: _isHovered ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
              ),
              child: Icon(
                widget.icon,
                color: color,
                size: ResponsiveUtils.iconSize(context, 24),
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            ).shimmer(
              duration: 2000.ms,
              color: color.withValues(alpha: 0.3),
            ),
            
            const SizedBox(height: 4),
            
            // Value with count-up animation
            Text(
              widget.value,
              style: TextStyle(
                color: AppTheme.textDarkHeading,
                fontSize: ResponsiveUtils.fontSize(context, 28),
                fontWeight: FontWeight.bold,
                height: 1.2,
                shadows: _isHovered ? [
                  Shadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ] : [],
              ),
            ),
            
            // Label
            Text(
              widget.label,
              style: TextStyle(
                color: _isHovered ? color : AppTheme.textMuted,
                fontSize: ResponsiveUtils.fontSize(context, 12),
                fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1.0, 1.0),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}
