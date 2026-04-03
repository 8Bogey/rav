import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_dimens.dart';
import 'package:mawlid_al_dhaki/core/theme/app_shadows.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/subscribers/dialogs/subscriber_dialog.dart';
import 'package:mawlid_al_dhaki/shared/utils/app_transitions.dart';
import 'package:gap/gap.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.isDarkMode});

  final bool isDarkMode;

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final today = '${dayNames[now.weekday % 7]}، ${now.day} ${_getMonthName(now.month)} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [AppColors.darkBgSurface, AppColors.darkBgPage]
              : [AppColors.primary, AppColors.primary.withGreen(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً، الأدمن 👋',
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppDimens.s8),
              Text(
                today,
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Gap(AppDimens.s4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.statusActive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(AppDimens.s8),
                  Text(
                    'النظام يعمل بشكل طبيعي',
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderAction(
                icon: Icons.notifications_outlined,
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
              const Gap(AppDimens.s12),
              _buildAddButton(context),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.s12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimens.rMd),
        ),
        child: Icon(icon, color: Colors.white, size: AppDimens.iconMd),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppTransitions.showPremiumDialog(
          context: context,
          child: const SubscriberDialog(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.s20, vertical: AppDimens.s12),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(AppDimens.rMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: AppColors.textOnGold, size: AppDimens.iconMd),
            const Gap(AppDimens.s8),
            Text(
              'إضافة مشترك',
              style: AppTypography.labelLg.copyWith(color: AppColors.textOnGold),
            ),
          ],
        ),
      ),
    );
  }
}