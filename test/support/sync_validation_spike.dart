import 'package:mawlid_al_dhaki/core/sync/sync_conflict.dart';

/// Test helper: in-memory sync metadata / conflict simulation (not production sync).
class SyncValidationSpike {
  final List<SyncRecord> _localRecords = [];
  final List<SyncRecord> _cloudRecords = [];

  static const String LOCAL_ONLY = 'local_only';
  static const String SYNC_PENDING = 'sync_pending';
  static const String SYNCED = 'synced';
  static const String CONFLICT = 'conflict';

  SyncRecord createLocalRecord({
    required String tableName,
    required Map<String, dynamic> data,
  }) {
    final record = SyncRecord(
      id: _generateId(),
      tableName: tableName,
      data: data,
      lastModified: DateTime.now(),
      syncStatus: LOCAL_ONLY,
      dirtyFlag: true,
      cloudId: null,
      deletedLocally: false,
      permissionsMask: null,
    );

    _localRecords.add(record);
    return record;
  }

  void updateLocalRecord(SyncRecord record, Map<String, dynamic> newData) {
    record.data.addAll(newData);
    record.lastModified = DateTime.now();
    record.dirtyFlag = true;

    if (record.syncStatus == SYNCED) {
      record.syncStatus = SYNC_PENDING;
    }
  }

  void deleteLocalRecord(SyncRecord record) {
    record.deletedLocally = true;
    record.dirtyFlag = true;
    record.lastModified = DateTime.now();
  }

  List<SyncConflict> detectConflicts() {
    final conflicts = <SyncConflict>[];

    for (final localRecord in _localRecords) {
      if (!(localRecord.dirtyFlag ?? false)) continue;

      final cloudRecord = _findCorrespondingCloudRecord(localRecord);

      if (cloudRecord != null) {
        if (_wasModifiedAfterLastSync(cloudRecord)) {
          conflicts.add(SyncConflict(
            localRecordId: localRecord.id,
            cloudRecordId: cloudRecord.id.toString(),
            tableName: localRecord.tableName,
            localLastModified: localRecord.lastModified ?? DateTime.now(),
            cloudLastModified: cloudRecord.lastModified,
            conflictType: ConflictType.concurrentModification,
            conflictDetectedAt: DateTime.now(),
          ));
        }

        if ((localRecord.deletedLocally ?? false) &&
            _wasModifiedAfterLastSync(cloudRecord)) {
          conflicts.add(SyncConflict(
            localRecordId: localRecord.id,
            cloudRecordId: cloudRecord.id.toString(),
            tableName: localRecord.tableName,
            localLastModified: localRecord.lastModified ?? DateTime.now(),
            cloudLastModified: cloudRecord.lastModified,
            conflictType: ConflictType.deleteModifyConflict,
            conflictDetectedAt: DateTime.now(),
          ));
        }
      }
    }

    return conflicts;
  }

  void resolveConflictsLastWriteWins(List<SyncConflict> conflicts) {
    for (final conflict in conflicts) {
      final localRecord = _findLocalRecordById(conflict.localRecordId);

      if (localRecord == null) continue;

      switch (conflict.conflictType) {
        case ConflictType.concurrentModification:
          if (conflict.cloudLastModified != null &&
              localRecord.lastModified != null &&
              conflict.cloudLastModified!.isAfter(localRecord.lastModified!)) {
            _updateLocalFromCloud(localRecord, conflict.cloudRecordId ?? '');
            localRecord.syncStatus = SYNCED;
            localRecord.dirtyFlag = false;
          } else {
            localRecord.syncStatus = SYNC_PENDING;
          }
          break;

        case ConflictType.deleteModifyConflict:
          if (conflict.cloudLastModified != null &&
              localRecord.lastModified != null &&
              conflict.cloudLastModified!.isAfter(localRecord.lastModified!)) {
            localRecord.deletedLocally = false;
            _updateLocalFromCloud(localRecord, conflict.cloudRecordId ?? '');
            localRecord.syncStatus = SYNCED;
            localRecord.dirtyFlag = false;
          } else {
            localRecord.syncStatus = SYNC_PENDING;
          }
          break;

        case ConflictType.dualDeleteConflict:
          localRecord.syncStatus = SYNCED;
          localRecord.dirtyFlag = false;
          break;

        case ConflictType.businessRuleViolation:
        case ConflictType.dataIntegrityConflict:
          localRecord.syncStatus = CONFLICT;
          break;
      }
    }
  }

