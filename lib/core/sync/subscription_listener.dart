/**
 * Subscription Listener - Read Path for Local-First Sync
 * 
 * Subscribes to Convex real-time queries.
 * When data changes in the cloud, applies changes locally via Drift's insertOnConflictUpdate().
 * 
 * Follows MINIMAX_IMPLEMENTATION_GUIDE.md patterns.
 */

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

/// Configuration for subscription listener
class SubscriptionListenerConfig {
  /// List of tables to subscribe to
  final List<String> tables;
  
  /// Polling interval for non-real-time fallback (in seconds)
  final int pollingIntervalSeconds;
  
  /// Maximum number of consecutive errors before pausing
  final int maxConsecutiveErrors;
  
  /// Delay between retry attempts (in seconds)
  final int retryDelaySeconds;

  const SubscriptionListenerConfig({
    this.tables = const [
      'subscribers',
      'cabinets',
      'payments',
      'workers',
      'auditLog',
      'generatorSettings',
      'whatsappTemplates',
    ],
    this.pollingIntervalSeconds = 30,
    this.maxConsecutiveErrors = 5,
    this.retryDelaySeconds = 10,
  });
}

/// Status of a subscription
class SubscriptionStatus {
  final bool isActive;
  final String? error;
  final DateTime? lastSync;
  final int consecutiveErrors;

  const SubscriptionStatus({
    required this.isActive,
    this.error,
    this.lastSync,
    this.consecutiveErrors = 0,
  });
}

/// Listener for Convex real-time subscriptions
class SubscriptionListener {
  final AppDatabase _database;
  final ConvexConfig _convexConfig;
  final SubscriptionListenerConfig _config;
  
  final Map<String, StreamSubscription<dynamic>> _subscriptions = {};
  final Map<String, SubscriptionStatus> _status = {};
  Timer? _pollingTimer;
  Timer? _retryTimer;
  bool _isPaused = false;
  int _consecutiveErrors = 0;
  
  /// Stream controller for status updates
  final _statusController = StreamController<Map<String, SubscriptionStatus>>.broadcast();
  Stream<Map<String, SubscriptionStatus>> get statusStream => _statusController.stream;

  SubscriptionListener({
    required AppDatabase database,
    ConvexConfig? convexConfig,
    SubscriptionListenerConfig? config,
  })  : _database = database,
        _convexConfig = convexConfig ?? ConvexConfig,
        _config = config ?? const SubscriptionListenerConfig();

  /// Start listening to all configured tables
  Future<void> startListening({required String ownerId}) async {
    if (!_convexConfig.isInitialized) {
      debugPrint('SubscriptionListener: Convex not initialized, cannot start');
      return;
    }

    debugPrint('SubscriptionListener: Starting for ownerId: $ownerId');
    _isPaused = false;
    _consecutiveErrors = 0;

    // Start real-time subscriptions for each table
    for (final table in _config.tables) {
      await _startSubscription(table, ownerId);
    }

    // Start polling fallback
    _startPolling(ownerId);
  }

  /// Start a subscription for a specific table
  Future<void> _startSubscription(String table, String ownerId) async {
    try {
      // Map table to query function name
      final queryMap = {
        'subscribers': 'getActiveSubscribers',
        'cabinets': 'getActiveCabinets',
        'payments': 'getActivePayments',
        'workers': 'getActiveWorkers',
        'auditLog': 'getActiveAuditLogs',
        'generatorSettings': 'getGeneratorSettings',
        'whatsappTemplates': 'getActiveWhatsappTemplates',
      };

      final queryName = queryMap[table];
      if (queryName == null) {
        debugPrint('SubscriptionListener: Unknown table: $table');
        return;
      }

      // Cancel existing subscription if any
      await _subscriptions[table]?.cancel();

      // Subscribe to real-time query
      final client = _convexConfig.client;
      final stream = client.query(queryName, {'ownerId': ownerId});

      _subscriptions[table] = stream.listen(
        (documents) => _onDataReceived(table, documents),
        onError: (error) => _onError(table, error),
        onDone: () => _onDone(table),
      );

      _status[table] = const SubscriptionStatus(isActive: true);
      debugPrint('SubscriptionListener: Subscribed to $table');
      
      _emitStatus();
    } catch (e) {
      debugPrint('SubscriptionListener: Error starting subscription for $table: $e');
      _status[table] = SubscriptionStatus(
        isActive: false,
        error: e.toString(),
        consecutiveErrors: _consecutiveErrors,
      );
      _emitStatus();
    }
  }

  /// Handle incoming data from subscription
  Future<void> _onDataReceived(String table, dynamic documents) async {
    try {
      debugPrint('SubscriptionListener: Received ${documents.length} documents for $table');
      
      // Reset error count on successful data
      _consecutiveErrors = 0;

      // Parse documents and sync to local DB
      await _syncToLocal(table, documents);

      // Update status
      _status[table] = SubscriptionStatus(
        isActive: true,
        lastSync: DateTime.now(),
        consecutiveErrors: 0,
      );
      _emitStatus();
    } catch (e) {
      debugPrint('SubscriptionListener: Error syncing $table: $e');
      _handleError(table, e.toString());
    }
  }

