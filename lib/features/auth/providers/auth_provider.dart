import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/services/secure_storage_service.dart';

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
  late final Auth0 _auth0;

  AuthNotifier()
      : _auth0 = Auth0(
          'dev-cqkioj1eiksobor3.us.auth0.com',
          'DqcGcBSR8ETDelWq9SRENnQOZsj7TTSB',
        ),
        super(const AuthState());

  /// Login via Auth0 Universal Login (web auth - token comes from Auth0)
  Future<bool> loginWithAuth0() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credentials = await _auth0.webAuthentication(scheme: 'http').login(
            redirectUrl: 'http://127.0.0.1:8899/callback',
          );

      final token = credentials.accessToken;
      final userId = credentials.user.sub;
      final email = credentials.user.email;
      final name = credentials.user.name;
      final picture = credentials.user.pictureUrl?.toString();

      if (token != null && userId != null) {
        await AppConvexConfig.setAuth(token);

        // Save to secure storage for session restoration
        await SecureStorageService.instance.setAccessToken(token);
        await SecureStorageService.instance.setUserId(userId);

        // Upsert user to Convex with JWT claims (with retry)
        await _upsertUserToConvex(
          userId: userId,
          email: email,
          name: name,
          picture: picture,
          role: 'worker', // default role
          permissions: [],
        );

        state = AuthState(
          isAuthenticated: true,
          userId: userId,
          accessToken: token,
          role: UserRole.worker,
          permissions: [],
          isLoading: false,
          email: email,
          name: name,
          picture: picture,
        );
        debugPrint('[AuthNotifier] Auth0 login successful: $userId');
        return true;
      }

      state = const AuthState(
          isLoading: false, errorMessage: 'Login failed: no token received');
      return false;
    } catch (e, st) {
      debugPrint('[AuthNotifier] Auth0 login error: $e\n$st');
      state = AuthState(
          isLoading: false, errorMessage: 'Login failed: ${e.toString()}');
      return false;
    }
  }

  /// Initialize auth state from existing session
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Check for existing session in secure storage
      final token = await SecureStorageService.instance.getAccessToken();
      final userId = await SecureStorageService.instance.getUserId();

      if (token != null && userId != null) {
        await AppConvexConfig.setAuth(token);

        // Try to get user from Convex to resolve role/permissions
        String? role;
        List<String> permissions = [];
        try {
          final user = await AppConvexConfig.mutation(
              'mutations/users:getCurrentUser', {});
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
      state = const AuthState(isLoading: false);
    } catch (e, st) {
      debugPrint('[AuthNotifier] Initialize error: $e\n$st');
      state = AuthState(
          isLoading: false, errorMessage: 'Failed to restore session');
    }
  }

  /// Login via Google (uses Universal Login with Google connection)
  Future<bool> loginWithGoogle() async {
    // For Google, we use Universal Login which opens Auth0's hosted page
    // where user can click "Continue with Google"
    return loginWithAuth0();
  }

  /// Login via email/password using Auth0 web auth (Universal Login page)
  Future<bool> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // For email/password, we also use Universal Login
    // The user enters credentials on Auth0's hosted page
    return loginWithAuth0();
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
            '[AuthNotifier] WARNING: Unknown role "$role", defaulting to worker');
        return UserRole.worker;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: 'http').logout();
    } catch (e) {
      debugPrint('[AuthNotifier] Auth0 logout error: $e');
    }
    await SecureStorageService.instance.deleteAll();
    await AppConvexConfig.clearAuth();
    state = const AuthState();
    debugPrint('[AuthNotifier] Logged out');
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Set auth state directly (for guest login)
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
