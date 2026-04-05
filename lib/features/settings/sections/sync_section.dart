import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/sync/network_status_provider.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

class SyncSection extends ConsumerWidget {
  const SyncSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final syncState = ref.watch(networkStatusProvider);

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
                              ref
                                  .read(networkStatusProvider.notifier)
                                  .syncToCloud();
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
                              ref
                                  .read(networkStatusProvider.notifier)
                                  .syncFromCloud();
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
                          ref
                              .read(networkStatusProvider.notifier)
                              .syncBothDirections();
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
}
