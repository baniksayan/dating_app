import 'package:flutter/widgets.dart';

extension NumberExt on num {
  /// Vertical space (SizedBox with height)
  SizedBox get vSpace => SizedBox(height: toDouble());

  /// Horizontal space (SizedBox with width)
  SizedBox get hSpace => SizedBox(width: toDouble());

  /// Returns a Duration in milliseconds
  Duration get milliseconds => Duration(milliseconds: toInt());

  /// Returns a Duration in seconds
  Duration get seconds => Duration(seconds: toInt());
}
