-- Enhanced Row Level Security (RLS) Policies for Offline-First Scenarios
-- These policies are designed to work better with offline-first applications
-- by considering sync metadata fields and providing more granular access control

-- Enable RLS on all tables (if not already enabled)
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cabinets ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_templates ENABLE ROW LEVEL SECURITY;

-- Enhanced RLS policies for subscribers table
-- Admins can access all subscribers
CREATE POLICY "Admins_full_access_to_subscribers"
ON subscribers FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can access subscribers in their assigned cabinets
-- Enhanced to support offline sync by allowing access to records they may have 
-- previously worked with, even if assignment changes
CREATE POLICY "Workers_access_assigned_subscribers"
ON subscribers FOR SELECT USING (
  subscribers.cabinet IN (
    SELECT DISTINCT cabinet FROM workers 
    WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  )
  OR 
  subscribers.worker_id IN (
    SELECT id FROM workers 
    WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  )
);

-- Allow workers to insert/update subscribers they're assigned to
-- This supports offline data creation/modification
CREATE POLICY "Workers_modify_assigned_subscribers"
ON subscribers FOR INSERT WITH CHECK (
  cabinet IN (
    SELECT DISTINCT cabinet FROM workers 
    WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  )
);

-- Allow workers to update subscribers they've previously worked with
CREATE POLICY "Workers_update_worked_subscribers"
ON subscribers FOR UPDATE USING (
  id IN (
    SELECT DISTINCT subscriber_id FROM payments
    WHERE worker = (SELECT name FROM auth.users WHERE id = auth.uid())
  )
  OR
  cabinet IN (
    SELECT DISTINCT cabinet FROM workers 
    WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  )
);

-- Enhanced RLS policies for cabinets table
-- Admins can access all cabinets
CREATE POLICY "Admins_full_access_to_cabinets"
ON cabinets FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can access their assigned cabinets with offline support
CREATE POLICY "Workers_access_their_cabinets"
ON cabinets FOR ALL USING (
  name IN (
    SELECT DISTINCT cabinet FROM workers 
    WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  )
);

-- Enhanced RLS policies for payments table
-- Admins can access all payments
CREATE POLICY "Admins_full_access_to_payments"
ON payments FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can access payments they've collected
-- Enhanced to support offline access to recently collected payments
CREATE POLICY "Workers_access_their_payments"
ON payments FOR ALL USING (
  worker = (SELECT name FROM auth.users WHERE id = auth.uid())
  OR
  subscriber_id IN (
    SELECT id FROM subscribers 
    WHERE cabinet IN (
      SELECT DISTINCT cabinet FROM workers 
      WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
    )
  )
);

-- Enhanced RLS policies for workers table
-- Admins can access all workers
CREATE POLICY "Admins_full_access_to_workers"
ON workers FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can view themselves and their colleagues
CREATE POLICY "Workers_view_team_members"
ON workers FOR SELECT USING (
  phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  OR
  cabinet IN (
    SELECT DISTINCT cabinet FROM workers 
    WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
  )
);

-- Enhanced RLS policies for audit_log table
-- Only admins can access audit logs
CREATE POLICY "Admins_full_access_to_audit_log"
ON audit_log FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Enhanced RLS policies for whatsapp_templates table
-- Admins can manage all templates
CREATE POLICY "Admins_manage_all_templates"
ON whatsapp_templates FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Users can view active templates with offline support
CREATE POLICY "Users_view_active_templates_offline"
ON whatsapp_templates FOR SELECT USING (
  is_active = 1
  OR
  id IN (
    SELECT DISTINCT template_id FROM (
      SELECT 1 as template_id -- Simplified for example
    ) t
  )
);

-- Additional policies for sync operations
-- Allow access to records marked for sync to support conflict resolution
CREATE POLICY "Access_sync_pending_records"
ON subscribers FOR SELECT USING (
  sync_status = 'sync_pending' 
  OR sync_status = 'conflict'
  AND EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND (
      raw_user_meta_data->>'role' = 'admin'
      OR
      subscribers.cabinet IN (
        SELECT DISTINCT cabinet FROM workers 
        WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
      )
    )
  )
);

-- Similar policies for other tables
CREATE POLICY "Access_sync_pending_cabinets"
ON cabinets FOR SELECT USING (
  sync_status = 'sync_pending' 
  OR sync_status = 'conflict'
  AND EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND (
      raw_user_meta_data->>'role' = 'admin'
      OR
      cabinets.name IN (
        SELECT DISTINCT cabinet FROM workers 
        WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
      )
    )
  )
);

CREATE POLICY "Access_sync_pending_payments"
ON payments FOR SELECT USING (
  sync_status = 'sync_pending' 
  OR sync_status = 'conflict'
  AND EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND (
      raw_user_meta_data->>'role' = 'admin'
      OR
      payments.worker = (SELECT name FROM auth.users WHERE id = auth.uid())
    )
  )
);

-- Policies for conflict resolution with proper access controls
CREATE POLICY "Resolve_record_conflicts"
ON subscribers FOR UPDATE USING (
  sync_status = 'conflict'
  AND EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND (
      raw_user_meta_data->>'role' = 'admin'
      OR
      subscribers.cabinet IN (
        SELECT DISTINCT cabinet FROM workers 
        WHERE phone = (SELECT phone FROM auth.users WHERE id = auth.uid())
      )
    )
  )
) WITH CHECK (
  sync_status = 'synced'
);

-- Grant necessary permissions with enhanced security
GRANT ALL ON subscribers TO authenticated;
GRANT ALL ON cabinets TO authenticated;
GRANT ALL ON payments TO authenticated;
GRANT ALL ON workers TO authenticated;
GRANT ALL ON audit_log TO authenticated;
GRANT ALL ON whatsapp_templates TO authenticated;

GRANT USAGE ON SCHEMA public TO authenticated;

-- Additional functions for enhanced security and offline support
-- Function to check if user has access to a specific subscriber
CREATE OR REPLACE FUNCTION check_subscriber_access(subscriber_id INT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM subscribers s
    JOIN auth.users u ON true
    LEFT JOIN workers w ON w.phone = u.phone
    WHERE s.id = subscriber_id
    AND (
      u.raw_user_meta_data->>'role' = 'admin'
      OR s.cabinet IN (
        SELECT DISTINCT cabinet FROM workers 
        WHERE phone = u.phone
      )
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has access to a specific cabinet
CREATE OR REPLACE FUNCTION check_cabinet_access(cabinet_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM auth.users u
    WHERE (
      u.raw_user_meta_data->>'role' = 'admin'
      OR cabinet_name IN (
        SELECT DISTINCT cabinet FROM workers 
        WHERE phone = u.phone
      )
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;