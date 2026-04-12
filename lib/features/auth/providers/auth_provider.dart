import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpServer, InternetAddress;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/services/secure_storage_service.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'dart:math';

/// Auth Provider Architecture Notes
/// ================================
///
/// This AuthNotifier provides Riverpod state management for authentication.
///
/// CURRENT ARCHITECTURE:
/// - AuthNotifier: Riverpod StateNotifier for UI state
/// - WebViewAuthService: Singleton for robust PKCE + token handling
///
/// MIGRATION PATH (rav-tx6w):
/// The recommended consolidation approach is:
/// 1. AuthNotifier should delegate to WebViewAuthService for auth operations
/// 2. WebViewAuthService handles: PKCE flow, callback server, token refresh
/// 3. AuthNotifier handles: Riverpod state management, UI updates
///
/// Current implementation in this file has some duplicate code with WebViewAuthService.
/// Future work: Refactor to use WebViewAuthService as singleton engine,
/// wrapping with Riverpod state management here.

/// Auth0 Configuration
class AuthConfig {
  static const String domain = 'dev-cqkioj1eiksobor3.us.auth0.com';
  static const String clientId = 'DqcGcBSR8ETDelWq9SRENnQOZsj7TTSB';
  static const String audience = 'https://hearty-meadowlark-390.convex.cloud';
  static const String redirectUri = 'http://127.0.0.1:8899/callback';
  static const String tokenUrl = 'https://$domain/oauth/token';
  static const String loginUrl = 'https://$domain/authorize';
}

String _generateRandomString(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
  final random = Random.secure();
  return List.generate(length, (_) => chars[random.nextInt(chars.length)])
      .join();
}

String _generateCodeVerifier() => _generateRandomString(128);

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
class AuthResult {
  final bool success;
  final String? userId;
  final String? accessToken;
  final String? refreshToken;
  final String? error;
  final String? email;
  final String? name;
  final String? picture;
  final String? role;
  final List<String> permissions;

  AuthResult({
    required this.success,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.error,
    this.email,
    this.name,
    this.picture,
    this.role,
    this.permissions = const [],
  });
}

