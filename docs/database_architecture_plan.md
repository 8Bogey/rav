# Database Architecture Plan

This document outlines the integrated database architecture for the Smart Generator Manager application, focusing on offline-first functionality with eventual consistency. The architecture leverages Drift for local storage and Supabase for cloud synchronization, following the established Beads issue structure.

## Overview

The database architecture implements a robust offline-first approach that ensures data availability regardless of network connectivity while maintaining eventual consistency between local and cloud databases.

## Key Components

### 1. Local Storage (Drift Database)

#### Core Tables
- **SubscribersTable**: Subscriber information with codes, cabinets, and statuses
- **CabinetsTable**: Cabinet management with subscriber counts and progress tracking
- **PaymentsTable**: Payment records linked to subscribers and workers
- **WorkersTable**: Worker profiles with permissions and collection metrics
- **AuditLogTable**: Activity logging for accountability
- **WhatsappTemplatesTable**: WhatsApp message templates

#### Enhanced Sync Metadata Fields (Under Enhancement)
Additional fields will be added to support synchronization:
- `last_synced_at`: Timestamp of last successful sync
- `dirty`: Flag indicating local changes requiring sync
- `conflict_resolution_fields`: Fields needed for conflict resolution strategies
- `sync_selectors`: Selective sync markers for Android permissions

### 2. Cloud Storage (Supabase)

#### Tables Structure
The cloud database mirrors the local schema with additional fields for synchronization and row-level security.

#### Security Configuration
- Row-level security policies for appropriate data access
- Authentication setup for secure connections
- Proper indexing for optimized sync queries

## Synchronization Strategy

The synchronization service orchestrates bidirectional data flow between local and cloud databases with the following principles:

### Eventual Consistency Model
1. **Local-first**: All operations work against local database immediately
2. **Background Sync**: Asynchronous synchronization when online
3. **Conflict Resolution**: Automated and manual conflict resolution strategies
4. **Selective Sync**: Efficient syncing of relevant data subset (Android permissions)

### Conflict Resolution Strategies (Under Implementation)
1. **Last-write-wins**: Automatic resolution based on timestamps
2. **Manual Resolution**: User intervention for critical conflicts
3. **Merge Strategies**: Intelligent merging for complex object types
4. **User Notifications**: Alerting for conflicts requiring attention

## Implementation Plan

The database architecture enhancements are tracked through the following Beads issues:

### Epic: Refactor database architecture for enhanced offline-first with eventual consistency (rav-clz)
Primary umbrella task covering all database architecture improvements.

#### Related Tasks:
1. **Setup Drift local database (rav-1jj)**: Configure and set up the local Drift database with proper table schemas that match the existing app_database.dart structure.

2. **Setup Supabase cloud database (rav-kec)**: Configure Supabase cloud database with matching table schemas, authentication, and row-level security policies.

3. **Implement Drift + Supabase database architecture (rav-66a)**: Implement the database architecture using Drift for local storage and Supabase for cloud synchronization.

4. **Implement synchronization logic (rav-9it)**: Develop synchronization logic to handle offline-first functionality with eventual consistency.

5. **Enhance Drift local database with sync metadata (rav-izy)**: Extending the existing Drift local database schema to include synchronization metadata fields.

6. **Implement enhanced synchronization service (rav-360)**: Creating an advanced synchronization service that handles background sync, selective data syncing for Android permissions, network state monitoring, and queue management for sync operations.

7. **Implement advanced conflict resolution strategies (rav-ota)**: Developing and implementing sophisticated conflict resolution strategies for handling data conflicts during sync.

8. **Optimize Supabase cloud database for offline-first (rav-azy)**: Optimizing the Supabase cloud database configuration and schema to better support offline-first functionality.

9. **Test and validate offline-first database architecture (rav-591)**: Creating comprehensive tests to validate the offline-first database architecture with eventual consistency.

## Dependencies and Relationships

The implementation follows a logical progression:
1. Basic setup of local (rav-1jj) and cloud (rav-kec) databases
2. Implementation of database architecture (rav-66a) with current sync logic (rav-9it)
3. Enhancement of architecture for robust offline-first support through the epic (rav-clz) and its tasks

## Expected Outcomes

Upon completion of this database architecture plan, the application will:
1. Support full offline functionality with seamless user experience
2. Maintain data consistency across all devices through eventual consistency
3. Handle network disruptions gracefully without data loss
4. Provide transparent conflict resolution mechanisms
5. Enable selective data syncing for performance optimization
6. Ensure data integrity and security throughout the synchronization process

## Future Enhancements

Potential areas for future improvement include:
- Real-time sync capabilities for collaborative features
- Advanced analytics on sync patterns and performance
- Machine learning-based conflict resolution for common scenarios
- Compression and bandwidth optimization for sync operations