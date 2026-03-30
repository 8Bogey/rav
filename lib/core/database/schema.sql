-- SQL Schema for Supabase Database
-- Based on Drift database schema from app_database.dart

-- Subscribers Table
CREATE TABLE IF NOT EXISTS subscribers (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  cabinet TEXT NOT NULL,
  phone TEXT NOT NULL,
  status INTEGER NOT NULL, -- 0: inactive, 1: active, 2: suspended, 3: disconnected
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  accumulated_debt REAL DEFAULT 0,
  tags TEXT,
  notes TEXT,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE,
  sync_status TEXT DEFAULT 'local_only',
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT
);

-- Cabinets Table
CREATE TABLE IF NOT EXISTS cabinets (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  name TEXT NOT NULL,
  total_subscribers INTEGER NOT NULL,
  current_subscribers INTEGER NOT NULL,
  collected_amount REAL DEFAULT 0,
  delayed_subscribers INTEGER NOT NULL,
  completion_date TIMESTAMP WITH TIME ZONE,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE,
  sync_status TEXT DEFAULT 'local_only',
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT
);

-- Payments Table
CREATE TABLE IF NOT EXISTS payments (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  subscriber_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  worker TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  cabinet TEXT NOT NULL,
  
  -- Foreign key constraint
  CONSTRAINT fk_payments_subscriber 
    FOREIGN KEY (subscriber_id) 
    REFERENCES subscribers(id) 
    ON DELETE CASCADE,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE,
  sync_status TEXT DEFAULT 'local_only',
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT
);

-- Workers Table
CREATE TABLE IF NOT EXISTS workers (
  -- Primary identifier
  id SERIAL PRIMARY KEY,
  
  -- Business data fields
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  permissions TEXT NOT NULL, -- JSON string of permissions
  today_collected REAL DEFAULT 0,
  month_total REAL DEFAULT 0,
  
  -- Sync metadata fields
  last_modified TIMESTAMP WITH TIME ZONE,
  sync_status TEXT DEFAULT 'local_only',
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT
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
  last_modified TIMESTAMP WITH TIME ZONE,
  sync_status TEXT DEFAULT 'local_only',
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT
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
  last_modified TIMESTAMP WITH TIME ZONE,
  sync_status TEXT DEFAULT 'local_only',
  dirty_flag BOOLEAN DEFAULT FALSE,
  cloud_id TEXT,
  deleted_locally BOOLEAN DEFAULT FALSE,
  permissions_mask TEXT
);