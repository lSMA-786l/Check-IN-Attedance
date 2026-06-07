import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/mock/mock_data.dart';
import '../leaves/leave_screen.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/splash/splash_screen.dart';

/// Profile Screen - Settings and user management
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;

    return Scaffold(
      body: ResponsiveUtils.constrainedContent(
        context: context,
        maxWidth: 800,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Avatar
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryPlum,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                vertical: ResponsiveUtils.spacing(context, 40),
                horizontal: ResponsiveUtils.spacing(context, 20),
              ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: ResponsiveUtils.size(context, 100),
                          height: ResponsiveUtils.size(context, 100),
                          decoration: const BoxDecoration(
                            color: AppTheme.cardWhite,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: ResponsiveUtils.iconSize(context, 50),
                            color: AppTheme.primaryPlum,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppTheme.statusGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: AppTheme.textLightHeading,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user.email,
                      style: TextStyle(
                        color: AppTheme.textLightHeading.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ID
                    Text(
                      'ID: ${user.id}',
                      style: TextStyle(
                        color: AppTheme.textLightHeading.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu Items
              Padding(
                padding: ResponsiveUtils.horizontalPadding(context, mobile: 20),
                child: Column(
                  children: [
                    // My Details
                    _MenuTile(
                      icon: Icons.person_outline,
                      title: 'My Details',
                      onTap: () {
                        // Navigate to details screen (placeholder)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('My Details screen coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // My Leaves (NEW)
                    _MenuTile(
                      icon: Icons.event_busy,
                      title: 'My Leaves',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaveScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Settings Section
                    _MenuTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      trailing: const SizedBox(),
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),

                    // Notifications Toggle
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: const Text(
                          'Notifications',
                          style: TextStyle(
                            color: AppTheme.textBody,
                            fontSize: 16,
                          ),
                        ),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                        activeTrackColor: AppTheme.statusGreen,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Theme
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: const Text(
                          'Theme',
                          style: TextStyle(
                            color: AppTheme.textBody,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Text(
                          'System',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Theme selection coming soon')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Change Password
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppTheme.cardShadow],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: const Text(
                          'Change Password',
                          style: TextStyle(
                            color: AppTheme.textBody,
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textMuted,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Change password screen coming soon')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Support Tickets
                    _MenuTile(
                      icon: Icons.support_agent,
                      title: 'Support Tickets',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Support tickets screen coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Privacy Policy
                    _MenuTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy policy screen coming soon')),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.statusCrimson.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.statusCrimson.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.statusCrimson.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: AppTheme.statusCrimson,
                            size: 24,
                          ),
                        ),
                        title: const Text(
                          'Logout',
                          style: TextStyle(
                            color: AppTheme.statusCrimson,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () async {
                          // Show confirmation dialog
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.statusCrimson,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && mounted) {
                            // Clear auth state IMMEDIATELY
                            final authService = AuthService();
                            await authService.logout();
                            
                            // Small delay to ensure state is cleared
                            await Future.delayed(const Duration(milliseconds: 100));
                            
                            if (mounted) {
                              // Navigate to splash and remove all routes
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const SplashScreen(),
                                ),
                                (_) => false,
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppTheme.cardShadow],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPlum.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryPlum,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textDarkHeading,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textMuted,
            ),
        onTap: onTap,
      ),
    );
  }
}
