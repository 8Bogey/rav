import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

/// Result of a data integrity validation check
class IntegrityCheckResult {
  final bool isValid;
  final String? errorMessage;
  final String tableName;
  final int? recordId;
  final IntegrityIssueType? issueType;
  final Map<String, dynamic>? invalidFields;

  IntegrityCheckResult({
    required this.isValid,
    this.errorMessage,
    required this.tableName,
    this.recordId,
    this.issueType,
    this.invalidFields,
  });
}

/// Types of integrity issues
enum IntegrityIssueType {
  foreignKeyViolation,
  dataTypeMismatch,
  requiredFieldMissing,
  uniqueConstraintViolation,
  invalidFormat,
  checksumMismatch,
}

/// Service for validating data integrity during sync
class DataIntegrityService {
  final AppDatabase _database;

  DataIntegrityService(this._database);

  /// Validate a record before syncing to cloud
  Future<IntegrityCheckResult> validateForSync(
    String tableName,
    Map<String, dynamic> data, {
    bool isLocalToCloud = true,
  }) async {
    switch (tableName.toLowerCase()) {
      case 'subscribers':
        return await _validateSubscriber(data);
      case 'cabinets':
        return await _validateCabinet(data);
      case 'payments':
        return await _validatePayment(data);
      case 'workers':
        return await _validateWorker(data);
      default:
        return IntegrityCheckResult(
          isValid: true,
          tableName: tableName,
        );
    }
  }

