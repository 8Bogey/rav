-- Indexes for Optimized Sync Queries in Offline-First Application
-- These indexes are designed to improve performance of sync operations

-- Index on last_modified for efficient retrieval of recently changed records
-- This is crucial for incremental sync operations
CREATE INDEX IF NOT EXISTS idx_subscribers_last_modified 
ON subscribers(last_modified DESC);

CREATE INDEX IF NOT EXISTS idx_cabinets_last_modified 
ON cabinets(last_modified DESC);

CREATE INDEX IF NOT EXISTS idx_payments_last_modified 
ON payments(last_modified DESC);

CREATE INDEX IF NOT EXISTS idx_workers_last_modified 
ON workers(last_modified DESC);

CREATE INDEX IF NOT EXISTS idx_audit_log_last_modified 
ON audit_log(last_modified DESC);

CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_last_modified 
ON whatsapp_templates(last_modified DESC);

-- Composite index for sync status filtering
-- Allows efficient querying of records that need syncing
CREATE INDEX IF NOT EXISTS idx_subscribers_sync_status_dirty 
ON subscribers(sync_status, dirty_flag) 
WHERE dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_cabinets_sync_status_dirty 
ON cabinets(sync_status, dirty_flag) 
WHERE dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_payments_sync_status_dirty 
ON payments(sync_status, dirty_flag) 
WHERE dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_workers_sync_status_dirty 
ON workers(sync_status, dirty_flag) 
WHERE dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_audit_log_sync_status_dirty 
ON audit_log(sync_status, dirty_flag) 
WHERE dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_sync_status_dirty 
ON whatsapp_templates(sync_status, dirty_flag) 
WHERE dirty_flag = true;

-- Indexes for conflict detection
-- These help identify records that may have conflicts during sync
CREATE INDEX IF NOT EXISTS idx_subscribers_cloud_id 
ON subscribers(cloud_id) 
WHERE cloud_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_cabinets_cloud_id 
ON cabinets(cloud_id) 
WHERE cloud_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_payments_cloud_id 
ON payments(cloud_id) 
WHERE cloud_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_workers_cloud_id 
ON workers(cloud_id) 
WHERE cloud_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_audit_log_cloud_id 
ON audit_log(cloud_id) 
WHERE cloud_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_cloud_id 
ON whatsapp_templates(cloud_id) 
WHERE cloud_id IS NOT NULL;

-- Efficient lookup by sync status for batch processing
-- Useful for identifying records in different states of the sync process
CREATE INDEX IF NOT EXISTS idx_subscribers_sync_status 
ON subscribers(sync_status) 
WHERE sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_cabinets_sync_status 
ON cabinets(sync_status) 
WHERE sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_payments_sync_status 
ON payments(sync_status) 
WHERE sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_workers_sync_status 
ON workers(sync_status) 
WHERE sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_audit_log_sync_status 
ON audit_log(sync_status) 
WHERE sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_sync_status 
ON whatsapp_templates(sync_status) 
WHERE sync_status IN ('sync_pending', 'conflict');

-- Additional indexes for business logic queries that might occur during sync
-- Cabinet-based lookups are common in the application
CREATE INDEX IF NOT EXISTS idx_subscribers_cabinet 
ON subscribers(cabinet);

CREATE INDEX IF NOT EXISTS idx_payments_cabinet 
ON payments(cabinet);

CREATE INDEX IF NOT EXISTS idx_payments_subscriber_id 
ON payments(subscriber_id);

-- Partial indexes for soft-deleted records
-- Important for sync operations that need to handle deletions
CREATE INDEX IF NOT EXISTS idx_subscribers_deleted 
ON subscribers(deleted_locally) 
WHERE deleted_locally = true;

CREATE INDEX IF NOT EXISTS idx_cabinets_deleted 
ON cabinets(deleted_locally) 
WHERE deleted_locally = true;

CREATE INDEX IF NOT EXISTS idx_payments_deleted 
ON payments(deleted_locally) 
WHERE deleted_locally = true;

CREATE INDEX IF NOT EXISTS idx_workers_deleted 
ON workers(deleted_locally) 
WHERE deleted_locally = true;

-- Timestamp-based indexes for efficient date range queries
-- Useful for historical sync operations or pruning old data
CREATE INDEX IF NOT EXISTS idx_subscribers_date_range 
ON subscribers(start_date);

CREATE INDEX IF NOT EXISTS idx_payments_date_range 
ON payments(date);

-- Covering indexes for frequently accessed columns during sync
-- These indexes include all data needed for common sync queries
-- Reducing the need to access the main table pages
CREATE INDEX IF NOT EXISTS idx_subscribers_sync_cover 
ON subscribers(last_modified, sync_status, dirty_flag, deleted_locally, cloud_id)
WHERE sync_status = 'sync_pending' OR dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_cabinets_sync_cover 
ON cabinets(last_modified, sync_status, dirty_flag, deleted_locally, cloud_id)
WHERE sync_status = 'sync_pending' OR dirty_flag = true;

CREATE INDEX IF NOT EXISTS idx_payments_sync_cover 
ON payments(last_modified, sync_status, dirty_flag, deleted_locally, cloud_id)
WHERE sync_status = 'sync_pending' OR dirty_flag = true;

-- Update the README to include information about the indexes
-- This is documented in the README.md file in this directory