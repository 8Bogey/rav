import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

class SubscribersScreen extends StatelessWidget {
  const SubscribersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المشتركون',
                style: AppTypography.h2.copyWith(color: AppColors.textHeading),
              ).animate().fadeIn(duration: 300.ms),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      color: AppColors.textOnGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إضافة مشترك',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.textOnGold,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Simple placeholder for now
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'قائمة المشتركين',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم تنفيذ هذه الشاشة لاحقاً',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}