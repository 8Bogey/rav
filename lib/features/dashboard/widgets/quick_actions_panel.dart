import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/app_dimens.dart';
import 'package:mawlid_al_dhaki/core/theme/app_shadows.dart';
import 'package:gap/gap.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({
    super.key,
    required this.isDarkMode,
    required this.onAddSubscriber,
    required this.onRecordPayment,
    required this.onNavigateToCabinets,
    required this.onNavigateToSubscribers,
    required this.onNavigateToWorkers,
    required this.onNavigateToReports,
  });

  final bool isDarkMode;
  final VoidCallback onAddSubscriber;
  final VoidCallback onRecordPayment;
  final VoidCallback onNavigateToCabinets;
  final VoidCallback onNavigateToSubscribers;
  final VoidCallback onNavigateToWorkers;
  final VoidCallback onNavigateToReports;

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.person_add, 'label': 'إضافة مشترك', 'color': AppColors.statusInfo, 'action': onAddSubscriber},
      {'icon': Icons.payments, 'label': 'تسجيل دفعة', 'color': AppColors.statusActive, 'action': onRecordPayment},
      {'icon': Icons.apps, 'label': 'الخزائن', 'color': AppColors.primary, 'action': onNavigateToCabinets},
      {'icon': Icons.people, 'label': 'المشتركون', 'color': AppColors.gold, 'action': onNavigateToSubscribers},
      {'icon': Icons.engineering, 'label': 'الموظفين', 'color': AppColors.statusWarning, 'action': onNavigateToWorkers},
      {'icon': Icons.bar_chart, 'label': 'التقارير', 'color': AppColors.statusDanger, 'action': onNavigateToReports},
    ];

    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const Gap(AppDimens.s16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid for quick actions
              int crossAxisCount;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6; // Large screens
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 4; // Medium screens
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3; // Small screens
              } else {
                crossAxisCount = 2; // Very small screens
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppDimens.s12,
                  mainAxisSpacing: AppDimens.s12,
                  childAspectRatio: 1.1,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildQuickActionButton(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    color: action['color'] as Color,
                    onTap: action['action'] as VoidCallback,
                    index: index,
                    isDarkMode: isDarkMode,
                  );
                },
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.s12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.rMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.s10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppDimens.iconMd),
            ),
            const Gap(AppDimens.s8),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate(delay: (150 + index * 50).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
  }
}