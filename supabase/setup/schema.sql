-- Complete Supabase Database Schema for Offline-First Application
-- This schema includes all tables with sync metadata and conflict resolution fields

-- Subscribers Table
CREATE TABLE IF NOT EXISTS subscribers (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  cabinet TEXT NOT NULL,
  phone TEXT NOT NULL,
  status INTEGER NOT NULL DEFAULT 1, -- 0: inactive, 1: active, 2: suspended, 3: disconnected
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  accumulated_debt REAL DEFAULT 0,
  tags TEXT,
  notes TEXT,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'local_only' CHECK (sync_status IN ('local_only', 'sync_pending', 'synced', 'conflict')),
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT,
  
  -- Conflict resolution fields
  conflict_origin TEXT,
  conflict_detected_at TIMESTAMP WITH TIME ZONE,
  conflict_resolved_at TIMESTAMP WITH TIME ZONE,
  conflict_resolution_strategy TEXT,
  
  -- Sync tracking fields
  last_synced_at TIMESTAMP WITH TIME ZONE,
  last_sync_error TEXT,
  sync_retry_count INTEGER DEFAULT 0
);

-- Cabinets Table
CREATE TABLE IF NOT EXISTS cabinets (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  name TEXT NOT NULL UNIQUE,
  total_subscribers INTEGER NOT NULL DEFAULT 0,
  current_subscribers INTEGER NOT NULL DEFAULT 0,
  collected_amount REAL DEFAULT 0,
  delayed_subscribers INTEGER NOT NULL DEFAULT 0,
  completion_date TIMESTAMP WITH TIME ZONE,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'local_only' CHECK (sync_status IN ('local_only', 'sync_pending', 'synced', 'conflict')),
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT,
  
  -- Conflict resolution fields
  conflict_origin TEXT,
  conflict_detected_at TIMESTAMP WITH TIME ZONE,
  conflict_resolved_at TIMESTAMP WITH TIME ZONE,
  conflict_resolution_strategy TEXT,
  
  -- Sync tracking fields
  last_synced_at TIMESTAMP WITH TIME ZONE,
  last_sync_error TEXT,
  sync_retry_count INTEGER DEFAULT 0
);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  subscriber_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  worker TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  cabinet TEXT NOT NULL,
  
  -- Foreign key constraint
  CONSTRAINT fk_payments_subscriber 
    FOREIGN KEY (subscriber_id) 
    REFERENCES subscribers(id) 
    ON DELETE CASCADE,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'local_only' CHECK (sync_status IN ('local_only', 'sync_pending', 'synced', 'conflict')),
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT,
  
  -- Conflict resolution fields
  conflict_origin TEXT,
  conflict_detected_at TIMESTAMP WITH TIME ZONE,
  conflict_resolved_at TIMESTAMP WITH TIME ZONE,
  conflict_resolution_strategy TEXT,
  
  -- Sync tracking fields
  last_synced_at TIMESTAMP WITH TIME ZONE,
  last_sync_error TEXT,
  sync_retry_count INTEGER DEFAULT 0
);

-- Workers Table
CREATE TABLE IF NOT EXISTS workers (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  permissions TEXT NOT NULL DEFAULT '{}', -- JSON string of permissions
  today_collected REAL DEFAULT 0,
  month_total REAL DEFAULT 0,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'local_only' CHECK (sync_status IN ('local_only', 'sync_pending', 'synced', 'conflict')),
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT,
  
  -- Conflict resolution fields
  conflict_origin TEXT,
  conflict_detected_at TIMESTAMP WITH TIME ZONE,
  conflict_resolved_at TIMESTAMP WITH TIME ZONE,
  conflict_resolution_strategy TEXT
);

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_log (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  user TEXT NOT NULL,
  action TEXT NOT NULL,
  target TEXT NOT NULL,
  details TEXT NOT NULL,
  type TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'local_only' CHECK (sync_status IN ('local_only', 'sync_pending', 'synced', 'conflict')),
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT,
  
  -- Conflict resolution fields
  conflict_origin TEXT,
  conflict_detected_at TIMESTAMP WITH TIME ZONE,
  conflict_resolved_at TIMESTAMP WITH TIME ZONE,
  conflict_resolution_strategy TEXT,
  
  -- Sync tracking fields
  last_synced_at TIMESTAMP WITH TIME ZONE,
  last_sync_error TEXT,
  sync_retry_count INTEGER DEFAULT 0
);

-- WhatsApp Templates Table
CREATE TABLE IF NOT EXISTS whatsapp_templates (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  is_active INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  sync_status TEXT DEFAULT 'local_only' CHECK (sync_status IN ('local_only', 'sync_pending', 'synced', 'conflict')),
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT,
  
  -- Conflict resolution fields
  conflict_origin TEXT,
  conflict_detected_at TIMESTAMP WITH TIME ZONE,
  conflict_resolved_at TIMESTAMP WITH TIME ZONE,
  conflict_resolution_strategy TEXT,
  
  -- Sync tracking fields
  last_synced_at TIMESTAMP WITH TIME ZONE,
  last_sync_error TEXT,
  sync_retry_count INTEGER DEFAULT 0
);

-- Add indexes for foreign key performance
CREATE INDEX IF NOT EXISTS idx_payments_subscriber_id ON payments(subscriber_id);
CREATE INDEX IF NOT EXISTS idx_subscribers_cabinet ON subscribers(cabinet);
CREATE INDEX IF NOT EXISTS idx_subscribers_phone ON subscribers(phone);
CREATE INDEX IF NOT EXISTS idx_subscribers_status ON subscribers(status);
CREATE INDEX IF NOT EXISTS idx_workers_phone ON workers(phone);
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON audit_log(user);
CREATE INDEX IF NOT EXISTS idx_audit_log_timestamp ON audit_log(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_type ON audit_log(type);

-- Add updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.last_modified = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers to automatically update last_modified
CREATE TRIGGER update_subscribers_modified
  BEFORE UPDATE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cabinets_modified
  BEFORE UPDATE ON cabinets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_modified
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workers_modified
  BEFORE UPDATE ON workers
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_audit_log_modified
  BEFORE UPDATE ON audit_log
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_whatsapp_templates_modified
  BEFORE UPDATE ON whatsapp_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security on all tables
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cabinets ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_templates ENABLE ROW LEVEL SECURITY;
