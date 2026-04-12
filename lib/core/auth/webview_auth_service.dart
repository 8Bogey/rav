import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpServer, InternetAddress, HttpRequest, HttpStatus;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/services/secure_storage_service.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'dart:math';

/// Auth0 Configuration
/// Values loaded from environment variables in debug mode, with production fallbacks.
/// In production, these should be set via environment or configuration management.
class Auth0Config {
  static const String _defaultDomain = 'dev-cqkioj1eiksobor3.us.auth0.com';
  static const String _defaultClientId = 'DqcGcBSR8ETDelWq9SRENnQOZsj7TTSB';
  static const String _defaultAudience =
      'https://hearty-meadowlark-390.convex.cloud';

  static String get domain {
    if (kDebugMode) {
      return String.fromEnvironment(
        'AUTH0_DOMAIN',
        defaultValue: _defaultDomain,
      );
    }
    return _defaultDomain;
  }

  static String get clientId {
    if (kDebugMode) {
      return String.fromEnvironment(
        'AUTH0_APPLICATION_ID',
        defaultValue: _defaultClientId,
      );
    }
    return _defaultClientId;
  }

  static String get audience {
    if (kDebugMode) {
      return String.fromEnvironment(
        'AUTH0_AUDIENCE',
        defaultValue: _defaultAudience,
      );
    }
    return _defaultAudience;
  }

  static const String redirectUri = 'http://127.0.0.1:8899/callback';
  static const String logoutRedirectUri = 'urn:ietf:wg:oauth:2.0:oob';
  static String get tokenUrl => 'https://$domain/oauth/token';
  static String get loginUrl => 'https://$domain/authorize';
}

/// Generate random string for PKCE
String _generateRandomString(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)])
      .join();
}

/// Generate code verifier for PKCE
String _generateCodeVerifier() {
  return _generateRandomString(128);
}

/// Generate code challenge from verifier
String _generateCodeChallenge(String codeVerifier) {
  final bytes = utf8.encode(codeVerifier);
  final digest = sha256.convert(bytes);
  return base64Url
      .encode(digest.bytes)
      .replaceAll('+', '-')
      .replaceAll('/', '_')
      .replaceAll('=', '');
}

/// Result of Auth0 login attempt
class WebViewAuthResult {
  final bool success;
  final String? userId;
  final String? accessToken;
  final String? error;
  final bool fallbackToDemo;
  final String? role;
  final List<String> permissions;
  final String? email;
  final String? name;
  final String? picture;

  WebViewAuthResult({
    required this.success,
    this.userId,
    this.accessToken,
    this.error,
    this.fallbackToDemo = false,
    this.role,
    this.permissions = const [],
    this.email,
    this.name,
    this.picture,
  });
}

/// Auth0 Service using WebView for in-app login
class WebViewAuthService {
  static WebViewAuthService? _instance;
  String? _accessToken;
  String? _idToken;
  String? _userId;
  String? _refreshToken;
  String? _email;
  String? _name;
  String? _picture;
  String? _role;
  List<String> _permissions = [];

  // HTTP Server for OAuth callback
  HttpServer? _callbackServer;
  int _callbackPort = 8899;
  Completer<String?>? _authCodeCompleter;
  String? _codeVerifier;
  String? _currentAuthState; // OAuth state for CSRF protection

  WebViewAuthService._();

  static WebViewAuthService get instance {
    _instance ??= WebViewAuthService._();
    return _instance!;
  }

  bool get isAuthenticated => _accessToken != null;
  String? get userId => _userId;
  String? get accessToken => _accessToken;
  String? get email => _email;
  String? get name => _name;
  String? get picture => _picture;
  String? get role => _role;
  List<String> get permissions => List.unmodifiable(_permissions);