enum UserRole { admin, worker }

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? accessToken;
  final UserRole role;
  final List<String> permissions;
  final bool isLoading;
  final String? errorMessage;
  final String? email;
  final String? name;
  final String? picture;
  final bool needsSync; // True when session restored, to force /syncing screen

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.accessToken,
    this.role = UserRole.admin,
    this.permissions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.email,
    this.name,
    this.picture,
    this.needsSync = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? accessToken,
    UserRole? role,
    List<String>? permissions,
    bool? isLoading,
    String? errorMessage,
    String? email,
    String? name,
    String? picture,
    bool? needsSync,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      email: email ?? this.email,
      name: name ?? this.name,
      picture: picture ?? this.picture,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  bool hasPermission(String permission) {
    if (role == UserRole.admin || permissions.contains('*')) return true;
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> required) {
    return required.any(hasPermission);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  HttpServer? _callbackServer;
  String? _codeVerifier;
  Completer<String?>? _authCodeCompleter;
  Timer? _refreshTimer;

  AuthNotifier() : super(const AuthState());

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _callbackServer?.close();
    super.dispose();
  }

  /// Start proactive token refresh timer (refresh every 20 hours)
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    // Refresh proactively 4 hours before expiry (Auth0 tokens last 24h by default)
    _refreshTimer = Timer.periodic(const Duration(hours: 20), (_) {
      _refreshAccessToken();
    });
    debugPrint('[Auth] Token refresh timer started (20 hour interval)');
  }

  /// Refresh access token using stored refresh token
  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null) {
        debugPrint('[Auth] No refresh token available');
        return false;
      }

      debugPrint('[Auth] Refreshing access token...');
      final response = await http.post(
        Uri.parse(AuthConfig.tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': AuthConfig.clientId,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'] as String?;

        if (newAccessToken != null) {
          await SecureStorageService.instance.setAccessToken(newAccessToken);

          // Handle refresh token rotation
          final newRefreshToken = data['refresh_token'] as String?;
          if (newRefreshToken != null) {
            await SecureStorageService.instance
                .setRefreshToken(newRefreshToken);
          }

          // Update Convex auth
          await AppConvexConfig.setAuth(newAccessToken);

          // Update state
          state = state.copyWith(accessToken: newAccessToken);
          debugPrint('[Auth] Token refresh successful');
          return true;
        }
      }

      debugPrint('[Auth] Token refresh failed: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('[Auth] Token refresh error: $e');
      return false;
    }
  }

  /// Handle 401 errors from Convex by refreshing token and retrying
  Future<bool> handleAuthError() async {
    final refreshed = await _refreshAccessToken();
    if (!refreshed) {
      // Refresh failed, need to re-authenticate
      await logout();
    }
    return refreshed;
  }

  /// Logout and clear all tokens
  Future<void> logout() async {
    _refreshTimer?.cancel();
    await SecureStorageService.instance.deleteAll();
    await AppConvexConfig.setAuth('');
    state = const AuthState();
    debugPrint('[Auth] Logged out');
  }

  Future<AuthResult> _loginWithAuth0Universal() async {
    try {
      // Start local callback server
      _callbackServer =
          await HttpServer.bind(InternetAddress.loopbackIPv4, 8899);

      // Generate PKCE
      _codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(_codeVerifier!);
      final dynamicRedirectUri = 'http://127.0.0.1:8899/callback';

      // Build Auth0 Universal Login URL (NOT Google-specific)
      final authUrl = Uri.parse(AuthConfig.loginUrl).replace(
        queryParameters: {
          'response_type': 'code',
          'client_id': AuthConfig.clientId,
          'redirect_uri': dynamicRedirectUri,
          'audience': AuthConfig.audience,
          'scope': 'openid profile email offline_access',
          'code_challenge': codeChallenge,
          'code_challenge_method': 'S256',
          'state': _generateRandomString(32),
          'prompt': 'login',
        },
      );

      debugPrint('[Auth] Opening Auth0 Universal Login: $authUrl');

      _authCodeCompleter = Completer<String?>();

      // Open WebView
      final webview = await WebviewWindow.create(
        configuration: CreateConfiguration(
          windowWidth: 500,
          windowHeight: 700,
          title: 'Login - Smart Gen',
        ),
      );

      webview.addOnUrlRequestCallback((url) {
        final uri = Uri.parse(url);
        if (uri.host == '127.0.0.1' &&
            uri.path == '/callback' &&
            uri.queryParameters.containsKey('code')) {
          _authCodeCompleter?.complete(uri.queryParameters['code']);
          webview.close();
        }
      });

      webview.launch(authUrl.toString());

      // Wait for auth code
      final authCode = await _authCodeCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => null,
      );

      await _callbackServer?.close(force: true);
      _callbackServer = null;

      if (authCode == null) {
        return AuthResult(success: false, error: 'Login timeout');
      }

      // Exchange code for tokens
      return await _exchangeCodeForTokens(
          authCode, _codeVerifier!, dynamicRedirectUri);
    } catch (e) {
      debugPrint('[Auth] Login error: $e');
      return AuthResult(success: false, error: e.toString());
    }
  }

  Future<AuthResult> _exchangeCodeForTokens(
      String authCode, String codeVerifier, String redirectUri) async {
    final response = await http.post(
      Uri.parse(AuthConfig.tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': AuthConfig.clientId,
        'code': authCode,
        'code_verifier': codeVerifier,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'] as String?;
      final idToken = data['id_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken == null) {
        return AuthResult(success: false, error: 'No access token');
      }

      // Decode ID token
      String? userId, email, name, picture, role;
      List<String> permissions = [];

      if (idToken != null) {
        try {
          final parts = idToken.split('.');
          if (parts.length >= 2) {
            var payload = parts[1];
            final paddedLength = (4 - payload.length % 4) % 4;
            payload += '=' * paddedLength;
            final claims = jsonDecode(utf8.decode(base64Url.decode(payload)))
                as Map<String, dynamic>;
            userId = claims['sub'];
            email = claims['email'];
            name = claims['name'];
            picture = claims['picture'];
            role = claims['https://mawlid-al-dhaki.com/role'] as String? ??
                claims['role'] as String?;
            final permsRaw =
                claims['https://mawlid-al-dhaki.com/permissions'] ??
                    claims['permissions'];
            if (permsRaw is List) {
              permissions = permsRaw.map((e) => e.toString()).toList();
            }
          }
        } catch (e) {
          debugPrint('[Auth] Failed to decode ID token: $e');
        }
      }

      return AuthResult(
        success: true,
        userId: userId,
        accessToken: accessToken,
        refreshToken: refreshToken,
        email: email,
        name: name,
        picture: picture,
        role: role,
        permissions: permissions,
      );
    } else {
      return AuthResult(
          success: false, error: 'Token exchange failed: ${response.body}');
    }
  }

  /// Login via Auth0 Universal Login (opens Auth0 page where user can choose Google or email)
  Future<bool> loginWithAuth0() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _loginWithAuth0Universal();

      if (result.success &&
          result.accessToken != null &&
          result.userId != null) {
        await AppConvexConfig.setAuth(result.accessToken!);
        await SecureStorageService.instance.setAccessToken(result.accessToken!);
        await SecureStorageService.instance.setUserId(result.userId!);

        // Store refresh token if available
        if (result.refreshToken != null) {
          await SecureStorageService.instance
              .setRefreshToken(result.refreshToken!);
        }

        await _upsertUserToConvex(
          userId: result.userId!,
          email: result.email,
          name: result.name,
          picture: result.picture,
          role: result.role ?? 'worker',
          permissions: result.permissions,
        );

        state = AuthState(
          isAuthenticated: true,
          userId: result.userId,
          accessToken: result.accessToken,
          role: _mapRole(result.role),
          permissions: result.permissions,
          isLoading: false,
          email: result.email,
          name: result.name,
          picture: result.picture,
        );

        // Start token refresh timer
        _startRefreshTimer();

        debugPrint('[Auth] Login successful: ${result.userId}');
        return true;
      }

      state = AuthState(
          isLoading: false, errorMessage: result.error ?? 'Login failed');
      return false;
    } catch (e, st) {
      debugPrint('[Auth] Login error: $e\n$st');
      state = AuthState(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  /// Initialize auth state
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final userId = await SecureStorageService.instance.getUserId();

      if (token != null && userId != null) {
        // Validate token with Convex
        await AppConvexConfig.setAuth(token);

        try {
          final user = await AppConvexConfig.mutation(
              'mutations/users:getCurrentUser', {});
          final role = user['role'] as String?;
          final permsRaw = user['permissions'] as List?;
          final permissions = permsRaw?.map((e) => e.toString()).toList() ?? [];

          state = AuthState(
            isAuthenticated: true,
            userId: userId,
            accessToken: token,
            role: _mapRole(role),
            permissions: permissions,
            isLoading: false,
            needsSync: true, // Force /syncing screen on session restore
          );

          // Start token refresh timer for restored session
          _startRefreshTimer();

          debugPrint('[Auth] Session restored: $userId, role: $role');
          return;
        } catch (e) {
          debugPrint('[Auth] Session validation failed: $e');
          // Token is invalid - clear it
          await SecureStorageService.instance.deleteAll();
        }
      }
      state = const AuthState(isLoading: false);
    } catch (e, st) {
      debugPrint('[Auth] Initialize error: $e\n$st');
      state = AuthState(
          isLoading: false, errorMessage: 'Failed to restore session');
    }
  }

  /// Login via Google (still uses Universal Login but focuses on Google)
  Future<bool> loginWithGoogle() async {
    // Same as loginWithAuth0 - Universal Login shows Google option
    return loginWithAuth0();
  }

  /// Login via email/password (for ROPC flow - direct API call)
  ///
  /// ⚠️ DEPRECATION NOTICE:
  /// Resource Owner Password Credentials (ROPC) grant is deprecated by Auth0.
  /// - Cannot use MFA with ROPC
  /// - App handles credentials directly (security risk)
  /// - Will be removed in future Auth0 versions
  ///
  /// MIGRATION PATH:
  /// Use Auth0 Universal Login (loginWithAuth0) instead, which supports:
  /// - Email/password authentication via secure Auth0-hosted page
  /// - MFA support
  /// - Passwordless authentication
  /// - Social logins (Google, etc.)
  ///
  /// This method is kept for backward compatibility during migration.
  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await http.post(
        Uri.parse(AuthConfig.tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': email,
          'password': password,
          'audience': AuthConfig.audience,
          'scope': 'openid profile email offline_access',
          'client_id': AuthConfig.clientId,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'] as String?;
        final idToken = data['id_token'] as String?;

        if (accessToken == null) {
          state = const AuthState(
              isLoading: false, errorMessage: 'No access token');
          return false;
        }

        // Decode ID token
        String? userId, userEmail, userName, picture, role;
        List<String> permissions = [];

        if (idToken != null) {
          try {
            final parts = idToken.split('.');
            if (parts.length >= 2) {
              var payload = parts[1];
              final paddedLength = (4 - payload.length % 4) % 4;
              payload += '=' * paddedLength;
              final claims = jsonDecode(utf8.decode(base64Url.decode(payload)))
                  as Map<String, dynamic>;
              userId = claims['sub'];
              userEmail = claims['email'];
              userName = claims['name'];
              picture = claims['picture'];
              role = claims['https://mawlid-al-dhaki.com/role'] as String? ??
                  claims['role'] as String?;
              final permsRaw =
                  claims['https://mawlid-al-dhaki.com/permissions'] ??
                      claims['permissions'];
              if (permsRaw is List) {
                permissions = permsRaw.map((e) => e.toString()).toList();
              }
            }
          } catch (e) {
            debugPrint('[Auth] Failed to decode ID token: $e');
          }
        }

        await AppConvexConfig.setAuth(accessToken);
        await SecureStorageService.instance.setAccessToken(accessToken);
        await SecureStorageService.instance.setUserId(userId ?? email);

        // Store refresh token if available (ROPC may return refresh_token)
        final refreshToken = data['refresh_token'] as String?;
        if (refreshToken != null) {
          await SecureStorageService.instance.setRefreshToken(refreshToken);
        }

        await _upsertUserToConvex(
          userId: userId ?? email,
          email: userEmail,
          name: userName,
          picture: picture,
          role: role ?? 'worker',
          permissions: permissions,
        );

        state = AuthState(
          isAuthenticated: true,
          userId: userId ?? email,
          accessToken: accessToken,
          role: _mapRole(role),
          permissions: permissions,
          isLoading: false,
          email: userEmail,
          name: userName,
          picture: picture,
        );

        // Start token refresh timer
        _startRefreshTimer();

        debugPrint('[Auth] Email/password login successful: $userId');
        return true;
      } else {
        String errorMsg = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg =
              errorData['error_description'] ?? errorData['error'] ?? errorMsg;
        } catch (_) {}
        state = AuthState(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    } catch (e, st) {
      debugPrint('[Auth] Email/password login error: $e\n$st');
      state = AuthState(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> _upsertUserToConvex({
    required String userId,
    String? email,
    String? name,
    String? picture,
    String? role,
    List<String>? permissions,
  }) async {
    const maxRetries = 2;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        await AppConvexConfig.mutation('mutations/users:upsertUser', {
          'email': email,
          'name': name,
          'picture': picture,
          'role': role,
          'permissions': permissions,
        });
        debugPrint('[Auth] User upserted to Convex successfully');
        return;
      } catch (e) {
        if (attempt < maxRetries) {
          debugPrint(
              '[Auth] User upsert attempt ${attempt + 1} failed: $e, retrying...');
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
        } else {
          debugPrint(
              '[Auth] ERROR: Failed to upsert user after ${maxRetries + 1} attempts: $e');
        }
      }
    }
  }

  UserRole _mapRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'worker':
        return UserRole.worker;
      default:
        return UserRole.worker;
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  void setAuthState({
    required bool isAuthenticated,
    String? userId,
    String? accessToken,
    UserRole? role,
    List<String>? permissions,
  }) {
    state = AuthState(
      isAuthenticated: isAuthenticated,
      userId: userId,
      accessToken: accessToken,
      role: role ?? UserRole.admin,
      permissions: permissions ?? [],
      isLoading: false,
      errorMessage: null,
    );
    if (accessToken != null) {
      AppConvexConfig.setAuth(accessToken);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});
