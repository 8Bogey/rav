# Supabase Authentication Setup

This guide explains how to configure Supabase Authentication for the offline-first application.

## Overview

The application uses Supabase Auth for user authentication with two primary roles:
- **Admin**: Full access to all data and features
- **Worker**: Limited access based on assignments

## Setup Steps

### 1. Enable Authentication

1. Go to your Supabase project dashboard
2. Navigate to "Authentication" → "Providers"
3. Enable Email authentication
4. Optionally enable other providers (Google, GitHub, etc.)

### 2. Configure User Roles

The application expects user roles to be stored in user metadata:

1. In the Supabase dashboard, go to "Authentication" → "Users"
2. For admin users, add the following to their user metadata:
   ```json
   {
     "role": "admin"
   }
   ```

3. For worker users, add the following to their user metadata:
   ```json
   {
     "role": "worker"
   }
   ```

### 3. Set Up Custom Claims (JWT)

To make roles available in JWT claims:

1. Go to "Authentication" → "Settings"
2. Under "JWT Settings", add custom claims:
   ```sql
   -- Get user role from raw_user_meta_data
   CLAIM role AS (raw_user_meta_data->>'role')
   ```

### 4. Configure Email Templates (Optional)

Customize email templates for better user experience:

1. Go to "Authentication" → "Templates"
2. Customize:
   - Confirmation email template
   - Password recovery template
   - Email change template

## Role-Based Access Control

### Admin Users
- Full access to all tables
- Can manage all subscribers, cabinets, payments
- Access to audit logs
- Can manage WhatsApp templates

### Worker Users
- Limited access based on assignments
- Can only view subscribers in their assigned cabinets
- Can only view payments they've collected
- Read-only access to worker information
- Can view active WhatsApp templates

## Testing Authentication

### Using Supabase Client

```dart
// Sign up a new user
final response = await supabase.auth.signUp(
  email: 'admin@example.com',
  password: 'secure-password',
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: 'admin@example.com',
  password: 'secure-password',
);

// Get user session
final session = supabase.auth.currentSession;
```

### Checking User Roles

```dart
// Get current user
final user = supabase.auth.currentUser;

// Check if user is admin
final isAdmin = user?.userMetadata?['role'] == 'admin';

// Check if user is worker
final isWorker = user?.userMetadata?['role'] == 'worker';
```

## Security Considerations

1. **Always use Row Level Security (RLS)** - Enabled by default in schema
2. **Validate user roles on both client and server**
3. **Use secure passwords** for all accounts
4. **Regularly review user permissions**
5. **Enable multi-factor authentication** for admin accounts

## Troubleshooting

### Common Issues

1. **User can't access data**: Check user role in metadata
2. **RLS policies not working**: Ensure RLS is enabled on tables
3. **JWT claims missing**: Verify custom claims configuration

### Debugging Tips

1. Check user metadata in Supabase dashboard
2. Test RLS policies using Supabase SQL editor
3. Verify JWT contents using online decoder tools