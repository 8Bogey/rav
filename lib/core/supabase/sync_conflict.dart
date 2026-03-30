/// Represents a synchronization conflict between local and cloud records
class SyncConflict {
  final int localRecordId;
  final String? cloudRecordId;
  final String tableName;
  final DateTime localLastModified;
  final DateTime? cloudLastModified;
  final ConflictType conflictType;
  final Map<String, dynamic>? localData;
  final Map<String, dynamic>? cloudData;
  final String? conflictOrigin;
  final DateTime conflictDetectedAt;

  SyncConflict({
    required this.localRecordId,
    required this.cloudRecordId,
    required this.tableName,
    required this.localLastModified,
    required this.cloudLastModified,
    required this.conflictType,
    this.localData,
    this.cloudData,
    this.conflictOrigin,
    required this.conflictDetectedAt,
  });

  /// Get a human-readable description of the conflict
  String get description {
    switch (conflictType) {
      case ConflictType.concurrentModification:
        return 'Both local and cloud records were modified';
      case ConflictType.deleteModifyConflict:
        return 'Record was deleted locally but modified in cloud';
      case ConflictType.dualDeleteConflict:
        return 'Record was deleted in both locations';
      case ConflictType.businessRuleViolation:
        return 'Modification violates business rules';
      case ConflictType.dataIntegrityConflict:
        return 'Data integrity conflict detected';
    }
  }
  
  /// Get a user-friendly, detailed description of the conflict with context
  String get userFriendlyDescription {
    switch (conflictType) {
      case ConflictType.concurrentModification:
        return 'Both the local and cloud versions of this $tableName record (ID: $localRecordId) were modified. '
            'The local version was last modified on ${localLastModified.toString()} and the cloud version was last modified on ${cloudLastModified?.toString() ?? 'unknown'}.';
      case ConflictType.deleteModifyConflict:
        return 'This $tableName record (ID: $localRecordId) was deleted locally but modified in the cloud. '
            'You deleted this record locally, but someone else modified it in the cloud after your deletion.';
      case ConflictType.dualDeleteConflict:
        return 'This $tableName record (ID: $localRecordId) was deleted in both the local database and cloud database.';
      case ConflictType.businessRuleViolation:
        return 'A modification to this $tableName record (ID: $localRecordId) violates business rules. '
            'The system detected that applying this change would create inconsistencies.';
      case ConflictType.dataIntegrityConflict:
        return 'A data integrity conflict was detected for this $tableName record (ID: $localRecordId). '
            'Different fields in this record have conflicting values between local and cloud versions.';
    }
  }
  
  /// Get resolution options available for this conflict type
  List<ConflictResolutionStrategy> get resolutionOptions {
    switch (conflictType) {
      case ConflictType.concurrentModification:
        // For concurrent modifications, all resolution strategies are viable
        return [
          ConflictResolutionStrategy.lastWriteWins,
          ConflictResolutionStrategy.preferLocal,
          ConflictResolutionStrategy.preferCloud,
          ConflictResolutionStrategy.mergeChanges,
          ConflictResolutionStrategy.manualResolution,
        ];
      case ConflictType.deleteModifyConflict:
        // For delete/modify conflicts, we can prefer either version or merge if possible
        return [
          ConflictResolutionStrategy.lastWriteWins,
          ConflictResolutionStrategy.preferLocal,
          ConflictResolutionStrategy.preferCloud,
          ConflictResolutionStrategy.manualResolution,
        ];
      case ConflictType.dualDeleteConflict:
        // For dual deletes, there's nothing to resolve since both sides agree on deletion
        return [
          ConflictResolutionStrategy.lastWriteWins,
          ConflictResolutionStrategy.preferLocal,
          ConflictResolutionStrategy.preferCloud,
        ];
      case ConflictType.businessRuleViolation:
        // Business rule violations require manual resolution or specific validation bypass
        return [
          ConflictResolutionStrategy.manualResolution,
          ConflictResolutionStrategy.preferLocal,
          ConflictResolutionStrategy.preferCloud,
        ];
      case ConflictType.dataIntegrityConflict:
        // Data integrity issues might benefit from merging non-conflicting fields or manual resolution
        return [
          ConflictResolutionStrategy.mergeChanges,
          ConflictResolutionStrategy.manualResolution,
          ConflictResolutionStrategy.preferLocal,
          ConflictResolutionStrategy.preferCloud,
        ];
    }
  }
  
