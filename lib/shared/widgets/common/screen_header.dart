import 'package:flutter/material.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

/// Reusable screen header with title and optional action button.
/// Replaces the duplicated header pattern found in 6+ screens.
class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final Widget? leading;
  final List<Widget>? trailing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.actionIcon = Icons.add,
    this.onActionPressed,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.h2.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextHead
                        : AppColors.textHeading,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Row(
          children: [
            if (trailing != null) ...trailing!,
            if (actionLabel != null && onActionPressed != null) ...[
              if (trailing != null && trailing!.isNotEmpty)
                const SizedBox(width: 12),
              GestureDetector(
                onTap: onActionPressed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        actionIcon,
                        color: AppColors.textOnGold,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        actionLabel!,
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.textOnGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
