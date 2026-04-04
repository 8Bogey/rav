import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handling service
class ErrorService {
  static final ErrorService _instance = ErrorService._();
  factory ErrorService() => _instance;
  ErrorService._();

  final List<void Function(Object error, StackTrace? stack)> _listeners = [];

  void addListener(void Function(Object, StackTrace?) listener) {
    _listeners.add(listener);
  }

  void report(Object error, {StackTrace? stackTrace}) {
    debugPrint('[ErrorService] $error');
    if (stackTrace != null) {
      debugPrint('[ErrorService] Stack: $stackTrace');
    }
    for (final listener in _listeners) {
      try {
        listener(error, stackTrace);
      } catch (e) {
        debugPrint('[ErrorService] Listener error: $e');
      }
    }
  }

  /// Show an error dialog to the user
  static void showErrorDialog(BuildContext context, String message,
      {String? title}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title ?? 'خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// Show a retry dialog
  static Future<bool> showRetryDialog(BuildContext context, {String? message}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('فشل العملية'),
        content: Text(
            message ?? 'حدث خطأ أثناء تنفيذ العملية. هل تريد إعادة المحاولة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }
}
