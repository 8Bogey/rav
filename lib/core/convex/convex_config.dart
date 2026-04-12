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

/// Retry helper with exponential backoff
class _RetryHelper {
  static Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    required bool Function(T result) isSuccess,
  }) async {
    var delay = initialDelay;
    Object? lastError;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final result = await operation();
        if (isSuccess(result)) return result;
      } catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          debugPrint(
              '[Retry] Attempt ${attempt + 1} failed: $e, retrying in ${delay.inSeconds}s');
          await Future.delayed(delay);
          delay *= 2; // Exponential backoff
        }
      }
    }
    throw Exception(
        'Operation failed after ${maxRetries + 1} attempts: $lastError');
  }
}

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

    debugPrint(
        'AppConvexConfig: Initialized with deployment URL: $deploymentUrl');
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

  /// Make a mutation request to Convex with retry and exponential backoff
  static Future<Map<String, dynamic>> mutation(
    String mutationName,
    Map<String, dynamic> args,
  ) async {
    if (_deploymentUrl == null) {
      throw Exception('Convex not initialized');
    }

    return _RetryHelper.withRetry<Map<String, dynamic>>(
      operation: () => _executeMutation(mutationName, args),
      maxRetries: 3,
      initialDelay: const Duration(seconds: 1),
      isSuccess: (result) => true,
    );
  }

  /// Internal mutation execution (called by retry helper)
  static Future<Map<String, dynamic>> _executeMutation(
    String mutationName,
    Map<String, dynamic> args,
  ) async {
    // Convex HTTP API format: POST /api/mutation with JSON body containing path and args
    final url = Uri.parse('$_deploymentUrl/api/mutation');

    debugPrint('════════════════════════════════════════');
    debugPrint('CONVEX HTTP REQUEST:');
    debugPrint('URL: $url');
    debugPrint('Mutation: $mutationName');
    debugPrint('Authenticated: $isAuthenticated');
    if (_authToken != null) {
      final tokenLen = _authToken!.length;
      final previewLen = tokenLen > 20 ? 20 : tokenLen;
      debugPrint(
          'Token: ${_authToken!.substring(0, previewLen)}... (len=$tokenLen)');
    }
    debugPrint('Body: ${jsonEncode(args)}');
    debugPrint('════════════════════════════════════════');

    // Build request body per Convex HTTP API spec
    final requestBody = {
      'path': mutationName,
      'args': args,
      'format': 'json',
    };

    // Send auth header only for real JWT tokens (not guest-token)
    final hasValidJwt = _authToken != null &&
        _authToken!.isNotEmpty &&
        _authToken != 'guest-token';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (hasValidJwt) 'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(requestBody),
    );

    debugPrint('RESPONSE STATUS: ${response.statusCode}');
    debugPrint('RESPONSE HEADERS: ${response.headers}');
    debugPrint('RESPONSE BODY: ${response.body}');
    debugPrint('═══════════════════════════════════════');

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        // Convex returns {"status": "success", "value": {...}} or {"status": "error", "errorMessage": "..."}
        if (responseData['status'] == 'success') {
          return responseData['value'] as Map<String, dynamic>;
        } else if (responseData['status'] == 'error') {
          throw Exception('Convex error: ${responseData['errorMessage']}');
        }
        return responseData;
      } catch (e) {
        debugPrint('JSON DECODE ERROR: $e');
        debugPrint('Response was not valid JSON: ${response.body}');
        throw Exception('Invalid JSON response: ${response.body}');
      }
    } else {
      debugPrint(
          '[Convex] mutation failed: ${response.statusCode} ${response.body}');
      throw Exception('Convex mutation failed: ${response.body}');
    }
  }

  /// Make a query request to Convex with retry and exponential backoff
  static Future<dynamic> query(
    String queryName,
    Map<String, dynamic> args,
  ) async {
    if (_deploymentUrl == null) {
      throw Exception('Convex not initialized');
    }

    return _RetryHelper.withRetry<dynamic>(
      operation: () => _executeQuery(queryName, args),
      maxRetries: 3,
      initialDelay: const Duration(seconds: 1),
      isSuccess: (result) => true,
    );
  }

  /// Internal query execution (called by retry helper)
  static Future<dynamic> _executeQuery(
    String queryName,
    Map<String, dynamic> args,
  ) async {
    // Convex HTTP API format: POST /api/query with JSON body containing path and args
    final url = Uri.parse('$_deploymentUrl/api/query');

    debugPrint('════════════════════════════════════════');
    debugPrint('CONVEX HTTP QUERY:');
    debugPrint('URL: $url');
    debugPrint('Query: $queryName');
    debugPrint('Body: ${jsonEncode(args)}');
    debugPrint('════════════════════════════════════════');

    // Build request body per Convex HTTP spec
    final requestBody = {
      'path': queryName,
      'args': args,
      'format': 'json',
    };

    // Send auth header only for real JWT tokens (not guest-token)
    final hasValidJwt = _authToken != null &&
        _authToken!.isNotEmpty &&
        _authToken != 'guest-token';

    debugPrint(
        '[ConvexQuery] Auth: validJWT=$hasValidJwt, token=${_authToken?.substring(0, _authToken != null && _authToken!.length > 10 ? 10 : 0)}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Only send auth header if we have a valid JWT
        if (hasValidJwt) 'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(requestBody),
    );

    debugPrint('RESPONSE STATUS: ${response.statusCode}');
    debugPrint(
        'RESPONSE BODY (first 500): ${response.body.length > 500 ? response.body.substring(0, 500) : response.body}');
    debugPrint('═══════════════════════════════════════');

    // Check if response is valid JSON before parsing
    if (response.body.isEmpty) {
      debugPrint('ERROR: Empty response body');
      throw Exception('Convex query failed: Empty response');
    }

    // Check for non-JSON responses (like HTML error pages)
    final bodyTrimmed = response.body.trim();
    if (!bodyTrimmed.startsWith('{') && !bodyTrimmed.startsWith('[')) {
      debugPrint('ERROR: Response is not JSON. Status: ${response.statusCode}');
      debugPrint(
          'This likely means Convex returned an error page instead of JSON');
      throw Exception(
          'Convex query failed: Non-JSON response - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
    }

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
        // Convex returns {"status": "success", "value": {...}} or {"status": "error", "errorMessage": "..."}
        if (responseData['status'] == 'success') {
          return responseData['value'];
        } else if (responseData['status'] == 'error') {
          throw Exception('Convex error: ${responseData['errorMessage']}');
        }
        return responseData;
      } catch (e) {
        debugPrint('ERROR: Failed to parse JSON: $e');
        debugPrint('Raw response: ${response.body}');
        throw Exception('Convex query failed: Invalid JSON - ${response.body}');
      }
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