  /// Sync received documents to local Drift database
  Future<void> _syncToLocal(String table, dynamic documents) async {
    final tableData = _getTableReference(table);
    if (tableData == null) return;

    if (documents is! List) {
      debugPrint('SubscriptionListener: Expected list for $table, got ${documents.runtimeType}');
      return;
    }

    await _database.batch((batch) {
      for (final doc in documents) {
        try {
          final data = doc is Map ? doc : _parseDocument(doc);
          
          if (data == null || data.isEmpty) continue;

          // Skip soft-deleted documents
          if (data['isDeleted'] == true) continue;

          // Convert to Drift companions based on table
          final companion = _createCompanion(table, data);
          if (companion == null) continue;

          // Use insertOnConflictUpdate for seamless sync
          batch.insert(
            tableData,
            companion,
            mode: InsertMode.insertOrReplace,
          );
        } catch (e) {
          debugPrint('SubscriptionListener: Error processing document in $table: $e');
        }
      }
    });

    debugPrint('SubscriptionListener: Synced ${documents.length} documents to $table');
  }

  /// Get table reference for Drift
  TableInfo<Table, dynamic>? _getTableReference(String table) {
    switch (table) {
      case 'subscribers':
        return _database.subscribersTable;
      case 'cabinets':
        return _database.cabinetsTable;
      case 'payments':
        return _database.paymentsTable;
      case 'workers':
        return _database.workersTable;
      case 'auditLog':
        return _database.auditLogTable;
      case 'generatorSettings':
        return _database.generatorSettingsTable;
      case 'whatsappTemplates':
        return _database.whatsappTemplatesTable;
      default:
        return null;
    }
  }

