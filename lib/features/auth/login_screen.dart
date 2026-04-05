import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
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
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).loginWithAuth0();
      if (success && mounted) context.go('/dashboard');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    final textColor =
        isDarkMode ? AppColors.darkTextHead : AppColors.textHeading;
    final bodyColor =
        isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary;
    final mutedColor =
        isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted;
    final surfaceColor =
        isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBgPage : AppColors.bgPage,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.flash_on, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Smart_gen',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'نظام إدارة مشتركي مولدات الكهرباء',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: bodyColor),
                ),
                const SizedBox(height: 48),

                // Login card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'اضغط الزر أدناه لتسجيل الدخول',
                        style: TextStyle(fontSize: 13, color: bodyColor),
                      ),
                      const SizedBox(height: 24),

                      // Error message
                      if (authState.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.statusDangerS,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.statusDanger),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.statusDanger, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.statusDanger),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleLogin,
                          icon: const Icon(Icons.login, size: 18),
                          label: Text(
                            _isLoading
                                ? 'جاري تسجيل الدخول...'
                                : 'تسجيل الدخول',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.textOnGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Text('v1.0.0',
                    style: TextStyle(fontSize: 12, color: mutedColor)),
                const SizedBox(height: 4),
                Text('© 2026 Smart_gen',
                    style: TextStyle(fontSize: 12, color: mutedColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