  /// Get the recommended resolution strategy based on conflict type and timestamps
  ConflictResolutionStrategy get recommendedResolutionStrategy {
    switch (conflictType) {
      case ConflictType.concurrentModification:
        // For concurrent modifications, use last-write-wins if timestamps are available
        if (cloudLastModified != null && localLastModified.isBefore(cloudLastModified!)) {
          return ConflictResolutionStrategy.preferCloud;
        } else if (cloudLastModified != null && localLastModified.isAfter(cloudLastModified!)) {
          return ConflictResolutionStrategy.preferLocal;
        }
        // If timestamps are equal or unavailable, fall back to last-write-wins as default
        return ConflictResolutionStrategy.lastWriteWins;
      case ConflictType.deleteModifyConflict:
        // For delete/modify conflicts, prefer the more recent change
        if (cloudLastModified != null && localLastModified.isBefore(cloudLastModified!)) {
          return ConflictResolutionStrategy.preferCloud;
        } else {
          return ConflictResolutionStrategy.preferLocal;
        }
      case ConflictType.dualDeleteConflict:
        // Nothing to resolve for dual deletes
        return ConflictResolutionStrategy.lastWriteWins;
      case ConflictType.businessRuleViolation:
        // Always require manual resolution for business rule violations
        return ConflictResolutionStrategy.manualResolution;
      case ConflictType.dataIntegrityConflict:
        // For data integrity conflicts, attempt to merge if possible
        return ConflictResolutionStrategy.mergeChanges;
    }
  }
}

/// Types of conflicts that can occur during synchronization
enum ConflictType {
  /// Both local and cloud records were modified
  concurrentModification,
  
  /// Record was deleted locally but modified in cloud
  deleteModifyConflict,
  
  /// Record was deleted in both locations
  dualDeleteConflict,
  
  /// Modification violates business rules
  businessRuleViolation,
  
  /// Data integrity conflict detected
  dataIntegrityConflict,
}

/// Phases reported during [SupabaseService.syncBidirectional] for UI progress.
enum SyncPipelinePhase {
  localToCloud,
  cloudToLocal,
  conflictsDetecting,
  conflictsResolving,
}

/// Resolution strategies for handling conflicts
enum ConflictResolutionStrategy {
  /// Use the version with the most recent timestamp (last-write-wins)
  lastWriteWins,
  
  /// Merge changes from both versions when possible
  mergeChanges,
  
  /// Keep local version and discard cloud changes
  preferLocal,
  
  /// Keep cloud version and discard local changes
  preferCloud,
  
  /// Mark for manual resolution by user
  manualResolution,
  
  /// Create a new record combining both versions
  forkRecord,
}

/// Short Arabic summary for settings / notifications after sync.
String summarizeSyncConflictsAr(List<SyncConflict> conflicts) {
  if (conflicts.isEmpty) {
    return 'لم يُرصد أي تعارض في آخر مزامنة.';
  }
  final manual = conflicts.where((c) {
    return c.recommendedResolutionStrategy ==
            ConflictResolutionStrategy.manualResolution ||
        c.conflictType == ConflictType.businessRuleViolation;
  }).length;
  if (manual > 0) {
    return 'رُصد $manual تعارضاً يتطلب مراجعة يدوية من أصل ${conflicts.length}.';
  }
  return 'عُالج ${conflicts.length} تعارضاً تلقائياً.';
}