  /// Parse document to Map
  Map<String, dynamic>? _parseDocument(dynamic doc) {
    if (doc is Map) {
      return doc.map((k, v) => MapEntry(k.toString(), v));
    }
    if (doc is String) {
      try {
        return jsonDecode(doc);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Create Drift companion based on table type
  Insertable<dynamic>? _createCompanion(String table, Map<String, dynamic> data) {
    // Convert timestamps to DateTime
    final processedData = _processTimestamps(data);

    switch (table) {
      case 'subscribers':
        return SubscribersTableCompanion(
          id: Value(processedData['id'] ?? ''),
          name: Value(processedData['name'] ?? ''),
          code: Value(processedData['code'] ?? ''),
          cabinet: Value(processedData['cabinet'] ?? ''),
          phone: Value(processedData['phone'] ?? ''),
          status: Value(processedData['status'] ?? 0),
          startDate: Value(_parseDateTime(processedData['startDate'])),
          accumulatedDebt: Value((processedData['accumulatedDebt'] ?? 0).toDouble()),
          tags: Value(processedData['tags']),
          notes: Value(processedData['notes']),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      case 'cabinets':
        return CabinetsTableCompanion(
          id: Value(processedData['id'] ?? ''),
          name: Value(processedData['name'] ?? ''),
          letter: Value(processedData['letter']),
          totalSubscribers: Value(processedData['totalSubscribers'] ?? 0),
          currentSubscribers: Value(processedData['currentSubscribers'] ?? 0),
          collectedAmount: Value((processedData['collectedAmount'] ?? 0).toDouble()),
          delayedSubscribers: Value(processedData['delayedSubscribers'] ?? 0),
          completionDate: Value(_parseDateTime(processedData['completionDate'])),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      case 'payments':
        return PaymentsTableCompanion(
          id: Value(processedData['id'] ?? ''),
          subscriberId: Value(processedData['subscriberId'] ?? ''),
          amount: Value((processedData['amount'] ?? 0).toDouble()),
          worker: Value(processedData['worker'] ?? ''),
          date: Value(_parseDateTime(processedData['date']) ?? DateTime.now()),
          cabinet: Value(processedData['cabinet'] ?? ''),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      case 'workers':
        return WorkersTableCompanion(
          id: Value(processedData['id'] ?? ''),
          name: Value(processedData['name'] ?? ''),
          phone: Value(processedData['phone'] ?? ''),
          permissions: Value(processedData['permissions'] ?? ''),
          todayCollected: Value((processedData['todayCollected'] ?? 0).toDouble()),
          monthTotal: Value((processedData['monthTotal'] ?? 0).toDouble()),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      case 'auditLog':
        return AuditLogTableCompanion(
          id: Value(processedData['id'] ?? ''),
          user: Value(processedData['user'] ?? ''),
          action: Value(processedData['action'] ?? ''),
          target: Value(processedData['target'] ?? ''),
          details: Value(processedData['details'] ?? ''),
          type: Value(processedData['type'] ?? ''),
          timestamp: Value(_parseDateTime(processedData['timestamp']) ?? DateTime.now()),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      case 'generatorSettings':
        return GeneratorSettingsTableCompanion(
          id: Value(processedData['id'] ?? ''),
          name: Value(processedData['name'] ?? ''),
          phoneNumber: Value(processedData['phoneNumber'] ?? ''),
          address: Value(processedData['address'] ?? ''),
          logoPath: Value(processedData['logoPath']),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      case 'whatsappTemplates':
        return WhatsappTemplatesTableCompanion(
          id: Value(processedData['id'] ?? ''),
          title: Value(processedData['title'] ?? ''),
          content: Value(processedData['content'] ?? ''),
          isActive: Value(processedData['isActive'] ?? 0),
          ownerId: Value(processedData['ownerId'] ?? ''),
          version: Value(processedData['version'] ?? 0),
          isDeleted: Value(processedData['isDeleted'] ?? false),
          createdAt: Value(_parseDateTime(processedData['createdAt']) ?? DateTime.now()),
          updatedAt: Value(_parseDateTime(processedData['updatedAt']) ?? DateTime.now()),
        );

      default:
        return null;
    }
  }

  /// Process timestamps in data
  Map<String, dynamic> _processTimestamps(Map<String, dynamic> data) {
    final processed = Map<String, dynamic>.from(data);
    final timestampFields = ['createdAt', 'updatedAt', 'startDate', 'completionDate', 'date', 'timestamp'];
    
    for (final field in timestampFields) {
      if (processed[field] is int) {
        // Unix timestamp - convert to ISO string for parsing
        processed[field] = DateTime.fromMillisecondsSinceEpoch(processed[field]).toIso8601String();
      }
    }
    
    return processed;
  }

  /// Parse datetime from various formats
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Handle subscription errors
  void _onError(String table, Object error) {
    debugPrint('SubscriptionListener: Error on $table: $error');
    _handleError(table, error.toString());
  }

  /// Handle subscription done
  void _onDone(String table) {
    debugPrint('SubscriptionListener: Subscription done for $table');
    _status[table] = SubscriptionStatus(
      isActive: false,
      error: 'Subscription completed',
      consecutiveErrors: _consecutiveErrors,
    );
    _emitStatus();
  }

  /// Handle errors and implement retry logic
  void _handleError(String table, String error) {
    _consecutiveErrors++;
    
    _status[table] = SubscriptionStatus(
      isActive: false,
      error: error,
      consecutiveErrors: _consecutiveErrors,
    );
    _emitStatus();

    // Pause if too many consecutive errors
    if (_consecutiveErrors >= _config.maxConsecutiveErrors) {
      _isPaused = true;
      debugPrint('SubscriptionListener: Pausing due to too many errors');
      _scheduleRetry();
    }
  }

  /// Start polling fallback
  void _startPolling(String ownerId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: _config.pollingIntervalSeconds),
      (_) => _pollAllTables(ownerId),
    );
    debugPrint('SubscriptionListener: Started polling fallback');
  }

  /// Poll all tables for changes (fallback when real-time fails)
  Future<void> _pollAllTables(String ownerId) async {
    if (_isPaused || !_convexConfig.isInitialized) return;

    for (final table in _config.tables) {
      try {
        final queryMap = {
          'subscribers': 'getActiveSubscribers',
          'cabinets': 'getActiveCabinets',
          'payments': 'getActivePayments',
          'workers': 'getActiveWorkers',
          'auditLog': 'getActiveAuditLogs',
          'generatorSettings': 'getGeneratorSettings',
          'whatsappTemplates': 'getActiveWhatsappTemplates',
        };

        final queryName = queryMap[table];
        if (queryName == null) continue;

        final client = _convexConfig.client;
        final result = await client.query(queryName, {'ownerId': ownerId});
        
        if (result != null) {
          await _onDataReceived(table, result);
        }
      } catch (e) {
        debugPrint('SubscriptionListener: Polling error for $table: $e');
      }
    }
  }

  /// Schedule retry after pause
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(
      Duration(seconds: _config.retryDelaySeconds),
      () {
        _isPaused = false;
        _consecutiveErrors = 0;
        debugPrint('SubscriptionListener: Resuming after retry delay');
      },
    );
  }

  /// Emit status update
  void _emitStatus() {
    _statusController.add(Map.from(_status));
  }

  /// Stop listening
  Future<void> stopListening() async {
    _pollingTimer?.cancel();
    _retryTimer?.cancel();

    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _isPaused = true;
    
    for (final table in _config.tables) {
      _status[table] = const SubscriptionStatus(isActive: false);
    }
    _emitStatus();
    
    debugPrint('SubscriptionListener: Stopped listening');
  }

  /// Get current status
  Map<String, SubscriptionStatus> get status => Map.from(_status);

  /// Check if listening is active
  bool get isActive => _subscriptions.values.any((s) => s.isPaused == false) && !_isPaused;

  /// Dispose resources
  void dispose() {
    stopListening();
    _statusController.close();
    debugPrint('SubscriptionListener: Disposed');
  }
}