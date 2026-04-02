import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';

/// When `false` (build with `--dart-define=DEMO_AUTH=false`), demo login is rejected until real auth is wired.
const bool kDemoAuthLogin =
    bool.fromEnvironment('DEMO_AUTH', defaultValue: true);

/// User role enum for RBAC
enum UserRole {
  admin,
  worker,
}

class AuthState {
  final bool isAuthenticated;
  final String? userId; // Added for tenant isolation (ownerId)
  final String? errorMessage;
  final UserRole role;
  final List<String> permissions;

  AuthState({
    required this.isAuthenticated,
    this.userId,
    this.errorMessage,
    this.role = UserRole.admin,
    this.permissions = const [],
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? errorMessage,
    UserRole? role,
    List<String>? permissions,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    // Admin has all permissions
    if (role == UserRole.admin || permissions.contains('*')) {
      return true;
    }
    return permissions.contains(permission);
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<String> requiredPermissions) {
    return requiredPermissions.any(hasPermission);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  
  AuthNotifier(this._ref) : super(AuthState(isAuthenticated: false, userId: null));

  Future<void> login(String password) async {
    // Use real Auth0 authentication
    final result = await Auth0Service.instance.login();
    
    if (!result.success) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'فشل تسجيل الدخول: ${result.error ?? "خطأ غير معروف"}',
      );
      return;
    }
    
    // Auth0 login successful - wire token to Convex
    if (result.accessToken != null) {
      await AppConvexConfig.setAuth(result.accessToken!);
      debugPrint('[AuthNotifier] Convex auth set with Auth0 token');
    }
    
    state = AuthState(
      isAuthenticated: true,
      userId: result.userId,
      errorMessage: null,
    );
    
    debugPrint('[AuthNotifier] Auth0 login successful, userId: ${result.userId}');
  }
  
  void logout() async {
    // Clear Convex auth
    await AppConvexConfig.clearAuth();
    
    // Logout from Auth0
    await Auth0Service.instance.logout();
    
    debugPrint('[AuthNotifier] Logout, clearing userId');
    state = AuthState(
      isAuthenticated: false,
      userId: null,
      errorMessage: null,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);