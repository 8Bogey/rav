-- Conflict Detection Triggers for Offline-First Application
-- These triggers automatically detect and mark potential conflicts during sync operations

-- Function to detect conflicts on INSERT
CREATE OR REPLACE FUNCTION detect_insert_conflict()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if a record with the same business key already exists
  -- This could indicate a conflict if the local database has a record with the same key
  IF NEW.cloud_id IS NOT NULL THEN
    -- Check if there's already a record with this cloud_id
    -- This would indicate the record was already synced from cloud
    IF EXISTS (SELECT 1 FROM subscribers WHERE cloud_id = NEW.cloud_id AND id != NEW.id) THEN
      -- Mark as conflict
      NEW.sync_status := 'conflict';
      NEW.conflict_origin := 'cloud_duplicate';
      NEW.conflict_detected_at := NOW();
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to detect conflicts on UPDATE
CREATE OR REPLACE FUNCTION detect_update_conflict()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if the record was modified more recently in the cloud than locally
  -- This compares the last_modified timestamp
  IF OLD.last_modified IS NOT NULL AND NEW.last_modified IS NOT NULL THEN
    -- If cloud record is newer than local, flag as potential conflict
    -- This is determined by comparing timestamps
    IF OLD.last_modified > NEW.last_modified THEN
      -- Cloud version is newer than local version
      NEW.sync_status := 'conflict';
      NEW.conflict_origin := 'concurrent_modification';
      NEW.conflict_detected_at := NOW();
    END IF;
  END IF;
  
  -- Check if record was deleted locally but modified in cloud
  IF OLD.deleted_locally = true AND NEW.deleted_locally = false THEN
    NEW.sync_status := 'conflict';
    NEW.conflict_origin := 'delete_modify';
    NEW.conflict_detected_at := NOW();
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for subscribers table
CREATE TRIGGER subscribers_insert_conflict_trigger
  BEFORE INSERT ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION detect_insert_conflict();

CREATE TRIGGER subscribers_update_conflict_trigger
  BEFORE UPDATE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION detect_update_conflict();

-- Triggers for cabinets table
CREATE TRIGGER cabinets_insert_conflict_trigger
  BEFORE INSERT ON cabinets
  FOR EACH ROW
  EXECUTE FUNCTION detect_insert_conflict();

CREATE TRIGGER cabinets_update_conflict_trigger
  BEFORE UPDATE ON cabinets
  FOR EACH ROW
  EXECUTE FUNCTION detect_update_conflict();

-- Triggers for payments table
CREATE TRIGGER payments_insert_conflict_trigger
  BEFORE INSERT ON payments
  FOR EACH ROW
  EXECUTE FUNCTION detect_insert_conflict();

CREATE TRIGGER payments_update_conflict_trigger
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION detect_update_conflict();

-- Triggers for workers table
CREATE TRIGGER workers_insert_conflict_trigger
  BEFORE INSERT ON workers
  FOR EACH ROW
  EXECUTE FUNCTION detect_insert_conflict();

CREATE TRIGGER workers_update_conflict_trigger
  BEFORE UPDATE ON workers
  FOR EACH ROW
  EXECUTE FUNCTION detect_update_conflict();

-- Additional function for detecting sync inconsistencies
CREATE OR REPLACE FUNCTION detect_sync_inconsistency()
RETURNS TRIGGER AS $$
BEGIN
  -- Check for sync status inconsistencies
  IF NEW.dirty_flag = true AND NEW.sync_status = 'synced' THEN
    -- This is an inconsistency - dirty flag should not be true for synced records
    NEW.sync_status := 'sync_pending';
  END IF;
  
  -- Check for deletion inconsistencies
  IF NEW.deleted_locally = true AND NEW.sync_status = 'local_only' THEN
    -- If deleted locally, should be marked for sync
    NEW.sync_status := 'sync_pending';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for sync inconsistency detection
CREATE TRIGGER subscribers_sync_check_trigger
  BEFORE UPDATE ON subscribers
  FOR EACH ROW
  EXECUTE FUNCTION detect_sync_inconsistency();

CREATE TRIGGER cabinets_sync_check_trigger
  BEFORE UPDATE ON cabinets
  FOR EACH ROW
  EXECUTE FUNCTION detect_sync_inconsistency();

