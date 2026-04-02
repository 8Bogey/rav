import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, Process, HttpServer, InternetAddress, HttpRequest;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:math';

/// Auth0 Configuration
/// 
/// These values come from Auth0 dashboard.
/// - Domain: dev-cqkioj1eiksobor3.us.auth0.com
/// - Client ID: DqcGcBSR8ETDelWq9SRENnQOZsj7TTSB
/// - Audience: The Convex deployment URL (for JWT token generation)
class Auth0Config {
  static const String domain = 'dev-cqkioj1eiksobor3.us.auth0.com';
  static const String clientId = 'DqcGcBSR8ETDelWq9SRENnQOZsj7TTSB';
  
  // Remove audience - not required for basic auth
  // Can add back once API is created in Auth0
  static const String? audience = null; // 'https://hearty-meadowlark-390.convex.cloud' - requires API setup in Auth0
  
  // Callback URL for Native app
  static const String redirectUri = 'http://127.0.0.1:5173/callback';
  
  // Auth0 URLs
  static const String tokenUrl = 'https://$domain/oauth/token';
  static const String loginUrl = 'https://$domain/authorize';
}

/// Generate random string for PKCE (only unreserved characters)
String _generateRandomString(int length) {
  // Use only unreserved characters: A-Z, a-z, 0-9, -, _, ., ~
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

/// Generate code verifier for PKCE (43-128 characters, only unreserved)
String _generateCodeVerifier() {
  return _generateRandomString(128);
}

/// Generate code challenge from verifier
String _generateCodeChallenge(String codeVerifier) {
  final bytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(bytes);
  // Use base64Url encoding without padding, then make URL safe
  return base64Url.encode(digest.bytes)
      .replaceAll('+', '-')
      .replaceAll('/', '_')
      .replaceAll('=', '');
}

/// Auth0 Service for handling authentication
/// 
/// Uses PKCE flow with local callback server for desktop apps.
class Auth0Service {
  static Auth0Service? _instance;
  HttpServer? _callbackServer;
  String? _codeVerifier;
  Completer<String?>? _authCodeCompleter;
  
  String? _accessToken;
  String? _idToken;
  String? _userId;
  
  Auth0Service._();
  
  static Auth0Service get instance {
    _instance ??= Auth0Service._();
    return _instance!;
  }
  
  /// Initialize Auth0 service
  Future<void> initialize() async {
    debugPrint('[Auth0Service] Initialized with PKCE flow');
  }
  
  /// Check if user is logged in
  bool get isAuthenticated => _accessToken != null;
  
  /// Get current user ID (from Auth0 subject)
  String? get userId => _userId;
  
  /// Get the JWT token for Convex authentication
  String? get accessToken => _accessToken;
  
  /// Login with Auth0 using PKCE flow
  Future<Auth0Result> login() async {
    try {
      // Generate PKCE values
      _codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(_codeVerifier!);
      
      // Build the authorization URL with PKCE
      final Map<String, String> queryParams = {
        'response_type': 'code',
        'client_id': Auth0Config.clientId,
        'redirect_uri': Auth0Config.redirectUri,
        'scope': 'openid profile email',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'state': _generateRandomString(32),
      };
      
      // Add audience only if configured (requires API in Auth0)
      if (Auth0Config.audience != null) {
        queryParams['audience'] = Auth0Config.audience!;
      }
      
      final authUrl = Uri.parse(Auth0Config.loginUrl).replace(
        queryParameters: queryParams,
      );
      
      debugPrint('[Auth0Service] Starting PKCE flow, callback: ${Auth0Config.redirectUri}');
      
      // Start local callback server
      final server = await _startCallbackServer();
      _callbackServer = server;
      
      // Open browser for login
      if (await canLaunchUrl(authUrl)) {
        await launchUrl(authUrl);
        debugPrint('[Auth0Service] Opened Auth0 login page');
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', authUrl.toString()]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [authUrl.toString()]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [authUrl.toString()]);
      }
      
      // Wait for callback with timeout
      final authCode = await _waitForCallback(timeoutSeconds: 120);
      
      // Stop server
      await _stopCallbackServer();
      
      if (authCode == null) {
        return Auth0Result(
          success: false,
          error: 'انتهت مهلة تسجيل الدخول. يرجى المحاولة مرة أخرى.',
          fallbackToDemo: true,
        );
      }
      
      // Exchange code for tokens
      return await _exchangeCodeForTokens(authCode);
      
    } catch (e) {
      debugPrint('[Auth0Service] Login error: $e');
      await _stopCallbackServer();
      return Auth0Result(
        success: false,
        error: 'خطأ في تسجيل الدخول: $e',
        fallbackToDemo: true,
      );
    }
  }
  
  /// Start local server to receive callback
  Future<HttpServer> _startCallbackServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 5173);
    server.listen(_handleCallbackRequest);
    debugPrint('[Auth0Service] Callback server started on port 5173');
    return server;
  }
  
  /// Handle incoming callback request
  void _handleCallbackRequest(HttpRequest request) async {
    final uri = request.uri;
    debugPrint('[Auth0Service] Received callback: ${uri.query}');
    
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    
    if (code != null) {
      _authCodeCompleter?.complete(code);
    } else if (error != null) {
      _authCodeCompleter?.completeError(Exception(error));
    }
    
    // Send response to close the window
    request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
    request.response.write('''
      <html>
        <head><title>تم تسجيل الدخول</title></head>
        <body>
          <h2>تم تسجيل الدخول بنجاح!</h2>
          <p>يمكنك إغلاق هذه النافذة والعودة للتطبيق.</p>
          <script>setTimeout(() => window.close(), 2000);</script>
        </body>
      </html>
    ''');
    await request.response.close();
  }
  
  /// Wait for authorization code
  Future<String?> _waitForCallback({int timeoutSeconds = 120}) async {
    _authCodeCompleter = Completer<String?>();
    
    try {
      return await _authCodeCompleter!.future.timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          debugPrint('[Auth0Service] Callback timeout');
          return null;
        },
      );
    } catch (e) {
      debugPrint('[Auth0Service] Callback error: $e');
      return null;
    }
  }
  
  /// Stop callback server
  Future<void> _stopCallbackServer() async {
    if (_callbackServer != null) {
      await _callbackServer!.close(force: true);
      _callbackServer = null;
      debugPrint('[Auth0Service] Callback server stopped');
    }
  }
  
  /// Exchange authorization code for tokens
  Future<Auth0Result> _exchangeCodeForTokens(String code) async {
    try {
      // For demo purposes, we'll simulate successful token exchange
      // In production, you'd make an HTTP POST to Auth0 token endpoint
      
      // Generate mock tokens for demo
      _accessToken = 'auth0-token-${DateTime.now().millisecondsSinceEpoch}';
      _idToken = 'id-token-${DateTime.now().millisecondsSinceEpoch}';
      _userId = 'auth0-user-${DateTime.now().millisecondsSinceEpoch}';
      
      // Save tokens
      await _saveTokens();
      
      debugPrint('[Auth0Service] Token exchange successful, userId: $_userId');
      
      return Auth0Result(
        success: true,
        userId: _userId,
        accessToken: _accessToken,
      );
    } catch (e) {
      debugPrint('[Auth0Service] Token exchange error: $e');
      return Auth0Result(
        success: false,
        error: 'فشل في استبدال الرمز: $e',
      );
    }
  }
  
  /// Set token directly (for testing)
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
        final uri = Uri.parse(logoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else if (Platform.isWindows) {
          await Process.run('cmd', ['/c', 'start', '', logoutUrl]);
        }
      } catch (_) {
        // Ignore errors
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
