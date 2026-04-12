import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/guest_migration_service.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_sync_processor.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_down_sync_service.dart';
import 'package:mawlid_al_dhaki/core/sync/enhanced_sync_service.dart';

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
  EnhancedSyncService? _enhancedSync;

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
  void dispose() {
    _enhancedSync?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start enhanced sync when auth becomes ready
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.isAuthenticated == false && next.isAuthenticated) {
        // Migrate guest data to authenticated user before sync
        _migrateGuestDataIfNeeded(next.userId);
        _startEnhancedSync();
      }
    });

    return widget.child;
  }

  Future<void> _migrateGuestDataIfNeeded(String? userId) async {
    if (userId == null || userId.startsWith('guest-')) return;

    try {
      final database = ref.read(databaseProvider);
      final migrationService = GuestMigrationService(database);
      final guestCount = await migrationService.getGuestDataCount();
      if (guestCount > 0) {
        debugPrint(
            '[AuthGate] Found $guestCount guest records, migrating to $userId');
        final migrated = await migrationService.migrateGuestData(userId);
        debugPrint('[AuthGate] Guest migration complete: $migrated records');
      }
    } catch (e) {
      debugPrint('[AuthGate] Guest migration error: $e');
    }
  }

  void _startEnhancedSync() {
    final database = ref.read(databaseProvider);
    final syncProcessor = ConvexSyncProcessor(database);
    final downSyncService = ConvexDownSyncService(database);

    // Initialize enhanced sync service
    _enhancedSync = EnhancedSyncService(
      syncProcessor: syncProcessor,
      downSyncService: downSyncService,
    );

    // Start both up-sync and down-sync
    syncProcessor.start();
    downSyncService.syncFromCloud();

    debugPrint('[AuthGate] Enhanced sync started');
  }
}
