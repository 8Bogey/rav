// Convex Client - Standardized HTTP API Client
// 
// This module provides a unified client for interacting with Convex Cloud.
// Currently uses HTTP for queries and mutations.
// 
// ARCHITECTURE DECISION:
// - Using custom HTTP client instead of official Convex SDK to avoid version compatibility issues
// - HTTP provides reliable request/response for CRUD operations
// - Real-time subscriptions (WebSocket) can be added later when needed
// 
// FUTURE ENHANCEMENT:
// - Add WebSocket support via dart:io WebSocket for real-time down-sync
// - This would enable: subscribe to queries, receive push notifications on data changes

import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Centralized Convex client for all cloud operations.
/// 
/// Provides:
/// - Query execution (read)
/// - Mutation execution (write)
/// - Authentication management
/// - Connection state tracking
class ConvexClient {
  final String deploymentUrl;
  String? _authToken;
  final http.Client _httpClient;
  
  // Connection state
  bool _isInitialized = false;
  
  ConvexClient({
    required this.deploymentUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  /// Initialize the client
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint('ConvexClient: Initialized');
  }
  
  /// Check if initialized
  bool get isInitialized => _isInitialized;
  
  /// Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('ConvexClient: Auth token ${token != null ? 'set' : 'cleared'}');
  }
  
  /// Check if authenticated
  bool get isAuthenticated => _authToken != null;
  
  /// Execute a query (read operation)
  Future<dynamic> query(String queryName, [Map<String, dynamic>? args]) async {
    final url = Uri.parse('$deploymentUrl/api/query/$queryName');
    
    final response = await _httpClient.post(
      url,
      headers: _buildHeaders(),
      body: args != null ? jsonEncode(args) : '{}',
    );
    
    return _handleResponse(response);
  }
  
  /// Execute a mutation (write operation)
  Future<dynamic> mutation(String mutationName, [Map<String, dynamic>? args]) async {
    final url = Uri.parse('$deploymentUrl/api/mutation/$mutationName');
    
    final response = await _httpClient.post(
      url,
      headers: _buildHeaders(),
      body: args != null ? jsonEncode(args) : '{}',
    );
    
    return _handleResponse(response);
  }
  
  /// Execute an action (server-side function)
  Future<dynamic> action(String actionName, [Map<String, dynamic>? args]) async {
    final url = Uri.parse('$deploymentUrl/api/action/$actionName');
    
    final response = await _httpClient.post(
      url,
      headers: _buildHeaders(),
      body: args != null ? jsonEncode(args) : '{}',
    );
    
    return _handleResponse(response);
  }
  
  /// Build HTTP headers for requests
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }
  
  /// Handle HTTP response and parse result
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // Convex returns { value: ... } for successful responses
      if (body is Map && body.containsKey('value')) {
        return body['value'];
      }
      return body;
    } else if (response.statusCode == 401) {
      throw ConvexAuthException('Authentication required');
    } else {
      throw ConvexException('Request failed: ${response.statusCode} - ${response.body}');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _httpClient.close();
    _isInitialized = false;
    debugPrint('ConvexClient: Disposed');
  }
}

/// Exception for authentication failures
class ConvexAuthException implements Exception {
  final String message;
  ConvexAuthException(this.message);
  
  @override
  String toString() => 'ConvexAuthException: $message';
}

/// Exception for general Convex errors
class ConvexException implements Exception {
  final String message;
  ConvexException(this.message);
  
  @override
  String toString() => 'ConvexException: $message';
}
