import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/dashboard_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/app_dimens.dart';
import 'package:mawlid_al_dhaki/core/theme/app_shadows.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/features/subscribers/dialogs/subscriber_dialog.dart';
import 'package:gap/gap.dart';

// Provider for DashboardService
final dashboardServiceProvider = Provider((ref) {
  final database = ref.read(databaseProvider);
  return DashboardService(database);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final dashboardService = ref.watch(dashboardServiceProvider);
    
    return FutureBuilder(
      future: Future.wait([
        dashboardService.getTotalSubscribers(),
        dashboardService.getTotalCabinets(),
        dashboardService.getCompletedCabinets(),
        dashboardService.getTodayCollectedAmount(),
        dashboardService.getWeeklyCollectedAmount(),
        dashboardService.getMonthlyCollectedAmount(),
        dashboardService.getActiveSubscribers(),
        dashboardService.getNonPayingSubscribers(),
        dashboardService.getRecentActivities(),
        dashboardService.getPaymentTrends(),
        dashboardService.getDailyCollections(),
        dashboardService.getPaymentStatusDistribution(),
        dashboardService.getCabinetsWithProgress(),
        dashboardService.getAlerts(),
        dashboardService.getCabinetCompletionRate(),
        dashboardService.getWorkerPerformance(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error, isDarkMode, context);
        }
        
        final data = snapshot.data as List<dynamic>;
        
        // Extract all data
        final totalSubscribers = data[0] as int;
        final totalCabinets = data[1] as int;
        final completedCabinets = data[2] as int;
        final todayCollected = data[3] as double;
        final weeklyCollected = data[4] as double;
        final monthlyCollected = data[5] as double;
        final activeSubscribers = data[6] as int;
        final nonPayingSubscribers = data[7] as int;
        final recentActivities = data[8] as List<Map<String, dynamic>>;
        final paymentTrends = data[9] as List<Map<String, dynamic>>;
        final dailyCollections = data[10] as List<Map<String, dynamic>>;
        final paymentDistribution = data[11] as Map<String, int>;
        final cabinetsProgress = data[12] as List<Map<String, dynamic>>;
        final alerts = data[13] as List<Map<String, dynamic>>;
        final cabinetCompletionRate = data[14] as double;
        final workerPerformance = data[15] as double;
        
        return _buildDashboard(
          context: context,
          isDarkMode: isDarkMode,
          totalSubscribers: totalSubscribers,
          totalCabinets: totalCabinets,
          completedCabinets: completedCabinets,
          todayCollected: todayCollected,
          weeklyCollected: weeklyCollected,
          monthlyCollected: monthlyCollected,
          activeSubscribers: activeSubscribers,
          nonPayingSubscribers: nonPayingSubscribers,
          recentActivities: recentActivities,
          paymentTrends: paymentTrends,
          dailyCollections: dailyCollections,
          paymentDistribution: paymentDistribution,
          cabinetsProgress: cabinetsProgress,
          alerts: alerts,
          cabinetCompletionRate: cabinetCompletionRate,
          workerPerformance: workerPerformance,
        );
      },
    );
  }

  Widget _buildErrorWidget(Object? error, bool isDarkMode, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: AppColors.statusDanger),
          const Gap(16),
          Text(
            'حدث خطأ أثناء تحميل البيانات',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const Gap(8),
          Text(
            error.toString(),
            style: AppTypography.bodyMd.copyWith(
              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
            ),
          ),
          const Gap(16),
          ElevatedButton(
            onPressed: () => (context as Element).markNeedsBuild(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard({
    required BuildContext context,
    required bool isDarkMode,
    required int totalSubscribers,
    required int totalCabinets,
    required int completedCabinets,
    required double todayCollected,
    required double weeklyCollected,
    required double monthlyCollected,
    required int activeSubscribers,
    required int nonPayingSubscribers,
    required List<Map<String, dynamic>> recentActivities,
    required List<Map<String, dynamic>> paymentTrends,
    required List<Map<String, dynamic>> dailyCollections,
    required Map<String, int> paymentDistribution,
    required List<Map<String, dynamic>> cabinetsProgress,
    required List<Map<String, dynamic>> alerts,
    required double cabinetCompletionRate,
    required double workerPerformance,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.contentPaddingH),
      reverse: Directionality.of(context) == TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Header with Gradient
          _buildHeader(context, isDarkMode),
          const Gap(AppDimens.cardGap),
          
          // Quick Actions Panel
          _buildQuickActions(context, isDarkMode),
          const Gap(AppDimens.cardGap),
          
          // Stats Cards Section
          _buildSectionTitle('الإحصائيات', isDarkMode),
          const Gap(AppDimens.s16),
          _buildStatsGrid(
            todayCollected: todayCollected,
            weeklyCollected: weeklyCollected,
            monthlyCollected: monthlyCollected,
            totalSubscribers: totalSubscribers,
            activeSubscribers: activeSubscribers,
            nonPayingSubscribers: nonPayingSubscribers,
            cabinetCompletionRate: cabinetCompletionRate,
            workerPerformance: workerPerformance,
            isDarkMode: isDarkMode,
          ),
          const Gap(AppDimens.cardGap),
          
          // Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie Chart - Payment Status
              Expanded(
                child: _buildPieChartCard(
                  paymentDistribution: paymentDistribution,
                  isDarkMode: isDarkMode,
                ),
              ),
              const Gap(AppDimens.cardGap),
              // Bar Chart - Daily Collections
              Expanded(
                child: _buildBarChartCard(
                  dailyCollections: dailyCollections,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const Gap(AppDimens.cardGap),
          
          // Line Chart - Payment Trends
          _buildLineChartCard(paymentTrends: paymentTrends, isDarkMode: isDarkMode),
          const Gap(AppDimens.cardGap),
          
          // Bottom Row: Alerts + Cabinet Progress
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alerts Panel
              Expanded(
                child: _buildAlertsCard(alerts: alerts, isDarkMode: isDarkMode),
              ),
              const Gap(AppDimens.cardGap),
              // Cabinet Progress
              Expanded(
                child: _buildCabinetProgressCard(
                  cabinetsProgress: cabinetsProgress,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
          const Gap(AppDimens.cardGap),
          
          // Recent Activities
          _buildRecentActivitiesCard(
            recentActivities: recentActivities,
            isDarkMode: isDarkMode,
          ),
          const Gap(AppDimens.cardGap),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    final now = DateTime.now();
    final dayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    final today = '${dayNames[now.weekday % 7]}، ${now.day} ${_getMonthName(now.month)} ${now.year}';
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [AppColors.darkBgSurface, AppColors.darkBgPage]
              : [AppColors.primary, AppColors.primary.withGreen(180)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.rLg),
boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً، الأدمن 👋',
                style: AppTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(AppDimens.s8),
              Text(
                today,
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Gap(AppDimens.s4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.statusActive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(AppDimens.s8),
                  Text(
                    'النظام يعمل بشكل طبيعي',
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildHeaderAction(
                icon: Icons.notifications_outlined,
                onTap: () {},
                isDarkMode: isDarkMode,
              ),
              const Gap(AppDimens.s12),
              _buildAddButton(context),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.s12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimens.rMd),
        ),
        child: Icon(icon, color: Colors.white, size: AppDimens.iconMd),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Dismiss',
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) {
            return const SubscriberDialog();
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.s20, vertical: AppDimens.s12),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(AppDimens.rMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: AppColors.textOnGold, size: AppDimens.iconMd),
            const Gap(AppDimens.s8),
            Text(
              'إضافة مشترك',
              style: AppTypography.labelLg.copyWith(color: AppColors.textOnGold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDarkMode) {
    final actions = [
      {'icon': Icons.person_add, 'label': 'إضافة مشترك', 'color': AppColors.statusInfo, 'action': () => _showSubscriberDialog(context)},
      {'icon': Icons.payments, 'label': 'تسجيل دفعة', 'color': AppColors.statusActive, 'action': () => _showPaymentDialog(context)},
      {'icon': Icons.apps, 'label': 'الكabenات', 'color': AppColors.primary, 'action': () => _navigateToCabinets(context)},
      {'icon': Icons.people, 'label': 'المشتركون', 'color': AppColors.gold, 'action': () => _navigateToSubscribers(context)},
      {'icon': Icons.engineering, 'label': 'الموظفين', 'color': AppColors.statusWarning, 'action': () => _navigateToWorkers(context)},
      {'icon': Icons.bar_chart, 'label': 'التقارير', 'color': AppColors.statusDanger, 'action': () => _navigateToReports(context)},
    ];
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إجراءات سريعة',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const Gap(AppDimens.s16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid for quick actions
              int crossAxisCount;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6; // Large screens
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 4; // Medium screens
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3; // Small screens
              } else {
                crossAxisCount = 2; // Very small screens
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppDimens.s12,
                  mainAxisSpacing: AppDimens.s12,
                  childAspectRatio: 1.1,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildQuickActionButton(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    color: action['color'] as Color,
                    onTap: action['action'] as VoidCallback,
                    index: index,
                    isDarkMode: isDarkMode,
                  );
                },
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required int index,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimens.s12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.rMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimens.s10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppDimens.iconMd),
            ),
            const Gap(AppDimens.s8),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ).animate(delay: (150 + index * 50).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: AppTypography.h3.copyWith(
        color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
      ),
    );
  }

  Widget _buildStatsGrid({
    required double todayCollected,
    required double weeklyCollected,
    required double monthlyCollected,
    required int totalSubscribers,
    required int activeSubscribers,
    required int nonPayingSubscribers,
    required double cabinetCompletionRate,
    required double workerPerformance,
    required bool isDarkMode,
  }) {
    final stats = [
      {'title': 'المحصّل اليوم', 'value': _formatAmount(todayCollected), 'unit': 'IQD', 'icon': Icons.today, 'color': AppColors.primary, 'gradient': [AppColors.primary, AppColors.primary.withGreen(200)]},
      {'title': 'المحصّل الأسبوع', 'value': _formatAmount(weeklyCollected), 'unit': 'IQD', 'icon': Icons.date_range, 'color': AppColors.statusInfo, 'gradient': [AppColors.statusInfo, AppColors.statusInfo.withBlue(200)]},
      {'title': 'المحصّل الشهر', 'value': _formatAmount(monthlyCollected), 'unit': 'IQD', 'icon': Icons.calendar_month, 'color': AppColors.statusActive, 'gradient': [AppColors.statusActive, AppColors.statusActive.withGreen(200)]},
      {'title': 'المشتركون', 'value': totalSubscribers.toString(), 'unit': 'مشترك', 'icon': Icons.people, 'color': AppColors.gold, 'gradient': [AppColors.gold, AppColors.gold.withRed(200)]},
      {'title': 'النشطون', 'value': activeSubscribers.toString(), 'unit': 'مشترك', 'icon': Icons.check_circle, 'color': AppColors.statusActive, 'gradient': [AppColors.statusActive, const Color(0xFF4CAF50)]},
      {'title': 'المتأخرون', 'value': nonPayingSubscribers.toString(), 'unit': 'مشترك', 'icon': Icons.warning, 'color': AppColors.statusWarning, 'gradient': [AppColors.statusWarning, AppColors.statusWarning.withRed(200)]},
      {'title': 'الكabenات', 'value': '${cabinetCompletionRate.toStringAsFixed(0)}%', 'unit': 'مكتملة', 'icon': Icons.apps, 'color': AppColors.primary, 'gradient': [AppColors.primary, AppColors.primary.withBlue(200)]},
      {'title': 'أداء العمال', 'value': '${workerPerformance.toStringAsFixed(0)}%', 'unit': 'كفاءة', 'icon': Icons.engineering, 'color': AppColors.statusInfo, 'gradient': [AppColors.statusInfo, AppColors.statusInfo.withGreen(200)]},
    ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid for stats - adjust based on screen width
        int crossAxisCount;
        double childAspectRatio;
        
        if (constraints.maxWidth > 1400) {
          // Large screens - 4 columns
          crossAxisCount = 4;
          childAspectRatio = 1.8;
        } else if (constraints.maxWidth > 1000) {
          // Medium-large screens - 3 columns
          crossAxisCount = 3;
          childAspectRatio = 1.8;
        } else if (constraints.maxWidth > 600) {
          // Medium screens - 2 columns
          crossAxisCount = 2;
          childAspectRatio = 1.8;
        } else {
          // Small screens - 1 column
          crossAxisCount = 1;
          childAspectRatio = 2.2;
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppDimens.cardGap,
            mainAxisSpacing: AppDimens.cardGap,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              title: stat['title'] as String,
              value: stat['value'] as String,
              unit: stat['unit'] as String,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              gradient: stat['gradient'] as List<Color>,
              index: index,
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required List<Color> gradient,
    required int index,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMd.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const Gap(AppDimens.s8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: AppTypography.statLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(AppDimens.s4),
                    Text(
                      unit,
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppDimens.s12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimens.rMd),
            ),
            child: Icon(icon, color: Colors.white, size: AppDimens.iconLg),
          ),
        ],
      ),
    ).animate(delay: (200 + index * 60).ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildPieChartCard({
    required Map<String, int> paymentDistribution,
    required bool isDarkMode,
  }) {
    final paid = paymentDistribution['paid'] ?? 0;
    final partial = paymentDistribution['partial'] ?? 0;
    final unpaid = paymentDistribution['unpaid'] ?? 0;
    final total = paid + partial + unpaid;
    final sections = <PieChartSectionData>[];
    
    if (total > 0) {
      if (paid > 0) {
        sections.add(PieChartSectionData(
          value: paid.toDouble(),
          title: '$paid',
          titleStyle: AppTypography.labelSm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          color: AppColors.statusActive,
          radius: 60,
          titlePositionPercentageOffset: 0.5,
        ));
      }
      if (partial > 0) {
        sections.add(PieChartSectionData(
          value: partial.toDouble(),
          title: '$partial',
          titleStyle: AppTypography.labelSm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          color: AppColors.statusWarning,
          radius: 60,
          titlePositionPercentageOffset: 0.5,
        ));
      }
      if (unpaid > 0) {
        sections.add(PieChartSectionData(
          value: unpaid.toDouble(),
          title: '$unpaid',
          titleStyle: AppTypography.labelSm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          color: AppColors.statusDanger,
          radius: 60,
          titlePositionPercentageOffset: 0.5,
        ));
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الدفع',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const Gap(AppDimens.s16),
          SizedBox(
            height: 180,
            child: total > 0 
                ? PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  )
                : Center(
                    child: Text(
                      'لا توجد بيانات',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ),
          ),
          const Gap(AppDimens.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('مدفوع', AppColors.statusActive, isDarkMode),
              _buildLegendItem('جزئي', AppColors.statusWarning, isDarkMode),
              _buildLegendItem('متأخر', AppColors.statusDanger, isDarkMode),
            ],
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.1);
  }

  Widget _buildBarChartCard({
    required List<Map<String, dynamic>> dailyCollections,
    required bool isDarkMode,
  }) {
    if (dailyCollections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppDimens.rLg),
          boxShadow: AppShadows.card,
        ),
        child: Center(
          child: Text(
            'لا توجد بيانات',
            style: AppTypography.bodyMd.copyWith(
              color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ),
      );
    }
    final amounts = dailyCollections.map((e) => (e['amount'] as num?)?.toDouble() ?? 0.0);
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    final maxY = maxAmount > 0 ? maxAmount * 1.2 : 1000000.0;
    
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التحصيل اليومي',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const Gap(AppDimens.s16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final amount = (dailyCollections[groupIndex]['amount'] as num?)?.toDouble() ?? 0.0;
                      return BarTooltipItem(
                        _formatAmount(amount),
                        AppTypography.labelSm.copyWith(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dailyCollections.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dailyCollections[index]['day'] as String,
                              style: AppTypography.labelSm.copyWith(
                                color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: dailyCollections.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value['amount'] as num?)?.toDouble() ?? 0.0,
                        color: AppColors.primary,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 500.ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildLineChartCard({
    required List<Map<String, dynamic>> paymentTrends,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '趋势 التحويلات',
            style: AppTypography.h3.copyWith(
              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const Gap(AppDimens.s16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: paymentTrends.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), ((entry.value['payments'] as num?) ?? 0).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: paymentTrends.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), ((entry.value['commissions'] as num?) ?? 0).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppColors.gold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.gold.withOpacity(0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < paymentTrends.length) {
                          return Text(
                            paymentTrends[index]['day'] as String,
                            style: AppTypography.bodySm.copyWith(
                              color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const Gap(AppDimens.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('التحويلات', AppColors.primary, isDarkMode),
              _buildLegendItem('العمولات', AppColors.gold, isDarkMode),
            ],
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildAlertsCard({
    required List<Map<String, dynamic>> alerts,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.s8),
                decoration: BoxDecoration(
                  color: AppColors.statusDanger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.rMd),
                ),
                child: Icon(Icons.warning, color: AppColors.statusDanger, size: AppDimens.iconMd),
              ),
              const Gap(AppDimens.s12),
              Text(
                'التنبيهات',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                ),
              ),
              const Spacer(),
              if (alerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.s10, vertical: AppDimens.s4),
                  decoration: BoxDecoration(
                    color: AppColors.statusDanger,
                    borderRadius: BorderRadius.circular(AppDimens.rMd),
                  ),
                  child: Text(
                    '${alerts.length}',
                    style: AppTypography.labelSm.copyWith(color: Colors.white),
                  ),
                ),
            ],
          ),
          const Gap(AppDimens.s16),
          if (alerts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.cardPadding),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: AppColors.statusActive),
                    const Gap(AppDimens.s12),
                    Text(
                      'لا توجد تنبيهات',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...alerts.asMap().entries.map((entry) {
              final alert = entry.value;
              final severity = alert['severity'] as String;
              final color = severity == 'danger' ? AppColors.statusDanger : AppColors.statusWarning;
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimens.s12),
                padding: const EdgeInsets.all(AppDimens.s12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.rMd),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const Gap(AppDimens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert['title'] as String,
                            style: AppTypography.labelMd.copyWith(
                              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                            ),
                          ),
                          Text(
                            alert['message'] as String,
                            style: AppTypography.bodySm.copyWith(
                              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate(delay: 700.ms).fadeIn().slideX(begin: -0.1);
  }

  Widget _buildCabinetProgressCard({
    required List<Map<String, dynamic>> cabinetsProgress,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.s8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimens.rMd),
                ),
                child: Icon(Icons.apps, color: AppColors.primary, size: AppDimens.iconMd),
              ),
              const Gap(AppDimens.s12),
              Text(
                'تقدم الكabenات',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                ),
              ),
            ],
          ),
          const Gap(AppDimens.s16),
          if (cabinetsProgress.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.cardPadding),
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 48, color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted),
                    const Gap(AppDimens.s12),
                    Text(
                      'لا توجد كabenات',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...cabinetsProgress.asMap().entries.map((entry) {
              final cabinet = entry.value;
              final progress = cabinet['progress'] as double;
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (cabinet['name'] ?? '') as String,
                          style: AppTypography.labelMd.copyWith(
                            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                          ),
                        ),
                        Text(
                          '${cabinet['current']}/${cabinet['total']}',
                          style: AppTypography.labelSm.copyWith(
                            color: isDarkMode ? AppColors.darkTextBody : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppDimens.s8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: progress >= 1.0 
                                    ? [AppColors.statusActive, AppColors.statusActive.withGreen(150)]
                                    : [AppColors.primary, AppColors.primary.withBlue(200)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    ).animate(delay: 800.ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildRecentActivitiesCard({
    required List<Map<String, dynamic>> recentActivities,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppDimens.rLg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأنشطة الأخيرة',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'عرض الكل ←',
                  style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const Gap(AppDimens.s16),
          if (recentActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.cardPadding),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 48, color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted),
                    const Gap(AppDimens.s12),
                    Text(
                      'لا توجد أنشطة حديثة',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...recentActivities.take(5).toList().asMap().entries.map((entry) {
              final activity = entry.value;
              final color = _getColorFromName((activity['color'] as String?) ?? 'statusInfo');
              
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimens.s12),
                padding: const EdgeInsets.all(AppDimens.s12),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                  borderRadius: BorderRadius.circular(AppDimens.rMd),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimens.rMd),
                      ),
                      child: Center(
                        child: Text(
                          (activity['userCode'] as String?) ?? '-',
                          style: AppTypography.labelSm.copyWith(color: color, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const Gap(AppDimens.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (activity['userName'] as String?) ?? '-',
                            style: AppTypography.labelMd.copyWith(
                              color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                            ),
                          ),
                          Text(
                            (activity['activity'] as String?) ?? '-',
                            style: AppTypography.bodySm.copyWith(
                              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      (activity['date'] as String?) ?? '-',
                      style: AppTypography.labelSm.copyWith(
                        color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (900 + entry.key * 100).ms).fadeIn().slideX(begin: 0.05);
            }),
        ],
      ),
    ).animate(delay: 900.ms).fadeIn().slideY(begin: 0.1);
  }

  Widget _buildLegendItem(String label, Color color, bool isDarkMode) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(AppDimens.s8),
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'statusActive': return AppColors.statusActive;
      case 'statusInfo': return AppColors.statusInfo;
      case 'statusDanger': return AppColors.statusDanger;
      case 'statusWarning': return AppColors.statusWarning;
      default: return AppColors.statusActive;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _getMonthName(int month) {
    const months = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return months[month];
  }

  // Navigation and dialog methods
  void _showSubscriberDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SubscriberDialog();
      },
    );
  }

  void _showPaymentDialog(BuildContext context) {
    // Show snackbar - payment requires selecting a subscriber first
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('يرجى اختيار مشترك لتسجيل الدفعة'),
        action: SnackBarAction(
          label: 'المشتركون',
          onPressed: () => _navigateToSubscribers(context),
        ),
      ),
    );
  }

  void _navigateToCabinets(BuildContext context) {
    // Would use Navigator or Router in real implementation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('التوجه إلى الكabenات...')),
    );
  }

  void _navigateToSubscribers(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('التوجه إلى المشتركين...')),
    );
  }

  void _navigateToWorkers(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('التوجه إلى الموظفين...')),
    );
  }

  void _navigateToReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('التوجه إلى التقارير...')),
    );
  }
}
