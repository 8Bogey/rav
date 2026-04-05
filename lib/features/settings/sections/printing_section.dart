import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';

class PrintingSection extends ConsumerWidget {
  const PrintingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
          'رأس المستند',
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
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ميزة الطباعة غير متاحة حالياً'),
                    backgroundColor: AppColors.statusWarning,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: $e'),
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

  Widget _buildTextField(String label, String value,
      {required bool isDarkMode, Function(String)? onChanged}) {
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
}
