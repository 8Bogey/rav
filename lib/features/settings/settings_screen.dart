import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/settings_service.dart';
import 'package:mawlid_al_dhaki/core/sync/network_status_provider.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';
import 'package:mawlid_al_dhaki/features/settings/widgets/settings_sidebar.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/general_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/appearance_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/printing_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/security_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/sync_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/notifications_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/backup_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/license_section.dart';
import 'package:mawlid_al_dhaki/features/settings/sections/trash_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final syncState = ref.watch(networkStatusProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإعدادات',
                style: AppTypography.h2.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                ),
              ),
              GestureDetector(
                onTap: () => _saveAllSettings(context, ref),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.save,
                        color: AppColors.textOnGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حفظ الإعدادات',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.textOnGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Two-column layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings sidebar
                SettingsSidebar(isDarkMode: isDarkMode),
                const SizedBox(width: 16),
                // Content area
                _buildContentArea(
                    isDarkMode: isDarkMode, syncState: syncState, ref: ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea({
    required bool isDarkMode,
    required NetworkStatus syncState,
    required WidgetRef ref,
  }) {
    final selectedSection = ref.watch(settingsSectionProvider);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final fade = FadeTransition(opacity: animation, child: child);
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(position: slide, child: fade);
            },
            child: KeyedSubtree(
              key: ValueKey(selectedSection),
              child: _buildSectionContent(
                selectedSection,
                isDarkMode: isDarkMode,
                syncState: syncState,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent(
    String section, {
    required bool isDarkMode,
    required NetworkStatus syncState,
  }) {
    switch (section) {
      case 'معلومات المولد':
        return const GeneralSection();
      case 'المظهر':
        return const AppearanceSection();
      case 'الطباعة':
        return const PrintingSection();
      case 'الأمان':
        return const SecuritySection();
      case 'المزامنة':
        return const SyncSection();
      case 'الإشعارات':
        return const NotificationsSection();
      case 'النسخ الاحتياطي':
        return const BackupSection();
      case 'الترخيص':
        return const LicenseSection();
      case 'سلة المحذوفات':
        return const TrashSection();
      default:
        return const GeneralSection();
    }
  }

  Future<void> _saveAllSettings(BuildContext context, WidgetRef ref) async {
    final isLoading = ref.read(settingsLoadingProvider);
    if (isLoading) return;

    // Get current values from providers
    final name = ref.read(generatorNameProvider);
    final phone = ref.read(generatorPhoneProvider);
    final address = ref.read(generatorAddressProvider);
    final logoPath = ref.read(logoPathProvider);

    // Set loading state
    ref.read(settingsLoadingProvider.notifier).state = true;

    try {
      // Import and use settings service
      final database = ref.read(databaseProvider);
      final settingsService = SettingsService(database);

      // Save generator settings
      final settings = GeneratorSettings(
        id: '',
        name: name,
        phoneNumber: phone,
        address: address,
        logoPath: logoPath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await settingsService.updateGeneratorSettings(settings);

      // Save printer settings
      await settingsService.setPrinterSettings({
        'printerName': ref.read(printerNameProvider),
        'paperSize': ref.read(paperSizeProvider),
        'documentTitle': ref.read(documentTitleProvider),
        'documentPhone': ref.read(documentPhoneProvider),
      });

      // Save notification settings
      await settingsService.setNotificationSettings({
        'paymentReminders': ref.read(paymentRemindersProvider),
        'reminderDays': ref.read(reminderDaysProvider),
        'syncNotifications': ref.read(syncNotificationsProvider),
        'systemAlerts': ref.read(systemAlertsProvider),
        'whatsappNotifications': ref.read(whatsappNotificationsProvider),
      });

      // Save security settings
      await settingsService.setSecuritySettings({
        'autoLock': ref.read(autoLockProvider),
        'autoLockMinutes': ref.read(autoLockMinutesProvider),
      });

      // Save backup settings
      await settingsService.setBackupSettings({
        'cloudBackupEnabled': ref.read(cloudBackupEnabledProvider),
        'autoBackupFrequency': ref.read(autoBackupFrequencyProvider),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الإعدادات بنجاح'),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ الإعدادات: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    } finally {
      ref.read(settingsLoadingProvider.notifier).state = false;
    }
  }
}
