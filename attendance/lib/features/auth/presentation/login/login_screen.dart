import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/router/employee_shell.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _formController;
  late AnimationController _shakeController;
  late List<Animation<double>> _fieldOpacities;
  late List<Animation<Offset>> _fieldSlides;
  late Animation<double> _shakeAnimation;

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Shake animation for errors
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Staggered animations for each field
    _fieldOpacities = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _formController,
          curve: Interval(
            index * 0.15,
            0.4 + index * 0.15,
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _fieldSlides = List.generate(5, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _formController,
          curve: Interval(
            index * 0.15,
            0.4 + index * 0.15,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _formController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _shakeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    // Simple validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      _shakeController.forward().then((_) => _shakeController.reverse());
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simulate login (no backend) then save auth state
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Save login state
    await AuthService().login();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const EmployeeShell(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 768;
    final isMedium = size.width >= 768 && size.width < 1024;

    double cardWidth = isSmall
        ? size.width * 0.9
        : isMedium
            ? size.width * 0.6
            : 420;

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 16 : 24,
              vertical: 24,
            ),
            child: AnimatedBuilder(
              animation: _formController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fieldOpacities[0],
                  child: child,
                );
              },
              child: Container(
                width: cardWidth,
                padding: EdgeInsets.all(isSmall ? 24 : 32),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPlum.withValues(alpha: 0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 12),
                    _buildForgotPassword(),
                    const SizedBox(height: 24),
                    _buildSignInButton(),
                    const SizedBox(height: 20),
                    _buildSignUpText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _fieldSlides[0],
          child: FadeTransition(
            opacity: _fieldOpacities[0],
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  AppTheme.primaryPlum,
                  AppTheme.primaryPlum.withValues(alpha: 0.8),
                ],
              ).createShader(bounds);
            },
            child: const Text(
              'NOVA TECH',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textBody,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _fieldSlides[1],
          child: FadeTransition(
            opacity: _fieldOpacities[1],
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shake = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Focus(
          onFocusChange: (hasFocus) => setState(() {}),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _emailFocusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryPlum.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.primaryPlum.withValues(alpha: 0.08),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: InputDecoration(
                labelText: 'Email or Username',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppTheme.primaryPlum.withValues(alpha: 0.7),
                ),
                errorText: _errorMessage != null && _emailController.text.trim().isEmpty
                    ? ''
                    : null,
                errorStyle: const TextStyle(height: 0),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _fieldSlides[2],
          child: FadeTransition(
            opacity: _fieldOpacities[2],
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final shake = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Focus(
          onFocusChange: (hasFocus) => setState(() {}),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _passwordFocusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryPlum.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppTheme.primaryPlum.withValues(alpha: 0.08),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AppTheme.primaryPlum.withValues(alpha: 0.7),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                errorText: _errorMessage != null && _passwordController.text.trim().isEmpty
                    ? ''
                    : null,
                errorStyle: const TextStyle(height: 0),
              ),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fieldOpacities[2],
          child: child,
        );
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to forgot password
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppTheme.primaryPlum,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return SlideTransition(
          position: _fieldSlides[3],
          child: FadeTransition(
            opacity: _fieldOpacities[3],
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {},
        onTapUp: (_) {},
        onTapCancel: () {},
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 100),
          tween: Tween(begin: 1.0, end: 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignIn,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppTheme.creamBackground),
                    ),
                  )
                : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpText() {
    return AnimatedBuilder(
      animation: _formController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fieldOpacities[3],
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: AppTheme.textBody,
              fontSize: 14,
            ),
          ),
          InkWell(
            onTap: () {
              // TODO: Navigate to sign up
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: AppTheme.primaryPlum,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
