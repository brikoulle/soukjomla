import '../config/app_config.dart';

class Logger {
  static void info(String message, {Map<String, dynamic>? data}) {
    if (AppConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      final dataStr = data != null ? ' | ${data.toString()}' : '';
      print('[INFO] $timestamp | $message$dataStr');
    }
  }

  static void debug(String message, {Map<String, dynamic>? data}) {
    if (AppConfig.enableLogging) {
      final timestamp = DateTime.now().toIso8601String();
      final dataStr = data != null ? ' | ${data.toString()}' : '';
      print('[DEBUG] $timestamp | $message$dataStr');
    }
  }

  static void warning(String message, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final dataStr = data != null ? ' | ${data.toString()}' : '';
    print('[WARN] $timestamp | $message$dataStr');
  }

  static void error(
    String message, {
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final dataStr = data != null ? ' | ${data.toString()}' : '';
    final stackStr = stackTrace != null ? '\n$stackTrace' : '';
    print('[ERROR] $timestamp | $message$dataStr$stackStr');
  }
}
