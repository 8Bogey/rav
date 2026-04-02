import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
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
}

/// Auth0 Service for handling authentication
/// 
/// This service manages the Auth0 login flow and provides
/// the JWT token needed for Convex authentication.
class Auth0Service {
  static Auth0Service? _instance;
  static Auth0? _auth0;
  
  String? _accessToken;
  String? _idToken;
  String? _userId;
  
  Auth0Service._();
  
  static Auth0Service get instance {
    _instance ??= Auth0Service._();
    return _instance!;
  }
  
  /// Initialize Auth0
  Future<void> initialize() async {
    if (_auth0 != null) return;
    
    _auth0 = Auth0(
      Auth0Config.domain,
      Auth0Config.clientId,
    );
    
    debugPrint('[Auth0Service] Initialized with domain: ${Auth0Config.domain}');
  }
  
  /// Check if user is logged in
  bool get isAuthenticated => _accessToken != null;
  
  /// Get current user ID (from Auth0 subject)
  String? get userId => _userId;
  
  /// Get the JWT token for Convex authentication
  String? get accessToken => _accessToken;
  
  /// Login with Auth0
  /// 
  /// This opens the Auth0 Universal Login page in a browser.
  /// For desktop apps, we use the redirect URI scheme.
  Future<Auth0Result> login() async {
    if (_auth0 == null) {
      await initialize();
    }
    
    try {
      final credentials = await _auth0!.webAuthentication(
        scheme: 'mawlid',
      ).login(
        audience: Auth0Config.audience,
      );
      
      _accessToken = credentials.accessToken;
      _idToken = credentials.idToken;
      _userId = credentials.user.sub;
      
      // Save tokens for persistence
      await _saveTokens();
      
      debugPrint('[Auth0Service] Login successful, userId: $_userId');
      
      return Auth0Result(
        success: true,
        userId: _userId,
        accessToken: _accessToken,
      );
    } catch (e) {
      debugPrint('[Auth0Service] Login error: $e');
      return Auth0Result(
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Logout from Auth0
  Future<void> logout() async {
    if (_auth0 == null) return;
    
    try {
      await _auth0!.webAuthentication(
        scheme: 'mawlid',
      ).logout();
      
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
        
        // Try to refresh the token silently
        // For now, just verify the token exists
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
  
  Auth0Result({
    required this.success,
    this.userId,
    this.accessToken,
    this.error,
  });
}
