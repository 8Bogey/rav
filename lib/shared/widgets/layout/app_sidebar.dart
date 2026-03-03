import 'package:flutter/material.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  // Track hovered item for hover effects
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 220, // sidebarWidth from PRD
        color: AppColors.bgSidebar, // bgSidebar from PRD (#1B4332)
        child: Column(
          children: [
            // Logo section
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
                      'المولد الذكي',
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
                          color: Color(0xFFffffff70), // 70% opacity white
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Main navigation items
                    _buildNavItem('لوحة التحكم', Icons.dashboard_outlined, 0, context),
                    _buildNavItem('المشتركون', Icons.people_outline, 1, context),
                    _buildNavItem('الكابينات', Icons.apps_outlined, 2, context),
                    _buildNavItem('التحصيل', Icons.account_balance_wallet_outlined, 3, context),
                    _buildNavItem('العمال', Icons.engineering_outlined, 4, context),
                    _buildNavItem('التقارير', Icons.bar_chart_outlined, 5, context),
                    _buildNavItem('واتساب', Icons.chat_outlined, 6, context),
                    
                    // Tools section header
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Text(
                        'الأدوات',
                        style: TextStyle(
                          color: Color(0xFFffffff70), // 70% opacity white
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    // Secondary navigation items
                    _buildNavItem('الإعدادات', Icons.settings_outlined, 7, context),
                    _buildNavItem('سجل التدقيق', Icons.history_outlined, 8, context),
                  ],
                ),
              ),
            ),
            
            // User info section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
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
                      // Logout functionality
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(String title, IconData icon, int index, BuildContext context) {
    // Determine if this is the active route
    // This is a simplified check - in a real app you'd check against the current route
    bool isActive = index == 0; // Assuming dashboard is active by default
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Navigate to different screens based on the item
                switch (index) {
                  case 0: // Dashboard
                    Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                    break;
                  case 1: // Subscribers
                    Navigator.of(context).pushNamedAndRemoveUntil('/subscribers', (route) => false);
                    break;
                  // Add cases for other navigation items as needed
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  // Hover effect: semi-transparent white background
                  color: _hoveredIndex == index && !isActive
                      ? const Color(0x14FFFFFF) // rgba(255,255,255,0.08) as per PRD
                      : isActive
                          ? AppColors.gold // Solid gold background for active item
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: isActive 
                          ? AppColors.textOnGold // White icon on gold background
                          : _hoveredIndex == index
                              ? Colors.white // Full white on hover
                              : const Color(0xFFffffffbf), // 75% opacity white for normal state
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isActive 
                              ? AppColors.textOnGold // White text on gold background
                              : _hoveredIndex == index
                                  ? Colors.white // Full white on hover
                                  : const Color(0xFFffffffbf), // 75% opacity white for normal state
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Active indicator as per Bitepoint pattern
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textOnGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.gold,
                          size: 12,
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