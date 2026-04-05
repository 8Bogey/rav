import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';

class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
}
