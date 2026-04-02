/// Utility class for Convex ID handling.
///
/// Convex uses proprietary Base32-encoded document IDs (e.g., "abc123...").
/// Standard UUIDs cannot be used directly as Convex document IDs.
///
/// This class provides methods to:
/// - Generate valid Convex IDs (by omitting for new docs)
/// - Map between local UUIDs and Convex document IDs
class ConvexIdUtils {
  ConvexIdUtils._();

  /// Placeholder to indicate a new document should be created.
  /// Convex will auto-generate the document ID.
  static const String newDocumentMarker = '__NEW_DOCUMENT__';

  /// Check if an ID is a standard UUID format
  static bool isUuid(String id) {
    // Standard UUID pattern: 8-4-4-4-12 hex digits
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  /// Check if an ID looks like a Convex document ID (Base32-like)
  /// Convex IDs are typically alphanumeric, 12+ characters
  static bool isConvexId(String id) {
    if (id.isEmpty) return false;
    // Convex IDs are usually lowercase alphanumeric, 12+ chars
    if (id.length < 12) return false;
    return RegExp(r'^[a-z0-9]+$').hasMatch(id);
  }

  /// For new documents, don't pass an ID - let Convex generate one.
  /// This returns null to indicate "create new".
  ///
  /// For existing documents, pass the Convex document ID.
  /// This returns the Convex ID string.
  static String? forDocument({String? localId, String? convexId}) {
    if (convexId != null && convexId.isNotEmpty) {
      // We have a Convex ID - use it for update
      return convexId;
    }
    // No Convex ID - this is a new document, don't pass id
    return null;
  }
}