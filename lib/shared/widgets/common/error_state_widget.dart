import 'package:flutter/material.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

/// Reusable error state widget.
/// Replaces the duplicated error UI found in 8+ screens.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? errorDetail;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.errorDetail,
    this.retryLabel = 'إعادة المحاولة',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.statusDanger,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.h3.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
            if (errorDetail != null) ...[
              const SizedBox(height: 8),
              Text(
                errorDetail!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
