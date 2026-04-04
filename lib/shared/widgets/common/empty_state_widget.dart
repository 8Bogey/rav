import 'package:flutter/material.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

/// Reusable empty state widget.
/// Replaces the duplicated empty state UI found in 5+ screens.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color:
                  isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h3.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
