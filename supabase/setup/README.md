# Supabase Database Setup

This directory contains the necessary SQL scripts to set up the Supabase cloud database for the offline-first application.

## Files

1. `schema.sql` - Contains the table definitions for all application tables with sync metadata and conflict resolution fields
2. `rls_policies.sql` - Contains Row Level Security policies for data access control
3. `indexes.sql` - Contains performance indexes optimized for sync operations
4. `enhanced_rls_policies.sql` - Contains enhanced RLS policies designed for offline-first scenarios
5. `conflict_detection_triggers.sql` - Contains triggers for automatic conflict detection
6. `efficient_sync_queries.sql` - Contains functions and views for efficient data retrieval during sync

## Setup Instructions

1. **Execute schema.sql** in your Supabase SQL editor to create the tables
2. **Execute rls_policies.sql** to set up security policies
3. **Execute indexes.sql** to create performance indexes for sync operations
4. **Configure authentication** in the Supabase dashboard:
   - Set up user roles (admin, worker)
   - Configure email templates if needed
   - See [auth_setup.md](auth_setup.md) for detailed instructions
5. **Update environment variables** in your Flutter app:
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
   - See [environment_setup.md](environment_setup.md) for detailed instructions

## Table Structure

The database consists of 6 tables:

1. **subscribers** - Customer/subscriber information
2. **cabinets** - Cabinet/group management
3. **payments** - Payment transaction records
4. **workers** - Worker/user profiles
5. **audit_log** - System activity logging
6. **whatsapp_templates** - WhatsApp message templates

All tables include sync metadata fields for offline-first functionality:
- last_modified
- sync_status
- dirty_flag
- cloud_id
- deleted_locally
- permissions_mask

## Performance Optimization

The database includes specialized indexes for optimizing sync operations:

1. **Timestamp indexes** - For efficient retrieval of recently changed records
2. **Status indexes** - For filtering records that need syncing
3. **Cloud ID indexes** - For conflict detection and resolution
4. **Composite indexes** - For efficient batch processing of sync operations
5. **Covering indexes** - To reduce disk I/O during sync queries

These indexes significantly improve sync performance, especially as the dataset grows.

## Conflict Detection

Automatic conflict detection is implemented through database triggers that monitor:

1. **Concurrent modifications** - When the same record is modified both locally and in the cloud
2. **Delete-modify conflicts** - When a record is deleted locally but modified in the cloud
3. **Duplicate identifiers** - When attempting to insert a record that already exists in the cloud
4. **Sync inconsistencies** - When sync metadata is inconsistent

The system provides views for monitoring active conflicts and functions for resolving them.

## Efficient Data Retrieval

To minimize bandwidth usage during sync operations:

1. **Minimal data functions** - Retrieve only essential fields needed for sync decisions
2. **Prioritized sync views** - Order records by importance for sequential sync processing
3. **Batch retrieval procedures** - Efficiently fetch groups of records needing sync
4. **Materialized summaries** - Pre-computed summaries of recent changes
5. **Indexing strategies** - Specialized indexes for sync query performance

## Security

RLS policies enforce:
- Admin users have full access to all data
- Worker users have limited access based on their assignments
- Audit logs are restricted to admin users only

Enhanced RLS Policies:
The enhanced RLS policies in `enhanced_rls_policies.sql` provide additional security considerations for offline-first scenarios:
- Support for accessing records during sync operations
- Conflict resolution access controls
- Better handling of assignment changes during offline periods
- Functions for validating access to specific records

## Authentication

Application assumes:
- Users authenticate via Supabase Auth
- User roles are stored in user metadata
- Workers are identified by their names from JWT claims