  /// Validate subscriber record
  Future<IntegrityCheckResult> _validateSubscriber(Map<String, dynamic> data) async {
    // Check required fields
    final requiredFields = ['name', 'code', 'cabinet', 'phone', 'status', 'start_date'];
    for (final field in requiredFields) {
      if (data[field] == null) {
        return IntegrityCheckResult(
          isValid: false,
          tableName: 'subscribers',
          errorMessage: 'Required field missing: $field',
          issueType: IntegrityIssueType.requiredFieldMissing,
          invalidFields: {field: null},
        );
      }
    }

    // Validate status is valid integer
    if (data['status'] is! int || data['status'] < 0 || data['status'] > 3) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'subscribers',
        errorMessage: 'Invalid status value: ${data['status']}',
        issueType: IntegrityIssueType.dataTypeMismatch,
        invalidFields: {'status': data['status']},
      );
    }

    // Validate cabinet exists (foreign key check)
    if (data['cabinet'] != null) {
      final cabinetExists = await _checkCabinetExists(data['cabinet']);
      if (!cabinetExists) {
        return IntegrityCheckResult(
          isValid: false,
          tableName: 'subscribers',
          errorMessage: 'Foreign key violation: cabinet "${data['cabinet']}" does not exist',
          issueType: IntegrityIssueType.foreignKeyViolation,
          invalidFields: {'cabinet': data['cabinet']},
        );
      }
    }

    // Validate phone format
    if (data['phone'] != null && !_isValidPhone(data['phone'])) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'subscribers',
        errorMessage: 'Invalid phone format: ${data["phone"]}',
        issueType: IntegrityIssueType.invalidFormat,
        invalidFields: {'phone': data['phone']},
      );
    }

    return IntegrityCheckResult(isValid: true, tableName: 'subscribers');
  }

  /// Validate cabinet record
  Future<IntegrityCheckResult> _validateCabinet(Map<String, dynamic> data) async {
    // Check required fields
    if (data['name'] == null) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'cabinets',
        errorMessage: 'Required field missing: name',
        issueType: IntegrityIssueType.requiredFieldMissing,
        invalidFields: {'name': null},
      );
    }

    // Validate numeric fields
    if (data['total_subscribers'] != null && data['total_subscribers'] is! int) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'cabinets',
        errorMessage: 'Invalid data type for total_subscribers',
        issueType: IntegrityIssueType.dataTypeMismatch,
        invalidFields: {'total_subscribers': data['total_subscribers']},
      );
    }

    if (data['current_subscribers'] != null && data['current_subscribers'] is! int) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'cabinets',
        errorMessage: 'Invalid data type for current_subscribers',
        issueType: IntegrityIssueType.dataTypeMismatch,
        invalidFields: {'current_subscribers': data['current_subscribers']},
      );
    }

    // Validate counts are non-negative
    if (data['total_subscribers'] != null && data['total_subscribers'] < 0) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'cabinets',
        errorMessage: 'total_subscribers cannot be negative',
        issueType: IntegrityIssueType.invalidFormat,
        invalidFields: {'total_subscribers': data['total_subscribers']},
      );
    }

    return IntegrityCheckResult(isValid: true, tableName: 'cabinets');
  }

  /// Validate payment record
  Future<IntegrityCheckResult> _validatePayment(Map<String, dynamic> data) async {
    // Check required fields
    final requiredFields = ['subscriber_id', 'amount', 'worker', 'date', 'cabinet'];
    for (final field in requiredFields) {
      if (data[field] == null) {
        return IntegrityCheckResult(
          isValid: false,
          tableName: 'payments',
          errorMessage: 'Required field missing: $field',
          issueType: IntegrityIssueType.requiredFieldMissing,
          invalidFields: {field: null},
        );
      }
    }

    // Validate amount is positive number
    if (data['amount'] is! num || (data['amount'] as num) <= 0) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'payments',
        errorMessage: 'Amount must be a positive number',
        issueType: IntegrityIssueType.dataTypeMismatch,
        invalidFields: {'amount': data['amount']},
      );
    }

    // Validate subscriber exists (foreign key check)
    if (data['subscriber_id'] != null) {
      final subscriberExists = await _checkSubscriberExists(data['subscriber_id']);
      if (!subscriberExists) {
        return IntegrityCheckResult(
          isValid: false,
          tableName: 'payments',
          errorMessage: 'Foreign key violation: subscriber_id ${data['subscriber_id']} does not exist',
          issueType: IntegrityIssueType.foreignKeyViolation,
          invalidFields: {'subscriber_id': data['subscriber_id']},
        );
      }
    }

    return IntegrityCheckResult(isValid: true, tableName: 'payments');
  }

  /// Validate worker record
  Future<IntegrityCheckResult> _validateWorker(Map<String, dynamic> data) async {
    // Check required fields
    if (data['name'] == null || data['phone'] == null || data['permissions'] == null) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'workers',
        errorMessage: 'Required fields missing: name, phone, or permissions',
        issueType: IntegrityIssueType.requiredFieldMissing,
        invalidFields: {
          'name': data['name'],
          'phone': data['phone'],
          'permissions': data['permissions'],
        },
      );
    }

    // Validate phone format
    if (data['phone'] != null && !_isValidPhone(data['phone'])) {
      return IntegrityCheckResult(
        isValid: false,
        tableName: 'workers',
        errorMessage: 'Invalid phone format: ${data["phone"]}',
        issueType: IntegrityIssueType.invalidFormat,
        invalidFields: {'phone': data['phone']},
      );
    }

    // Validate permissions is valid JSON
    if (data['permissions'] != null) {
      try {
        if (data['permissions'] is String) {
          jsonDecode(data['permissions']);
        }
      } catch (e) {
        return IntegrityCheckResult(
          isValid: false,
          tableName: 'workers',
          errorMessage: 'Invalid permissions JSON format',
          issueType: IntegrityIssueType.invalidFormat,
          invalidFields: {'permissions': data['permissions']},
        );
      }
    }

    return IntegrityCheckResult(isValid: true, tableName: 'workers');
  }

  /// Check if cabinet exists
  Future<bool> _checkCabinetExists(String name) async {
    try {
      final result = await _database.customSelect(
        'SELECT COUNT(*) as count FROM cabinets WHERE name = ?',
        variables: [Variable.withString(name)],
      ).getSingle();
      return result.read<int>('count') > 0;
    } catch (e) {
      return false;
    }
  }

  /// Check if subscriber exists
  Future<bool> _checkSubscriberExists(int id) async {
    try {
      final result = await _database.customSelect(
        'SELECT COUNT(*) as count FROM subscribers WHERE id = ?',
        variables: [Variable.withInt(id)],
      ).getSingle();
      return result.read<int>('count') > 0;
    } catch (e) {
      return false;
    }
  }

  /// Validate phone number format
  bool _isValidPhone(String phone) {
    // Allow digits, +, -, spaces, and parentheses
    final phoneRegex = RegExp(r'^[\d\s\+\-\(\)]+$');
    return phoneRegex.hasMatch(phone) && phone.length >= 7;
  }

  /// Generate checksum for a record
  String generateChecksum(Map<String, dynamic> data) {
    // Sort keys for consistent ordering
    final sortedKeys = data.keys.toList()..sort();
    final buffer = StringBuffer();

    for (final key in sortedKeys) {
      // Skip sync metadata fields
      if (_isSyncMetadataField(key)) continue;
      buffer.write(key.toString());
      buffer.write(':');
      buffer.write(data[key]?.toString() ?? '');
      buffer.write('|');
    }

    return _simpleHash(buffer.toString());
  }

  /// Simple hash function for checksum
  String _simpleHash(String input) {
    var hash = 0;
    for (var i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  /// Verify checksum matches
  bool verifyChecksum(
    Map<String, dynamic> data,
    String storedChecksum,
  ) {
    final calculatedChecksum = generateChecksum(data);
    return calculatedChecksum == storedChecksum;
  }

  /// Check if field is sync metadata
  bool _isSyncMetadataField(String fieldName) {
    const syncFields = [
      'last_modified',
      'sync_status',
      'dirty_flag',
      'cloud_id',
      'deleted_locally',
      'permissions_mask',
      'conflict_origin',
      'conflict_detected_at',
      'conflict_resolved_at',
      'conflict_resolution_strategy',
      'last_synced_at',
      'last_sync_error',
      'sync_retry_count',
      'checksum',
    ];
    return syncFields.contains(fieldName.toLowerCase());
  }

  /// Validate all records in a table
  Future<List<IntegrityCheckResult>> validateTable(String tableName) async {
    final results = <IntegrityCheckResult>[];

    try {
      final records = await _database.customSelect('SELECT * FROM $tableName').get();

      for (final record in records) {
        final data = record.data;
        final result = await validateForSync(tableName, data);
        if (!result.isValid) {
          results.add(IntegrityCheckResult(
            isValid: result.isValid,
            errorMessage: result.errorMessage,
            tableName: tableName,
            recordId: data['id'],
            issueType: result.issueType,
            invalidFields: result.invalidFields,
          ));
        }
      }
    } catch (e) {
      results.add(IntegrityCheckResult(
        isValid: false,
        tableName: tableName,
        errorMessage: 'Error validating table: $e',
      ));
    }

    return results;
  }

  /// Get integrity report for all tables
  Future<Map<String, List<IntegrityCheckResult>>> getFullIntegrityReport() async {
    final report = <String, List<IntegrityCheckResult>>{};

    final tables = ['subscribers', 'cabinets', 'payments', 'workers'];

    for (final table in tables) {
      report[table] = await validateTable(table);
    }

    return report;
  }
}
