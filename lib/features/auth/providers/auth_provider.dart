import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!kDemoAuthLogin) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage:
            'وضع العرض التوضيحي معطّل (DEMO_AUTH=false). اربط المصادقة الفعلية أو أعد البناء مع DEMO_AUTH.',
      );
      return;
    }

    // Demo PRD: accept any non-empty password when kDemoAuthLogin is true
    if (password.isEmpty) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'يرجى إدخال كلمة المرور',
      );
      return;
    }
    
    // Successful authentication - set a demo userId for tenant isolation
    debugPrint('[AuthNotifier] Login successful, setting userId: demo-user-001');
    state = AuthState(
      isAuthenticated: true,
      userId: 'demo-user-001', // Fixed userId for demo mode - used as ownerId
      errorMessage: null,
    );
  }
  
  void logout() {
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