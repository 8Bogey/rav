import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneratorSettings {
  final int id;
  final String name;
  final String phoneNumber;
  final String address;
  final String logoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  GeneratorSettings({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.logoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GeneratorSettings.fromDatabase(GeneratorSettingsData data) {
    return GeneratorSettings(
      id: data.id,
      name: data.name,
      phoneNumber: data.phoneNumber,
      address: data.address,
      logoPath: data.logoPath ?? '',
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  GeneratorSettingsTableCompanion toCompanion(bool forInsert) {
    return GeneratorSettingsTableCompanion(
      id: forInsert ? const Value.absent() : Value(id),
      name: Value(name),
      phoneNumber: Value(phoneNumber),
      address: Value(address),
      logoPath: Value(logoPath),
      createdAt: forInsert ? const Value.absent() : Value(createdAt),
      updatedAt: Value(DateTime.now()),
    );
  }
}

// Extension to add database table for generator settings
extension GeneratorSettingsTable on AppDatabase {
  Future<void> createGeneratorSettingsTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS generator_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        address TEXT NOT NULL,
        logo_path TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}

class SettingsService {
  final AppDatabase database;

  SettingsService(this.database);

  // Get generator settings
  Future<GeneratorSettings?> getGeneratorSettings() async {
    try {
      final results = await database.select(database.generatorSettingsTable).get();
      
      if (results.isEmpty) {
        // Create default settings if none exist
        final defaultSettings = GeneratorSettings(
          id: 1,
          name: 'المولد الذكي',
          phoneNumber: '07701234567',
          address: 'بغداد - المنصور - شارع الحرية',
          logoPath: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await database.into(database.generatorSettingsTable).insert(
          GeneratorSettingsTableCompanion.insert(
            name: defaultSettings.name,
            phoneNumber: defaultSettings.phoneNumber,
            address: defaultSettings.address,
            logoPath: Value(defaultSettings.logoPath),
          ),
        );
        
        return defaultSettings;
      }
      
      final data = results.first;
      return GeneratorSettings.fromDatabase(data);
    } catch (e) {
      // Return default settings on error
      return GeneratorSettings(
        id: 1,
        name: 'المولد الذكي',
        phoneNumber: '07701234567',
        address: 'بغداد - المنصور - شارع الحرية',
        logoPath: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Update generator settings
  Future<bool> updateGeneratorSettings(GeneratorSettings settings) async {
    try {
      await database.into(database.generatorSettingsTable).insertOnConflictUpdate(
        GeneratorSettingsTableCompanion(
          id: Value(settings.id),
          name: Value(settings.name),
          phoneNumber: Value(settings.phoneNumber),
          address: Value(settings.address),
          logoPath: Value(settings.logoPath),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get theme preference
  Future<String> getThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('theme_preference') ?? 'system';
    } catch (e) {
      return 'system';
    }
  }

  // Set theme preference
  Future<void> setThemePreference(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_preference', theme);
    } catch (e) {
      // Silent fail
    }
  }

  // Get language preference
  Future<String> getLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('language_preference') ?? 'ar';
    } catch (e) {
      return 'ar';
    }
  }

  // Set language preference
  Future<void> setLanguagePreference(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_preference', language);
    } catch (e) {
      // Silent fail
    }
  }

  // Get printer settings
  Future<Map<String, dynamic>> getPrinterSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'printerName': prefs.getString('printer_name') ?? 'default',
        'paperSize': prefs.getString('paper_size') ?? 'a4',
        'documentTitle': prefs.getString('document_title') ?? 'مولد الدين الإسلامي',
        'documentPhone': prefs.getString('document_phone') ?? '07701234567',
      };
    } catch (e) {
      return {
        'printerName': 'default',
        'paperSize': 'a4',
        'documentTitle': 'مولد الدين الإسلامي',
        'documentPhone': '07701234567',
      };
    }
  }

  // Set printer settings
  Future<void> setPrinterSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (settings['printerName'] != null) {
        await prefs.setString('printer_name', settings['printerName']);
      }
      if (settings['paperSize'] != null) {
        await prefs.setString('paper_size', settings['paperSize']);
      }
      if (settings['documentTitle'] != null) {
        await prefs.setString('document_title', settings['documentTitle']);
      }
      if (settings['documentPhone'] != null) {
        await prefs.setString('document_phone', settings['documentPhone']);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Get notification settings
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'paymentReminders': prefs.getBool('payment_reminders') ?? true,
        'reminderDays': prefs.getInt('reminder_days') ?? 1,
        'syncNotifications': prefs.getBool('sync_notifications') ?? true,
        'systemAlerts': prefs.getBool('system_alerts') ?? true,
        'whatsappNotifications': prefs.getBool('whatsapp_notifications') ?? false,
      };
    } catch (e) {
      return {
        'paymentReminders': true,
        'reminderDays': 1,
        'syncNotifications': true,
        'systemAlerts': true,
        'whatsappNotifications': false,
      };
    }
  }

  // Set notification settings
  Future<void> setNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (settings['paymentReminders'] != null) {
        await prefs.setBool('payment_reminders', settings['paymentReminders']);
      }
      if (settings['reminderDays'] != null) {
        await prefs.setInt('reminder_days', settings['reminderDays']);
      }
      if (settings['syncNotifications'] != null) {
        await prefs.setBool('sync_notifications', settings['syncNotifications']);
      }
      if (settings['systemAlerts'] != null) {
        await prefs.setBool('system_alerts', settings['systemAlerts']);
      }
      if (settings['whatsappNotifications'] != null) {
        await prefs.setBool('whatsapp_notifications', settings['whatsappNotifications']);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Get security settings
  Future<Map<String, dynamic>> getSecuritySettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'autoLock': prefs.getBool('auto_lock') ?? true,
        'autoLockMinutes': prefs.getInt('auto_lock_minutes') ?? 5,
      };
    } catch (e) {
      return {
        'autoLock': true,
        'autoLockMinutes': 5,
      };
    }
  }

  // Set security settings
  Future<void> setSecuritySettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (settings['autoLock'] != null) {
        await prefs.setBool('auto_lock', settings['autoLock']);
      }
      if (settings['autoLockMinutes'] != null) {
        await prefs.setInt('auto_lock_minutes', settings['autoLockMinutes']);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Get backup settings
  Future<Map<String, dynamic>> getBackupSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'cloudBackupEnabled': prefs.getBool('cloud_backup_enabled') ?? true,
        'autoBackupFrequency': prefs.getString('auto_backup_frequency') ?? 'daily',
        'lastBackupTime': prefs.getString('last_backup_time'),
      };
    } catch (e) {
      return {
        'cloudBackupEnabled': true,
        'autoBackupFrequency': 'daily',
        'lastBackupTime': null,
      };
    }
  }

  // Set backup settings
  Future<void> setBackupSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (settings['cloudBackupEnabled'] != null) {
        await prefs.setBool('cloud_backup_enabled', settings['cloudBackupEnabled']);
      }
      if (settings['autoBackupFrequency'] != null) {
        await prefs.setString('auto_backup_frequency', settings['autoBackupFrequency']);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Update last backup time
  Future<void> updateLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_backup_time', DateTime.now().toIso8601String());
    } catch (e) {
      // Silent fail
    }
  }

  // Get ampere price
  Future<double> getAmperePrice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('ampere_price') ?? 2500.0;
    } catch (e) {
      return 2500.0;
    }
  }

  // Set ampere price
  Future<void> setAmperePrice(double price) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('ampere_price', price);
    } catch (e) {
      // Silent fail
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString('app_password');
      
      if (storedPassword == null) {
        // First time setting password
        await prefs.setString('app_password', newPassword);
        return true;
      }
      
      if (storedPassword != currentPassword) {
        return false; // Wrong current password
      }
      
      await prefs.setString('app_password', newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if password is set
  Future<bool> isPasswordSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('app_password') != null;
    } catch (e) {
      return false;
    }
  }

  // Logout all sessions (clear all session data)
  Future<void> logoutAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session_token');
      await prefs.remove('session_expires');
      await prefs.remove('user_id');
      // Keep password but clear session
    } catch (e) {
      // Silent fail
    }
  }

  // Get last backup time
  Future<DateTime?> getLastBackupTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString('last_backup_time');
      if (timeStr != null) {
        return DateTime.parse(timeStr);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Create local backup
  Future<String?> createBackup(AppDatabase database) async {
    try {
      // Export database to JSON
      final subscribers = await database.select(database.subscribersTable).get();
      final cabinets = await database.select(database.cabinetsTable).get();
      final payments = await database.select(database.paymentsTable).get();
      final workers = await database.select(database.workersTable).get();
      final generatorSettings = await database.select(database.generatorSettingsTable).get();
      
      final backupData = {
        'version': '1.0.0',
        'createdAt': DateTime.now().toIso8601String(),
        'subscribers': subscribers.map((s) => {
          'id': s.id,
          'name': s.name,
          'code': s.code,
          'cabinet': s.cabinet,
          'phone': s.phone,
          'status': s.status,
          'accumulatedDebt': s.accumulatedDebt,
        }).toList(),
        'cabinets': cabinets.map((c) => {
          'id': c.id,
          'name': c.name,
          'letter': c.letter,
          'currentSubscribers': c.currentSubscribers,
          'totalSubscribers': c.totalSubscribers,
        }).toList(),
        'payments': payments.map((p) => {
          'id': p.id,
          'subscriberId': p.subscriberId,
          'amount': p.amount,
          'date': p.date.toIso8601String(),
          'worker': p.worker,
        }).toList(),
        'workers': workers.map((w) => {
          'id': w.id,
          'name': w.name,
          'phone': w.phone,
        }).toList(),
        'generatorSettings': generatorSettings.map((g) => {
          'id': g.id,
          'name': g.name,
          'phoneNumber': g.phoneNumber,
          'address': g.address,
        }).toList(),
      };
      
      return backupData.toString();
    } catch (e) {
      return null;
    }
  }

  // Restore from backup
  Future<bool> restoreBackup(String backupData) async {
    // This would require parsing the backup data and restoring to database
    // For now, just return false as it's complex
    return false;
  }
}