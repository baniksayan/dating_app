import 'package:flutter/painting.dart';
import 'color_ext.dart';

extension StringExt on String {
  /// Capitalize first letter of string
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if it's a valid email address
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if it's a valid OTP (e.g. 4 or 6 digits)
  bool get isValidOtp => RegExp(r'^\d{4,6}$').hasMatch(this);

  /// Parse the string directly to a Color (assumes Hex string)
  Color toColor() => ColorExt.fromHex(this);
}
