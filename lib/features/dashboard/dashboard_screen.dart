import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً، الأدمن 👋',
                    style: AppTypography.h2.copyWith(color: AppColors.textHeading),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الاثنين، 2 مارس 2026',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              // Action buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      color: AppColors.textOnGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إضافة مشترك',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.textOnGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Stats cards grid
          Text(
            'نظرة عامة',
            style: AppTypography.h3.copyWith(color: AppColors.textHeading),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOverviewCard(
                title: 'المحصّل اليوم',
                value: '247,000',
                unit: 'IQD',
                icon: Icons.account_balance_wallet,
                color: AppColors.primary,
                progress: 0.75,
              ),
              _buildOverviewCard(
                title: 'المشتركون',
                value: '1,240',
                unit: 'مشترك',
                icon: Icons.people,
                color: AppColors.statusInfo,
                progress: 0.85,
              ),
              _buildOverviewCard(
                title: 'الكابينات المكتملة',
                value: '12',
                unit: 'من 15',
                icon: Icons.apps,
                color: AppColors.statusActive,
                progress: 0.8,
              ),
              _buildOverviewCard(
                title: 'لم يدفعوا',
                value: '89',
                unit: 'مشترك',
                icon: Icons.warning,
                color: AppColors.statusWarning,
                progress: 0.3,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Recent activities section
          Text(
            'الأنشطة الأخيرة',
            style: AppTypography.h3.copyWith(color: AppColors.textHeading),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
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
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'بحث في الأنشطة...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppColors.bgSurfaceAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Activity items
                _buildActivityItem(
                  'أحمد علي محمود',
                  'أكمل دفع قيمة الاشتراك',
                  'A4',
                  '01/03/26',
                  AppColors.statusActive,
                ),
                const Divider(height: 32),
                _buildActivityItem(
                  'محمد حسن سامي',
                  'تمت إضافته كمشترك جديد',
                  'B2',
                  '01/02/26',
                  AppColors.statusInfo,
                ),
                const Divider(height: 32),
                _buildActivityItem(
                  'خالد رامي فهد',
                  'تم قطع الخدمة لعدم الدفع',
                  'C7',
                  '01/11/25',
                  AppColors.statusDanger,
                ),
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'عرض جميع الأنشطة ←',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Payment trends section
          Text(
            'التحويلات الشهرية',
            style: AppTypography.h3.copyWith(color: AppColors.textHeading),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
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
            child: Column(
              children: [
                // Chart placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'مخطط التحويلات',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem('التحويلات', AppColors.primary),
                    _buildLegendItem('العمولات', AppColors.gold),
                    _buildLegendItem('المصاريف', AppColors.statusWarning),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOverviewCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.numMd.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTypography.statLg.copyWith(
                    color: AppColors.textHeading,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(
    String userName,
    String activity,
    String userCode,
    String date,
    Color color,
  ) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              userCode,
              style: AppTypography.labelMd.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Activity details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: userName,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textHeading,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' $activity',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Status indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.textBody,
          ),
        ),
      ],
    );
  }
}