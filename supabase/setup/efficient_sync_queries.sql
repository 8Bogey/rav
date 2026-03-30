-- Efficient Data Retrieval Mechanisms for Sync Operations
-- These queries and mechanisms optimize bandwidth usage and sync performance

-- Function to get minimal subscriber data for sync
-- Retrieves only essential fields needed for conflict detection and basic sync
CREATE OR REPLACE FUNCTION get_minimal_subscriber_sync_data(since_timestamp TIMESTAMPTZ)
RETURNS TABLE (
  id INTEGER,
  cloud_id TEXT,
  last_modified TIMESTAMPTZ,
  sync_status TEXT,
  dirty_flag BOOLEAN,
  deleted_locally BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.cloud_id,
    s.last_modified,
    s.sync_status,
    s.dirty_flag,
    s.deleted_locally
  FROM subscribers s
  WHERE s.last_modified >= since_timestamp
     OR s.dirty_flag = true
     OR s.sync_status IN ('sync_pending', 'conflict');
END;
$$ LANGUAGE plpgsql;

-- Function to get minimal cabinet data for sync
CREATE OR REPLACE FUNCTION get_minimal_cabinet_sync_data(since_timestamp TIMESTAMPTZ)
RETURNS TABLE (
  id INTEGER,
  cloud_id TEXT,
  last_modified TIMESTAMPTZ,
  sync_status TEXT,
  dirty_flag BOOLEAN,
  deleted_locally BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.cloud_id,
    c.last_modified,
    c.sync_status,
    c.dirty_flag,
    c.deleted_locally
  FROM cabinets c
  WHERE c.last_modified >= since_timestamp
     OR c.dirty_flag = true
     OR c.sync_status IN ('sync_pending', 'conflict');
END;
$$ LANGUAGE plpgsql;

-- Function to get minimal payment data for sync
CREATE OR REPLACE FUNCTION get_minimal_payment_sync_data(since_timestamp TIMESTAMPTZ)
RETURNS TABLE (
  id INTEGER,
  cloud_id TEXT,
  last_modified TIMESTAMPTZ,
  sync_status TEXT,
  dirty_flag BOOLEAN,
  deleted_locally BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.cloud_id,
    p.last_modified,
    p.sync_status,
    p.dirty_flag,
    p.deleted_locally
  FROM payments p
  WHERE p.last_modified >= since_timestamp
     OR p.dirty_flag = true
     OR p.sync_status IN ('sync_pending', 'conflict');
END;
$$ LANGUAGE plpgsql;

-- Function to get minimal worker data for sync
CREATE OR REPLACE FUNCTION get_minimal_worker_sync_data(since_timestamp TIMESTAMPTZ)
RETURNS TABLE (
  id INTEGER,
  cloud_id TEXT,
  last_modified TIMESTAMPTZ,
  sync_status TEXT,
  dirty_flag BOOLEAN,
  deleted_locally BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    w.id,
    w.cloud_id,
    w.last_modified,
    w.sync_status,
    w.dirty_flag,
    w.deleted_locally
  FROM workers w
  WHERE w.last_modified >= since_timestamp
     OR w.dirty_flag = true
     OR w.sync_status IN ('sync_pending', 'conflict');
END;
$$ LANGUAGE plpgsql;

-- Views for efficient sync data retrieval
-- View for subscribers requiring sync
CREATE OR REPLACE VIEW subscribers_needing_sync AS
SELECT 
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  cabinet,
  worker_id
FROM subscribers 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

-- View for cabinets requiring sync
CREATE OR REPLACE VIEW cabinets_needing_sync AS
SELECT 
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally
FROM cabinets 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

-- View for payments requiring sync
CREATE OR REPLACE VIEW payments_needing_sync AS
SELECT 
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  worker,
  subscriber_id
FROM payments 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

-- View for workers requiring sync
CREATE OR REPLACE VIEW workers_needing_sync AS
SELECT 
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  name,
  phone
FROM workers 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

-- Materialized views for performance-critical sync operations
-- These should be refreshed periodically based on sync frequency
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_recent_changes_summary AS
SELECT 
  'subscribers' as table_name,
  COUNT(*) as count,
  MAX(last_modified) as latest_change
FROM subscribers 
WHERE last_modified >= NOW() - INTERVAL '1 hour'

UNION ALL

SELECT 
  'cabinets' as table_name,
  COUNT(*) as count,
  MAX(last_modified) as latest_change
FROM cabinets 
WHERE last_modified >= NOW() - INTERVAL '1 hour'

UNION ALL

SELECT 
  'payments' as table_name,
  COUNT(*) as count,
  MAX(last_modified) as latest_change
FROM payments 
WHERE last_modified >= NOW() - INTERVAL '1 hour'

UNION ALL

SELECT 
  'workers' as table_name,
  COUNT(*) as count,
  MAX(last_modified) as latest_change
FROM workers 
WHERE last_modified >= NOW() - INTERVAL '1 hour';

-- Refresh the materialized view periodically
-- This can be scheduled using Supabase cron jobs or external schedulers
-- REFRESH MATERIALIZED VIEW mv_recent_changes_summary;

-- Stored procedure for batch sync operations
-- This procedure handles efficient batch retrieval of records needing sync
CREATE OR REPLACE PROCEDURE batch_sync_retrieval(
  IN since_time TIMESTAMPTZ,
  IN batch_size INTEGER DEFAULT 100,
  OUT subscribers_batch JSONB,
  OUT cabinets_batch JSONB,
  OUT payments_batch JSONB,
  OUT workers_batch JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
  subscriber_cursor CURSOR FOR
    SELECT to_jsonb(s) FROM subscribers s
    WHERE s.last_modified >= since_time
       OR s.dirty_flag = true
       OR s.sync_status IN ('sync_pending', 'conflict')
    LIMIT batch_size;

  cabinet_cursor CURSOR FOR
    SELECT to_jsonb(c) FROM cabinets c
    WHERE c.last_modified >= since_time
       OR c.dirty_flag = true
       OR c.sync_status IN ('sync_pending', 'conflict')
    LIMIT batch_size;

  payment_cursor CURSOR FOR
    SELECT to_jsonb(p) FROM payments p
    WHERE p.last_modified >= since_time
       OR p.dirty_flag = true
       OR p.sync_status IN ('sync_pending', 'conflict')
    LIMIT batch_size;

  worker_cursor CURSOR FOR
    SELECT to_jsonb(w) FROM workers w
    WHERE w.last_modified >= since_time
       OR w.dirty_flag = true
       OR w.sync_status IN ('sync_pending', 'conflict')
    LIMIT batch_size;
BEGIN
  -- Collect subscribers batch
  SELECT jsonb_agg(s) INTO subscribers_batch
  FROM (
    SELECT s FROM subscriber_cursor s
  ) s;

  -- Collect cabinets batch
  SELECT jsonb_agg(c) INTO cabinets_batch
  FROM (
    SELECT c FROM cabinet_cursor c
  ) c;

  -- Collect payments batch
  SELECT jsonb_agg(p) INTO payments_batch
  FROM (
    SELECT p FROM payment_cursor p
  ) p;

  -- Collect workers batch
  SELECT jsonb_agg(w) INTO workers_batch
  FROM (
    SELECT w FROM worker_cursor w
  ) w;
END;
$$;

-- Indexes to support efficient sync queries
-- These indexes complement the general performance indexes created earlier
CREATE INDEX IF NOT EXISTS idx_subscribers_sync_batch 
ON subscribers(last_modified DESC, id)
WHERE last_modified IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_cabinets_sync_batch 
ON cabinets(last_modified DESC, id)
WHERE last_modified IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_payments_sync_batch 
ON payments(last_modified DESC, id)
WHERE last_modified IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_workers_sync_batch 
ON workers(last_modified DESC, id)
WHERE last_modified IS NOT NULL;

-- Composite index for efficient batch sync retrieval
CREATE INDEX IF NOT EXISTS idx_subscribers_sync_composite 
ON subscribers(last_modified DESC, dirty_flag, sync_status)
WHERE last_modified IS NOT NULL 
   OR dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_cabinets_sync_composite 
ON cabinets(last_modified DESC, dirty_flag, sync_status)
WHERE last_modified IS NOT NULL 
   OR dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_payments_sync_composite 
ON payments(last_modified DESC, dirty_flag, sync_status)
WHERE last_modified IS NOT NULL 
   OR dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

CREATE INDEX IF NOT EXISTS idx_workers_sync_composite 
ON workers(last_modified DESC, dirty_flag, sync_status)
WHERE last_modified IS NOT NULL 
   OR dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict');

-- Functions for calculating sync priority
-- These functions help determine which records should be synced first
CREATE OR REPLACE FUNCTION calculate_sync_priority(
  last_modified TIMESTAMPTZ,
  dirty_flag BOOLEAN,
  sync_status TEXT,
  conflict_origin TEXT
) RETURNS INTEGER AS $$
BEGIN
  -- Priority calculation based on various factors
  -- Higher number = higher priority
  RETURN 
    CASE 
      WHEN conflict_origin IS NOT NULL THEN 100  -- Conflicts have highest priority
      WHEN sync_status = 'sync_pending' THEN 50   -- Pending sync has medium-high priority
      WHEN dirty_flag = true THEN 30              -- Dirty records have medium priority
      WHEN last_modified >= NOW() - INTERVAL '5 minutes' THEN 20  -- Recent changes
      ELSE 10  -- Default priority
    END;
END;
$$ LANGUAGE plpgsql;

-- View that orders records by sync priority
CREATE OR REPLACE VIEW prioritized_sync_records AS
SELECT 
  'subscribers' as table_name,
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  calculate_sync_priority(last_modified, dirty_flag, sync_status, conflict_origin) as priority_score
FROM subscribers 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict')

UNION ALL

SELECT 
  'cabinets' as table_name,
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  calculate_sync_priority(last_modified, dirty_flag, sync_status, conflict_origin) as priority_score
FROM cabinets 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict')

UNION ALL

SELECT 
  'payments' as table_name,
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  calculate_sync_priority(last_modified, dirty_flag, sync_status, conflict_origin) as priority_score
FROM payments 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict')

UNION ALL

SELECT 
  'workers' as table_name,
  id,
  cloud_id,
  last_modified,
  sync_status,
  dirty_flag,
  deleted_locally,
  calculate_sync_priority(last_modified, dirty_flag, sync_status, conflict_origin) as priority_score
FROM workers 
WHERE dirty_flag = true 
   OR sync_status IN ('sync_pending', 'conflict')

ORDER BY priority_score DESC, last_modified DESC;