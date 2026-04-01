/**
 * Convex Client Configuration
 * 
 * Initializes and provides the Convex client for the Flutter app.
 * Used for real-time subscriptions and mutations.
 */

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App's Convex configuration wrapper (avoids conflict with package's ConvexConfig)
class AppConvexConfig {
  static String? _deploymentUrl;
  static bool _isInitialized = false;

  /// Initialize Convex client with deployment URL
  static Future<void> initialize(String deploymentUrl) async {
    if (_isInitialized) {
      debugPrint('AppConvexConfig: Already initialized');
      return;
    }

    _deploymentUrl = deploymentUrl;
    
    // Initialize the Convex client singleton with package's ConvexConfig
    final config = ConvexConfig(
      deploymentUrl: deploymentUrl,
      clientId: 'mawlid_al_dhaki_app',
    );
    
    await ConvexClient.initialize(config);
    
    _isInitialized = true;
    
    debugPrint('AppConvexConfig: Initialized with deployment URL: $deploymentUrl');
  }

  /// Get the Convex client instance (singleton)
  static ConvexClient get client => ConvexClient.instance;

  /// Check if client is initialized
  static bool get isInitialized => _isInitialized;

  /// Get deployment URL
  static String? get deploymentUrl => _deploymentUrl;

  /// Check if user is authenticated (sync)
  static bool get isAuthenticated => client.isAuthenticated;

  /// Get auth state stream (reactive)
  static Stream<bool> get authStateStream => client.authState;

  /// Set authentication token (call on login)
  static Future<void> setAuth(String? token) async {
    await client.setAuth(token: token);
  }

  /// Clear authentication (call on logout)
  static Future<void> clearAuth() async {
    await client.setAuth(token: null);
  }

  /// Dispose the client
  static void dispose() {
    _deploymentUrl = null;
    _isInitialized = false;
    debugPrint('AppConvexConfig: Disposed');
  }
}

/// Provider for Convex client
final convexClientProvider = Provider<ConvexClient>((ref) {
  if (!AppConvexConfig.isInitialized) {
    throw StateError('AppConvexConfig not initialized. Call AppConvexConfig.initialize() in main().');
  }
  return AppConvexConfig.client;
});