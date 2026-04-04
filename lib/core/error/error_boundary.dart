import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  const AppErrorBoundary({super.key, required this.child});

  @override
  ConsumerState<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends ConsumerState<AppErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  void Function(FlutterErrorDetails)? _previousOnError;

  @override
  void initState() {
    super.initState();
    _previousOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
      }
      debugPrint(
          'AppErrorBoundary caught: ${details.exception}\n${details.stack}');
      _previousOnError?.call(details);
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _previousOnError;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'حدث خطأ غير متوقع',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _stackTrace = null;
                    });
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return widget.child;
  }
}