CREATE TRIGGER payments_sync_check_trigger
  BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION detect_sync_inconsistency();

CREATE TRIGGER workers_sync_check_trigger
  BEFORE UPDATE ON workers
  FOR EACH ROW
  EXECUTE FUNCTION detect_sync_inconsistency();

-- Function to log conflict detection events
CREATE OR REPLACE FUNCTION log_conflict_detection()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a record into audit log when conflict is detected
  INSERT INTO audit_log (user, action, target, details, type, timestamp)
  VALUES (
    'SYSTEM',
    'CONFLICT_DETECTED',
    TG_TABLE_NAME,
    'Conflict detected for record ID: ' || NEW.id || ', Origin: ' || COALESCE(NEW.conflict_origin, 'unknown'),
    'SYNC_CONFLICT',
    NOW()
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to log conflict detection
CREATE TRIGGER subscribers_conflict_log_trigger
  AFTER UPDATE ON subscribers
  FOR EACH ROW
  WHEN (NEW.sync_status = 'conflict')
  EXECUTE FUNCTION log_conflict_detection();

CREATE TRIGGER cabinets_conflict_log_trigger
  AFTER UPDATE ON cabinets
  FOR EACH ROW
  WHEN (NEW.sync_status = 'conflict')
  EXECUTE FUNCTION log_conflict_detection();

CREATE TRIGGER payments_conflict_log_trigger
  AFTER UPDATE ON payments
  FOR EACH ROW
  WHEN (NEW.sync_status = 'conflict')
  EXECUTE FUNCTION log_conflict_detection();

CREATE TRIGGER workers_conflict_log_trigger
  AFTER UPDATE ON workers
  FOR EACH ROW
  WHEN (NEW.sync_status = 'conflict')
  EXECUTE FUNCTION log_conflict_detection();

-- Views for easy conflict monitoring
CREATE OR REPLACE VIEW active_conflicts AS
SELECT 
  'subscribers' as table_name,
  id,
  name as record_identifier,
  conflict_origin,
  conflict_detected_at,
  last_modified as local_last_modified
FROM subscribers 
WHERE sync_status = 'conflict'

UNION ALL

SELECT 
  'cabinets' as table_name,
  id,
  name as record_identifier,
  conflict_origin,
  conflict_detected_at,
  last_modified as local_last_modified
FROM cabinets 
WHERE sync_status = 'conflict'

UNION ALL

SELECT 
  'payments' as table_name,
  id,
  worker || ': ' || amount as record_identifier,
  conflict_origin,
  conflict_detected_at,
  last_modified as local_last_modified
FROM payments 
WHERE sync_status = 'conflict'

UNION ALL

SELECT 
  'workers' as table_name,
  id,
  name as record_identifier,
  conflict_origin,
  conflict_detected_at,
  last_modified as local_last_modified
FROM workers 
WHERE sync_status = 'conflict';

-- Function to reset conflict status after resolution
CREATE OR REPLACE FUNCTION reset_conflict_status(record_table TEXT, record_id INT)
RETURNS VOID AS $$
BEGIN
  CASE record_table
    WHEN 'subscribers' THEN
      UPDATE subscribers 
      SET sync_status = 'synced', 
          conflict_resolved_at = NOW(),
          conflict_resolution_strategy = 'manual'
      WHERE id = record_id AND sync_status = 'conflict';
      
    WHEN 'cabinets' THEN
      UPDATE cabinets 
      SET sync_status = 'synced', 
          conflict_resolved_at = NOW(),
          conflict_resolution_strategy = 'manual'
      WHERE id = record_id AND sync_status = 'conflict';
      
    WHEN 'payments' THEN
      UPDATE payments 
      SET sync_status = 'synced', 
          conflict_resolved_at = NOW(),
          conflict_resolution_strategy = 'manual'
      WHERE id = record_id AND sync_status = 'conflict';
      
    WHEN 'workers' THEN
      UPDATE workers 
      SET sync_status = 'synced', 
          conflict_resolved_at = NOW(),
          conflict_resolution_strategy = 'manual'
      WHERE id = record_id AND sync_status = 'conflict';
  END CASE;
END;
$$ LANGUAGE plpgsql;