import 'package:flutter/painting.dart';

extension ColorExt on Color {
  /// Converts a Hex String to a Color instance. Supports formats like #RRGGBB, RRGGBB, #AARRGGBB.
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Darken the color by a given percentage (0.0 to 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  /// Lighten the color by a given percentage (0.0 to 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  /// Returns true if the color is bright / light, useful for dynamic contrast
  bool get isLight {
    // Standard relative luminance formula
    final double luminance = computeLuminance();
    return luminance > 0.5;
  }
}
