/**
 * Auth Provider for Riverpod
 * 
 * Manages authentication state and user session.
 * Uses Convex for authentication.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';

/// User role enum
enum UserRole {
  admin,
  worker,
}

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? name;
  final UserRole role;
  final List<String> permissions;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.name,
    this.role = UserRole.admin,
    this.permissions = const [],
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? name,
    UserRole? role,
    List<String>? permissions,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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

  /// Check if user has all specified permissions
  bool hasAllPermissions(List<String> requiredPermissions) {
    return requiredPermissions.every(hasPermission);
  }
}

/// Auth notifier for managing auth state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Initialize auth state from Convex
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      if (!ConvexConfig.isInitialized) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
        return;
      }

      final identity = ConvexConfig.client.auth.getUserIdentity();
      
      if (identity != null) {
        state = AuthState(
          isAuthenticated: true,
          userId: identity.subject,
          email: identity.email,
          name: identity.name,
          role: UserRole.admin, // Default role, will be updated from worker profile
          permissions: [], // Will be loaded from worker profile
          isLoading: false,
        );

        // Load user profile to get role and permissions
        await _loadUserProfile();
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      debugPrint('AuthNotifier: Error initializing: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load user profile from Convex to get role and permissions
  Future<void> _loadUserProfile() async {
    if (!state.isAuthenticated || state.userId == null) return;

    try {
      // Query worker by ownerId
      // Note: This would need to be implemented as a query in Convex
      // For now, we'll default to admin role
      state = state.copyWith(
        role: UserRole.admin,
        permissions: ['*'], // Admin has all permissions
      );
    } catch (e) {
      debugPrint('AuthNotifier: Error loading profile: $e');
    }
  }

  /// Sign in (would use Convex auth)
  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Convex auth would be handled here
      // For now, just check if client is authenticated
      if (ConvexConfig.isAuthenticated) {
        await initialize();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Not authenticated',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      ConvexConfig.client.auth.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update role
  void setRole(UserRole role) {
    state = state.copyWith(role: role);
  }

  /// Update permissions
  void setPermissions(List<String> permissions) {
    state = state.copyWith(permissions: permissions);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider for current user ID (ownerId)
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).userId;
});

/// Provider for checking if user is admin
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).role == UserRole.admin;
});

/// Provider for checking if user is worker
final isWorkerProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).role == UserRole.worker;
});

/// Provider for permission check
final hasPermissionProvider = Provider.family<bool, String>((ref, permission) {
  return ref.watch(authStateProvider).hasPermission(permission);
});

/// Provider for auth loading state
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

/// Provider for auth error
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});