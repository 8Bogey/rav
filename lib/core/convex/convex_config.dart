// Convex Client Configuration
// 
// ARCHITECTURE DECISION:
// - Using custom HTTP client instead of official Convex SDK to avoid version compatibility issues
// - HTTP provides reliable request/response for CRUD operations
// - Real-time subscriptions (WebSocket) can be added later when needed
//
// STANDARDIZATION: This file is the canonical Convex client.
// All cloud operations should go through AppConvexConfig (not direct HTTP calls).
//
// FUTURE ENHANCEMENT:
// - Add WebSocket support via dart:io WebSocket for real-time down-sync
// - This would enable: subscribe to queries, receive push notifications on data changes

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// App's Convex configuration - unified client for all cloud operations.
/// 
/// Provides:
/// - Query execution (read)
/// - Mutation execution (write)  
/// - Action execution (server-side functions)
/// - Authentication management
/// - Connection state tracking
class AppConvexConfig {
  static String? _deploymentUrl;
  static bool _isInitialized = false;
  static String? _authToken;
  static http.Client? _httpClient;

  /// Initialize Convex client with deployment URL
  static Future<void> initialize(String deploymentUrl) async {
    if (_isInitialized) {
      debugPrint('AppConvexConfig: Already initialized');
      return;
    }

    _deploymentUrl = deploymentUrl;
    _isInitialized = true;
    
    debugPrint('AppConvexConfig: Initialized with deployment URL: $deploymentUrl');
  }

  /// Check if client is initialized
  static bool get isInitialized => _isInitialized;

  /// Get deployment URL
  static String? get deploymentUrl => _deploymentUrl;

  /// Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;

  /// Set authentication token (call on login)
  static Future<void> setAuth(String? token) async {
    _authToken = token;
    debugPrint('AppConvexConfig: Auth token set');
  }

  /// Clear authentication (call on logout)
  static Future<void> clearAuth() async {
    _authToken = null;
    debugPrint('AppConvexConfig: Auth cleared');
  }

  /// Make a mutation request to Convex
  static Future<Map<String, dynamic>> mutation(
    String mutationName, 
    Map<String, dynamic> args,
  ) async {
    if (_deploymentUrl == null) {
      throw Exception('Convex not initialized');
    }

    final url = Uri.parse('$_deploymentUrl/api/mutation/$mutationName');
    
    debugPrint('════════════════════════════════════════');
    debugPrint('CONVEX HTTP REQUEST:');
    debugPrint('URL: $url');
    debugPrint('Mutation: $mutationName');
    debugPrint('Authenticated: $isAuthenticated');
    if (_authToken != null) {
      final tokenLen = _authToken!.length;
      final previewLen = tokenLen > 20 ? 20 : tokenLen;
      debugPrint('Token: ${_authToken!.substring(0, previewLen)}... (len=$tokenLen)');
    }
    debugPrint('Body: ${jsonEncode(args)}');
    debugPrint('════════════════════════════════════════');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(args),
      );

      debugPrint('RESPONSE STATUS: ${response.statusCode}');
      debugPrint('RESPONSE BODY: ${response.body}');
      debugPrint('═══════════════════════════════════════');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('[Convex] mutation failed: ${response.statusCode} ${response.body}');
        throw Exception('Convex mutation failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('HTTP ERROR: $e');
      rethrow;
    }
  }

  /// Make a query request to Convex
  static Future<dynamic> query(
    String queryName, 
    Map<String, dynamic> args,
  ) async {
    if (_deploymentUrl == null) {
      throw Exception('Convex not initialized');
    }

    final url = Uri.parse('$_deploymentUrl/api/query/$queryName');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(args),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Convex query failed: ${response.body}');
    }
  }

  /// Dispose the client
  static void dispose() {
    _deploymentUrl = null;
    _isInitialized = false;
    _authToken = null;
    debugPrint('AppConvexConfig: Disposed');
  }
}

/// Provider placeholder (can be extended later if needed)
final convexClientProvider = Provider<dynamic>((ref) {
  if (!AppConvexConfig.isInitialized) {
    throw StateError('AppConvexConfig not initialized');
  }
  return AppConvexConfig;
});
