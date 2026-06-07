import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/router/employee_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _spiralController;
  late AnimationController _textController;
  late AnimationController _particleController;

  late Animation<double> _textFadeAnimation;
  late Animation<double> _textScaleAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Spiral rotation animation (continuous)
    _spiralController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Particle pulse animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Text animations (smoother with curves)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start text animation
    _textController.forward();

    // Navigate after 3 seconds based on auth status
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check if user is logged in
    final isLoggedIn = await AuthService().isLoggedIn();
    
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const EmployeeShell() : LoginScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _spiralController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: Stack(
        children: [
          // Animated Spiral Background
          AnimatedBuilder(
            animation: _spiralController,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: SpiralPainter(
                  animation: _spiralController.value,
                  particleAnimation: _particleController.value,
                ),
              );
            },
          ),

          // Gradient Overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  AppTheme.creamBackground.withValues(alpha: 0.3),
                  AppTheme.creamBackground.withValues(alpha: 0.8),
                  AppTheme.creamBackground,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Animated NOVA TECH Text
          Center(
            child: AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textFadeAnimation,
                  child: ScaleTransition(
                    scale: _textScaleAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: child,
                    ),
                  ),
                );
              },
              child: _buildNovaText(size),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNovaText(Size size) {
    // Responsive text size
    double fontSize = size.width < 768
        ? 48.0
        : size.width < 1024
            ? 64.0
            : 72.0;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            AppTheme.primaryPlum,
            AppTheme.primaryPlum.withValues(alpha: 0.7),
            AppTheme.statusBlue.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: Text(
        'NOVA TECH',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 4.0,
          color: Colors.white,
          shadows: [
            Shadow(
              color: AppTheme.primaryPlum.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Animated Spiral Background with Better Visibility
class SpiralPainter extends CustomPainter {
  final double animation;
  final double particleAnimation;

  SpiralPainter({required this.animation, required this.particleAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 0.9;

    // Draw animated gradient circles (background layer)
    _drawPulsingCircles(canvas, center, size, maxRadius);

    // Draw bold spirals (main visual layer)
    _drawBoldSpirals(canvas, center, maxRadius);

    // Draw thin accent spirals (detail layer)
    _drawAccentSpirals(canvas, center, maxRadius);
  }

  void _drawPulsingCircles(Canvas canvas, Offset center, Size size, double maxRadius) {
    final paint = Paint()..style = PaintingStyle.stroke;

    for (int i = 1; i <= 8; i++) {
      final pulse = math.sin(particleAnimation * 2 * math.pi + i * 0.5) * 0.05;
      final radius = (maxRadius / 8) * i * (1 + pulse);
      
      paint.strokeWidth = 1.5;
      paint.color = AppTheme.primaryPlum.withValues(
        alpha: 0.08 * (9 - i) / 8 + particleAnimation * 0.03,
      );
      
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _drawBoldSpirals(Canvas canvas, Offset center, double maxRadius) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw 3 main spirals with good visibility
    for (int spiralIndex = 0; spiralIndex < 3; spiralIndex++) {
      final path = Path();
      final spiralOffset = spiralIndex * (2 * math.pi / 3);
      final rotationOffset = animation * 2 * math.pi + spiralOffset;

      bool firstPoint = true;
      for (double t = 0; t <= 12 * math.pi; t += 0.08) {
        final radius = (t / (12 * math.pi)) * maxRadius;
        final angle = t * 0.5 + rotationOffset;

        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);

        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }

      // Much more visible stroke width and opacity
      paint.strokeWidth = 3.0;
      
      // Better gradient with higher opacity
      final gradientColors = spiralIndex == 0
          ? [
              AppTheme.primaryPlum.withValues(alpha: 0.4 + particleAnimation * 0.15),
              AppTheme.primaryPlum.withValues(alpha: 0.25 + particleAnimation * 0.1),
              AppTheme.primaryPlum.withValues(alpha: 0.15),
            ]
          : spiralIndex == 1
              ? [
                  AppTheme.statusBlue.withValues(alpha: 0.35 + particleAnimation * 0.1),
                  AppTheme.statusBlue.withValues(alpha: 0.2 + particleAnimation * 0.05),
                  AppTheme.statusBlue.withValues(alpha: 0.1),
                ]
              : [
                  AppTheme.primaryPlum.withValues(alpha: 0.3 + particleAnimation * 0.1),
                  AppTheme.statusBlue.withValues(alpha: 0.2),
                  AppTheme.primaryPlum.withValues(alpha: 0.1),
                ];

      paint.shader = LinearGradient(
        colors: gradientColors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

      canvas.drawPath(path, paint);
    }
  }

  void _drawAccentSpirals(Canvas canvas, Offset center, double maxRadius) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw thinner counter-rotating spirals for depth
    for (int spiralIndex = 0; spiralIndex < 2; spiralIndex++) {
      final path = Path();
      final spiralOffset = spiralIndex * math.pi;
      final rotationOffset = -animation * 1.5 * math.pi + spiralOffset; // Counter-rotate

      bool firstPoint = true;
      for (double t = 0; t <= 10 * math.pi; t += 0.1) {
        final radius = (t / (10 * math.pi)) * maxRadius * 0.9;
        final angle = t * 0.6 + rotationOffset;

        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);

        if (firstPoint) {
          path.moveTo(x, y);
          firstPoint = false;
        } else {
          path.lineTo(x, y);
        }
      }

      paint.strokeWidth = 1.5;
      paint.shader = LinearGradient(
        colors: [
          AppTheme.statusBlue.withValues(alpha: 0.2 + particleAnimation * 0.08),
          AppTheme.statusBlue.withValues(alpha: 0.1),
          AppTheme.primaryPlum.withValues(alpha: 0.08),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SpiralPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.particleAnimation != particleAnimation;
  }
}

