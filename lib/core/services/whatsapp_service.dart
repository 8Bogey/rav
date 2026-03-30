import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/whatsapp_templates_dao.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WhatsappTemplate {
  final int id;
  final String title;
  final String content;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Sync metadata fields
  final DateTime? lastModified;
  final String? syncStatus;
  final bool? dirtyFlag;
  final String? cloudId;
  final bool? deletedLocally;
  final String? permissionsMask;

  WhatsappTemplate({
    required this.id,
    required this.title,
    required this.content,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastModified,
    this.syncStatus,
    this.dirtyFlag,
    this.cloudId,
    this.deletedLocally,
    this.permissionsMask,
  });

  factory WhatsappTemplate.fromDatabase(WhatsappTemplateData data) {
    return WhatsappTemplate(
      id: data.id,
      title: data.title,
      content: data.content,
      isActive: data.isActive == 1,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      lastModified: data.lastModified,
      syncStatus: data.syncStatus,
      dirtyFlag: data.dirtyFlag,
      cloudId: data.cloudId,
      deletedLocally: data.deletedLocally,
      permissionsMask: data.permissionsMask,
    );
  }

  WhatsappTemplatesTableCompanion toCompanion(bool forInsert) {
    return WhatsappTemplatesTableCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      title: Value(title),
      content: Value(content),
      isActive: Value(isActive ? 1 : 0),
      createdAt: forInsert ? const Value.absent() : Value(createdAt),
      updatedAt: Value(DateTime.now()),
      // Sync metadata fields
      lastModified: Value(lastModified),
      syncStatus: Value(syncStatus),
      dirtyFlag: Value(dirtyFlag),
      cloudId: Value(cloudId),
      deletedLocally: Value(deletedLocally),
      permissionsMask: Value(permissionsMask),
    );
  }
}

class WhatsappService {
  final AppDatabase database;
  late SubscribersService _subscribersService;
  late WhatsappTemplatesDao _templatesDao;

  WhatsappService(this.database) {
    _subscribersService = SubscribersService(database);
    _templatesDao = WhatsappTemplatesDao(database);
  }

  // Get all WhatsApp templates
  Future<List<WhatsappTemplate>> getAllTemplates() async {
    final templates = await _templatesDao.getAllTemplates();
    return templates.map((data) => WhatsappTemplate.fromDatabase(data)).toList();
  }

  // Get active WhatsApp template
  Future<WhatsappTemplate?> getActiveTemplate() async {
    final template = await _templatesDao.getActiveTemplate();
    return template != null ? WhatsappTemplate.fromDatabase(template) : null;
  }

  // Add a new WhatsApp template
  Future<int> addTemplate(WhatsappTemplate template) {
    final companion = template.toCompanion(true);
    return _templatesDao.addTemplate(companion);
  }

  // Update a WhatsApp template
  Future<bool> updateTemplate(WhatsappTemplate template) {
    final companion = template.toCompanion(false);
    return _templatesDao.updateTemplate(companion);
  }

  // Delete a WhatsApp template
  Future<int> deleteTemplate(int id) {
    return _templatesDao.deleteTemplate(id);
  }

  // Get subscribers count
  Future<int> getSubscribersCount() async {
    final subscribers = await _subscribersService.getAllSubscribers();
    return subscribers.length;
  }

  // Get recent WhatsApp messages log
  Future<List<Map<String, dynamic>>> getMessagesLog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('whatsapp_messages_log');
      
      if (messagesJson == null) {
        return [];
      }
      
      final List<dynamic> messages = jsonDecode(messagesJson);
      return messages.map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (e) {
      return [];
    }
  }

  // Log a WhatsApp message
  Future<void> logMessage({
    required String subscriberName,
    required String subscriberPhone,
    required String message,
    required bool isSuccess,
    String? errorMessage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing messages
      final messagesJson = prefs.getString('whatsapp_messages_log');
      List<Map<String, dynamic>> messages = [];
      
      if (messagesJson != null) {
        messages = (jsonDecode(messagesJson) as List)
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
      
      // Add new message at the beginning
      messages.insert(0, {
        'subscriberName': subscriberName,
        'subscriberPhone': subscriberPhone,
        'message': message,
        'isSuccess': isSuccess,
        'errorMessage': errorMessage,
        'time': DateTime.now().toIso8601String(),
      });
      
      // Keep only last 50 messages
      if (messages.length > 50) {
        messages = messages.sublist(0, 50);
      }
      
      await prefs.setString('whatsapp_messages_log', jsonEncode(messages));
    } catch (e) {
      // Silent fail
    }
  }

  // Get dirty templates (those with dirtyFlag = true)
  Future<List<WhatsappTemplateData>> getDirtyTemplates() {
    return _templatesDao.getDirtyTemplates();
  }
  
  // Mark a template record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return _templatesDao.markConflictForManualResolution(id);
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return _templatesDao.updateConflictResolution(
      id,
      conflictResolutionStrategy: conflictResolutionStrategy,
      conflictResolvedAt: conflictResolvedAt,
      conflictOrigin: conflictOrigin,
    );
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return _templatesDao.markDeletedLocally(id);
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return _templatesDao.undeleteRecord(id);
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return _templatesDao.updateSyncError(id, errorMessage);
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return _templatesDao.incrementSyncRetryCount(id);
  }
  
  // Update sync status
  Future<int> updateSyncStatus(int id, String status) {
    return _templatesDao.updateSyncStatus(id, status);
  }
  
  // Mark record as dirty
  Future<int> markRecordAsDirty(int id) {
    return _templatesDao.markRecordAsDirty(id);
  }
  
  // Clear dirty flag
  Future<int> clearDirtyFlag(int id) {
    return _templatesDao.clearDirtyFlag(id);
  }
}