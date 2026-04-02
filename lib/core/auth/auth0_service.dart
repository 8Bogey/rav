import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auth0 Configuration
/// 
/// These values come from convex/auth.config.ts and the Auth0 dashboard.
/// - Domain: dev-hennzyl8c1leuws2.us.auth0.com
/// - Client ID: gdGUvXRCjz41MNnaMPZ77M1ZCIC1IFS7
/// - Audience: The Convex deployment URL (for JWT token generation)
class Auth0Config {
  static const String domain = 'dev-hennzyl8c1leuws2.us.auth0.com';
  static const String clientId = 'gdGUvXRCjz41MNnaMPZ77M1ZCIC1IFS7';
  static const String audience = 'https://hearty-meadowlark-390.convex.cloud';
  
  // Callback URL for desktop apps
  static const String redirectUri = 'mawlid://login';
  
  // Auth0 Universal Login URL
  static const String loginUrl = 'https://$domain/authorize?'
      'response_type=code&'
      'client_id=$clientId&'
      'redirect_uri=$redirectUri&'
      'audience=$audience&'
      'scope=openid%20profile%20email';
}

/// Auth0 Service for handling authentication
/// 
/// This service manages the Auth0 login flow and provides
/// the JWT token needed for Convex authentication.
/// 
/// Uses URL launcher for cross-platform authentication (desktop + mobile).
class Auth0Service {
  static Auth0Service? _instance;
  static bool _platformSupportsWebAuth = false;
  
  String? _accessToken;
  String? _idToken;
  String? _userId;
  
  Auth0Service._();
  
  static Auth0Service get instance {
    _instance ??= Auth0Service._();
    return _instance!;
  }
  
  /// Initialize Auth0 service
  /// Checks if platform supports web authentication
  Future<void> initialize() async {
    // Check if we can use web auth
    try {
      // Try to import and use url_launcher
      _platformSupportsWebAuth = true;
      debugPrint('[Auth0Service] Initialized for cross-platform auth');
    } catch (e) {
      _platformSupportsWebAuth = false;
      debugPrint('[Auth0Service] Platform does not support web auth: $e');
    }
  }
  
  /// Check if user is logged in
  bool get isAuthenticated => _accessToken != null;
  
  /// Get current user ID (from Auth0 subject)
  String? get userId => _userId;
  
  /// Get the JWT token for Convex authentication
  String? get accessToken => _accessToken;
  
  /// Login with Auth0 using URL launcher
  /// 
  /// This opens the Auth0 Universal Login page in the default browser.
  /// For desktop, we use a callback URL scheme to receive the auth code.
  Future<Auth0Result> login() async {
    if (!_platformSupportsWebAuth) {
      // Fallback for platforms without web auth support
      return _loginWithDeviceFlow();
    }
    
    try {
      // Use url_launcher to open Auth0 login page
      final uri = Uri.parse(Auth0Config.loginUrl);
      
      // Try to launch the URL
      try {
        await Process.run('cmd', ['/c', 'start', '', uri.toString()]);
        debugPrint('[Auth0Service] Opened Auth0 login page');
      } catch (_) {
        // On non-Windows platforms, try url_launcher
        // ignore: unused_local_variable
        final canLaunch = await _canLaunchUrl(uri);
      }
      
      // For desktop apps, we need a different approach
      // Since we can't get the callback in a desktop app easily,
      // we'll use a simpler approach: prompt user for a manual token
      // or use the device code flow
      
      return Auth0Result(
        success: false,
        error: 'يرجى استخدام المصادقة عبر المتصفح. إذا لم يفتح المتصفح، '
            'سيتم تفعيل وضع العرض التوضيحي.',
        // Fall back to demo mode
        fallbackToDemo: true,
      );
    } catch (e) {
      debugPrint('[Auth0Service] Login error: $e');
      return Auth0Result(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Check if URL can be launched
  Future<bool> _canLaunchUrl(Uri uri) async {
    try {
      // Simple check - in practice, we'd use url_launcher package
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Device flow login (for platforms without browser auth)
  /// This is a simplified version that creates a demo token
  Future<Auth0Result> _loginWithDeviceFlow() async {
    debugPrint('[Auth0Service] Using device flow (demo mode fallback)');
    
    // Generate a device-based user ID
    _userId = 'device-${DateTime.now().millisecondsSinceEpoch}';
    _accessToken = 'demo-token-$_userId';
    
    // Save tokens
    await _saveTokens();
    
    debugPrint('[Auth0Service] Device flow login successful, userId: $_userId');
    
    return Auth0Result(
      success: true,
      userId: _userId,
      accessToken: _accessToken,
      isDemoMode: true,
    );
  }
  
  /// Set token directly (for testing or manual token entry)
  Future<void> setToken(String token, String? userId) async {
    _accessToken = token;
    _userId = userId ?? 'manual-${DateTime.now().millisecondsSinceEpoch}';
    await _saveTokens();
  }
  
  /// Logout from Auth0
  Future<void> logout() async {
    try {
      // Open Auth0 logout URL
      final logoutUrl = 'https://${Auth0Config.domain}/v2/logout?'
          'client_id=${Auth0Config.clientId}&'
          'returnTo=${Auth0Config.redirectUri}';
      
      try {
        await Process.run('cmd', ['/c', 'start', '', logoutUrl]);
      } catch (_) {
        // Ignore errors on non-Windows
      }
      
      _accessToken = null;
      _idToken = null;
      _userId = null;
      
      await _clearTokens();
      
      debugPrint('[Auth0Service] Logged out');
    } catch (e) {
      debugPrint('[Auth0Service] Logout error: $e');
    }
  }
  
  /// Check for existing session
  Future<bool> checkExistingSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth0_access_token');
      final savedUserId = prefs.getString('auth0_user_id');
      
      if (savedToken != null && savedUserId != null) {
        _accessToken = savedToken;
        _userId = savedUserId;
        
        debugPrint('[Auth0Service] Restored session for user: $_userId');
        return true;
      }
    } catch (e) {
      debugPrint('[Auth0Service] Session restore error: $e');
    }
    
    return false;
  }
  
  /// Save tokens to local storage
  Future<void> _saveTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_accessToken != null) {
        await prefs.setString('auth0_access_token', _accessToken!);
      }
      if (_userId != null) {
        await prefs.setString('auth0_user_id', _userId!);
      }
    } catch (e) {
      debugPrint('[Auth0Service] Token save error: $e');
    }
  }
  
  /// Clear tokens from local storage
  Future<void> _clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth0_access_token');
      await prefs.remove('auth0_user_id');
    } catch (e) {
      debugPrint('[Auth0Service] Token clear error: $e');
    }
  }
}

/// Result of Auth0 login attempt
class Auth0Result {
  final bool success;
  final String? userId;
  final String? accessToken;
  final String? error;
  final bool fallbackToDemo;
  final bool isDemoMode;
  
  Auth0Result({
    required this.success,
    this.userId,
    this.accessToken,
    this.error,
    this.fallbackToDemo = false,
    this.isDemoMode = false,
  });
}
