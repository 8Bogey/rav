import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';

class GeneralSection extends ConsumerWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
}
