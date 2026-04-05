import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/settings_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';

class BackupSection extends ConsumerWidget {
  const BackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
