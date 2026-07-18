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
    final String fullPayload = '$tagPrefix$message';

    if (fullPayload.length > 800) {
      final RegExp pattern = RegExp('.{1,800}');
      pattern.allMatches(fullPayload).forEach((match) {
        final chunk = match.group(0);
        if (chunk != null) {
          final DateTime now = DateTime.now();
          final String timeStr =
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
          final String logMsg = '$prefix [$timeStr]: $chunk';
          // ignore: avoid_print
          print(logMsg);
          debugPrint(logMsg);
        }
      });
    } else {
      final DateTime now = DateTime.now();
      final String timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';
      final String logMsg = '$prefix [$timeStr]: $fullPayload';
      // ignore: avoid_print
      print(logMsg);
      debugPrint(logMsg);
    }
  }
}
