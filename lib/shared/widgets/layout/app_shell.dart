import 'package:flutter/material.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
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
                  // TopBar - matching Bitepoint style
                  Container(
                    height: 56, // topBarHeight from PRD
                    decoration: const BoxDecoration(
                      color: AppColors.bgSurface, // bgSurface for TopBar
                      // Add shadow matching Bitepoint style
                      boxShadow: [
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
                              color: AppColors.textHeading,
                            ),
                          ),
                        ),
                        
                        // Right side - Actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Notification button
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  // Handle notifications
                                },
                              ),
                              // Add more action buttons as needed
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main content area with proper padding
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24), // contentPaddingH/V from PRD
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