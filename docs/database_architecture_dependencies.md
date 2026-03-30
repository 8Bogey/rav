# Database Architecture Dependencies for Offline-First Implementation

This document outlines the dependencies and implementation order for the database architecture refactor to support offline-first functionality with eventual consistency.

## Dependency Structure Visualization

```mermaid
graph TD
    A[Database Architecture Epic<br/>(rav-clz)] --> B[Setup Drift Local DB<br/>(rav-1jj)]
    A --> C[Setup Supabase Cloud DB<br/>(rav-kec)]
    B --> D[Add Sync Metadata to Drift<br/>(rav-ti5)]
    C --> E[Add Sync Metadata to Supabase<br/>(rav-793)]
    D --> F[Bidirectional Sync Implementation<br/>(rav-7g8)]
    E --> F
    F --> G[Enhanced Sync Service<br/>(rav-360)]
    A --> H[Conflict Resolution Strategies<br/>(rav-ota)]
    A --> I[Test Offline-First Architecture<br/>(rav-591)]
    G --> I
```

## Implementation Order

1. **Foundation Setup** (Parallel)
   - Setup Drift local database (rav-1jj)
   - Setup Supabase cloud database (rav-kec)

2. **Metadata Enhancement** (Parallel, after setup)
   - Add sync metadata to Drift database tables (rav-ti5)
   - Add sync metadata to Supabase database tables (rav-793)

3. **Core Sync Implementation**
   - Implement bidirectional sync with conflict resolution (rav-7g8)

4. **Advanced Features**
   - Enhanced synchronization service (rav-360)
   - Advanced conflict resolution strategies (rav-ota)

5. **Validation**
   - Test and validate offline-first database architecture (rav-591)

## Detailed Dependencies

### Setup Phase
- `rav-1jj` (Setup Drift) → `rav-ti5` (Add Sync Metadata to Drift)
- `rav-kec` (Setup Supabase) → `rav-793` (Add Sync Metadata to Supabase)

### Implementation Phase
- `rav-ti5` (Sync Metadata Drift) → `rav-7g8` (Bidirectional Sync)
- `rav-793` (Sync Metadata Supabase) → `rav-7g8` (Bidirectional Sync)
- `rav-7g8` (Bidirectional Sync) → `rav-360` (Enhanced Sync Service)

### Testing Phase
- `rav-360` (Enhanced Sync Service) → `rav-591` (Testing)
- `rav-ota` (Conflict Resolution) → `rav-591` (Testing)

## Sync Metadata Fields Required

For each table in both databases, the following fields need to be added:

### Local Drift Database
- `last_modified` (DateTime): Timestamp of last local modification
- `sync_status` (String): Status of sync ('local_only', 'sync_pending', 'synced', 'conflict')
- `dirty_flag` (Boolean): Indicates if record has unsynced changes
- `cloud_id` (String): Unique identifier in cloud database
- `deleted_locally` (Boolean): Soft delete marker for sync purposes
- `permissions_mask` (String): Selective sync markers for Android permissions

### Cloud Supabase Database
- `last_modified` (DateTime): Timestamp of last modification (local or cloud)
- `last_synced` (DateTime): When last synced with any client
- `sync_version` (Integer): Version counter for conflict detection
- `deleted` (Boolean): Soft delete marker for sync purposes
- `permissions_mask` (String): Selective sync markers for Android permissions

## Conflict Resolution Strategy Dependencies

The conflict resolution implementation (rav-ota) can proceed in parallel with core sync but will be validated during testing (rav-591).

This dependency structure ensures:
1. Proper foundation is established before building advanced features
2. Sync metadata is consistent between local and cloud databases
3. Bidirectional sync implementation comes before the enhanced service layer
4. Testing validates the complete implementation including conflict resolution