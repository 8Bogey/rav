import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    ref.read(authProvider.notifier).clearError();

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(authProvider.notifier).loginWithAuth0();

      if (success && mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.statusDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.darkBgPage
            : AppColors.bgPage, // Cream background as specified
        body: Stack(
          children: [
            // Custom title bar area (part of the design but hidden from OS)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 32, // Standard Windows title bar height
              child: Container(
                color: AppColors.primary.withOpacity(0.8),
                // This area acts as a drag region for window moving
              ),
            ),
            // Main content centered
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and app name with animation
                    Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.flash_on,
                            color: Colors.white,
                            size: 32,
                          ),
                        )
                            .animate()
                            .scaleXY(begin: 0.8, end: 1.0, duration: 600.ms),
                        const SizedBox(height: 16),
                        Text(
                          'Smart_gen',
                          style: AppTypography.h2.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          'نظام إدارة مشتركي مولدات الكهرباء',
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextBody
                                : AppColors.textSecondary,
                          ),
                        ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                    const SizedBox(height: 48),

                    // Login card with animation - matching Bitepoint style
                    Container(
                      width: 400,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBgSurface
                            : AppColors.bgSurface,
                        borderRadius:
                            BorderRadius.circular(20), // rXl radius (20px)
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 32,
                            offset: Offset(0, 8),
                          ),
                        ], // Proper elevation shadow as per PRD
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: AppTypography.h3.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextHead
                                  : AppColors.textHeading,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'أدخل كلمة المرور للوصول إلى النظام',
                            style: AppTypography.bodyMd.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextBody
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error message if any - styled as per PRD
                          if (authState.errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.statusDangerS,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.statusDanger,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.statusDanger,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.errorMessage!,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.statusDanger,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Auth0 login button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      _handleLogin();
                                    },
                              icon: const Icon(Icons.login),
                              label: Text(
                                'تسجيل الدخول عبر Auth0',
                                style: AppTypography.labelLg.copyWith(
                                  color: AppColors.textOnGold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.textOnGold,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(
                        begin: 0.1,
                        curve: Curves.easeOutBack,
                        duration: 600.ms),

                    const SizedBox(height: 32),

                    // Version info - styled as per PRD
                    Text(
                      'v1.0.0',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                    Text(
                      '© 2026 Smart_gen',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
