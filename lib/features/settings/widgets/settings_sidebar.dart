import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_screen.dart';

class SettingsSidebar extends StatelessWidget {
  const SettingsSidebar({super.key, required this.isDarkMode, required this.ref});

  final bool isDarkMode;
  final WidgetRef ref;

  void _playSectionChangeSound() {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
                _buildMenuItem('معلومات المولد', selectedSection == 'معلومات المولد',
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
                _buildMenuItem('سلة المحذوفات', selectedSection == 'سلة المحذوفات',
                    isDarkMode: isDarkMode,
                    onTap: () => ref
                        .read(settingsSectionProvider.notifier)
                        .state = 'سلة المحذوفات'),
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
}