  /// Decode JWT and extract claims
  Map<String, dynamic>? _decodeIdTokenClaims(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      final paddedLength = (4 - payload.length % 4) % 4;
      final paddedPayload = payload + ('=' * paddedLength);
      final decoded = utf8.decode(base64Url.decode(paddedPayload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save tokens to secure storage
  Future<void> _saveTokens() async {
    final storage = SecureStorageService.instance;
    if (_accessToken != null) {
      await storage.setAccessToken(_accessToken!);
    }
    if (_refreshToken != null) {
      await storage.setRefreshToken(_refreshToken!);
    }
    if (_userId != null) {
      await storage.setUserId(_userId!);
    }
  }

  /// Start local HTTP server to receive OAuth callback
  Future<HttpServer> _startCallbackServer() async {
    final portsToTry = [8899, 9999, 9998, 9997, 0];

    for (final port in portsToTry) {
      try {
        final server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          port,
        );
        server.listen(_handleCallbackRequest);
        _callbackPort = server.port;
        print(
            '[WebViewAuth] Callback server listening on 127.0.0.1:$_callbackPort');
        return server;
      } catch (e) {
        print('[WebViewAuth] Failed to bind to port $port: $e');
        continue;
      }
    }

    throw Exception('Could not start callback server on any available port');
  }

  /// Handle incoming callback request from Auth0
  void _handleCallbackRequest(HttpRequest request) async {
    final uri = request.uri;
    print('[WebViewAuth] Received callback: ${uri.query}');

    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    final receivedState = uri.queryParameters['state'];

    // Validate state to prevent CSRF attacks
    if (receivedState == null || receivedState != _currentAuthState) {
      print('[WebViewAuth] State mismatch - possible CSRF attack');
      request.response.statusCode = HttpStatus.badRequest;
      request.response.headers.set('Content-Type', 'text/html; charset=utf-8');
      request.response.write('<h1>Error: Invalid state parameter</h1>');
      await request.response.close();
      _authCodeCompleter
          ?.completeError(Exception('State mismatch - possible CSRF attack'));
      return;
    }

    if (code != null) {
      _authCodeCompleter?.complete(code);
    } else if (error != null) {
      _authCodeCompleter?.completeError(Exception(error));
    }

    // Send HTML response to close the window nicely
    request.response.headers.set('Content-Type', 'text/html; charset=utf-8');

    const htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>تم تسجيل الدخول</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 40px;
      background: rgba(255,255,255,0.1);
      border-radius: 20px;
      backdrop-filter: blur(10px);
    }
    h1 { font-size: 28px; margin-bottom: 10px; }
    p { font-size: 16px; opacity: 0.9; }
  </style>
</head>
<body>
  <div class="container">
    <h1>تم تسجيل الدخول بنجاح! ✓</h1>
    <p>جاري التحويل إلى التطبيق...</p>
  </div>
</body>
</html>
''';

    request.response.write(htmlContent);
    await request.response.close();
  }

  /// Stop callback server
  Future<void> _stopCallbackServer() async {
    if (_callbackServer != null) {
      await _callbackServer!.close(force: true);
      _callbackServer = null;
      print('[WebViewAuth] Callback server stopped');
    }
  }

  /// Login using WebView - opens popup within the app
  Future<WebViewAuthResult> login({String? connection}) async {
    try {
      // Start local callback server FIRST (before opening WebView)
      _callbackServer = await _startCallbackServer();

      // Generate PKCE values
      _codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(_codeVerifier!);

      // Generate and store state for CSRF protection
      _currentAuthState = _generateRandomString(32);

      // Build authorization URL with dynamic port
      final dynamicRedirectUri = 'http://127.0.0.1:$_callbackPort/callback';
      final Map<String, String> queryParams = {
        'response_type': 'code',
        'client_id': Auth0Config.clientId,
        'redirect_uri': dynamicRedirectUri,
        'audience': Auth0Config.audience,
        'scope': 'openid profile email offline_access',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
        'state': _currentAuthState!,
        'prompt': 'login',
      };

      if (connection != null && connection.isNotEmpty) {
        queryParams['connection'] = connection;
      }

      final authUrl = Uri.parse(Auth0Config.loginUrl).replace(
        queryParameters: queryParams,
      );

      print('[WebViewAuth] Opening login URL: $authUrl');
      print('[WebViewAuth] Callback will be at: $dynamicRedirectUri');

      // Create completer for the auth code
      _authCodeCompleter = Completer<String?>();

      // Open WebView window with configuration
      Webview webview;
      try {
        webview = await WebviewWindow.create(
          configuration: CreateConfiguration(
            windowWidth: 500,
            windowHeight: 700,
            title: 'تسجيل الدخول - Smart Gen',
          ),
        );
      } catch (e) {
        print('[WebViewAuth] Failed to create WebView: $e');
        await _stopCallbackServer();
        return WebViewAuthResult(
          success: false,
          error: 'تعذر فتح نافذة تسجيل الدخول: $e',
          fallbackToDemo: true,
        );
      }

      // Set up URL callback listener to detect OAuth redirect
      webview.addOnUrlRequestCallback((url) {
        final uri = Uri.parse(url);
        // Detect callback URL with auth code
        if (uri.host == '127.0.0.1' &&
            uri.path == '/callback' &&
            uri.queryParameters.containsKey('code')) {
          // Validate state to prevent CSRF attacks
          final receivedState = uri.queryParameters['state'];
          if (receivedState == null || receivedState != _currentAuthState) {
            print(
                '[WebViewAuth] State mismatch in WebView callback - possible CSRF attack');
            _authCodeCompleter?.completeError(
                Exception('State mismatch - possible CSRF attack'));
            webview.close();
            return;
          }

          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];

          if (code != null) {
            print('[WebViewAuth] Captured auth code from URL callback');
            _authCodeCompleter?.complete(code);
          } else if (error != null) {
            print('[WebViewAuth] Auth error from URL callback: $error');
            _authCodeCompleter?.completeError(Exception(error));
          }

          // Close WebView immediately after capturing
          webview.close();
        }
      });

      // Handle case where user closes WebView without completing login
      webview.onClose.whenComplete(() {
        if (!_authCodeCompleter!.isCompleted) {
          print('[WebViewAuth] WebView closed by user');
          _authCodeCompleter?.complete(null);
        }
      });

      // Launch Auth0 login page in WebView
      webview.launch(authUrl.toString());

      // Wait for the auth code (with timeout)
      String? authCode;
      try {
        authCode = await _authCodeCompleter!.future.timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            print('[WebViewAuth] Callback timeout');
            return null;
          },
        );
      } catch (e) {
        print('[WebViewAuth] Error during login: $e');
        await _stopCallbackServer();
        return WebViewAuthResult(
          success: false,
          error: e.toString(),
          fallbackToDemo: true,
        );
      }

      // Stop the callback server
      await _stopCallbackServer();

      if (authCode == null) {
        return WebViewAuthResult(
          success: false,
          error: 'انتهت مهلة تسجيل الدخول. يرجى المحاولة مرة أخرى.',
          fallbackToDemo: true,
        );
      }

      print('[WebViewAuth] Received auth code, exchanging for tokens...');

      // Exchange code for tokens
      return await _exchangeCodeForTokens(
          authCode, _codeVerifier!, dynamicRedirectUri);
    } catch (e) {
      print('[WebViewAuth] Login error: $e');
      await _stopCallbackServer();
      return WebViewAuthResult(
        success: false,
        error: 'خطأ في تسجيل الدخول: $e',
        fallbackToDemo: true,
      );
    }
  }

  /// Login via Auth0 Resource Owner Password Credentials (ROPC) grant.
  /// Direct email/password authentication — no WebView popup needed.
  ///
  /// Requires "Resource Owner" grant type enabled in Auth0 dashboard.
  /// Only works with Database connections (Username-Password-Authentication).
  Future<WebViewAuthResult> loginWithROPC({
    required String email,
    required String password,
  }) async {
    try {
      print('[WebViewAuth] ROPC login attempt for: $email');

      final response = await http.post(
        Uri.parse(Auth0Config.tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': email,
          'password': password,
          'audience': Auth0Config.audience,
          'scope': 'openid profile email offline_access',
          'client_id': Auth0Config.clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _idToken = data['id_token'];
        _refreshToken = data['refresh_token'];

        // Decode ID token claims
        if (_idToken != null) {
          final claims = _decodeIdTokenClaims(_idToken!);
          if (claims != null) {
            _userId = claims['sub'];
            _email = claims['email'];
            _name = claims['name'];
            _picture = claims['picture'];
            _role = claims['https://mawlid-al-dhaki.com/role'] as String? ??
                claims['role'] as String?;
            final permsRaw =
                claims['https://mawlid-al-dhaki.com/permissions'] ??
                    claims['permissions'];
            if (permsRaw is List) {
              _permissions = permsRaw.map((e) => e.toString()).toList();
            }
          }
        }

        // Save tokens
        await _saveTokens();

        // Set Convex auth
        if (_accessToken != null) {
          await AppConvexConfig.setAuth(_accessToken!);
        }

        print('[WebViewAuth] ROPC login successful for user: $_userId');

        return WebViewAuthResult(
          success: true,
          userId: _userId,
          accessToken: _accessToken,
          role: _role,
          permissions: _permissions,
          email: _email,
          name: _name,
          picture: _picture,
        );
      } else {
        print('[WebViewAuth] ROPC token exchange failed: ${response.body}');
        String errorMessage;
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error_description'] ??
              errorData['error'] ??
              'Authentication failed';
        } catch (_) {
          errorMessage =
              'Authentication failed (status ${response.statusCode})';
        }
        return WebViewAuthResult(
          success: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      print('[WebViewAuth] ROPC login error: $e');
      return WebViewAuthResult(
        success: false,
        error: 'خطأ في تسجيل الدخول: $e',
      );
    }
  }

  /// Exchange authorization code for tokens
  Future<WebViewAuthResult> _exchangeCodeForTokens(
    String authCode,
    String codeVerifier,
    String redirectUri,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(Auth0Config.tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'client_id': Auth0Config.clientId,
          'code': authCode,
          'code_verifier': codeVerifier,
          'redirect_uri': redirectUri,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _idToken = data['id_token'];
        _refreshToken = data['refresh_token'];

        // Decode ID token claims
        if (_idToken != null) {
          final claims = _decodeIdTokenClaims(_idToken!);
          if (claims != null) {
            _userId = claims['sub'];
            _email = claims['email'];
            _name = claims['name'];
            _picture = claims['picture'];
            _role = claims['https://mawlid-al-dhaki.com/role'] as String? ??
                claims['role'] as String?;
            final permsRaw =
                claims['https://mawlid-al-dhaki.com/permissions'] ??
                    claims['permissions'];
            if (permsRaw is List) {
              _permissions = permsRaw.map((e) => e.toString()).toList();
            }
          }
        }

        // Save tokens
        await _saveTokens();

        // Set Convex auth
        if (_accessToken != null) {
          await AppConvexConfig.setAuth(_accessToken!);
        }

        print('[WebViewAuth] Login successful for user: $_userId');

        return WebViewAuthResult(
          success: true,
          userId: _userId,
          accessToken: _accessToken,
          role: _role,
          permissions: _permissions,
          email: _email,
          name: _name,
          picture: _picture,
        );
      } else {
        print('[WebViewAuth] Token exchange failed: ${response.body}');
        return WebViewAuthResult(
          success: false,
          error: 'فشل في استبدال رمز الدخول',
          fallbackToDemo: true,
        );
      }
    } catch (e) {
      print('[WebViewAuth] Token exchange error: $e');
      return WebViewAuthResult(
        success: false,
        error: 'خطأ: $e',
        fallbackToDemo: true,
      );
    }
  }

  /// Check existing session
  Future<bool> checkExistingSession() async {
    final storage = SecureStorageService.instance;
    final token = await storage.getAccessToken();
    final userId = await storage.getUserId();
    final refreshToken = await storage.getRefreshToken();

    if (token != null && userId != null) {
      // First, check if token is expired
      if (_isTokenExpired(token)) {
        print('[WebViewAuth] Stored token is expired, trying to refresh...');

        // Try to refresh the token
        if (refreshToken != null) {
          final refreshed = await _refreshAccessToken(refreshToken);
          if (!refreshed) {
            print(
                '[WebViewAuth] Token refresh failed, clearing stored credentials');
            await storage.delete(SecureStorageService.keyAccessToken);
            await storage.delete(SecureStorageService.keyRefreshToken);
            await storage.delete(SecureStorageService.keyUserId);
            return false;
          }
        } else {
          print(
              '[WebViewAuth] No refresh token available, clearing credentials');
          await storage.delete(SecureStorageService.keyAccessToken);
          await storage.delete(SecureStorageService.keyUserId);
          return false;
        }
      }

      _accessToken = token;
      _userId = userId;

      // Try to set Convex auth
      try {
        await AppConvexConfig.setAuth(_accessToken!);
        print('[WebViewAuth] Restored session for user: $userId');
        return true;
      } catch (e) {
        print('[WebViewAuth] Failed to restore Convex auth: $e');
        // Token might be expired - clear it
        await storage.delete(SecureStorageService.keyAccessToken);
        await storage.delete(SecureStorageService.keyUserId);
        return false;
      }
    }
    return false;
  }

  /// Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return true;
      final payload = parts[1];
      final paddedLength = (4 - payload.length % 4) % 4;
      final paddedPayload = payload + ('=' * paddedLength);
      final decoded = utf8.decode(base64Url.decode(paddedPayload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = claims['exp'] as int?;
      if (exp == null) return false; // No expiry = assume valid
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Consider expired if within 5 minutes of expiry (buffer)
      return expiry.isBefore(DateTime.now().add(const Duration(minutes: 5)));
    } catch (e) {
      return true; // Can't decode = assume expired
    }
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshAccessToken(String refreshToken) async {
    try {
      print('[WebViewAuth] Refreshing access token...');
      final response = await http.post(
        Uri.parse('https://${Auth0Config.domain}/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': Auth0Config.clientId,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];

        // Auth0 may return a new refresh token (rotation)
        if (data['refresh_token'] != null) {
          _refreshToken = data['refresh_token'];
        }

        // Re-decode ID token claims if new one was returned
        if (data['id_token'] != null) {
          _idToken = data['id_token'];
          final claims = _decodeIdTokenClaims(_idToken!);
          if (claims != null) {
            _userId = claims['sub'];
            _email = claims['email'];
            _name = claims['name'];
            _picture = claims['picture'];
          }
        }

        // Save refreshed tokens
        await _saveTokens();

        // Update Convex auth
        if (_accessToken != null) {
          await AppConvexConfig.setAuth(_accessToken!);
        }

        print('[WebViewAuth] Token refresh successful');
        return true;
      } else {
        print('[WebViewAuth] Token refresh failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[WebViewAuth] Token refresh error: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    final storage = SecureStorageService.instance;
    await storage.delete(SecureStorageService.keyAccessToken);
    await storage.delete(SecureStorageService.keyRefreshToken);
    await storage.delete(SecureStorageService.keyUserId);
    await storage.delete(SecureStorageService.keyKeepMeSignedIn);

    _accessToken = null;
    _idToken = null;
    _userId = null;
    _refreshToken = null;
    _email = null;
    _name = null;
    _picture = null;
    _currentAuthState = null;
    _role = null;
    _permissions = [];
  }
}
