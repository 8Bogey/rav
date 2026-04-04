import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_sync_processor.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';

/// Widget that initializes auth and starts sync when ready.
/// Place this as the root of your app after ProviderScope.
class AuthGate extends ConsumerWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Initialize auth on first build
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == false && next.isAuthenticated) {
        // Auth just became ready — start sync
        final database = ref.read(databaseProvider);
        final syncProcessor = ConvexSyncProcessor(database);
        syncProcessor.start();
        debugPrint('[AuthGate] Auth ready, sync started');
      }
    });

    // Run initialization
    if (!authState.isLoading && !authState.isAuthenticated) {
      // Trigger initialization once
      Future.microtask(() => ref.read(authProvider.notifier).initialize());
    }

    return child;
  }
}
