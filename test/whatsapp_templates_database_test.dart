import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/whatsapp_service.dart';

void main() {
  group('Whatsapp Templates Database Tests', () {
    late AppDatabase database;
    late WhatsappService whatsappService;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();
      
      // Initialize the database and service
      database = AppDatabase(executor);
      whatsappService = WhatsappService(database);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    test('Can add and retrieve a whatsapp template', () async {
      // Create a new whatsapp template
      final template = WhatsappTemplate(
        id: 0, // Will be auto-generated
        title: 'Payment Reminder',
        content: 'Dear customer, we remind you of the payment due on the 10th of each month.',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add the whatsapp template to the database
      final id = await whatsappService.addTemplate(template);
      
      // Verify that the whatsapp template was added
      expect(id, greaterThan(0));

      // Retrieve the whatsapp template from the database
      final retrievedTemplate = await whatsappService.getActiveTemplate();
      
      // Verify that the whatsapp template was retrieved correctly
      expect(retrievedTemplate, isNot(isNull));
      expect(retrievedTemplate!.title, equals('Payment Reminder'));
      expect(retrievedTemplate.content, equals('Dear customer, we remind you of the payment due on the 10th of each month.'));
      expect(retrievedTemplate.isActive, isTrue);
    });

    test('Can update a whatsapp template', () async {
      // Create and add a whatsapp template
      final template = WhatsappTemplate(
        id: 0,
        title: 'Original Template',
        content: 'Original content',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await whatsappService.addTemplate(template);

      // Update the whatsapp template
      final updatedTemplate = WhatsappTemplate(
        id: id,
        title: 'Updated Template',
        content: 'Updated content',
        isActive: true,
        createdAt: template.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await whatsappService.updateTemplate(updatedTemplate);
      
      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve all templates
      final templates = await whatsappService.getAllTemplates();
      
      // Verify that the whatsapp template was updated correctly
      expect(templates, isNotEmpty);
      final updatedEntry = templates.firstWhere((t) => t.id == id);
      expect(updatedEntry.title, equals('Updated Template'));
      expect(updatedEntry.content, equals('Updated content'));
      expect(updatedEntry.isActive, isTrue);
    });

    test('Can delete a whatsapp template', () async {
      // Create and add a whatsapp template
      final template = WhatsappTemplate(
        id: 0,
        title: 'Template to Delete',
        content: 'Content to delete',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await whatsappService.addTemplate(template);

      // Delete the whatsapp template
      final deletedCount = await whatsappService.deleteTemplate(id);
      
      // Verify that the whatsapp template was deleted
      expect(deletedCount, equals(1));

      // Retrieve all templates
      final templates = await whatsappService.getAllTemplates();
      
      // Verify that the whatsapp template no longer exists
      expect(templates.any((t) => t.id == id), isFalse);
    });

    test('Can get all whatsapp templates', () async {
      // Add a few whatsapp templates
      final template1 = WhatsappTemplate(
        id: 0,
        title: 'Template 1',
        content: 'Content for template 1',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final template2 = WhatsappTemplate(
        id: 0,
        title: 'Template 2',
        content: 'Content for template 2',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await whatsappService.addTemplate(template1);
      await whatsappService.addTemplate(template2);

      // Get all whatsapp templates
      final templates = await whatsappService.getAllTemplates();
      
      // Verify that we got the whatsapp templates
      expect(templates, isNotEmpty);
      expect(templates.length, greaterThanOrEqualTo(2));
    });
  });
}