import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_sync_processor.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';

/// Widget that initializes auth and starts sync when ready.
/// Place this as the root of your app after ProviderScope.
class AuthGate extends ConsumerStatefulWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize auth exactly once
    Future.microtask(() {
      if (mounted && !_initialized) {
        _initialized = true;
        ref.read(authProvider.notifier).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Start sync when auth becomes ready
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == false && next.isAuthenticated) {
        final database = ref.read(databaseProvider);
        final syncProcessor = ConvexSyncProcessor(database);
        syncProcessor.start();
        debugPrint('[AuthGate] Auth ready, sync started');
      }
    });

    return widget.child;
  }
}
