import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
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

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.accessToken,
    this.role = UserRole.admin,
    this.permissions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? accessToken,
    UserRole? role,
    List<String>? permissions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
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
  final Auth0Service _auth0;

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
          state = AuthState(
            isAuthenticated: true,
            userId: userId,
            accessToken: token,
            role: UserRole.admin,
            isLoading: false,
          );
          debugPrint('[AuthNotifier] Session restored: $userId');
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
      await _auth0.login();
      final token = _auth0.accessToken;
      final userId = _auth0.userId;

      if (token != null && userId != null) {
        await AppConvexConfig.setAuth(token);
        state = AuthState(
          isAuthenticated: true,
          userId: userId,
          accessToken: token,
          role: UserRole.admin,
          isLoading: false,
        );
        debugPrint('[AuthNotifier] Auth0 login successful: $userId');
        return true;
      }

      state = const AuthState(
        isLoading: false,
        errorMessage: 'Login failed: no token received',
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
}

final authServiceProvider =
    Provider<Auth0Service>((ref) => Auth0Service.instance);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final auth0 = ref.watch(authServiceProvider);
  return AuthNotifier(auth0);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).userId;
});
