import 'package:flutter/material.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/shared/widgets/layout/app_sidebar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;
  
  const AppShell({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgPage, // bgPage from PRD
        body: Row(
          children: [
            // Main content area (takes most of the space)
            Expanded(
              child: Column(
                children: [
                  // TopBar
                  Container(
                    height: 56, // topBarHeight from PRD
                    color: AppColors.bgSurface, // bgSurface for TopBar
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side - Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textHeading,
                            ),
                          ),
                        ),
                        
                        // Right side - Actions (empty for now)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // We'll add action buttons here later
                              const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main content area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20), // contentPaddingV and contentPaddingH from PRD
                      child: child,
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