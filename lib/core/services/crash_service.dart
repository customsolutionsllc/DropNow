import 'package:flutter/foundation.dart';

/// Centralized crash/error logger.
/// Stores last 50 errors in-memory for diagnostics.
/// In production, this can forward to Firebase Crashlytics or similar.
class CrashService {
  static final CrashService _instance = CrashService._();
  factory CrashService() => _instance;
  CrashService._();

  static const int _maxErrors = 50;
  final List<CrashRecord> _errors = [];

  List<CrashRecord> get errors => List.unmodifiable(_errors);

  /// Log an error with optional stack trace and context tag.
  void log(dynamic error, [StackTrace? stackTrace, String? context]) {
    final record = CrashRecord(
      error: error.toString(),
      stackTrace: stackTrace,
      context: context,
      timestamp: DateTime.now(),
    );

    _errors.add(record);
    if (_errors.length > _maxErrors) {
      _errors.removeAt(0);
    }

    debugPrint('[CRASH] ${context != null ? "($context) " : ""}$error');
    if (stackTrace != null) {
      debugPrint('[CRASH] $stackTrace');
    }
  }
}

class CrashRecord {
  final String error;
  final StackTrace? stackTrace;
  final String? context;
  final DateTime timestamp;

  const CrashRecord({
    required this.error,
    this.stackTrace,
    this.context,
    required this.timestamp,
  });
}
