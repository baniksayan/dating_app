import 'package:flutter/widgets.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  // Design baseline: iPhone 13 Pro (390 x 844)
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  /// Dynamic scale factor based on screen width
  static double scaleWidth(BuildContext context, double size) {
    final double width = MediaQuery.of(context).size.width;
    return (width / _baseWidth) * size;
  }

  /// Dynamic scale factor based on screen height
  static double scaleHeight(BuildContext context, double size) {
    final double height = MediaQuery.of(context).size.height;
    return (height / _baseHeight) * size;
  }

  /// Scale text font sizes with constraint limits to avoid overflow
  static double scaleText(BuildContext context, double size) {
    final double width = MediaQuery.of(context).size.width;
    final double scale = width / _baseWidth;
    // Don't let text scale down too aggressively or scale up too high
    final double clampedScale = scale.clamp(0.85, 1.25);
    return size * clampedScale;
  }

  /// Dynamic size selection for small vs normal vs tablet
  static T select<T>(
    BuildContext context, {
    required T standard,
    T? smallPhone,
    T? tablet,
  }) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 375 && smallPhone != null) {
      return smallPhone;
    } else if (width >= 768 && tablet != null) {
      return tablet;
    }
    return standard;
  }
}
