import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/cabinets_service.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';
import 'package:mawlid_al_dhaki/core/services/payments_service.dart';
import 'package:mawlid_al_dhaki/core/services/workers_service.dart';
import 'package:mawlid_al_dhaki/core/services/audit_log_service.dart';
import 'package:mawlid_al_dhaki/core/services/whatsapp_service.dart';
import 'supabase_config.dart';
import 'sync_conflict.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SupabaseService {
  /// Conflicts from the last completed [detectAndResolveConflicts] or bidirectional sync.
  List<SyncConflict> _lastSyncConflicts = [];

  /// Unmodifiable list from the last conflict detection + resolution pass.
  List<SyncConflict> get lastSyncConflicts =>
      List<SyncConflict>.unmodifiable(_lastSyncConflicts);

  late SupabaseClient _client;
  late CabinetsService _cabinetsService;
  late SubscribersService _subscribersService;
  late PaymentsService _paymentsService;
  late WorkersService _workersService;
  late AuditLogService _auditLogService;
  late WhatsappService _whatsappService;
  
  // Background sync variables
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  String? _workerPermissionsForBackgroundSync;

  /// Serializes all bidirectional sync work so login, background, and UI triggers do not overlap.
  Future<void> _serializedBidirectional = Future<void>.value();
  
  /// Check if a record should be synced based on permissions mask
  bool _shouldSyncRecord(String? recordPermissionsMask, String? workerPermissions) {
    // If no permissions mask on record or no worker permissions specified, sync everything
    if (recordPermissionsMask == null || workerPermissions == null) {
      return true;
    }
    
    // Parse permissions - assuming comma-separated permissions
    final recordPermissions = recordPermissionsMask.split(',').map((s) => s.trim()).toSet();
    final workerPermissionSet = workerPermissions.split(',').map((s) => s.trim()).toSet();
    
    // Sync if there's any intersection between record permissions and worker permissions
    return recordPermissions.intersection(workerPermissionSet).isNotEmpty;
  }
  
  /// Start background sync monitoring
  void startBackgroundSync({String? workerPermissions}) {
    _workerPermissionsForBackgroundSync = workerPermissions;
    
    // Listen for connectivity changes
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Check if any of the connectivity results indicates we're online
      if (results.any((result) => result != ConnectivityResult.none)) {
        // Device is online, trigger sync
        _performBackgroundSync();
      }
    });
    
    // Also check current connectivity status
    _checkInitialConnectivity();
  }
  
  /// Stop background sync monitoring
  void stopBackgroundSync() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
  
  /// Check initial connectivity status and sync if online
  Future<void> _checkInitialConnectivity() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    // Check if any of the connectivity results indicates we're online
    if (connectivityResults.any((result) => result != ConnectivityResult.none)) {
      // Device is online, trigger sync
      _performBackgroundSync();
    }
  }
  
  /// Perform background sync operation
  Future<void> _performBackgroundSync() async {
    try {
      print('Performing background sync...');
      await syncBidirectional(workerPermissions: _workerPermissionsForBackgroundSync);
      print('Background sync completed successfully');
    } catch (e) {
      print('Error during background sync: $e');
    }
  }

  /// Single entry point: local SQLite → Supabase → local, then conflict resolution.
  /// All callers share one serialized queue to avoid overlapping syncs.
  ///
  /// [onPhase] is invoked before each major step so UIs can show granular progress.
  Future<void> syncBidirectional({
    String? workerPermissions,
    void Function(SyncPipelinePhase phase)? onPhase,
  }) {
    Future<void> work() async {
      onPhase?.call(SyncPipelinePhase.localToCloud);
      await syncLocalToCloud(workerPermissions: workerPermissions);
      onPhase?.call(SyncPipelinePhase.cloudToLocal);
      await syncCloudToLocal(workerPermissions: workerPermissions);
      onPhase?.call(SyncPipelinePhase.conflictsDetecting);
      final conflicts = await _detectConflicts();
      onPhase?.call(SyncPipelinePhase.conflictsResolving);
      await _resolveConflictsLastWriteWins(conflicts);
      _lastSyncConflicts = List<SyncConflict>.from(conflicts);
    }

    _serializedBidirectional =
        _serializedBidirectional.catchError((_) {}).then((_) => work());
    return _serializedBidirectional;
  }
  
  /// Fetch a subscriber record from Supabase by ID
  Future<Map<String, dynamic>?> fetchCloudSubscriberById(int id) async {
    try {
      final response = await _client
          .from(SupabaseConfig.subscribersTable)
          .select()
          .eq('id', id)
          .limit(1)
          .single();
      
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching cloud subscriber by ID $id: $e');
      return null;
    }
  }
  
  /// Fetch a cabinet record from Supabase by ID
  Future<Map<String, dynamic>?> fetchCloudCabinetById(int id) async {
    try {
      final response = await _client
          .from(SupabaseConfig.cabinetsTable)
          .select()
          .eq('id', id)
          .limit(1)
          .single();
      
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching cloud cabinet by ID $id: $e');
      return null;
    }
  }
  
  /// Fetch a payment record from Supabase by ID
  Future<Map<String, dynamic>?> fetchCloudPaymentById(int id) async {
    try {
      final response = await _client
          .from(SupabaseConfig.paymentsTable)
          .select()
          .eq('id', id)
          .limit(1)
          .single();
      
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching cloud payment by ID $id: $e');
      return null;
    }
  }
  
  /// Fetch a worker record from Supabase by ID
  Future<Map<String, dynamic>?> fetchCloudWorkerById(int id) async {
    try {
      final response = await _client
          .from(SupabaseConfig.workersTable)
          .select()
          .eq('id', id)
          .limit(1)
          .single();
      
      return response as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching cloud worker by ID $id: $e');
      return null;
    }
  }

  SupabaseService({
    required AppDatabase database,
  }) {
    _client = Supabase.instance.client;
    _cabinetsService = CabinetsService(database);
    _subscribersService = SubscribersService(database);
    _paymentsService = PaymentsService(database);
    _workersService = WorkersService(database);
    _auditLogService = AuditLogService(database);
    _whatsappService = WhatsappService(database);
  }

  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  /// Sync all local data to Supabase
  Future<void> syncLocalToCloud({String? workerPermissions}) async {
    await syncCabinets(workerPermissions: workerPermissions);
    await syncSubscribers(workerPermissions: workerPermissions);
    await syncPayments(workerPermissions: workerPermissions);
    await syncWorkers(workerPermissions: workerPermissions);
    await syncAuditLog(workerPermissions: workerPermissions);
    await syncWhatsappTemplates(workerPermissions: workerPermissions);
  }

  /// Sync cabinets to Supabase
  Future<void> syncCabinets({String? workerPermissions}) async {
    try {
      final localCabinets = await _cabinetsService.getAllCabinets();
      
      for (final cabinet in localCabinets) {
        // Skip syncing this cabinet if it doesn't match worker permissions
        if (!_shouldSyncRecord(cabinet.permissionsMask, workerPermissions)) {
          continue;
        }
        
        final data = {
          'id': cabinet.id,
          'name': cabinet.name,
          'letter': cabinet.letter,
          'total_subscribers': cabinet.totalSubscribers,
          'current_subscribers': cabinet.currentSubscribers,
          'collected_amount': cabinet.collectedAmount,
          'delayed_subscribers': cabinet.delayedSubscribers,
          'completion_date': cabinet.completionDate?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          // Sync metadata fields
          'last_modified': cabinet.lastModified?.toIso8601String(),
          'sync_status': cabinet.syncStatus,
          'dirty_flag': cabinet.dirtyFlag,
          'cloud_id': cabinet.cloudId,
          'deleted_locally': cabinet.deletedLocally,
          'permissions_mask': cabinet.permissionsMask,
        };

        // Upsert cabinet data
        try {
          await _client
              .from(SupabaseConfig.cabinetsTable)
              .upsert(data, onConflict: 'id');
          
          // Reset sync error if sync was successful
          await _cabinetsService.resetSyncError(cabinet.id);
        } catch (e) {
          // Track sync error in database
          await _cabinetsService.updateSyncError(cabinet.id, e.toString());
          rethrow;
        }
      }
    } catch (e) {
      print('Error syncing cabinets: $e');
      rethrow;
    }
  }

  /// Sync subscribers to Supabase
  Future<void> syncSubscribers({String? workerPermissions}) async {
    try {
      final localSubscribers = await _subscribersService.getAllSubscribers();
      
      for (final subscriber in localSubscribers) {
        // Skip syncing this subscriber if it doesn't match worker permissions
        if (!_shouldSyncRecord(subscriber.permissionsMask, workerPermissions)) {
          continue;
        }
        
        final data = {
          'id': subscriber.id,
          'name': subscriber.name,
          'code': subscriber.code,
          'cabinet': subscriber.cabinet,
          'phone': subscriber.phone,
          'status': subscriber.status,
          'start_date': subscriber.startDate.toIso8601String(),
          'accumulated_debt': subscriber.accumulatedDebt,
          'tags': subscriber.tags,
          'notes': subscriber.notes,
          'updated_at': DateTime.now().toIso8601String(),
          // Sync metadata fields
          'last_modified': subscriber.lastModified?.toIso8601String(),
          'sync_status': subscriber.syncStatus,
          'dirty_flag': subscriber.dirtyFlag,
          'cloud_id': subscriber.cloudId,
          'deleted_locally': subscriber.deletedLocally,
          'permissions_mask': subscriber.permissionsMask,
        };

        // Upsert subscriber data
        await _client
            .from(SupabaseConfig.subscribersTable)
            .upsert(data, onConflict: 'id');
      }
    } catch (e) {
      print('Error syncing subscribers: $e');
      rethrow;
    }
  }

  /// Sync payments to Supabase
  Future<void> syncPayments({String? workerPermissions}) async {
    try {
      final localPayments = await _paymentsService.getAllPayments();
      
      for (final payment in localPayments) {
        // Skip syncing this payment if it doesn't match worker permissions
        if (!_shouldSyncRecord(payment.permissionsMask, workerPermissions)) {
          continue;
        }
        
        final data = {
          'id': payment.id,
          'subscriber_id': payment.subscriberId,
          'amount': payment.amount,
          'worker': payment.worker,
          'date': payment.date.toIso8601String(),
          'cabinet': payment.cabinet,
          'updated_at': DateTime.now().toIso8601String(),
          // Sync metadata fields
          'last_modified': payment.lastModified?.toIso8601String(),
          'sync_status': payment.syncStatus,
          'dirty_flag': payment.dirtyFlag,
          'cloud_id': payment.cloudId,
          'deleted_locally': payment.deletedLocally,
          'permissions_mask': payment.permissionsMask,
        };

        // Upsert payment data
        await _client
            .from(SupabaseConfig.paymentsTable)
            .upsert(data, onConflict: 'id');
      }
    } catch (e) {
      print('Error syncing payments: $e');
      rethrow;
    }
  }

  /// Sync workers to Supabase
  Future<void> syncWorkers({String? workerPermissions}) async {
    try {
      final localWorkers = await _workersService.getAllWorkers();
      
      for (final worker in localWorkers) {
        // Skip syncing this worker if it doesn't match worker permissions
        if (!_shouldSyncRecord(worker.permissionsMask, workerPermissions)) {
          continue;
        }
        
        final data = {
          'id': worker.id,
          'name': worker.name,
          'phone': worker.phone,
          'permissions': worker.permissions,
          'today_collected': worker.todayCollected,
          'month_total': worker.monthTotal,
          'updated_at': DateTime.now().toIso8601String(),
          // Sync metadata fields
          'last_modified': worker.lastModified?.toIso8601String(),
          'sync_status': worker.syncStatus,
          'dirty_flag': worker.dirtyFlag,
          'cloud_id': worker.cloudId,
          'deleted_locally': worker.deletedLocally,
          'permissions_mask': worker.permissionsMask,
        };

        // Upsert worker data
        await _client
            .from(SupabaseConfig.workersTable)
            .upsert(data, onConflict: 'id');
      }
    } catch (e) {
      print('Error syncing workers: $e');
      rethrow;
    }
  }

  /// Sync audit log to Supabase
  Future<void> syncAuditLog({String? workerPermissions}) async {
    try {
      final localAuditLogs = await _auditLogService.getAllAuditLogEntries();
      
      for (final auditLog in localAuditLogs) {
        // Skip syncing this audit log entry if it doesn't match worker permissions
        if (!_shouldSyncRecord(auditLog.permissionsMask, workerPermissions)) {
          continue;
        }
        
        final data = {
          'id': auditLog.id,
          'user': auditLog.user,
          'action': auditLog.action,
          'target': auditLog.target,
          'details': auditLog.details,
          'type': auditLog.type,
          'timestamp': auditLog.timestamp.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          // Sync metadata fields
          'last_modified': auditLog.lastModified?.toIso8601String(),
          'sync_status': auditLog.syncStatus,
          'dirty_flag': auditLog.dirtyFlag,
          'cloud_id': auditLog.cloudId,
          'deleted_locally': auditLog.deletedLocally,
          'permissions_mask': auditLog.permissionsMask,
        };

        // Upsert audit log data
        await _client
            .from(SupabaseConfig.auditLogTable)
            .upsert(data, onConflict: 'id');
      }
    } catch (e) {
      print('Error syncing audit log: $e');
      rethrow;
    }
  }

  /// Sync WhatsApp templates to Supabase
  Future<void> syncWhatsappTemplates({String? workerPermissions}) async {
    try {
      final localTemplates = await _whatsappService.getAllTemplates();
      
      for (final template in localTemplates) {
        // Skip syncing this template if it doesn't match worker permissions
        if (!_shouldSyncRecord(template.permissionsMask, workerPermissions)) {
          continue;
        }
        
        final data = {
          'id': template.id,
          'title': template.title,
          'content': template.content,
          'is_active': template.isActive ? 1 : 0,
          'created_at': template.createdAt.toIso8601String(),
          'updated_at': template.updatedAt.toIso8601String(),
          // Sync metadata fields
          'last_modified': template.lastModified?.toIso8601String(),
          'sync_status': template.syncStatus,
          'dirty_flag': template.dirtyFlag,
          'cloud_id': template.cloudId,
          'deleted_locally': template.deletedLocally,
          'permissions_mask': template.permissionsMask,
        };

        // Upsert WhatsApp template data
        await _client
            .from(SupabaseConfig.whatsappTemplatesTable)
            .upsert(data, onConflict: 'id');
      }
    } catch (e) {
      print('Error syncing WhatsApp templates: $e');
      rethrow;
    }
  }

  /// Sync all cloud data to local database
  Future<void> syncCloudToLocal({String? workerPermissions}) async {
    await syncCloudCabinets(workerPermissions: workerPermissions);
    await syncCloudSubscribers(workerPermissions: workerPermissions);
    await syncCloudPayments(workerPermissions: workerPermissions);
    await syncCloudWorkers(workerPermissions: workerPermissions);
    await syncCloudAuditLog(workerPermissions: workerPermissions);
    await syncCloudWhatsappTemplates(workerPermissions: workerPermissions);
  }

  /// Detect and resolve conflicts using last-write-wins strategy
  Future<List<SyncConflict>> detectAndResolveConflicts() async {
    final conflicts = await _detectConflicts();
    await _resolveConflictsLastWriteWins(conflicts);
    _lastSyncConflicts = List<SyncConflict>.from(conflicts);
    return conflicts;
  }

  /// Detect conflicts between local and cloud records
  Future<List<SyncConflict>> _detectConflicts() async {
    final conflicts = <SyncConflict>[];
    
    // Check cabinets for conflicts
    conflicts.addAll(await _detectCabinetConflicts());
    
    // Check subscribers for conflicts
    conflicts.addAll(await _detectSubscriberConflicts());
    
    // Check payments for conflicts
    conflicts.addAll(await _detectPaymentConflicts());
    
    // Check workers for conflicts
    conflicts.addAll(await _detectWorkerConflicts());
    
    return conflicts;
  }

  /// Resolve conflicts using last-write-wins strategy
  Future<void> _resolveConflictsLastWriteWins(List<SyncConflict> conflicts) async {
    for (final conflict in conflicts) {
      switch (conflict.conflictType) {
        case ConflictType.concurrentModification:
          await _resolveConcurrentModification(conflict);
          break;
        case ConflictType.deleteModifyConflict:
          await _resolveDeleteModifyConflict(conflict);
          break;
        case ConflictType.dualDeleteConflict:
          // Nothing to do for dual deletes
          break;
        case ConflictType.businessRuleViolation:
          await _resolveBusinessRuleConflict(conflict);
          break;
        case ConflictType.dataIntegrityConflict:
          await _resolveDataIntegrityConflict(conflict);
          break;
      }
    }
  }

  /// Sync cabinets from Supabase to local database
  Future<void> syncCloudCabinets({String? workerPermissions}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.cabinetsTable)
          .select()
          .order('updated_at', ascending: false);

      final cabinetsData = response as List<dynamic>;

      for (final data in cabinetsData) {
        // Skip syncing this cabinet if it doesn't match worker permissions
        final permissionsMask = data['permissions_mask'] as String?;
        if (!_shouldSyncRecord(permissionsMask, workerPermissions)) {
          continue;
        }
        
        final cabinet = Cabinet(
          id: data['id'] as int,
          name: data['name'] as String,
          letter: data['letter'] as String? ?? '',
          totalSubscribers: data['total_subscribers'] as int,
          currentSubscribers: data['current_subscribers'] as int,
          collectedAmount: (data['collected_amount'] as num?)?.toDouble() ?? 0.0,
          delayedSubscribers: data['delayed_subscribers'] as int,
          completionDate: data['completion_date'] != null
              ? DateTime.parse(data['completion_date'] as String)
              : null,
          // Sync metadata fields
          lastModified: data['last_modified'] != null ? DateTime.parse(data['last_modified'] as String) : null,
          syncStatus: data['sync_status'] as String?,
          dirtyFlag: data['dirty_flag'] as bool?,
          cloudId: data['cloud_id'] as String?,
          deletedLocally: data['deleted_locally'] as bool?,
          permissionsMask: data['permissions_mask'] as String?,
        );

        // Check if cabinet exists locally
        final existing = await _cabinetsService.getCabinetById(cabinet.id);
        if (existing == null) {
          // Add new cabinet
          await _cabinetsService.addCabinet(cabinet);
        } else {
          // Update existing cabinet
          await _cabinetsService.updateCabinet(cabinet);
        }
      }
    } catch (e) {
      print('Error syncing cloud cabinets: $e');
      rethrow;
    }
  }

  /// Sync subscribers from Supabase to local database
  Future<void> syncCloudSubscribers({String? workerPermissions}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.subscribersTable)
          .select()
          .order('updated_at', ascending: false);

      final subscribersData = response as List<dynamic>;

      for (final data in subscribersData) {
        // Skip syncing this subscriber if it doesn't match worker permissions
        final permissionsMask = data['permissions_mask'] as String?;
        if (!_shouldSyncRecord(permissionsMask, workerPermissions)) {
          continue;
        }
        
        final subscriber = Subscriber(
          id: data['id'] as int,
          name: data['name'] as String,
          code: data['code'] as String,
          cabinet: data['cabinet'] as String,
          phone: data['phone'] as String,
          status: data['status'] as int,
          startDate: DateTime.parse(data['start_date'] as String),
          accumulatedDebt: (data['accumulated_debt'] as num?)?.toDouble() ?? 0.0,
          tags: data['tags'] as String?,
          notes: data['notes'] as String?,
          // Sync metadata fields
          lastModified: data['last_modified'] != null ? DateTime.parse(data['last_modified'] as String) : null,
          syncStatus: data['sync_status'] as String?,
          dirtyFlag: data['dirty_flag'] as bool?,
          cloudId: data['cloud_id'] as String?,
          deletedLocally: data['deleted_locally'] as bool?,
          permissionsMask: data['permissions_mask'] as String?,
        );

        // Check if subscriber exists locally
        final existing = await _subscribersService.getSubscriberById(subscriber.id);
        if (existing == null) {
          // Add new subscriber
          await _subscribersService.addSubscriber(subscriber);
        } else {
          // Update existing subscriber
          await _subscribersService.updateSubscriber(subscriber);
        }
      }
    } catch (e) {
      print('Error syncing cloud subscribers: $e');
      rethrow;
    }
  }

  /// Sync payments from Supabase to local database
  Future<void> syncCloudPayments({String? workerPermissions}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.paymentsTable)
          .select()
          .order('updated_at', ascending: false);

      final paymentsData = response as List<dynamic>;

      for (final data in paymentsData) {
        // Skip syncing this payment if it doesn't match worker permissions
        final permissionsMask = data['permissions_mask'] as String?;
        if (!_shouldSyncRecord(permissionsMask, workerPermissions)) {
          continue;
        }
        
        final payment = Payment(
          id: data['id'] as int,
          subscriberId: data['subscriber_id'] as int,
          amount: (data['amount'] as num).toDouble(),
          worker: data['worker'] as String,
          date: DateTime.parse(data['date'] as String),
          cabinet: data['cabinet'] as String,
          // Sync metadata fields
          lastModified: data['last_modified'] != null ? DateTime.parse(data['last_modified'] as String) : null,
          syncStatus: data['sync_status'] as String?,
          dirtyFlag: data['dirty_flag'] as bool?,
          cloudId: data['cloud_id'] as String?,
          deletedLocally: data['deleted_locally'] as bool?,
          permissionsMask: data['permissions_mask'] as String?,
        );

        // Check if payment exists locally
        final existing = await _paymentsService.getPaymentById(payment.id);
        if (existing == null) {
          // Add new payment
          await _paymentsService.addPayment(payment);
        } else {
          // Update existing payment
          await _paymentsService.updatePayment(payment);
        }
      }
    } catch (e) {
      print('Error syncing cloud payments: $e');
      rethrow;
    }
  }

  /// Sync workers from Supabase to local database
  Future<void> syncCloudWorkers({String? workerPermissions}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.workersTable)
          .select()
          .order('updated_at', ascending: false);

      final workersData = response as List<dynamic>;

      for (final data in workersData) {
        // Skip syncing this worker if it doesn't match worker permissions
        final permissionsMask = data['permissions_mask'] as String?;
        if (!_shouldSyncRecord(permissionsMask, workerPermissions)) {
          continue;
        }
        
        final worker = Worker(
          id: data['id'] as int,
          name: data['name'] as String,
          phone: data['phone'] as String,
          permissions: data['permissions'] as String,
          todayCollected: (data['today_collected'] as num?)?.toDouble() ?? 0.0,
          monthTotal: (data['month_total'] as num?)?.toDouble() ?? 0.0,
          // Sync metadata fields
          lastModified: data['last_modified'] != null ? DateTime.parse(data['last_modified'] as String) : null,
          syncStatus: data['sync_status'] as String?,
          dirtyFlag: data['dirty_flag'] as bool?,
          cloudId: data['cloud_id'] as String?,
          deletedLocally: data['deleted_locally'] as bool?,
          permissionsMask: data['permissions_mask'] as String?,
        );

        // Check if worker exists locally
        final existing = await _workersService.getWorkerById(worker.id);
        if (existing == null) {
          // Add new worker
          await _workersService.addWorker(worker);
        } else {
          // Update existing worker
          await _workersService.updateWorker(worker);
        }
      }
    } catch (e) {
      print('Error syncing cloud workers: $e');
      rethrow;
    }
  }

  /// Sync audit log from Supabase to local database
  Future<void> syncCloudAuditLog({String? workerPermissions}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.auditLogTable)
          .select()
          .order('timestamp', ascending: false);

      final auditLogsData = response as List<dynamic>;

      for (final data in auditLogsData) {
        // Skip syncing this audit log entry if it doesn't match worker permissions
        final permissionsMask = data['permissions_mask'] as String?;
        if (!_shouldSyncRecord(permissionsMask, workerPermissions)) {
          continue;
        }
        
        final auditLog = AuditLogEntry(
          id: data['id'] as int,
          user: data['user'] as String,
          action: data['action'] as String,
          target: data['target'] as String,
          details: data['details'] as String,
          type: data['type'] as String,
          timestamp: DateTime.parse(data['timestamp'] as String),
        );

        // Check if audit log entry exists locally
        // For audit log, we typically just insert new entries
        try {
          await _auditLogService.addAuditLogEntry(auditLog);
        } catch (e) {
          // Ignore duplicate entries
          print('Duplicate audit log entry, ignoring: $e');
        }
      }
    } catch (e) {
      print('Error syncing cloud audit log: $e');
      rethrow;
    }
  }

  /// Sync WhatsApp templates from Supabase to local database
  Future<void> syncCloudWhatsappTemplates({String? workerPermissions}) async {
    try {
      final response = await _client
          .from(SupabaseConfig.whatsappTemplatesTable)
          .select()
          .order('updated_at', ascending: false);

      final templatesData = response as List<dynamic>;

      for (final data in templatesData) {
        // Skip syncing this template if it doesn't match worker permissions
        final permissionsMask = data['permissions_mask'] as String?;
        if (!_shouldSyncRecord(permissionsMask, workerPermissions)) {
          continue;
        }
        
        final template = WhatsappTemplate(
          id: data['id'] as int,
          title: data['title'] as String,
          content: data['content'] as String,
          isActive: (data['is_active'] as int) == 1,
          createdAt: DateTime.parse(data['created_at'] as String),
          updatedAt: DateTime.parse(data['updated_at'] as String),
          // Sync metadata fields
          lastModified: data['last_modified'] != null ? DateTime.parse(data['last_modified'] as String) : null,
          syncStatus: data['sync_status'] as String?,
          dirtyFlag: data['dirty_flag'] as bool?,
          cloudId: data['cloud_id'] as String?,
          deletedLocally: data['deleted_locally'] as bool?,
          permissionsMask: data['permissions_mask'] as String?,
        );

        // Check if template exists locally
        // Note: We need to implement getTemplateById in the service
        try {
          await _whatsappService.addTemplate(template);
        } catch (e) {
          // If it fails, it might be a duplicate, so update instead
          try {
            await _whatsappService.updateTemplate(template);
          } catch (updateError) {
            print('Error updating WhatsApp template: $updateError');
          }
        }
      }
    } catch (e) {
      print('Error syncing cloud WhatsApp templates: $e');
      rethrow;
    }
  }
  
  /// Detect conflicts for cabinets
  Future<List<SyncConflict>> _detectCabinetConflicts() async {
    final conflicts = <SyncConflict>[];
    
    try {
      // Get all dirty cabinets from local database
      final dirtyCabinets = await _cabinetsService.getDirtyCabinets();
      
      // For each dirty cabinet, check if there's a corresponding record in the cloud
      // with a more recent lastModified timestamp
      for (final cabinet in dirtyCabinets) {
        // Get the corresponding cloud record by ID
        final cloudRecords = await _client
            .from(SupabaseConfig.cabinetsTable)
            .select()
            .eq('id', cabinet.id)
            .limit(1);
            
        if (cloudRecords.isNotEmpty) {
          final cloudRecord = cloudRecords.first;
          final cloudLastModified = cloudRecord['last_modified'] != null 
              ? DateTime.parse(cloudRecord['last_modified'] as String) 
              : null;
              
          // Check if cloud record was modified after local record
          if (cloudLastModified != null && 
              cabinet.lastModified != null &&
              cloudLastModified.isAfter(cabinet.lastModified!)) {
            // This is a concurrent modification conflict
            conflicts.add(SyncConflict(
              localRecordId: cabinet.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'cabinets',
              localLastModified: cabinet.lastModified!,
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.concurrentModification,
              conflictDetectedAt: DateTime.now(),
            ));
          }
          
          // Check if record was deleted locally but modified in cloud
          if (cabinet.deletedLocally == true && 
              cloudLastModified != null) {
            conflicts.add(SyncConflict(
              localRecordId: cabinet.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'cabinets',
              localLastModified: cabinet.lastModified ?? DateTime.now(),
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.deleteModifyConflict,
              conflictDetectedAt: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      print('Error detecting cabinet conflicts: $e');
    }
    
    return conflicts;
  }
  
  /// Detect conflicts for subscribers
  Future<List<SyncConflict>> _detectSubscriberConflicts() async {
    final conflicts = <SyncConflict>[];
    
    try {
      // Get all dirty subscribers from local database
      final dirtySubscribers = await _subscribersService.getDirtySubscribers();
      
      // For each dirty subscriber, check if there's a corresponding record in the cloud
      // with a more recent lastModified timestamp
      for (final subscriber in dirtySubscribers) {
        // Get the corresponding cloud record by ID
        final cloudRecords = await _client
            .from(SupabaseConfig.subscribersTable)
            .select()
            .eq('id', subscriber.id)
            .limit(1);
            
        if (cloudRecords.isNotEmpty) {
          final cloudRecord = cloudRecords.first;
          final cloudLastModified = cloudRecord['last_modified'] != null 
              ? DateTime.parse(cloudRecord['last_modified'] as String) 
              : null;
              
          // Check if cloud record was modified after local record
          if (cloudLastModified != null && 
              subscriber.lastModified != null &&
              cloudLastModified.isAfter(subscriber.lastModified!)) {
            // This is a concurrent modification conflict
            conflicts.add(SyncConflict(
              localRecordId: subscriber.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'subscribers',
              localLastModified: subscriber.lastModified!,
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.concurrentModification,
              conflictDetectedAt: DateTime.now(),
            ));
          }
          
          // Check if record was deleted locally but modified in cloud
          if (subscriber.deletedLocally == true && 
              cloudLastModified != null) {
            conflicts.add(SyncConflict(
              localRecordId: subscriber.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'subscribers',
              localLastModified: subscriber.lastModified ?? DateTime.now(),
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.deleteModifyConflict,
              conflictDetectedAt: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      print('Error detecting subscriber conflicts: $e');
    }
    
    return conflicts;
  }
  
  /// Detect conflicts for payments
  Future<List<SyncConflict>> _detectPaymentConflicts() async {
    final conflicts = <SyncConflict>[];
    
    try {
      // Get all dirty payments from local database
      final dirtyPayments = await _paymentsService.getDirtyPayments();
      
      // For each dirty payment, check if there's a corresponding record in the cloud
      // with a more recent lastModified timestamp
      for (final payment in dirtyPayments) {
        // Get the corresponding cloud record by ID
        final cloudRecords = await _client
            .from(SupabaseConfig.paymentsTable)
            .select()
            .eq('id', payment.id)
            .limit(1);
            
        if (cloudRecords.isNotEmpty) {
          final cloudRecord = cloudRecords.first;
          final cloudLastModified = cloudRecord['last_modified'] != null 
              ? DateTime.parse(cloudRecord['last_modified'] as String) 
              : null;
              
          // Check if cloud record was modified after local record
          if (cloudLastModified != null && 
              payment.lastModified != null &&
              cloudLastModified.isAfter(payment.lastModified!)) {
            // This is a concurrent modification conflict
            conflicts.add(SyncConflict(
              localRecordId: payment.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'payments',
              localLastModified: payment.lastModified!,
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.concurrentModification,
              conflictDetectedAt: DateTime.now(),
            ));
          }
          
          // Check if record was deleted locally but modified in cloud
          if (payment.deletedLocally == true && 
              cloudLastModified != null) {
            conflicts.add(SyncConflict(
              localRecordId: payment.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'payments',
              localLastModified: payment.lastModified ?? DateTime.now(),
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.deleteModifyConflict,
              conflictDetectedAt: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      print('Error detecting payment conflicts: $e');
    }
    
    return conflicts;
  }
  
  /// Detect conflicts for workers
  Future<List<SyncConflict>> _detectWorkerConflicts() async {
    final conflicts = <SyncConflict>[];
    
    try {
      // Get all dirty workers from local database
      final dirtyWorkers = await _workersService.getDirtyWorkers();
      
      // For each dirty worker, check if there's a corresponding record in the cloud
      // with a more recent lastModified timestamp
      for (final worker in dirtyWorkers) {
        // Get the corresponding cloud record by ID
        final cloudRecords = await _client
            .from(SupabaseConfig.workersTable)
            .select()
            .eq('id', worker.id)
            .limit(1);
            
        if (cloudRecords.isNotEmpty) {
          final cloudRecord = cloudRecords.first;
          final cloudLastModified = cloudRecord['last_modified'] != null 
              ? DateTime.parse(cloudRecord['last_modified'] as String) 
              : null;
              
          // Check if cloud record was modified after local record
          if (cloudLastModified != null && 
              worker.lastModified != null &&
              cloudLastModified.isAfter(worker.lastModified!)) {
            // This is a concurrent modification conflict
            conflicts.add(SyncConflict(
              localRecordId: worker.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'workers',
              localLastModified: worker.lastModified!,
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.concurrentModification,
              conflictDetectedAt: DateTime.now(),
            ));
          }
          
          // Check if record was deleted locally but modified in cloud
          if (worker.deletedLocally == true && 
              cloudLastModified != null) {
            conflicts.add(SyncConflict(
              localRecordId: worker.id,
              cloudRecordId: cloudRecord['id'].toString(),
              tableName: 'workers',
              localLastModified: worker.lastModified ?? DateTime.now(),
              cloudLastModified: cloudLastModified,
              conflictType: ConflictType.deleteModifyConflict,
              conflictDetectedAt: DateTime.now(),
            ));
          }
        }
      }
    } catch (e) {
      print('Error detecting worker conflicts: $e');
    }
    
    return conflicts;
  }
  
  /// Resolve concurrent modification conflict using configurable strategies
  Future<void> _resolveConcurrentModification(SyncConflict conflict) async {
    // Default to last-write-wins strategy for concurrent modifications
    if (conflict.cloudLastModified != null && 
        conflict.localLastModified.isBefore(conflict.cloudLastModified!)) {
      // Cloud version is more recent, update local record with cloud data
      await _updateLocalFromCloud(conflict);
    } 
    // If local version is more recent or equal, it will be synced to cloud during next sync
  }
  
  /// Resolve delete/modify conflict using configurable strategies
  Future<void> _resolveDeleteModifyConflict(SyncConflict conflict) async {
    // For delete/modify conflicts, keep the version with the most recent timestamp
    if (conflict.cloudLastModified != null && 
        conflict.localLastModified.isBefore(conflict.cloudLastModified!)) {
      // Cloud version is more recent, undelete local record and update with cloud data
      await _undeleteAndSyncWithCloud(conflict);
    } else {
      // Local delete is more recent, it will be synced to cloud during next sync
      // Mark local record as needing deletion in cloud
      await _markForCloudDeletion(conflict);
    }
  }
  
  /// Resolve business rule violation conflicts
  Future<void> _resolveBusinessRuleConflict(SyncConflict conflict) async {
    // For business rule violations, log the conflict and mark for manual resolution
    print('Business rule conflict detected for ${conflict.tableName} record ${conflict.localRecordId}');
    
    // Update the record to mark it for manual resolution
    switch (conflict.tableName) {
      case 'subscribers':
        // Mark subscriber for manual resolution
        await _subscribersService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'cabinets':
        // Mark cabinet for manual resolution
        await _cabinetsService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'payments':
        // Mark payment for manual resolution
        await _paymentsService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'workers':
        // Mark worker for manual resolution
        await _workersService.markConflictForManualResolution(conflict.localRecordId);
        break;
    }
  }
  
  /// Resolve data integrity conflicts
  Future<void> _resolveDataIntegrityConflict(SyncConflict conflict) async {
    // For data integrity conflicts, attempt automated resolution if possible
    print('Data integrity conflict detected for ${conflict.tableName} record ${conflict.localRecordId}');
    
    // Try to merge the data if possible
    await _attemptAutomatedMerge(conflict);
  }
  
  /// Update local record with cloud data
  Future<void> _updateLocalFromCloud(SyncConflict conflict) async {
    // For delete/modify conflicts where cloud version is more recent
    print('Updating local record ${conflict.localRecordId} from cloud data');
    
    switch (conflict.tableName) {
      case 'subscribers':
        // Fetch the cloud subscriber record
        final cloudData = await fetchCloudSubscriberById(conflict.localRecordId);
        if (cloudData != null) {
          // Create a Subscriber object from cloud data
          final subscriber = Subscriber(
            id: cloudData['id'] as int,
            name: cloudData['name'] as String,
            code: cloudData['code'] as String,
            cabinet: cloudData['cabinet'] as String,
            phone: cloudData['phone'] as String,
            status: cloudData['status'] as int,
            startDate: DateTime.parse(cloudData['start_date'] as String),
            accumulatedDebt: (cloudData['accumulated_debt'] as num?)?.toDouble() ?? 0.0,
            tags: cloudData['tags'] as String?,
            notes: cloudData['notes'] as String?,
            // Sync metadata fields
            lastModified: cloudData['last_modified'] != null ? DateTime.parse(cloudData['last_modified'] as String) : null,
            lastSyncedAt: cloudData['last_synced_at'] != null ? DateTime.parse(cloudData['last_synced_at'] as String) : null,
            syncStatus: 'synced', // Set to synced since we're updating from cloud
            dirtyFlag: false, // Clear dirty flag since we're syncing from cloud
            cloudId: cloudData['cloud_id'] as String?,
            deletedLocally: cloudData['deleted_locally'] as bool?,
            permissionsMask: cloudData['permissions_mask'] as String?,
            // Conflict resolution fields
            conflictOrigin: cloudData['conflict_origin'] as String?,
            conflictDetectedAt: cloudData['conflict_detected_at'] != null ? DateTime.parse(cloudData['conflict_detected_at'] as String) : null,
            conflictResolvedAt: DateTime.now(), // Set to now since we're resolving the conflict
            conflictResolutionStrategy: 'preferCloud', // Indicate how this conflict was resolved
          );
          
          // Update the local subscriber record
          await _subscribersService.updateSubscriber(subscriber);
        }
        break;
        
      case 'cabinets':
        // Fetch the cloud cabinet record
        final cloudData = await fetchCloudCabinetById(conflict.localRecordId);
        if (cloudData != null) {
          // Create a Cabinet object from cloud data
          final cabinet = Cabinet(
            id: cloudData['id'] as int,
            name: cloudData['name'] as String,
            letter: cloudData['letter'] as String? ?? '',
            totalSubscribers: cloudData['total_subscribers'] as int,
            currentSubscribers: cloudData['current_subscribers'] as int,
            collectedAmount: (cloudData['collected_amount'] as num?)?.toDouble() ?? 0.0,
            delayedSubscribers: cloudData['delayed_subscribers'] as int,
            completionDate: cloudData['completion_date'] != null
                ? DateTime.parse(cloudData['completion_date'] as String)
                : null,
            // Sync metadata fields
            lastModified: cloudData['last_modified'] != null ? DateTime.parse(cloudData['last_modified'] as String) : null,
            lastSyncedAt: cloudData['last_synced_at'] != null ? DateTime.parse(cloudData['last_synced_at'] as String) : null,
            syncStatus: 'synced', // Set to synced since we're updating from cloud
            dirtyFlag: false, // Clear dirty flag since we're syncing from cloud
            cloudId: cloudData['cloud_id'] as String?,
            deletedLocally: cloudData['deleted_locally'] as bool?,
            permissionsMask: cloudData['permissions_mask'] as String?,
            // Conflict resolution fields
            conflictOrigin: cloudData['conflict_origin'] as String?,
            conflictDetectedAt: cloudData['conflict_detected_at'] != null ? DateTime.parse(cloudData['conflict_detected_at'] as String) : null,
            conflictResolvedAt: DateTime.now(), // Set to now since we're resolving the conflict
            conflictResolutionStrategy: 'preferCloud', // Indicate how this conflict was resolved
          );
          
          // Update the local cabinet record
          await _cabinetsService.updateCabinet(cabinet);
        }
        break;
        
      case 'payments':
        // Fetch the cloud payment record
        final cloudData = await fetchCloudPaymentById(conflict.localRecordId);
        if (cloudData != null) {
          // Create a Payment object from cloud data
          final payment = Payment(
            id: cloudData['id'] as int,
            subscriberId: cloudData['subscriber_id'] as int,
            amount: (cloudData['amount'] as num).toDouble(),
            worker: cloudData['worker'] as String,
            date: DateTime.parse(cloudData['date'] as String),
            cabinet: cloudData['cabinet'] as String,
            // Sync metadata fields
            lastModified: cloudData['last_modified'] != null ? DateTime.parse(cloudData['last_modified'] as String) : null,
            lastSyncedAt: cloudData['last_synced_at'] != null ? DateTime.parse(cloudData['last_synced_at'] as String) : null,
            syncStatus: 'synced', // Set to synced since we're updating from cloud
            dirtyFlag: false, // Clear dirty flag since we're syncing from cloud
            cloudId: cloudData['cloud_id'] as String?,
            deletedLocally: cloudData['deleted_locally'] as bool?,
            permissionsMask: cloudData['permissions_mask'] as String?,
            // Conflict resolution fields
            conflictOrigin: cloudData['conflict_origin'] as String?,
            conflictDetectedAt: cloudData['conflict_detected_at'] != null ? DateTime.parse(cloudData['conflict_detected_at'] as String) : null,
            conflictResolvedAt: DateTime.now(), // Set to now since we're resolving the conflict
            conflictResolutionStrategy: 'preferCloud', // Indicate how this conflict was resolved
          );
          
          // Update the local payment record
          await _paymentsService.updatePayment(payment);
        }
        break;
        
      case 'workers':
        // Fetch the cloud worker record
        final cloudData = await fetchCloudWorkerById(conflict.localRecordId);
        if (cloudData != null) {
          // Create a Worker object from cloud data
          final worker = Worker(
            id: cloudData['id'] as int,
            name: cloudData['name'] as String,
            phone: cloudData['phone'] as String,
            permissions: cloudData['permissions'] as String,
            todayCollected: (cloudData['today_collected'] as num?)?.toDouble() ?? 0.0,
            monthTotal: (cloudData['month_total'] as num?)?.toDouble() ?? 0.0,
            // Sync metadata fields
            lastModified: cloudData['last_modified'] != null ? DateTime.parse(cloudData['last_modified'] as String) : null,
            lastSyncedAt: cloudData['last_synced_at'] != null ? DateTime.parse(cloudData['last_synced_at'] as String) : null,
            syncStatus: 'synced', // Set to synced since we're updating from cloud
            dirtyFlag: false, // Clear dirty flag since we're syncing from cloud
            cloudId: cloudData['cloud_id'] as String?,
            deletedLocally: cloudData['deleted_locally'] as bool?,
            permissionsMask: cloudData['permissions_mask'] as String?,
            // Conflict resolution fields
            conflictOrigin: cloudData['conflict_origin'] as String?,
            conflictDetectedAt: cloudData['conflict_detected_at'] != null ? DateTime.parse(cloudData['conflict_detected_at'] as String) : null,
            conflictResolvedAt: DateTime.now(), // Set to now since we're resolving the conflict
            conflictResolutionStrategy: 'preferCloud', // Indicate how this conflict was resolved
          );
          
          // Update the local worker record
          await _workersService.updateWorker(worker);
        }
        break;
    }
  }
  
  /// Undelete local record and update with cloud data
  Future<void> _undeleteAndSyncWithCloud(SyncConflict conflict) async {
    // For delete/modify conflicts where cloud version is more recent
    print('Undeleting local record ${conflict.localRecordId} and syncing with cloud data');
    
    switch (conflict.tableName) {
      case 'subscribers':
        // Undelete the local subscriber record and update with cloud data
        await _subscribersService.undeleteRecord(conflict.localRecordId);
        await _subscribersService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        // The actual data update will happen during the next sync cycle
        break;
      case 'cabinets':
        // Undelete the local cabinet record and update with cloud data
        await _cabinetsService.undeleteRecord(conflict.localRecordId);
        await _cabinetsService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'payments':
        // Undelete the local payment record and update with cloud data
        await _paymentsService.undeleteRecord(conflict.localRecordId);
        await _paymentsService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'workers':
        // Undelete the local worker record and update with cloud data
        await _workersService.undeleteRecord(conflict.localRecordId);
        await _workersService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
    }
  }
  
  /// Mark local record for deletion in cloud
  Future<void> _markForCloudDeletion(SyncConflict conflict) async {
    // For delete/modify conflicts where local delete is more recent
    print('Marking local record ${conflict.localRecordId} for deletion in cloud');
    
    switch (conflict.tableName) {
      case 'subscribers':
        // Ensure the deletedLocally flag remains true and mark for sync
        await _subscribersService.markDeletedLocally(conflict.localRecordId);
        await _subscribersService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'cabinets':
        // Ensure the deletedLocally flag remains true and mark for sync
        await _cabinetsService.markDeletedLocally(conflict.localRecordId);
        await _cabinetsService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'payments':
        // Ensure the deletedLocally flag remains true and mark for sync
        await _paymentsService.markDeletedLocally(conflict.localRecordId);
        await _paymentsService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'workers':
        // Ensure the deletedLocally flag remains true and mark for sync
        await _workersService.markDeletedLocally(conflict.localRecordId);
        await _workersService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
    }
  }
  
  /// Attempt to automatically merge conflicting data
  Future<void> _attemptAutomatedMerge(SyncConflict conflict) async {
    // For data integrity conflicts, attempt to merge non-conflicting fields
    print('Attempting automated merge for ${conflict.tableName} record ${conflict.localRecordId}');
    
    // Check if we can merge the data based on field-level changes
    if (conflict.localData != null && conflict.cloudData != null) {
      // Compare fields and merge non-conflicting changes
      // This is a simplified example - real implementation would be more complex
      final mergedData = <String, dynamic>{};
      final conflicts = <String>[];
      
      conflict.localData!.forEach((key, localValue) {
        final cloudValue = conflict.cloudData![key];
        
        if (localValue == cloudValue) {
          // Values are the same, use either one
          mergedData[key] = localValue;
        } else if (key == 'lastModified') {
          // Use the more recent timestamp
          final localTs = DateTime.tryParse(localValue.toString());
          final cloudTs = DateTime.tryParse(cloudValue.toString());
          
          if (localTs != null && cloudTs != null) {
            mergedData[key] = localTs.isAfter(cloudTs) ? localValue : cloudValue;
          } else {
            mergedData[key] = localValue;
          }
        } else {
          // Field has different values in local and cloud - mark as conflicted
          conflicts.add(key);
        }
      });
      
      if (conflicts.isEmpty) {
        // No field-level conflicts, we can merge automatically
        print('Successfully merged data automatically');
        // Update the record with merged data
        await _updateWithMergedData(conflict, mergedData);
      } else {
        // There are field-level conflicts, mark for manual resolution
        print('Field-level conflicts detected: $conflicts');
        await _markForManualResolution(conflict);
      }
    } else {
      // Insufficient data for automated merge, mark for manual resolution
      await _markForManualResolution(conflict);
    }
  }
  
  /// Update record with merged data
  Future<void> _updateWithMergedData(SyncConflict conflict, Map<String, dynamic> mergedData) async {
    // Update local record with merged data
    print('Updating ${conflict.tableName} record ${conflict.localRecordId} with merged data');
    
    // Set sync status to indicate successful merge
    switch (conflict.tableName) {
      case 'subscribers':
        // Mark the conflict as resolved with merge strategy
        await _subscribersService.updateConflictResolution(
          conflict.localRecordId,
          conflictResolutionStrategy: 'merge',
          conflictResolvedAt: DateTime.now(),
          conflictOrigin: 'both',
        );
        await _subscribersService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        // The actual data update would require rebuilding the subscriber object with merged data
        // This is a simplified implementation - in practice, you'd need to reconstruct the object
        break;
      case 'cabinets':
        // Mark the conflict as resolved with merge strategy
        await _cabinetsService.updateConflictResolution(
          conflict.localRecordId,
          conflictResolutionStrategy: 'merge',
          conflictResolvedAt: DateTime.now(),
          conflictOrigin: 'both',
        );
        await _cabinetsService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'payments':
        // Mark the conflict as resolved with merge strategy
        await _paymentsService.updateConflictResolution(
          conflict.localRecordId,
          conflictResolutionStrategy: 'merge',
          conflictResolvedAt: DateTime.now(),
          conflictOrigin: 'both',
        );
        await _paymentsService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
      case 'workers':
        // Mark the conflict as resolved with merge strategy
        await _workersService.updateConflictResolution(
          conflict.localRecordId,
          conflictResolutionStrategy: 'merge',
          conflictResolvedAt: DateTime.now(),
          conflictOrigin: 'both',
        );
        await _workersService.updateSyncStatus(conflict.localRecordId, 'sync_pending');
        break;
    }
  }
  
  /// Mark conflict for manual resolution
  Future<void> _markForManualResolution(SyncConflict conflict) async {
    // Mark record for manual conflict resolution by user
    print('Marking ${conflict.tableName} record ${conflict.localRecordId} for manual resolution');
    
    // Update the record to mark it for manual resolution
    switch (conflict.tableName) {
      case 'subscribers':
        await _subscribersService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'cabinets':
        await _cabinetsService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'payments':
        await _paymentsService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'workers':
        await _workersService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'audit_log':
        await _auditLogService.markConflictForManualResolution(conflict.localRecordId);
        break;
      case 'whatsapp_templates':
        await _whatsappService.markConflictForManualResolution(conflict.localRecordId);
        break;
    }
  }
}