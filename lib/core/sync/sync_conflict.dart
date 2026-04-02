/// Sync Conflict Models
/// 
/// These models define sync conflict types and structures used for
/// tracking and resolving synchronization conflicts in the offline-first system.
/// This is a local implementation for the Convex-based sync, replacing the
/// previous Supabase-based implementation.

/// Conflict type enumeration
enum ConflictType {
  /// Concurrent modification on both local and cloud
  concurrentModification,
  
  /// Record deleted locally but modified in cloud
  deleteModifyConflict,
  
  /// Record deleted in both local and cloud
  dualDeleteConflict,
  
  /// Business rule violation during sync
  businessRuleViolation,
  
  /// Data integrity conflict
  dataIntegrityConflict,
}

/// Sync conflict structure
class SyncConflict {
  final int localRecordId;
  final String? cloudRecordId;
  final String tableName;
  final DateTime? localLastModified;
  final DateTime? cloudLastModified;
  final ConflictType conflictType;
  final DateTime conflictDetectedAt;

  SyncConflict({
    required this.localRecordId,
    this.cloudRecordId,
    required this.tableName,
    this.localLastModified,
    this.cloudLastModified,
    required this.conflictType,
    required this.conflictDetectedAt,
  });
}
