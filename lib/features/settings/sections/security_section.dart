import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/settings_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';

class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              ElevatedButton(
                onPressed: () => _showChangePasswordDialog(context, ref),
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
}
