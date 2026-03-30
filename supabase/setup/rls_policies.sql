-- Row Level Security (RLS) Policies for Supabase Database
-- These policies control access to data based on user roles and permissions

-- Enable RLS on all tables
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cabinets ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_templates ENABLE ROW LEVEL SECURITY;

-- Create roles (if not already created)
-- NOTE: Roles should be created in Supabase dashboard or via their auth system
-- For this application, we assume:
-- 1. Admin users have 'admin' in their app_metadata->>role
-- 2. Worker users have 'worker' in their app_metadata->>role
-- 3. Users are authenticated via Supabase Auth

-- Subscribers Table Policies
-- Admins can access all subscribers
CREATE POLICY "Admins can access all subscribers" 
ON subscribers FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can access subscribers in their assigned cabinets
CREATE POLICY "Workers can access assigned subscribers" 
ON subscribers FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM auth.users u
    JOIN workers w ON u.email = w.phone || '@example.com'  -- Assuming worker email mapping
    WHERE u.id = auth.uid() 
    AND w.name = auth.jwt()->>'worker_name'
    AND subscribers.cabinet IN (
      SELECT cabinet FROM workers WHERE name = auth.jwt()->>'worker_name'
    )
  )
);

-- Cabinets Table Policies
-- Admins can access all cabinets
CREATE POLICY "Admins can access all cabinets" 
ON cabinets FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can access their assigned cabinets
CREATE POLICY "Workers can access assigned cabinets" 
ON cabinets FOR SELECT USING (
  cabinets.id IN (
    SELECT c.id FROM cabinets c
    JOIN workers w ON c.name = w.name  -- Assuming cabinet name matches worker name for assignment
    WHERE w.phone IN (
      SELECT phone FROM workers WHERE name = auth.jwt()->>'worker_name'
    )
  )
);

-- Payments Table Policies
-- Admins can access all payments
CREATE POLICY "Admins can access all payments" 
ON payments FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Workers can access payments they've collected
CREATE POLICY "Workers can access their payments" 
ON payments FOR SELECT USING (
  payments.worker = auth.jwt()->>'worker_name'
);

-- Workers Table Policies
-- Admins can access all workers
CREATE POLICY "Admins can access all workers" 
ON workers FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Everyone can view worker information (read-only)
CREATE POLICY "Anyone can view workers" 
ON workers FOR SELECT USING (true);

-- Audit Log Table Policies
-- Only admins can access audit logs
CREATE POLICY "Only admins can access audit logs" 
ON audit_log FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- WhatsApp Templates Table Policies
-- Admins can manage all templates
CREATE POLICY "Admins can manage all templates" 
ON whatsapp_templates FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Users can view active templates
CREATE POLICY "Users can view active templates" 
ON whatsapp_templates FOR SELECT USING (
  is_active = 1
);

-- Grant necessary permissions
GRANT ALL ON subscribers TO authenticated;
GRANT ALL ON cabinets TO authenticated;
GRANT ALL ON payments TO authenticated;
GRANT ALL ON workers TO authenticated;
GRANT ALL ON audit_log TO authenticated;
GRANT ALL ON whatsapp_templates TO authenticated;

GRANT USAGE ON SCHEMA public TO authenticated;