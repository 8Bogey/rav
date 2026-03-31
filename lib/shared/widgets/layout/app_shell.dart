import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_dimens.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/shared/widgets/layout/app_sidebar.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';

/// Get title for the current route
String _getRouteTitle(String location) {
  if (location.contains('/dashboard')) return 'لوحة التحكم';
  if (location.contains('/subscribers')) return 'المشتركون';
  if (location.contains('/cabinets')) return 'الكابينات';
  if (location.contains('/collection')) return 'التحصيل';
  if (location.contains('/workers')) return 'العمال';
  if (location.contains('/reports')) return 'التقارير';
  if (location.contains('/whatsapp')) return 'واتساب';
  if (location.contains('/settings')) return 'الإعدادات';
  if (location.contains('/audit')) return 'سجل التدقيق';
  return 'المولد الذكي';
}

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final location = GoRouterState.of(context).matchedLocation;
    final title = _getRouteTitle(location);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDarkMode
            ? AppColors.darkBgPage
            : AppColors.bgPage, // bgPage from PRD
        body: Row(
          children: [
            // Main content area (takes most of the space)
            Expanded(
              child: Column(
                children: [
                  // TopBar - matching Bitepoint style
                  Container(
                    height: 56, // topBarHeight from PRD
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkBgSurface
                          : AppColors.bgSurface, // bgSurface for TopBar
                      // Add shadow matching Bitepoint style
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side - Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            title,
                            style: AppTypography.h3.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextHead
                                  : AppColors.textHeading,
                            ),
                          ),
                        ),

                        // Right side - Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Theme toggle button
                              IconButton(
                                icon: Icon(
                                  isDarkMode
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  color: isDarkMode
                                      ? AppColors.darkTextBody
                                      : AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .toggleTheme();
                                },
                              ),
                              // Notification button
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: isDarkMode
                                      ? AppColors.darkTextBody
                                      : AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  // Handle notifications
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content area with proper padding
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(
                          24), // contentPaddingH/V from PRD
                      color:
                          isDarkMode ? AppColors.darkBgPage : AppColors.bgPage,
                      child: AnimatedSwitcher(
                        duration: AppDimens.durationNormal,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          final slideAnimation = Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slideAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(location),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sidebar on the right (RTL layout)
            const AppSidebar(),
          ],
        ),
      ),
    );
  }
}
