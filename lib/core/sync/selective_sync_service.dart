import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

/// Selective sync configuration
class SelectiveSyncConfig {
  final bool syncCabinets;
  final bool syncSubscribers;
  final bool syncPayments;
  final bool syncWorkers;
  final bool syncAuditLog;
  final bool syncWhatsappTemplates;
  final DateTime? lastSyncTime;
  final String? workerPermissions;

  SelectiveSyncConfig({
    this.syncCabinets = true,
    this.syncSubscribers = true,
    this.syncPayments = true,
    this.syncWorkers = true,
    this.syncAuditLog = false,
    this.syncWhatsappTemplates = false,
    this.lastSyncTime,
    this.workerPermissions,
  });

  SelectiveSyncConfig copyWith({
    bool? syncCabinets,
    bool? syncSubscribers,
    bool? syncPayments,
    bool? syncWorkers,
    bool? syncAuditLog,
    bool? syncWhatsappTemplates,
    DateTime? lastSyncTime,
    String? workerPermissions,
  }) {
    return SelectiveSyncConfig(
      syncCabinets: syncCabinets ?? this.syncCabinets,
      syncSubscribers: syncSubscribers ?? this.syncSubscribers,
      syncPayments: syncPayments ?? this.syncPayments,
      syncWorkers: syncWorkers ?? this.syncWorkers,
      syncAuditLog: syncAuditLog ?? this.syncAuditLog,
      syncWhatsappTemplates: syncWhatsappTemplates ?? this.syncWhatsappTemplates,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      workerPermissions: workerPermissions ?? this.workerPermissions,
    );
  }

  Map<String, dynamic> toJson() => {
        'syncCabinets': syncCabinets,
        'syncSubscribers': syncSubscribers,
        'syncPayments': syncPayments,
        'syncWorkers': syncWorkers,
        'syncAuditLog': syncAuditLog,
        'syncWhatsappTemplates': syncWhatsappTemplates,
        'lastSyncTime': lastSyncTime?.toIso8601String(),
        'workerPermissions': workerPermissions,
      };

