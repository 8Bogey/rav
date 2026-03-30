# B08 Implementation Notes: Bidirectional Sync with Conflict Resolution

## Prerequisites
✅ B05: Enhance Drift local database with sync metadata (COMPLETED)  
✅ B06: Add sync metadata to Drift database tables (COMPLETED)  
✅ B07: Add sync metadata to Supabase database tables (COMPLETED)  

## Technical Approach

### Core Architecture
The bidirectional sync implementation will leverage the existing sync metadata fields to create a robust synchronization mechanism:

1. **Change Detection**: Use `dirtyFlag` to identify locally modified records
2. **Conflict Detection**: Use `syncStatus` field to track sync state and detect conflicts
3. **Identity Correlation**: Use `cloudId` to maintain consistent record identification across databases
4. **Timestamp Management**: Use `lastModified` for determining data freshness
5. **Selective Sync**: Use `permissionsMask` for granular data control
6. **Soft Deletion**: Use `deletedLocally` for tracking deletions without data loss

### Implementation Phases

#### Phase 1: Basic Sync Engine
**Objective**: Establish fundamental bidirectional synchronization capability

**Components**:
- Local → Cloud sync function
- Cloud → Local sync function  
- Basic conflict detection using `lastModified` timestamps
- Simple last-write-wins conflict resolution
- `dirtyFlag` tracking for change detection

**Success Criteria**:
✅ Records sync bidirectionally without data loss  
✅ Basic conflict detection works  
✅ Sync status properly tracked in `syncStatus` field  

#### Phase 2: Advanced Conflict Resolution
**Objective**: Implement sophisticated conflict resolution strategies

**Components**:
- Manual conflict resolution interface
- Merge strategies for complex data objects
- User notification system for conflicts requiring attention
- Conflict history tracking

**Success Criteria**:
✅ Multiple conflict resolution strategies available  
✅ Users can manually resolve complex conflicts  
✅ Conflict history maintained for auditing  

#### Phase 3: Selective Sync Implementation
**Objective**: Enable granular data synchronization based on permissions

**Components**:
- Permissions mask processing logic
- Selective data filtering based on user permissions
- Configuration interface for sync preferences

**Success Criteria**:
✅ Data syncs selectively based on permissions  
✅ Users can configure sync preferences  
✅ Performance optimized for selective syncing  

### Technical Details

#### Change Tracking Algorithm
```
1. On local data modification:
   - Set dirtyFlag = true
   - Update lastModified = current timestamp
   - Set syncStatus = 'sync_pending'

2. During sync cycle:
   - Query for records where dirtyFlag = true
   - Send to cloud database
   - On successful sync:
     - Set dirtyFlag = false
     - Set syncStatus = 'synced'
     - Update cloudId if new record
```

#### Conflict Detection Logic
```
1. During cloud-to-local sync:
   - Compare cloud.lastModified vs local.lastModified
   - If cloud is newer AND local.dirtyFlag = true → CONFLICT
   - Set syncStatus = 'conflict' on conflicting records

2. Conflict resolution triggers:
   - Automatic (last-write-wins) for simple conflicts
   - Manual resolution required for complex cases
```

#### Sync Status State Machine
```
local_only → sync_pending → synced ↔ conflict
    ↑                                ↓
    └───────────────←────────────────┘
```

States:
- `local_only`: Record exists only locally, never synced
- `sync_pending`: Local changes pending sync
- `synced`: Successfully synchronized
- `conflict`: Conflict detected, requires resolution

### Integration Points

#### With Existing Services
- **SubscribersService**: Sync subscriber data with conflict handling
- **CabinetsService**: Sync cabinet information bidirectionally  
- **PaymentsService**: Sync payment records with timestamp preservation
- **WorkersService**: Sync worker data with permissions consideration
- **AuditLogService**: Sync audit entries with selective filtering
- **WhatsappService**: Sync templates with version control

#### Supabase Integration
- Utilize existing SupabaseService.syncLocalToCloud() and syncCloudToLocal() methods
- Extend with conflict detection and resolution capabilities
- Add error handling for network failures

### Testing Strategy

#### Unit Tests
1. Change detection with dirtyFlag
2. Conflict detection scenarios
3. Sync status transitions
4. Timestamp handling edge cases

#### Integration Tests
1. Full sync cycles (local → cloud → local)
2. Conflict resolution scenarios
3. Selective sync based on permissions
4. Error handling and recovery

#### Performance Tests
1. Sync speed with large datasets
2. Memory usage during sync operations
3. Battery consumption during background sync

### Risk Mitigation

#### Data Loss Prevention
- Implement transaction-based sync operations
- Create rollback mechanisms for failed syncs
- Maintain backup copies during sync operations

#### Network Resilience
- Queue sync operations during offline periods
- Implement exponential backoff for retries
- Handle partial network connectivity gracefully

#### User Experience
- Provide sync progress indicators
- Notify users of conflicts requiring attention
- Allow manual sync triggering

### Dependencies
- B01: Setup Drift local database (in progress, depends on completed B06)
- B02: Setup Supabase cloud database (in progress, depends on completed B07)
- B09: Implement enhanced synchronization service (blocked by this task)

### Success Metrics
1. **Data Integrity**: Zero data loss during sync operations
2. **Conflict Resolution**: >95% conflicts resolved automatically
3. **Performance**: Sync operations complete within 2 seconds for typical datasets
4. **Reliability**: <1% sync failures requiring manual intervention

## Next Steps
1. Update B08 task with these implementation notes
2. Begin Phase 1 development focusing on basic sync engine
3. Create unit tests for change tracking algorithm
4. Implement conflict detection logic

---
*Based on findings from Sync Validation Spike (B13)*
*Date: March 16, 2026*