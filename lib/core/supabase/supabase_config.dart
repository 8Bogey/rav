/// Supabase configuration
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xmazwuoinhpgmydfoovj.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhtYXp3dW9pbmhwZ215ZGZvb3ZqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjYxNjUsImV4cCI6MjA5MDMwMjE2NX0.MaK_Oh5gmxALkqzVJEvrwSAa4NVEQar_G5lZw5ZAYSA',
  );
  
  // Table names in Supabase
  static const String cabinetsTable = 'cabinets';
  static const String subscribersTable = 'subscribers';
  static const String paymentsTable = 'payments';
  static const String workersTable = 'workers';
  static const String auditLogTable = 'audit_log';
  static const String whatsappTemplatesTable = 'whatsapp_templates';
}