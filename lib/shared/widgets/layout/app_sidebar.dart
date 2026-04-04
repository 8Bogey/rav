import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/router/route_names.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';

class AppSidebar extends ConsumerStatefulWidget {
  const AppSidebar({super.key});

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  // Track hovered item for hover effects
  int? _hoveredIndex;

  /// Route paths for navigation
  static const List<String> _routes = [
    AppRoutes.dashboard,
    AppRoutes.subscribers,
    AppRoutes.cabinets,
    AppRoutes.collection,
    AppRoutes.workers,
    AppRoutes.reports,
    AppRoutes.whatsapp,
    AppRoutes.settings,
    AppRoutes.audit,
  ];

  /// Get active index based on current route
  int _getActiveIndex(String location) {
    for (int i = 0; i < _routes.length; i++) {
      if (location.contains(_routes[i].replaceAll('/', ''))) {
        return i;
      }
    }
    return 0; // Default to dashboard
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _getActiveIndex(location);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MouseRegion(
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: Container(
          width: 220, // sidebarWidth from PRD
          decoration: BoxDecoration(
            color: AppColors.bgSidebar,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              bottomLeft: Radius.circular(22),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo section - enhanced to match Bitepoint style
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Smart_gen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation items section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main navigation section header
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          'القائمة الرئيسية',
                          style: TextStyle(
                            color: Color(0xffffffff70), // 70% opacity white
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Main navigation items
                      _buildNavItem(
                        title: 'لوحة التحكم',
                        icon: Icons.dashboard_outlined,
                        index: 0,
                        isActive: activeIndex == 0,
                        route: AppRoutes.dashboard,
                      ),
                      _buildNavItem(
                        title: 'المشتركون',
                        icon: Icons.people_outline,
                        index: 1,
                        isActive: activeIndex == 1,
                        route: AppRoutes.subscribers,
                      ),
                      _buildNavItem(
                        title: 'الكابينات',
                        icon: Icons.apps_outlined,
                        index: 2,
                        isActive: activeIndex == 2,
                        route: AppRoutes.cabinets,
                      ),
                      _buildNavItem(
                        title: 'التحصيل',
                        icon: Icons.account_balance_wallet_outlined,
                        index: 3,
                        isActive: activeIndex == 3,
                        route: AppRoutes.collection,
                      ),
                      _buildNavItem(
                        title: 'العمال',
                        icon: Icons.engineering_outlined,
                        index: 4,
                        isActive: activeIndex == 4,
                        route: AppRoutes.workers,
                      ),
                      _buildNavItem(
                        title: 'التقارير',
                        icon: Icons.bar_chart_outlined,
                        index: 5,
                        isActive: activeIndex == 5,
                        route: AppRoutes.reports,
                      ),
                      _buildNavItem(
                        title: 'واتساب',
                        icon: Icons.chat_outlined,
                        index: 6,
                        isActive: activeIndex == 6,
                        route: AppRoutes.whatsapp,
                      ),

                      // Tools section header
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Text(
                          'الأدوات',
                          style: TextStyle(
                            color: Color(0xffffffff70), // 70% opacity white
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Secondary navigation items
                      _buildNavItem(
                        title: 'الإعدادات',
                        icon: Icons.settings_outlined,
                        index: 7,
                        isActive: activeIndex == 7,
                        route: AppRoutes.settings,
                      ),
                      _buildNavItem(
                        title: 'سجل التدقيق',
                        icon: Icons.history_outlined,
                        index: 8,
                        isActive: activeIndex == 8,
                        route: AppRoutes.audit,
                      ),
                    ],
                  ),
                ),
              ),

              // User info section - enhanced styling to match Bitepoint
              MouseRegion(
                onEnter: (_) => setState(() =>
                    _hoveredIndex = -1), // Special index for logout button
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBgSidebar,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الأدمن',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'مدير النظام',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Logout using auth provider
                          ref.read(authProvider.notifier).logout();
                          // Navigate to login using GoRouter
                          context.go(AppRoutes.login);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String title,
    required IconData icon,
    required int index,
    required bool isActive,
    required String route,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Material(
            color: Colors.transparent,
              child: InkWell(
              onTap: () {
                // Play system sound feedback
                HapticFeedback.selectionClick();
                // Navigate using GoRouter
                context.go(route);
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  // Solid pills (no transparent backgrounds/strokes).
                  color: isActive
                      ? AppColors.gold
                      : _hoveredIndex == index
                          ? AppColors.primaryLight
                          : AppColors.primaryMid,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // iOS-like compact active marker
                    if (isActive)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
