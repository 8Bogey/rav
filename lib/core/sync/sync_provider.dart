import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/sync/enhanced_sync_service.dart';
import 'package:mawlid_al_dhaki/core/supabase/supabase_provider.dart';

/// Provider for the enhanced sync service with retry logic and real-time status
final enhancedSyncServiceProvider = Provider<EnhancedSyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final service = EnhancedSyncService(database: database, supabaseService: supabaseService);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for sync progress updates
final syncProgressProvider = StreamProvider<SyncProgress>((ref) {
  final syncService = ref.watch(enhancedSyncServiceProvider);
  return syncService.syncProgressStream;
});

/// Stream provider for sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(enhancedSyncServiceProvider);
  return syncService.syncStatusStream;
});

/// Provider for sync statistics
final syncStatisticsProvider = FutureProvider<SyncStatistics>((ref) async {
  final syncService = ref.watch(enhancedSyncServiceProvider);
  return syncService.getSyncStatistics();
});