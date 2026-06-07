import 'package:flutter/material.dart';

/// Responsive utility class for adaptive sizing across different screen sizes
class ResponsiveUtils {
  /// Device breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  
  /// Maximum content width for desktop
  static const double maxContentWidth = 1200;

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletBreakpoint;
  }

  /// Get responsive value based on screen size
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    }
    if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive width percentage
  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  /// Get responsive height percentage
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseFontSize) {
    final width = screenWidth(context);
    
    if (width < mobileBreakpoint) {
      return baseFontSize;
    } else if (width < tabletBreakpoint) {
      return baseFontSize * 1.1;
    } else {
      return baseFontSize * 1.15;
    }
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context, {
    double mobile = 20,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive<double>(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.all(value);
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context, {
    double mobile = 20,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive<double>(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.symmetric(horizontal: value);
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context, {
    double mobile = 20,
    double? tablet,
    double? desktop,
  }) {
    final value = responsive<double>(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.5,
      desktop: desktop ?? mobile * 2,
    );
    return EdgeInsets.symmetric(vertical: value);
  }

  /// Get grid column count based on screen size
  static int gridCrossAxisCount(BuildContext context, {
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    return responsive<int>(
      context: context,
      mobile: mobile,
      tablet: tablet ?? mobile * 2,
      desktop: desktop ?? mobile * 2,
    );
  }

  /// Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    return responsive<double>(
      context: context,
      mobile: baseSpacing,
      tablet: baseSpacing * 1.2,
      desktop: baseSpacing * 1.5,
    );
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    return responsive<double>(
      context: context,
      mobile: baseSize,
      tablet: baseSize * 1.1,
      desktop: baseSize * 1.2,
    );
  }

  /// Wrap content with max width constraint for desktop
  static Widget constrainedContent({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    if (!isDesktop(context)) {
      return child;
    }
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? maxContentWidth,
        ),
        child: child,
      ),
    );
  }

  /// Get responsive border radius
  static BorderRadius borderRadius(BuildContext context, double baseRadius) {
    final radius = responsive<double>(
      context: context,
      mobile: baseRadius,
      tablet: baseRadius * 1.1,
      desktop: baseRadius * 1.2,
    );
    return BorderRadius.circular(radius);
  }

  /// Get responsive size for widgets
  static double size(BuildContext context, double baseSize) {
    return responsive<double>(
      context: context,
      mobile: baseSize,
      tablet: baseSize * 1.15,
      desktop: baseSize * 1.3,
    );
  }
}
