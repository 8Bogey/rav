# Environment Variable Configuration

This guide explains how to configure environment variables for the Supabase integration.

## Required Environment Variables

The application requires two environment variables:

1. `SUPABASE_URL` - The URL of your Supabase project
2. `SUPABASE_ANON_KEY` - The anonymous key for your Supabase project

## Finding Your Supabase Credentials

### In Supabase Dashboard

1. Go to your Supabase project dashboard
2. Click on the "Settings" icon (gear) in the left sidebar
3. Navigate to "API" section
4. Copy the following values:
   - **Project URL**: This is your `SUPABASE_URL`
   - **anon key**: This is your `SUPABASE_ANON_KEY`

## Configuration Methods

### Method 1: Environment Files (.env)

Create a `.env` file in your project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Note: Add `.env` to your `.gitignore` file to prevent exposing credentials.

### Method 2: Flutter Configuration

In your Flutter app, create a configuration file:

```dart
// lib/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );
}
```

Then run your app with:
```bash
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### Method 3: Build Configuration

For release builds, add to your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

And load the environment variables programmatically.

## Testing the Configuration

### Verify Connection

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void testSupabaseConnection() async {
  try {
    final supabase = Supabase.instance.client;
    
    // Test a simple query
    final result = await supabase
        .from('subscribers')
        .select('count')
        .limit(1);
    
    print('Connection successful: ${result.length} records found');
  } catch (e) {
    print('Connection failed: $e');
  }
}
```

### Common Issues

1. **Invalid URL**: Make sure the URL includes `https://` and ends with `.supabase.co`
2. **Wrong key**: Double-check that you're using the anon key, not the service role key
3. **Network issues**: Ensure your app can reach the Supabase servers

## Security Best Practices

1. **Never hardcode credentials** in source code
2. **Use different keys** for development and production
3. **Rotate keys regularly** for security
4. **Restrict key permissions** when possible
5. **Monitor API usage** for unusual activity

## Development vs Production

### Development
```env
SUPABASE_URL=https://your-dev-project.supabase.co
SUPABASE_ANON_KEY=dev-anon-key
```

### Production
```env
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=prod-anon-key
```

## CI/CD Integration

For automated deployments, set environment variables in your CI/CD pipeline:

### GitHub Actions
```yaml
- name: Deploy to Firebase
  env:
    SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
    SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
  run: flutter build web
```

### GitLab CI
```yaml
deploy:
  stage: deploy
  script:
    - export SUPABASE_URL=$SUPABASE_URL
    - export SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
    - flutter build web
```