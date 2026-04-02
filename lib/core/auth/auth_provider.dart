/// Auth Provider for Riverpod with Auth0 integration
/// 
/// Manages authentication state and user session via Auth0.
/// Bridges Auth0 identity to Convex for tenant isolation.
library;

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart' as demo_auth;

/// User role enum
enum UserRole {
  admin,
  worker,
}

/// Auth state
class AuthState {
  final bool isAuthenticated;
  final String? userId; // Auth0 sub
  final String? email;
  final String? name;
  final String? picture;
  final UserRole role;
  final List<String> permissions;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.name,
    this.picture,
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
    String? picture,
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
      picture: picture ?? this.picture,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth notifier for managing auth state
class AuthNotifier extends StateNotifier<AuthState> {
  final Auth0 _auth0 = Auth0(
    'dev-hennzyl8c1leuws2.us.auth0.com', 
    'gdGUvXRCjz41MNnaMPZ77M1ZCIC1IFS7'
  );

  AuthNotifier() : super(const AuthState());

  /// Initialize auth state (check for existing session)
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final credentials = await _auth0.credentialsManager.credentials();
      await _updateConvexAndState(credentials);
        } catch (e) {
      debugPrint('AuthNotifier: No existing session: $e');
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  /// Sign in with Auth0
  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credentials = await _auth0.webAuthentication().login(
        audience: 'https://dev-hennzyl8c1leuws2.us.auth0.com/userinfo',
      );
      await _updateConvexAndState(credentials);
    } catch (e) {
      debugPrint('AuthNotifier: Sign in error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _auth0.webAuthentication().logout();
      await AppConvexConfig.clearAuth();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Internal helper to sync Auth0 token to Convex and update local state
  Future<void> _updateConvexAndState(Credentials credentials) async {
    // 1. Pass the Auth0 ID Token to Convex
    // This allows Convex to verify the user identity and enforce tenant isolation.
    await AppConvexConfig.setAuth(credentials.idToken);

    final user = credentials.user;
    state = AuthState(
      isAuthenticated: true,
      userId: user.sub,
      email: user.email,
      name: user.name,
      picture: user.pictureUrl?.toString(),
      role: UserRole.admin, // In SaaS, the first user is usually admin
      permissions: ['*'],
      isLoading: false,
    );
  }
}

/// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier();
  // Don't auto-initialize here to avoid circular dependencies if we use it in main
  return notifier;
});

/// Provider for current user ID (ownerId)
/// 
/// Reads from the demo auth provider since that's what the login screen uses.
/// Falls back to Auth0 provider if demo auth userId is null.
final currentUserIdProvider = Provider<String?>((ref) {
  // First try the demo auth provider (used by login screen)
  final demoAuthState = ref.watch(demo_auth.authProvider);
  if (demoAuthState.isAuthenticated && demoAuthState.userId != null) {
    debugPrint('[currentUserIdProvider] Using demo auth userId: ${demoAuthState.userId}');
    return demoAuthState.userId;
  }
  
  // Fall back to Auth0 provider
  final auth0State = ref.watch(authStateProvider);
  if (auth0State.isAuthenticated && auth0State.userId != null) {
    debugPrint('[currentUserIdProvider] Using Auth0 userId: ${auth0State.userId}');
    return auth0State.userId;
  }
  
  debugPrint('[currentUserIdProvider] No authenticated user, returning null');
  return null;
});