  factory SelectiveSyncConfig.fromJson(Map<String, dynamic> json) {
    return SelectiveSyncConfig(
      syncCabinets: json['syncCabinets'] ?? true,
      syncSubscribers: json['syncSubscribers'] ?? true,
      syncPayments: json['syncPayments'] ?? true,
      syncWorkers: json['syncWorkers'] ?? true,
      syncAuditLog: json['syncAuditLog'] ?? false,
      syncWhatsappTemplates: json['syncWhatsappTemplates'] ?? false,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'])
          : null,
      workerPermissions: json['workerPermissions'],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory SelectiveSyncConfig.fromJsonString(String jsonString) {
    return SelectiveSyncConfig.fromJson(jsonDecode(jsonString));
  }

  /// Default config - sync everything
  static SelectiveSyncConfig get defaultConfig => SelectiveSyncConfig();

  /// Get list of enabled sync tables
  List<String> get enabledTables {
    final tables = <String>[];
    if (syncCabinets) tables.add('cabinets');
    if (syncSubscribers) tables.add('subscribers');
    if (syncPayments) tables.add('payments');
    if (syncWorkers) tables.add('workers');
    if (syncAuditLog) tables.add('audit_log');
    if (syncWhatsappTemplates) tables.add('whatsapp_templates');
    return tables;
  }

  /// Check if a table is enabled for sync
  bool isTableEnabled(String tableName) {
    switch (tableName.toLowerCase()) {
      case 'cabinets':
        return syncCabinets;
      case 'subscribers':
        return syncSubscribers;
      case 'payments':
        return syncPayments;
      case 'workers':
        return syncWorkers;
      case 'audit_log':
        return syncAuditLog;
      case 'whatsapp_templates':
        return syncWhatsappTemplates;
      default:
        return true;
    }
  }
}

/// Service for managing selective sync configuration
class SelectiveSyncService {
  final AppDatabase _database;
  static const String _configKey = 'selective_sync_config';

  SelectiveSyncService(this._database);

  /// Get current selective sync config
  Future<SelectiveSyncConfig> getConfig() async {
    try {
      // Try to get from settings table
      final settings = await _database.customSelect(
        'SELECT value FROM app_settings WHERE key = ?',
        variables: [Variable.withString(_configKey)],
      ).getSingleOrNull();

      if (settings != null) {
        final value = settings.read<String?>('value');
        if (value != null) {
          return SelectiveSyncConfig.fromJsonString(value);
        }
      }
    } catch (e) {
      print('Error loading selective sync config: $e');
    }
    return SelectiveSyncConfig.defaultConfig;
  }

  /// Save selective sync config
  Future<void> saveConfig(SelectiveSyncConfig config) async {
    try {
      await _database.customStatement(
        '''INSERT OR REPLACE INTO app_settings (key, value, updated_at)
           VALUES (?, ?, ?)''',
        [_configKey, config.toJsonString(), DateTime.now().toIso8601String()],
      );
    } catch (e) {
      print('Error saving selective sync config: $e');
    }
  }

  /// Update single sync option
  Future<SelectiveSyncConfig> updateTableSync(
    String tableName,
    bool enabled,
  ) async {
    final config = await getConfig();
    SelectiveSyncConfig newConfig;

    switch (tableName.toLowerCase()) {
      case 'cabinets':
        newConfig = config.copyWith(syncCabinets: enabled);
        break;
      case 'subscribers':
        newConfig = config.copyWith(syncSubscribers: enabled);
        break;
      case 'payments':
        newConfig = config.copyWith(syncPayments: enabled);
        break;
      case 'workers':
        newConfig = config.copyWith(syncWorkers: enabled);
        break;
      case 'audit_log':
        newConfig = config.copyWith(syncAuditLog: enabled);
        break;
      case 'whatsapp_templates':
        newConfig = config.copyWith(syncWhatsappTemplates: enabled);
        break;
      default:
        return config;
    }

    await saveConfig(newConfig);
    return newConfig;
  }

  /// Set worker permissions for selective sync
  Future<SelectiveSyncConfig> setWorkerPermissions(String permissions) async {
    final config = await getConfig();
    final newConfig = config.copyWith(workerPermissions: permissions);
    await saveConfig(newConfig);
    return newConfig;
  }

  /// Reset to default config
  Future<SelectiveSyncConfig> resetConfig() async {
    await saveConfig(SelectiveSyncConfig.defaultConfig);
    return SelectiveSyncConfig.defaultConfig;
  }

  /// Get permissions mask for a specific table
  String getPermissionsMaskForTable(String tableName, String? workerPermissions) {
    if (workerPermissions == null) return '';
    
    // Map table names to permission keys
    final tablePermissionMap = {
      'cabinets': 'cabinet',
      'subscribers': 'subscriber',
      'payments': 'payment',
      'workers': 'worker',
    };

    final permissionKey = tablePermissionMap[tableName.toLowerCase()];
    if (permissionKey == null) return workerPermissions;

    // Return subset of permissions for this table
    final allPermissions = workerPermissions.split(',').map((s) => s.trim());
    return allPermissions
        .where((p) => p.toLowerCase().contains(permissionKey))
        .join(',');
  }
}

/// Riverpod provider for selective sync config
final selectiveSyncConfigProvider =
    StateNotifierProvider<SelectiveSyncConfigNotifier, SelectiveSyncConfig>((ref) {
  return SelectiveSyncConfigNotifier();
});

/// StateNotifier for selective sync config
class SelectiveSyncConfigNotifier extends StateNotifier<SelectiveSyncConfig> {
  SelectiveSyncConfigNotifier() : super(SelectiveSyncConfig.defaultConfig);

  void updateConfig(SelectiveSyncConfig config) {
    state = config;
  }

  void toggleTable(String tableName, bool enabled) {
    final newConfig = state.copyWith(
      syncCabinets: tableName == 'cabinets' ? enabled : state.syncCabinets,
      syncSubscribers: tableName == 'subscribers' ? enabled : state.syncSubscribers,
      syncPayments: tableName == 'payments' ? enabled : state.syncPayments,
      syncWorkers: tableName == 'workers' ? enabled : state.syncWorkers,
      syncAuditLog: tableName == 'audit_log' ? enabled : state.syncAuditLog,
      syncWhatsappTemplates: tableName == 'whatsapp_templates' ? enabled : state.syncWhatsappTemplates,
    );
    state = newConfig;
  }

  void setWorkerPermissions(String permissions) {
    state = state.copyWith(workerPermissions: permissions);
  }

  void reset() {
    state = SelectiveSyncConfig.defaultConfig;
  }
}

/// Extension to check if table should be synced based on config
extension SelectiveSyncExtension on SelectiveSyncConfig {
  /// Should sync cabinets
  bool get shouldSyncCabinets => syncCabinets;

  /// Should sync subscribers
  bool get shouldSyncSubscribers => syncSubscribers;

  /// Should sync payments
  bool get shouldSyncPayments => syncPayments;

  /// Should sync workers
  bool get shouldSyncWorkers => syncWorkers;

  /// Should sync audit log
  bool get shouldSyncAuditLog => syncAuditLog;

  /// Should sync WhatsApp templates
  bool get shouldSyncWhatsappTemplates => syncWhatsappTemplates;
}
