import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';

class SubscribersScreen extends StatefulWidget {
  const SubscribersScreen({super.key});

  @override
  State<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends State<SubscribersScreen> {
  // Mock data for subscribers
  final List<Map<String, dynamic>> _subscribers = [
    {
      'name': 'أحمد علي محمود',
      'code': 'A4',
      'cabinet': 'A',
      'status': 'نشط',
      'lastPayment': '01/03/26',
      'debt': 0,
      'color': AppColors.statusActive,
    },
    {
      'name': 'محمد حسن سامي',
      'code': 'B2',
      'cabinet': 'B',
      'status': 'موقوف',
      'lastPayment': '01/02/26',
      'debt': 10000,
      'color': AppColors.statusWarning,
    },
    {
      'name': 'خالد رامي فهد',
      'code': 'C7',
      'cabinet': 'C',
      'status': 'مقطوع',
      'lastPayment': '01/11/25',
      'debt': 8000,
      'color': AppColors.statusDanger,
    },
    {
      'name': 'علي محمد كريم',
      'code': 'D1',
      'cabinet': 'D',
      'status': 'نشط',
      'lastPayment': '01/05/26',
      'debt': 0,
      'color': AppColors.statusActive,
    },
    {
      'name': 'سامي عبد الله',
      'code': 'E3',
      'cabinet': 'E',
      'status': 'معلق',
      'lastPayment': '15/02/26',
      'debt': 5000,
      'color': AppColors.statusInfo,
    },
  ];

  // Track hovered row for hover effects
  int? _hoveredRowIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions - matching Bitepoint style
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المشتركون',
                style: AppTypography.h2.copyWith(color: AppColors.textHeading),
              ).animate().fadeIn(duration: 300.ms),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
              ).animate(delay: 100.ms).scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Filter tabs - matching Bitepoint style
          Row(
            children: [
              _buildFilterTab('الكل (1240)', true),
              const SizedBox(width: 8),
              _buildFilterTab('نشط (1100)', false),
              const SizedBox(width: 8),
              _buildFilterTab('موقوف (89)', false),
              const SizedBox(width: 8),
              _buildFilterTab('مقطوع (34)', false),
              const SizedBox(width: 8),
              _buildFilterTab('معلق (17)', false),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar - matching Bitepoint style
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث في المشتركين...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
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
          ),
          const SizedBox(height: 16),

          // Subscribers data table - matching PRD requirements
          Expanded(
            child: Container(
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
                  // Table header - matching PRD requirements
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.bgSurfaceAlt,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '#',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'المشترك',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'الكود',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'الكابينة',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'الدين المتراكم',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'آخر دفعة',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'الحالة',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table rows with hover effects
                  Expanded(
                    child: ListView.builder(
                      itemCount: _subscribers.length,
                      itemBuilder: (context, index) {
                        final subscriber = _subscribers[index];
                        return _buildSubscriberRow(subscriber, index);
                      },
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary 
            : AppColors.bgSurfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.labelMd.copyWith(
          color: isActive 
              ? AppColors.textOnGold 
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSubscriberRow(Map<String, dynamic> subscriber, int index) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRowIndex = index),
      onExit: (_) => setState(() => _hoveredRowIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hoveredRowIndex == index 
              ? AppColors.primarySurface.withOpacity(0.3) 
              : index % 2 == 0 
                  ? AppColors.bgSurface 
                  : AppColors.bgSurfaceAlt,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar with code
              Expanded(
                flex: 1,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: subscriber['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      subscriber['code'],
                      style: AppTypography.labelMd.copyWith(
                        color: subscriber['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Subscriber name
              Expanded(
                flex: 3,
                child: Text(
                  subscriber['name'],
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textHeading,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Code
              Expanded(
                flex: 1,
                child: Text(
                  subscriber['code'],
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textBody,
                  ),
                ),
              ),
              // Cabinet
              Expanded(
                flex: 1,
                child: Text(
                  subscriber['cabinet'],
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textBody,
                  ),
                ),
              ),
              // Debt
              Expanded(
                flex: 2,
                child: Text(
                  subscriber['debt'] > 0 
                      ? '${subscriber['debt']} IQD' 
                      : 'لا يوجد',
                  style: AppTypography.bodyMd.copyWith(
                    color: subscriber['debt'] > 0 
                        ? AppColors.statusDanger 
                        : AppColors.statusActive,
                  ),
                ),
              ),
              // Last payment
              Expanded(
                flex: 1,
                child: Text(
                  subscriber['lastPayment'],
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              // Status badge
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: subscriber['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscriber['status'],
                    style: AppTypography.labelMd.copyWith(
                      color: subscriber['color'],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}