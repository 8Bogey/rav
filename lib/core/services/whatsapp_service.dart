import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/whatsapp_templates_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class WhatsappService extends BaseService {
  WhatsappService(super.database);

  WhatsappTemplatesDao get _dao => database.whatsappTemplatesDao;
  late final OutboxService _outbox = OutboxService(database);
  static const _uuid = Uuid();

  // Get all WhatsApp templates
  Future<List<WhatsappTemplateData>> getAllTemplates(
      {required String ownerId}) {
    return _dao.getAllTemplates(ownerId: ownerId);
  }

  // Get active WhatsApp template
  Future<WhatsappTemplateData?> getActiveTemplate({required String ownerId}) {
    return _dao.getActiveTemplate(ownerId: ownerId);
  }

  // Add a new WhatsApp template
  Future<String> addTemplate({
    required String title,
    required String content,
    required bool isActive,
    required String ownerId,
  }) {
    final id = _uuid.v4();
    final now = DateTime.now();
    final companion = WhatsappTemplatesTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      title: Value(title),
      content: Value(content),
      isActive: Value(isActive),
      version: const Value(1),
      inTrash: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'whatsappTemplates',
      operationType: 'create',
      documentId: id,
      payload: {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'content': content,
        'isActive': isActive,
        'version': 1,
        'inTrash': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );

    return _dao.addTemplate(companion);
  }

  // Update a WhatsApp template
  Future<bool> updateTemplate(WhatsappTemplatesTableCompanion companion) {
    return _dao.updateTemplate(companion);
  }

  // Soft delete a WhatsApp template
  Future<int> deleteTemplate(String id) {
    return _dao.deleteTemplate(id);
  }

  // Get subscribers count
  Future<int> getSubscribersCount({required String ownerId}) async {
    final subscribers =
        await database.subscribersDao.getAllSubscribers(ownerId: ownerId);
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

  // Watch all templates (reactive stream)
  Stream<List<WhatsappTemplateData>> watchTemplates({required String ownerId}) {
    return _dao.watchAllTemplates(ownerId: ownerId);
  }
}
