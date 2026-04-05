import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/settings/settings_state.dart';

class LicenseSection extends ConsumerWidget {
  const LicenseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSubscribed = ref.watch(subscriptionStatusProvider);
    final subscriptionEndDate = ref.watch(subscriptionEndDateProvider);
    final isLoading = ref.watch(subscriptionLoadingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الترخيص والاشتراك',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        const SizedBox(height: 24),

        // Subscription status card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSubscribed
                  ? AppColors.statusActive.withOpacity(0.5)
                  : AppColors.statusWarning.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Status icon and text
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSubscribed
                          ? AppColors.statusActiveS
                          : AppColors.statusWarningS,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSubscribed ? Icons.verified_user : Icons.warning_amber,
                      color: isSubscribed
                          ? AppColors.statusActive
                          : AppColors.statusWarning,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSubscribed ? 'اشتراك نشط' : 'اشتراك غير نشط',
                          style: AppTypography.h3.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (subscriptionEndDate != null)
                          Text(
                            'ينتهي في: ${_formatDate(subscriptionEndDate)}',
                            style: AppTypography.bodySm.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextBody
                                  : AppColors.textBody,
                            ),
                          )
                        else
                          Text(
                            'قم بتفعيل الاشتراك للوصول الكامل',
                            style: AppTypography.bodySm.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Subscription benefits
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppColors.darkBgSurface
                      : AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مميزات الاشتراك:',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                      Icons.cloud,
                      'مزامنة سحابية غير محدودة',
                      isSubscribed,
                      isDarkMode,
                    ),
                    _buildFeatureRow(
                      Icons.backup,
                      'نسخ احتياطي تلقائي',
                      isSubscribed,
                      isDarkMode,
                    ),
                    _buildFeatureRow(
                      Icons.analytics,
                      'تقارير متقدمة',
                      isSubscribed,
                      isDarkMode,
                    ),
                    _buildFeatureRow(
                      Icons.support_agent,
                      'دعم فني أولوية',
                      isSubscribed,
                      isDarkMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Auth0 login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      isLoading ? null : () => _handleAuth0Login(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSubscribed ? AppColors.primary : AppColors.gold,
                    foregroundColor: isSubscribed
                        ? AppColors.textOnPrimary
                        : AppColors.textOnGold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.bolt),
                  label: Text(
                    isSubscribed
                        ? 'تحديث حالة الاشتراك'
                        : 'تفعيل الاشتراك الشهري',
                    style: AppTypography.labelLg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              if (!isSubscribed) ...[
                const SizedBox(height: 12),
                Text(
                  '5,000 IQD / شهر - الدفع عبر Auth0',
                  style: AppTypography.bodySm.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // App info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(Icons.flash_on, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                'Smart_gen',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الإصدار 1.0.0',
                style: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© 2026 جميع الحقوق محفوظة',
                style: AppTypography.bodySm.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextMuted
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
      IconData icon, String text, bool isActive, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? AppColors.statusActive : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: isActive
                ? (isDarkMode ? AppColors.darkTextBody : AppColors.textBody)
                : AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTypography.bodySm.copyWith(
              color: isActive
                  ? (isDarkMode ? AppColors.darkTextBody : AppColors.textBody)
                  : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAuth0Login(BuildContext context, WidgetRef ref) async {
    ref.read(subscriptionLoadingProvider.notifier).state = true;

    try {
      // Try Auth0 login
      final result = await Auth0Service.instance.login();

      if (result.success && result.accessToken != null) {
        // For demo purposes, we'll accept the login as a valid subscription
        // In production, you would verify the subscription with your backend
        ref.read(subscriptionStatusProvider.notifier).state = true;
        ref.read(subscriptionEndDateProvider.notifier).state =
            DateTime.now().add(const Duration(days: 30));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تفعيل الاشتراك بنجاح!'),
              backgroundColor: AppColors.statusActive,
            ),
          );
        }
      } else {
        // If Auth0 not available, use demo/subscription mode
        // For testing, auto-activate subscription
        ref.read(subscriptionStatusProvider.notifier).state = true;
        ref.read(subscriptionEndDateProvider.notifier).state =
            DateTime.now().add(const Duration(days: 30));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تفعيل وضع الاشتراك (تجريبي)'),
              backgroundColor: AppColors.statusInfo,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تفعيل الاشتراك: $e'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    } finally {
      ref.read(subscriptionLoadingProvider.notifier).state = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
