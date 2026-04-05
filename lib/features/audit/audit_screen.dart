import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/features/audit/providers/audit_provider.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/screen_header.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/error_state_widget.dart';

class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final auditState = ref.watch(auditLogProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'سجل التدقيق').animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Loading state
          if (auditState.isLoading && auditState.entries.isEmpty)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error state
          if (auditState.error != null && auditState.entries.isEmpty)
            Expanded(
              child: ErrorStateWidget(
                message: 'حدث خطأ أثناء تحميل سجل التدقيق',
                errorDetail: auditState.error,
                onRetry: () {
                  ref.read(auditLogProvider.notifier).loadAuditLog();
                },
              ),
            ),

          // Empty state
          if (!auditState.isLoading &&
              auditState.error == null &&
              auditState.entries.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment,
                      size: 64,
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد سجلات تدقيق',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم إضافة السجلات هنا عند تنفيذ الإجراءات',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Success state with data
          if (auditState.entries.isNotEmpty)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkBgSurface
                      : AppColors.bgSurface,
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
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: auditState.entries.length +
                            (auditState.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < auditState.entries.length) {
                            final log = auditState.entries[index];
                            return _buildTimelineItem(log, index,
                                isDarkMode: isDarkMode);
                          }
                          // Load more button
                          return _buildLoadMoreButton(context, ref, isDarkMode);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    final auditState = ref.watch(auditLogProvider);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Center(
        child: auditState.isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: () {
                  ref.read(auditLogProvider.notifier).loadMore();
                },
                icon: const Icon(Icons.arrow_downward, size: 18),
                label: const Text('تحميل المزيد'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: isDarkMode
                      ? AppColors.darkBgSurfaceAlt
                      : AppColors.bgSurfaceAlt,
                  foregroundColor:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
      ),
    );
  }

  Widget _buildTimelineItem(AuditLogEntry log, int index,
      {required bool isDarkMode}) {
    Color color = AppColors.statusActive;
    switch (log.type) {
      case 'دفعة':
        color = AppColors.statusActive;
        break;
      case 'تعديل':
        color = AppColors.statusInfo;
        break;
      case 'إضافة':
        color = AppColors.statusActive;
        break;
      case 'قطع':
        color = AppColors.statusDanger;
        break;
      default:
        color = AppColors.statusActive;
    }

    final timeDisplay =
        '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Log details
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkBgSurfaceAlt
                    : AppColors.bgSurfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '[$timeDisplay]',
                        style: AppTypography.bodySm.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          log.type,
                          style: AppTypography.labelMd.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: log.user,
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' ← ${log.action} ← ',
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextBody
                                : AppColors.textBody,
                          ),
                        ),
                        TextSpan(
                          text: log.target,
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (log.details.isNotEmpty) const SizedBox(height: 4),
                  if (log.details.isNotEmpty)
                    Text(
                      log.details,
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                ],
              ),
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms),
          ),
        ],
      ),
    );
  }
}
