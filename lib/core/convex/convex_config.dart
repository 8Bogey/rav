/**
 * Convex Client Configuration
 * 
 * Initializes and provides the Convex client for the Flutter app.
 * Used for real-time subscriptions and mutations.
 */

import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter/foundation.dart';

class ConvexConfig {
  static ConvexClient? _client;
  static String? _deploymentUrl;
  static bool _isInitialized = false;

  /// Initialize Convex client with deployment URL
  static void initialize(String deploymentUrl) {
    if (_isInitialized && _client != null) {
      debugPrint('ConvexConfig: Already initialized');
      return;
    }

    _deploymentUrl = deploymentUrl;
    _client = ConvexClient(deploymentUrl);
    _isInitialized = true;
    
    debugPrint('ConvexConfig: Initialized with deployment URL: $deploymentUrl');
  }

  /// Get the Convex client instance
  static ConvexClient get client {
    if (_client == null) {
      throw StateError('ConvexConfig: Client not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Check if client is initialized
  static bool get isInitialized => _isInitialized;

  /// Get deployment URL
  static String? get deploymentUrl => _deploymentUrl;

  /// Get authenticated user ID (subject from identity token)
  static String? get currentUserId => _client?.auth.getUserIdentity()?.subject;

  /// Check if user is authenticated
  static bool get isAuthenticated => _client?.auth.getUserIdentity() != null;

  /// Dispose the client
  static void dispose() {
    _client?.close();
    _client = null;
    _isInitialized = false;
    debugPrint('ConvexConfig: Disposed');
  }
}

/// Provider for Convex client
final convexClientProvider = Provider<ConvexClient>((ref) {
  if (!ConvexConfig.isInitialized) {
    throw StateError('ConvexConfig not initialized. Call ConvexConfig.initialize() in main().');
  }
  return ConvexConfig.client;
});