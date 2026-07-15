import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void info(String message, [String? tag]) {
    _log('💡 [INFO]', message, tag);
  }

  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      _log('⚙️ [DEBUG]', message, tag);
    }
  }

  static void warning(String message, [String? tag]) {
    _log('⚠️ [WARNING]', message, tag);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace, String? tag]) {
    _log('🚨 [ERROR]', message, tag);
    if (error != null) {
      _log('🚨 [DETAILS]', error.toString(), tag);
    }
    if (stackTrace != null) {
      _log('🚨 [STACKTRACE]', stackTrace.toString(), tag);
    }
  }

  static void _log(String prefix, String message, String? tag) {
    final String tagPrefix = tag != null ? '[$tag] ' : '';
    // Use debugPrint to avoid platform-specific log truncations
    debugPrint('$prefix: $tagPrefix$message');
  }
}
