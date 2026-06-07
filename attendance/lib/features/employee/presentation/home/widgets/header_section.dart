import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../data/mock/mock_data.dart';
import '../../../../../core/utils/responsive_utils.dart';

/// Header Section for Home Screen
class HeaderSection extends StatelessWidget {
  final VoidCallback onNotificationTap;
  final VoidCallback onLogoutTap;

  const HeaderSection({
    super.key,
    required this.onNotificationTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final unreadCount = MockData.notifications.where((n) => !n.isRead).length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryPlum,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(ResponsiveUtils.spacing(context, 30)),
          bottomRight: Radius.circular(ResponsiveUtils.spacing(context, 30)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        ResponsiveUtils.spacing(context, 20),
        ResponsiveUtils.spacing(context, 50),
        ResponsiveUtils.spacing(context, 20),
        ResponsiveUtils.spacing(context, 30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with user info and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOOD MORNING',
                      style: TextStyle(
                        color: AppTheme.textLightHeading,
                        fontSize: ResponsiveUtils.fontSize(context, 12),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.name,
                      style: TextStyle(
                        color: AppTheme.textLightHeading,
                        fontSize: ResponsiveUtils.fontSize(context, 24),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${user.id}',
                      style: TextStyle(
                        color: AppTheme.textLightHeading.withValues(alpha: 0.7),
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  // Notification bell
                  Stack(
                    children: [
                      IconButton(
                        onPressed: onNotificationTap,
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.textLightHeading,
                          size: ResponsiveUtils.iconSize(context, 28),
                        ),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.statusCrimson,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Logout button
                  IconButton(
                    onPressed: onLogoutTap,
                    icon: Icon(
                      Icons.logout,
                      color: AppTheme.textLightHeading,
                      size: ResponsiveUtils.iconSize(context, 24),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
