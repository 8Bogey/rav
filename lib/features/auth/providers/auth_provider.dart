import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/auth/webview_auth_service.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';

enum UserRole { admin, worker }

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? accessToken;
  final UserRole role;
  final List<String> permissions;
  final bool isLoading;
  final String? errorMessage;
  // User profile from JWT
  final String? email;
  final String? name;
  final String? picture;

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
  final WebViewAuthService _auth0;

  AuthNotifier(this._auth0) : super(const AuthState());

  /// Initialize auth state from existing session
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final hasSession = await _auth0.checkExistingSession();
      if (hasSession) {
        final token = _auth0.accessToken;
        final userId = _auth0.userId;
        if (token != null && userId != null) {
          await AppConvexConfig.setAuth(token);
          // Try to get user from Convex to resolve role/permissions
          String? role;
          List<String> permissions = [];
          try {
            final user = await AppConvexConfig.mutation(
              'mutations/users:getCurrentUser',
              {},
            );
            role = user['role'] as String?;
            final permsRaw = user['permissions'];
            if (permsRaw is List) {
              permissions = permsRaw.map((e) => e.toString()).toList();
            }
          } catch (e) {
            debugPrint('[AuthNotifier] Failed to fetch user from Convex: $e');
          }
          state = AuthState(
            isAuthenticated: true,
            userId: userId,
            accessToken: token,
            role: _mapRole(role),
            permissions: permissions,
            isLoading: false,
          );
          debugPrint('[AuthNotifier] Session restored: $userId, role: $role');
          return;
        }
      }
      state = const AuthState(isLoading: false);
    } catch (e, st) {
      debugPrint('[AuthNotifier] Initialize error: $e\n$st');
      state = AuthState(
        isLoading: false,
        errorMessage: 'Failed to restore session',
      );
    }
  }

  /// Login via Auth0
  Future<bool> loginWithAuth0() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _auth0.login();

      if (result.success) {
        final token = _auth0.accessToken;
        final userId = _auth0.userId;

        if (token != null && userId != null) {
          await AppConvexConfig.setAuth(token);

          // Upsert user to Convex with JWT claims (with retry)
          await _upsertUserToConvex(
            userId: userId,
            email: result.email,
            name: result.name,
            picture: result.picture,
            role: result.role,
            permissions: result.permissions,
          );

          // Use role/permissions from JWT, fallback to worker
          state = AuthState(
            isAuthenticated: true,
            userId: userId,
            accessToken: token,
            role: _mapRole(result.role),
            permissions: result.permissions,
            isLoading: false,
            email: result.email,
            name: result.name,
            picture: result.picture,
          );
          debugPrint(
              '[AuthNotifier] Auth0 login successful: $userId, role: ${result.role}');
          return true;
        }
      }

      // Login failed — surface the error
      state = AuthState(
        isLoading: false,
        errorMessage: result.error ?? 'Login failed: no token received',
      );
      return false;
    } catch (e, st) {
      debugPrint('[AuthNotifier] Auth0 login error: $e\n$st');
      state = AuthState(
        isLoading: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Login via email/password using Auth0 ROPC grant (direct, no WebView).
  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _auth0.loginWithROPC(
        email: email,
        password: password,
      );

      if (result.success) {
        final token = result.accessToken;
        final userId = result.userId;

        if (token != null && userId != null) {
          await AppConvexConfig.setAuth(token);

          // Upsert user to Convex with JWT claims (with retry)
          await _upsertUserToConvex(
            userId: userId,
            email: result.email,
            name: result.name,
            picture: result.picture,
            role: result.role,
            permissions: result.permissions,
          );

          // Use role/permissions from JWT, fallback to worker
          state = AuthState(
            isAuthenticated: true,
            userId: userId,
            accessToken: token,
            role: _mapRole(result.role),
            permissions: result.permissions,
            isLoading: false,
            email: result.email,
            name: result.name,
            picture: result.picture,
          );
          debugPrint(
              '[AuthNotifier] Email/password login successful: $userId, role: ${result.role}');
          return true;
        }
      }

      // Login failed — surface the error
      state = AuthState(
        isLoading: false,
        errorMessage: result.error ?? 'Login failed: no token received',
      );
      return false;
    } catch (e, st) {
      debugPrint('[AuthNotifier] Email/password login error: $e\n$st');
      state = AuthState(
        isLoading: false,
        errorMessage: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Login via Google using Auth0 WebView flow.
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _auth0.login(connection: 'google-oauth2');

      if (result.success) {
        final token = _auth0.accessToken;
        final userId = _auth0.userId;

        if (token != null && userId != null) {
          await AppConvexConfig.setAuth(token);

          // Upsert user to Convex with JWT claims (with retry)
          await _upsertUserToConvex(
            userId: userId,
            email: result.email,
            name: result.name,
            picture: result.picture,
            role: result.role,
            permissions: result.permissions,
          );

          // Use role/permissions from JWT, fallback to worker
          state = AuthState(
            isAuthenticated: true,
            userId: userId,
            accessToken: token,
            role: _mapRole(result.role),
            permissions: result.permissions,
            isLoading: false,
            email: result.email,
            name: result.name,
            picture: result.picture,
          );
          debugPrint(
              '[AuthNotifier] Google login successful: $userId, role: ${result.role}');
          return true;
        }
      }

      // Login failed — surface the error
      state = AuthState(
        isLoading: false,
        errorMessage: result.error ?? 'Google login failed: no token received',
      );
      return false;
    } catch (e, st) {
      debugPrint('[AuthNotifier] Google login error: $e\n$st');
      state = AuthState(
        isLoading: false,
        errorMessage: 'Google login failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Upsert user to Convex with retry logic
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
          'auth0Id': userId,
          'email': email,
          'name': name,
          'picture': picture,
          'role': role,
          'permissions': permissions,
        });
        debugPrint('[AuthNotifier] User upserted to Convex successfully');
        return;
      } catch (e) {
        if (attempt < maxRetries) {
          debugPrint(
              '[AuthNotifier] User upsert attempt ${attempt + 1} failed: $e, retrying...');
          await Future.delayed(Duration(milliseconds: 200 * (attempt + 1)));
        } else {
          debugPrint(
              '[AuthNotifier] ERROR: Failed to upsert user after ${maxRetries + 1} attempts: $e');
        }
      }
    }
  }

  /// Map string role from JWT to UserRole enum
  UserRole _mapRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'worker':
        return UserRole.worker;
      default:
        debugPrint(
            '[AuthNotifier] WARNING: Unknown role "$role", defaulting to worker (least privilege)');
        return UserRole.worker;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth0.logout();
    } catch (e) {
      debugPrint('[AuthNotifier] Auth0 logout error: $e');
    }
    await AppConvexConfig.clearAuth();
    state = const AuthState();
    debugPrint('[AuthNotifier] Logged out');
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Set auth state directly (for guest login and internal use only).
  /// Prefer loginWithEmailPassword(), loginWithGoogle(), or loginWithAuth0() for normal flows.
  void setAuthState({
    required bool isAuthenticated,
    String? userId,
    String? accessToken,
    UserRole? role,
    List<String>? permissions,
  }) {
    // Use default admin role if not provided
    final resolvedRole = role ?? UserRole.admin;

    state = AuthState(
      isAuthenticated: isAuthenticated,
      userId: userId,
      accessToken: accessToken,
      role: resolvedRole,
      permissions: permissions ?? [],
      isLoading: false,
      errorMessage: null,
    );

    // If we have an access token, also set it in Convex config
    if (accessToken != null) {
      AppConvexConfig.setAuth(accessToken);
    }
  }
}

final authServiceProvider =
    Provider<WebViewAuthService>((ref) => WebViewAuthService.instance);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth0 = ref.watch(authServiceProvider);
  return AuthNotifier(auth0);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});
