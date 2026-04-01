import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/settings_service.dart';
import 'package:mawlid_al_dhaki/core/services/print_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/core/sync/network_status_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings section provider
final settingsSectionProvider =
    StateProvider<String>((ref) => 'معلومات المولد');

// Logo path provider
final logoPathProvider = StateProvider<String>((ref) => '');

// Generator info providers (for persistent editing)
final generatorNameProvider = StateProvider<String>((ref) => 'المولد الذكي');
final generatorPhoneProvider = StateProvider<String>((ref) => '07701234567');
final generatorAddressProvider =
    StateProvider<String>((ref) => 'بغداد - المنصور - شارع الحرية');

// Settings loading state
final settingsLoadingProvider = StateProvider<bool>((ref) => false);

// Printer settings providers
final printerNameProvider = StateProvider<String>((ref) => 'default');
final paperSizeProvider = StateProvider<String>((ref) => 'a4');
final documentTitleProvider =
    StateProvider<String>((ref) => 'مولد الدين الإسلامي');
final documentPhoneProvider = StateProvider<String>((ref) => '07701234567');

// Notification settings providers
final paymentRemindersProvider = StateProvider<bool>((ref) => true);
final reminderDaysProvider = StateProvider<int>((ref) => 1);
final syncNotificationsProvider = StateProvider<bool>((ref) => true);
final systemAlertsProvider = StateProvider<bool>((ref) => true);
final whatsappNotificationsProvider = StateProvider<bool>((ref) => false);

// Security settings providers
final autoLockProvider = StateProvider<bool>((ref) => true);
final autoLockMinutesProvider = StateProvider<int>((ref) => 5);

// Backup settings providers
final cloudBackupEnabledProvider = StateProvider<bool>((ref) => true);
final autoBackupFrequencyProvider = StateProvider<String>((ref) => 'daily');