  void syncLocalToCloud() {
    for (final record in _localRecords) {
      if (record.dirtyFlag ?? false) {
        final cloudRecord = _findCorrespondingCloudRecord(record);

        if (cloudRecord == null) {
          _createCloudRecordFromLocal(record);
        } else {
          _updateCloudFromLocal(cloudRecord, record);
        }

        record.syncStatus = SYNCED;
        record.dirtyFlag = false;
      }

      if ((record.deletedLocally ?? false) && (record.dirtyFlag ?? false)) {
        final cloudRecord = _findCorrespondingCloudRecord(record);
        if (cloudRecord != null) {
          _deleteCloudRecord(cloudRecord);
        }
        record.syncStatus = SYNCED;
        record.dirtyFlag = false;
      }
    }
  }

  void syncCloudToLocal() {
    for (final cloudRecord in _cloudRecords) {
      final localRecord = _findLocalRecordByCloudId(cloudRecord.id.toString());

      if (localRecord == null) {
        _createLocalRecordFromCloud(cloudRecord);
      } else {
        if (_wasModifiedAfterLastSync(cloudRecord) &&
            (localRecord.lastModified == null ||
                (cloudRecord.lastModified != null &&
                    cloudRecord.lastModified!.isAfter(localRecord.lastModified!)))) {
          _updateLocalFromCloud(localRecord, cloudRecord.id.toString());
          localRecord.syncStatus = SYNCED;
          localRecord.dirtyFlag = false;
        }
      }
    }
  }

  void updateSyncStatus(SyncRecord record, String status) {
    record.syncStatus = status;
  }

  void markRecordAsDirty(SyncRecord record) {
    record.dirtyFlag = true;
    if (record.syncStatus == SYNCED) {
      record.syncStatus = SYNC_PENDING;
    }
  }

  void clearDirtyFlag(SyncRecord record) {
    record.dirtyFlag = false;
  }

  int _generateId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  SyncRecord? _findCorrespondingCloudRecord(SyncRecord localRecord) {
    try {
      return _cloudRecords.firstWhere(
        (record) => record.tableName == localRecord.tableName,
      );
    } on StateError {
      return null;
    }
  }

  SyncRecord? _findLocalRecordById(int id) {
    try {
      return _localRecords.firstWhere(
        (record) => record.id == id,
      );
    } on StateError {
      return null;
    }
  }

  SyncRecord? _findLocalRecordByCloudId(String cloudId) {
    try {
      return _localRecords.firstWhere(
        (record) => record.cloudId == cloudId,
      );
    } on StateError {
      return null;
    }
  }

  bool _wasModifiedAfterLastSync(SyncRecord record) {
    return record.lastModified != null;
  }

  void _updateLocalFromCloud(SyncRecord localRecord, String cloudId) {
    localRecord.cloudId = cloudId;
    localRecord.lastModified = DateTime.now();
  }

  void _createCloudRecordFromLocal(SyncRecord localRecord) {
    final cloudRecord = SyncRecord(
      id: _generateId(),
      tableName: localRecord.tableName,
      data: Map<String, dynamic>.from(localRecord.data),
      lastModified: DateTime.now(),
      syncStatus: SYNCED,
      dirtyFlag: false,
      cloudId: localRecord.id.toString(),
      deletedLocally: localRecord.deletedLocally,
      permissionsMask: localRecord.permissionsMask,
    );

    _cloudRecords.add(cloudRecord);
    localRecord.cloudId = cloudRecord.id.toString();
  }

  void _updateCloudFromLocal(SyncRecord cloudRecord, SyncRecord localRecord) {
    cloudRecord.data = Map<String, dynamic>.from(localRecord.data);
    cloudRecord.lastModified = DateTime.now();
    cloudRecord.deletedLocally = localRecord.deletedLocally;
  }

  void _deleteCloudRecord(SyncRecord cloudRecord) {
    _cloudRecords.remove(cloudRecord);
  }

  void _createLocalRecordFromCloud(SyncRecord cloudRecord) {
    final localRecord = SyncRecord(
      id: _generateId(),
      tableName: cloudRecord.tableName,
      data: Map<String, dynamic>.from(cloudRecord.data),
      lastModified: DateTime.now(),
      syncStatus: SYNCED,
      dirtyFlag: false,
      cloudId: cloudRecord.id.toString(),
      deletedLocally: cloudRecord.deletedLocally,
      permissionsMask: cloudRecord.permissionsMask,
    );

    _localRecords.add(localRecord);
  }

  List<SyncRecord> getLocalRecords() {
    return List.unmodifiable(_localRecords);
  }

  List<SyncRecord> getCloudRecords() {
    return List.unmodifiable(_cloudRecords);
  }
}

class SyncRecord {
  int id;
  String tableName;
  Map<String, dynamic> data;
  DateTime? lastModified;
  String? syncStatus;
  bool? dirtyFlag;
  String? cloudId;
  bool? deletedLocally;
  String? permissionsMask;

  SyncRecord({
    required this.id,
    required this.tableName,
    required this.data,
    this.lastModified,
    this.syncStatus,
    this.dirtyFlag,
    this.cloudId,
    this.deletedLocally,
    this.permissionsMask,
  });
}
