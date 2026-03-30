-- Indexes for Supabase Database
-- These indexes improve performance for sync operations and queries

-- Index on updated_at for efficient sorting in sync operations
CREATE INDEX IF NOT EXISTS idx_subscribers_updated_at ON subscribers (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_cabinets_updated_at ON cabinets (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_updated_at ON payments (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_workers_updated_at ON workers (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_updated_at ON whatsapp_templates (updated_at DESC);

-- Index on last_modified for conflict detection
CREATE INDEX IF NOT EXISTS idx_subscribers_last_modified ON subscribers (last_modified DESC);
CREATE INDEX IF NOT EXISTS idx_cabinets_last_modified ON cabinets (last_modified DESC);
CREATE INDEX IF NOT EXISTS idx_payments_last_modified ON payments (last_modified DESC);
CREATE INDEX IF NOT EXISTS idx_workers_last_modified ON workers (last_modified DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_last_modified ON whatsapp_templates (last_modified DESC);

-- Index on sync_status for filtering records by sync state
CREATE INDEX IF NOT EXISTS idx_subscribers_sync_status ON subscribers (sync_status);
CREATE INDEX IF NOT EXISTS idx_cabinets_sync_status ON cabinets (sync_status);
CREATE INDEX IF NOT EXISTS idx_payments_sync_status ON payments (sync_status);
CREATE INDEX IF NOT EXISTS idx_workers_sync_status ON workers (sync_status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_sync_status ON whatsapp_templates (sync_status);

-- Composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_subscribers_dirty_sync ON subscribers (dirty_flag, sync_status) WHERE dirty_flag = true;
CREATE INDEX IF NOT EXISTS idx_cabinets_dirty_sync ON cabinets (dirty_flag, sync_status) WHERE dirty_flag = true;
CREATE INDEX IF NOT EXISTS idx_payments_dirty_sync ON payments (dirty_flag, sync_status) WHERE dirty_flag = true;
CREATE INDEX IF NOT EXISTS idx_workers_dirty_sync ON workers (dirty_flag, sync_status) WHERE dirty_flag = true;
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_dirty_sync ON whatsapp_templates (dirty_flag, sync_status) WHERE dirty_flag = true;

-- Index on cabinet for subscriber lookups (common relationship)
CREATE INDEX IF NOT EXISTS idx_subscribers_cabinet ON subscribers (cabinet);

-- Index on worker for payment lookups (common relationship)
CREATE INDEX IF NOT EXISTS idx_payments_worker ON payments (worker);

-- Index on date for time-based queries
CREATE INDEX IF NOT EXISTS idx_payments_date ON payments (date DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_timestamp ON audit_log ("timestamp" DESC);