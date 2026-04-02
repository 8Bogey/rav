import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';

  /// Simple password for daily access (settable in settings)
  const String kDefaultDailyPassword = '123456';

/// Demo user ID - constant for persistence across restarts
/// In production, this would come from Auth0
const String kDemoUserId = 'demo-user-001';

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

  /// Set the daily password (called from Settings when user changes it)
  static String _dailyPassword = kDefaultDailyPassword;
  
  static void setDailyPassword(String password) {
    _dailyPassword = password;
  }
  
  /// Verify subscription status (called from Settings after Auth0 login)
  static bool _isSubscriptionActive = false;
  
  static void setSubscriptionStatus(bool active) {
    _isSubscriptionActive = active;
  }
  
  /// Check if user has an active subscription
  bool get hasActiveSubscription => _isSubscriptionActive;
  
  Future<void> login(String password) async {
    // Simple daily password check
    if (password.isEmpty) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'يرجى إدخال كلمة المرور',
      );
      return;
    }
    
    // Verify password
    if (password != _dailyPassword) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'كلمة المرور غير صحيحة',
      );
      return;
    }
    
    // Successful authentication - use constant demo user ID for persistence
    final userId = kDemoUserId;
    
    try {
      if (AppConvexConfig.isInitialized) {
        await AppConvexConfig.setAuth('session-$userId');
        debugPrint('[AuthNotifier] Convex auth set for: $userId');
      }
    } catch (e) {
      debugPrint('[AuthNotifier] setAuth error (non-fatal): $e');
    }
    
    state = AuthState(
      isAuthenticated: true,
      userId: userId,
      errorMessage: null,
    );
    
    debugPrint('[AuthNotifier] Login successful');
  }
  
  void logout() async {
    await AppConvexConfig.clearAuth();
    
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