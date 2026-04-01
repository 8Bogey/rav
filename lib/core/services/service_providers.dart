import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/auth/auth_provider.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/cabinets_service.dart';
export 'package:mawlid_al_dhaki/core/services/cabinets_service.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';
export 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';
import 'package:mawlid_al_dhaki/core/services/payments_service.dart';
export 'package:mawlid_al_dhaki/core/services/payments_service.dart';
import 'package:mawlid_al_dhaki/core/services/workers_service.dart';
export 'package:mawlid_al_dhaki/core/services/workers_service.dart';
import 'package:mawlid_al_dhaki/core/services/audit_log_service.dart';
export 'package:mawlid_al_dhaki/core/services/audit_log_service.dart';
import 'package:mawlid_al_dhaki/core/services/whatsapp_service.dart';
export 'package:mawlid_al_dhaki/core/services/whatsapp_service.dart';

/// Helper to get ownerId from ref - returns empty string as fallback
String _getOwnerId(Ref ref) {
  return ref.watch(currentUserIdProvider) ?? '';
}

/// Provider for CabinetsService
final cabinetsServiceProvider = Provider<CabinetsService>((ref) {
  final database = ref.watch(databaseProvider);
  final ownerId = _getOwnerId(ref);
  return CabinetsService(database);
});

/// Provider for SubscribersService
final subscribersServiceProvider = Provider<SubscribersService>((ref) {
  final database = ref.watch(databaseProvider);
  return SubscribersService(database);
});

/// Provider for PaymentsService
final paymentsServiceProvider = Provider<PaymentsService>((ref) {
  final database = ref.watch(databaseProvider);
  return PaymentsService(database);
});

/// Provider for WorkersService
final workersServiceProvider = Provider<WorkersService>((ref) {
  final database = ref.watch(databaseProvider);
  return WorkersService(database);
});

/// Provider for AuditLogService - requires ownerId
final auditLogServiceProvider = Provider<AuditLogService>((ref) {
  final database = ref.watch(databaseProvider);
  final ownerId = _getOwnerId(ref);
  return AuditLogService(database, ownerId: ownerId);
});

/// Provider for WhatsappService
final whatsappServiceProvider = Provider<WhatsappService>((ref) {
  final database = ref.watch(databaseProvider);
  return WhatsappService(database);
});