// Image picker instance
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _playSectionChangeSound() {
    // Best-effort: system click sound. Ignore failures on unsupported platforms.
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

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
          // Header with title and actions - matching Bitepoint style
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

          // Two-column layout - matching PRD requirements
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Settings sidebar
                _buildSettingsSidebar(isDarkMode: isDarkMode, ref: ref),
                const SizedBox(width: 16),
                // Content area
                _buildContentArea(
                    context: context,
                    isDarkMode: isDarkMode,
                    syncState: syncState,
                    ref: ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSidebar(
      {required bool isDarkMode, required WidgetRef ref}) {
    final selectedSection = ref.watch(settingsSectionProvider);

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Sidebar header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkBgSurfaceAlt
                  : AppColors.bgSurfaceAlt,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              'الإعدادات',
              style: AppTypography.h3.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
          ),
          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildMenuItem(
                    'معلومات المولد', selectedSection == 'معلومات المولد',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'معلومات المولد'),
                _buildMenuItem('المظهر', selectedSection == 'المظهر',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'المظهر'),
                _buildMenuItem('الطباعة', selectedSection == 'الطباعة',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'الطباعة'),
                _buildMenuItem('الأمان', selectedSection == 'الأمان',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'الأمان'),
                _buildMenuItem('المزامنة', selectedSection == 'المزامنة',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'المزامنة'),
                _buildMenuItem('الإشعارات', selectedSection == 'الإشعارات',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'الإشعارات'),
                _buildMenuItem(
                    'النسخ الاحتياطي', selectedSection == 'النسخ الاحتياطي',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'النسخ الاحتياطي'),
                _buildMenuItem('الترخيص', selectedSection == 'الترخيص',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'الترخيص'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, bool isSelected,
      {required bool isDarkMode, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        _playSectionChangeSound();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: AppTypography.bodyMd.copyWith(
            color: isSelected
                ? AppColors.textOnPrimary
                : (isDarkMode ? AppColors.darkTextBody : AppColors.textBody),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildContentArea(
      {required BuildContext context,
      required bool isDarkMode,
      required NetworkStatus syncState,
      required WidgetRef ref}) {
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
                ref: ref,
                context: context,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent(String section,
      {required bool isDarkMode,
      required NetworkStatus syncState,
      required WidgetRef ref,
      required BuildContext context}) {
    switch (section) {
      case 'معلومات المولد':
        return _buildGeneratorInfoSection(
            isDarkMode: isDarkMode, context: context, ref: ref);
      case 'المظهر':
        return _buildAppearanceSection(
            isDarkMode: isDarkMode, ref: ref, context: context);
      case 'الطباعة':
        return _buildPrintingSection(
            isDarkMode: isDarkMode, context: context, ref: ref);
      case 'الأمان':
        return _buildSecuritySection(
            isDarkMode: isDarkMode, context: context, ref: ref);
      case 'المزامنة':
        return _buildSyncSection(
            isDarkMode: isDarkMode,
            syncState: syncState,
            ref: ref,
            context: context);
      case 'الإشعارات':
        return _buildNotificationsSection(
            isDarkMode: isDarkMode, context: context, ref: ref);
      case 'النسخ الاحتياطي':
        return _buildBackupSection(
            isDarkMode: isDarkMode, context: context, ref: ref);
      case 'الترخيص':
        return _buildLicenseSection(isDarkMode: isDarkMode);
      default:
        return _buildGeneratorInfoSection(
            isDarkMode: isDarkMode, context: context, ref: ref);
    }
  }

  Widget _buildGeneratorInfoSection(
      {required bool isDarkMode,
      required BuildContext context,
      required WidgetRef ref}) {
    final name = ref.watch(generatorNameProvider);
    final phone = ref.watch(generatorPhoneProvider);
    final address = ref.watch(generatorAddressProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات المولد',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField('اسم المولد', name,
            isDarkMode: isDarkMode,
            onChanged: (v) =>
                ref.read(generatorNameProvider.notifier).state = v),
        const SizedBox(height: 16),
        _buildTextField('رقم الهاتف', phone,
            isDarkMode: isDarkMode,
            onChanged: (v) =>
                ref.read(generatorPhoneProvider.notifier).state = v),
        const SizedBox(height: 16),
        _buildTextField('العنوان', address,
            isDarkMode: isDarkMode,
            onChanged: (v) =>
                ref.read(generatorAddressProvider.notifier).state = v),
        const SizedBox(height: 16),
        Text(
          'الشعار:',
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flash_on,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'شعار المولد',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    Text(
                      'PNG, JPG حتى 2MB',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () async {
                  final picker = ref.read(imagePickerProvider);

                  // Show options: camera or gallery
                  final source = await showModalBottomSheet<ImageSource>(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('الكاميرا'),
                            onTap: () =>
                                Navigator.pop(context, ImageSource.camera),
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('معرض الصور'),
                            onTap: () =>
                                Navigator.pop(context, ImageSource.gallery),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (source == null) return;

                  try {
                    final pickedFile = await picker.pickImage(
                      source: source,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 85,
                    );

                    if (pickedFile != null) {
                      // Save path to provider and SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'generator_logo_path', pickedFile.path);
                      ref.read(logoPathProvider.notifier).state =
                          pickedFile.path;

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم رفع الشعار بنجاح')),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('فشل رفع الصورة: $e')),
                      );
                    }
                  }
                },
                child: Text(
                  '📎 رفع صورة',
                  style: AppTypography.labelLg.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextBody
                        : AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
      {required bool isDarkMode,
      required WidgetRef ref,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المظهر',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),
        _buildSettingRow(
          'الوضع الليلي',
          Switch(
            value: isDarkMode,
            onChanged: (v) => ref
                .read(themeModeProvider.notifier)
                .setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
            activeColor: AppColors.primary,
          ),
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildPrintingSection(
      {required bool isDarkMode,
      required BuildContext context,
      required WidgetRef ref}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الطباعة',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),

        // Printer connection status
        _buildSettingRow(
          'حالة الطابعة',
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusActiveS,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.statusActive,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'متصلة',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.statusActive,
                  ),
                ),
              ],
            ),
          ),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),

        // Printer selection
        _buildSettingRow(
          'الطابعة',
          DropdownButton<String>(
            value: ref.watch(printerNameProvider),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'default', child: Text('طابعة افتراضية')),
              DropdownMenuItem(value: 'thermal', child: Text('طابعة حرارية')),
            ],
            onChanged: (value) {
              if (value != null)
                ref.read(printerNameProvider.notifier).state = value;
            },
          ),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 16),

        // Paper size
        _buildSettingRow(
          'حجم الورق',
          DropdownButton<String>(
            value: ref.watch(paperSizeProvider),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'a4', child: Text('A4')),
              DropdownMenuItem(value: 'a5', child: Text('A5')),
              DropdownMenuItem(value: 'thermal', child: Text('حراري 80mm')),
            ],
            onChanged: (value) {
              if (value != null)
                ref.read(paperSizeProvider.notifier).state = value;
            },
          ),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 24),

        // Receipt header
        Text(
          '头部 المستند',
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField('عنوان المستند', ref.watch(documentTitleProvider),
            isDarkMode: isDarkMode,
            onChanged: (v) =>
                ref.read(documentTitleProvider.notifier).state = v),
        const SizedBox(height: 8),
        _buildTextField('رقم الهاتف', ref.watch(documentPhoneProvider),
            isDarkMode: isDarkMode,
            onChanged: (v) =>
                ref.read(documentPhoneProvider.notifier).state = v),

        const SizedBox(height: 24),

        // Test print button
        OutlinedButton.icon(
          onPressed: () async {
            try {
              await PrintService.printTestPage(
                printerName: ref.read(printerNameProvider),
                documentTitle: ref.read(documentTitleProvider),
                documentPhone: ref.read(documentPhoneProvider),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال صفحة الاختبار إلى الطابعة'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل الطباعة: $e'),
                    backgroundColor: AppColors.statusDanger,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.print),
          label: const Text('اختبار الطباعة'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection(
      {required bool isDarkMode,
      required BuildContext context,
      required WidgetRef ref}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأمان',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),

        // Password change section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تغيير كلمة المرور',
                style: AppTypography.bodyMd.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('كلمة المرور الحالية', '',
                  isDarkMode: isDarkMode, obscure: true),
              const SizedBox(height: 12),
              _buildTextField('كلمة المرور الجديدة', '',
                  isDarkMode: isDarkMode, obscure: true),
              const SizedBox(height: 12),
              _buildTextField('تأكيد كلمة المرور', '',
                  isDarkMode: isDarkMode, obscure: true),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  // Show password change dialog
                  _showChangePasswordDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: const Text('تغيير كلمة المرور'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Session management
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إدارة الجلسات',
                style: AppTypography.bodyMd.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                'الجلسة الحالية',
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.statusActiveS,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.statusActive,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'نشطة',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.statusActive,
                        ),
                      ),
                    ],
                  ),
                ),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 12),
              Text(
                'آخر تسجيل دخول: اليوم - 10:30 صباحاً',
                style: AppTypography.bodySm.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextMuted
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _showLogoutAllSessionsDialog(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.statusDanger,
                  side: const BorderSide(color: AppColors.statusDanger),
                ),
                child: const Text('تسجيل الخروج من جميع الجلسات'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Auto lock
        _buildSettingRow(
          'القفل التلقائي',
          Switch(
            value: ref.watch(autoLockProvider),
            onChanged: (value) =>
                ref.read(autoLockProvider.notifier).state = value,
            activeColor: AppColors.primary,
          ),
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 8),
        Text(
          'قفل التطبيق تلقائياً بعد ${ref.watch(autoLockMinutesProvider)} دقائق من عدم النشاط',
          style: AppTypography.bodySm.copyWith(
            color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(
      {required bool isDarkMode,
      required BuildContext context,
      required WidgetRef ref}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإشعارات',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),

        // Payment reminders
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تذكيرات الدفع',
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'إشعار عند اقتراب موعد الدفع',
                          style: AppTypography.bodySm.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ref.watch(paymentRemindersProvider),
                    onChanged: (value) => ref
                        .read(paymentRemindersProvider.notifier)
                        .state = value,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 36),
                  Text(
                    'قبل ${ref.watch(reminderDaysProvider)} يوم${ref.watch(reminderDaysProvider) > 1 ? '' : ''}',
                    style: AppTypography.bodySm.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Sync notifications
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.sync, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات المزامنة',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'إشعار عند اكتمال المزامنة',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ref.watch(syncNotificationsProvider),
                onChanged: (value) =>
                    ref.read(syncNotificationsProvider.notifier).state = value,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // System alerts
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تنبيهات النظام',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'تحذيرات انخفاض الرصيد والأخطاء',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ref.watch(systemAlertsProvider),
                onChanged: (value) =>
                    ref.read(systemAlertsProvider.notifier).state = value,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // WhatsApp notifications
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.chat, color: AppColors.statusActive),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إشعارات واتساب',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'إشعار عند فشل إرسال الرسالة',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: ref.watch(whatsappNotificationsProvider),
                onChanged: (value) => ref
                    .read(whatsappNotificationsProvider.notifier)
                    .state = value,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackupSection(
      {required bool isDarkMode,
      required BuildContext context,
      required WidgetRef ref}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النسخ الاحتياطي',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),

        // Last backup info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveS,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.backup,
                  color: AppColors.statusActive,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آخر نسخة احتياطية',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'اليوم - 10:30 صباحاً',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveS,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ناجح',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.statusActive,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Local backup
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'نسخ احتياطي محلي',
                    style: AppTypography.bodyMd.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextHead
                          : AppColors.textHeading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCreateBackupDialog(context, ref),
                      icon: const Icon(Icons.backup),
                      label: const Text('إنشاء نسخة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ميزة الاستعادة قيد التطوير'),
                            backgroundColor: AppColors.statusInfo,
                          ),
                        );
                      },
                      icon: const Icon(Icons.restore),
                      label: const Text('استعادة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textBody,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Cloud backup
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نسخ احتياطي للسحابة',
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'مزامنة تلقائية مع Supabase',
                          style: AppTypography.bodySm.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextMuted
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: ref.watch(cloudBackupEnabledProvider),
                    onChanged: (value) => ref
                        .read(cloudBackupEnabledProvider.notifier)
                        .state = value,
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSettingRow(
                'مزامنة تلقائية',
                DropdownButton<String>(
                  value: ref.watch(autoBackupFrequencyProvider),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'hourly', child: Text('كل ساعة')),
                    DropdownMenuItem(value: 'daily', child: Text('يومياً')),
                    DropdownMenuItem(value: 'weekly', child: Text('أسبوعياً')),
                  ],
                  onChanged: (value) {
                    if (value != null)
                      ref.read(autoBackupFrequencyProvider.notifier).state =
                          value;
                  },
                ),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Auto backup schedule info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'النسخ الاحتياطي التلقائي يتم كل يوم الساعة 2:00 صباحاً',
                  style: AppTypography.bodySm.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextBody
                        : AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLicenseSection({required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الترخيص',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.flash_on, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'المولد الذكي',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الإصدار 1.0.0',
                style: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© 2026 جميع الحقوق محفوظة',
                style: AppTypography.bodySm.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextMuted
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String title, Widget trailing,
      {required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.bodyMd.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          trailing,
        ],
      ),
    );
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

  Widget _buildTextField(String label, String value,
      {required bool isDarkMode,
      bool obscure = false,
      Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          obscureText: obscure,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
              ),
            ),
          ),
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncSection(
      {required bool isDarkMode,
      required NetworkStatus syncState,
      required WidgetRef ref,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المزامنة السحابية',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'حالة المزامنة',
                    style: AppTypography.bodyMd.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextHead
                          : AppColors.textHeading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (syncState.isSyncing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else if (syncState.lastSyncTime != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusActive.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'متزامن',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.statusActive,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (syncState.lastSyncTime != null)
                Text(
                  'آخر مزامنة: ${_formatDateTime(syncState.lastSyncTime!)}',
                  style: AppTypography.bodySm.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                ),
              if (syncState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: AppColors.statusDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    syncState.errorMessage!,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.statusDanger,
                    ),
                  ),
                ),
              if (syncState.lastConflictSummaryAr != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: (syncState.manualConflictAttentionCount > 0
                            ? AppColors.statusWarning
                            : AppColors.statusInfo)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    syncState.lastConflictSummaryAr!,
                    style: AppTypography.bodySm.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: syncState.isSyncing
                          ? null
                          : () {
                              ref.read(networkStatusProvider.notifier).syncToCloud();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'مزامنة إلى السحابة',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: syncState.isSyncing
                          ? null
                          : () {
                              ref.read(networkStatusProvider.notifier).syncFromCloud();
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'مزامنة من السحابة',
                        style: AppTypography.labelLg.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextBody
                              : AppColors.textBody,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: syncState.isSyncing
                      ? null
                      : () {
                          ref.read(networkStatusProvider.notifier).syncBothDirections();
                        },
                  child: Text(
                    'مزامنة ثنائي الاتجاه',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمات المرور غير متطابقة'),
                    backgroundColor: AppColors.statusDanger,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور يجب أن تكون 4 أحرف على الأقل'),
                    backgroundColor: AppColors.statusDanger,
                  ),
                );
                return;
              }

              final database = ref.read(databaseProvider);
              final settingsService = SettingsService(database);
              final success = await settingsService.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'تم تغيير كلمة المرور بنجاح'
                        : 'فشل تغيير كلمة المرور - كلمة المرور الحالية غير صحيحة'),
                    backgroundColor: success
                        ? AppColors.statusActive
                        : AppColors.statusDanger,
                  ),
                );
              }
            },
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _showLogoutAllSessionsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج من جميع الجلسات'),
        content: const Text('هل أنت متأكد من تسجيل الخروج من جميع الجلسات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
            ),
            onPressed: () async {
              final database = ref.read(databaseProvider);
              final settingsService = SettingsService(database);
              await settingsService.logoutAllSessions();

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الخروج من جميع الجلسات'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showCreateBackupDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('جاري إنشاء النسخة الاحتياطية...'),
          ],
        ),
      ),
    );

    try {
      final database = ref.read(databaseProvider);
      final settingsService = SettingsService(database);
      await settingsService.updateLastBackupTime();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
            backgroundColor: AppColors.statusActive,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إنشاء النسخة الاحتياطية: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    }
  }
}
