import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

export '../auth/auth_provider.dart' show currentUserIdProvider;

/// Provider for the AppDatabase instance.
///
/// This is a singleton provider that creates and manages the database
/// lifecycle. The database is lazily initialized on first access and
/// properly closed when the provider is disposed.
///
/// Usage:
/// ```dart
/// final db = ref.watch(databaseProvider);
/// final subscribers = await db.subscribersDao.getAllSubscribers();
/// ```
final databaseProvider = Provider<AppDatabase>((ref) {
  // Create the database instance
  final database = AppDatabase();

  // Ensure database is closed when provider is disposed
  ref.onDispose(() {
    database.close();
  });

  return database;
});

/// Provider for SubscribersDao
///
/// Convenience provider to access the SubscribersDao directly
final subscribersDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).subscribersDao;
});

/// Provider for CabinetsDao
///
/// Convenience provider to access the CabinetsDao directly
final cabinetsDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).cabinetsDao;
});

/// Provider for PaymentsDao
///
/// Convenience provider to access the PaymentsDao directly
final paymentsDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).paymentsDao;
});

/// Provider for WorkersDao
///
/// Convenience provider to access the WorkersDao directly
final workersDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).workersDao;
});

/// Provider for AuditLogDao
///
/// Convenience provider to access the AuditLogDao directly
final auditLogDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).auditLogDao;
});

/// Provider for WhatsappTemplatesDao
///
/// Convenience provider to access the WhatsappTemplatesDao directly
final whatsappTemplatesDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).whatsappTemplatesDao;
});
