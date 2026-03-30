/// Migration documentation for adding sync metadata fields to all database tables.
///
/// This migration adds the following fields to support offline-first functionality:
/// - lastModified: Timestamp of last local modification
/// - syncStatus: Status of sync ('local_only', 'sync_pending', 'synced', 'conflict')
/// - dirtyFlag: Boolean indicating if record has unsynced changes
/// - cloudId: Unique identifier in cloud database
/// - deletedLocally: Soft delete marker for sync purposes
/// - permissionsMask: Selective sync markers for Android permissions
///
/// Implementation Notes:
/// This migration was implemented by directly modifying the table definitions
/// in lib/core/database/app_database.dart rather than using a traditional 
/// migration approach, since the database was at version 1 and we're upgrading to version 2.
///
/// Fields added to each table:
/// - lastModified (DateTime, nullable): Timestamp of last local modification
/// - syncStatus (Text, default: 'local_only'): Status of sync process
/// - dirtyFlag (Bool, default: false): Indicates if record has unsynced changes
/// - cloudId (Text, nullable): Unique identifier in cloud database
/// - deletedLocally (Bool, default: false): Soft delete marker for sync purposes
/// - permissionsMask (Text, nullable): Selective sync markers for Android permissions