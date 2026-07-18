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
    final String logMsg = '$prefix: $tagPrefix$message';
    // Use both print and debugPrint to ensure it appears in both standard terminal and IDE debug console
    // ignore: avoid_print
    print(logMsg);
    debugPrint(logMsg);
  }
}
