import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/reports_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';

// Provider for ReportsService
final reportsServiceProvider = Provider((ref) {
  final database = ref.read(databaseProvider);
  return ReportsService(database);
});



class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final reportsService = ref.watch(reportsServiceProvider);
    
    return FutureBuilder(
      future: Future.wait([
        reportsService.getPaymentRatioData(),
        reportsService.getMonthlyRevenueData(),
        reportsService.getMonthlyProgressData(),
      ]),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDarkMode),
                const SizedBox(height: 24),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Handle error state
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDarkMode),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          size: 64,
                          color: AppColors.statusDanger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ أثناء تحميل التقارير',
                          style: AppTypography.h3.copyWith(
                            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry loading
                            (context as Element).markNeedsBuild();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'إعادة المحاولة',
                            style: AppTypography.labelLg.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Extract data from snapshot
        final data = snapshot.data as List<dynamic>;
        final paymentRatioData = data[0] as Map<String, double>;
        final monthlyRevenueData = data[1] as List<double>;
        final monthlyProgressData = data[2] as List<double>;
        
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
                    'التقارير',
                    style: AppTypography.h2.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextHead
                          : AppColors.textHeading,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  Row(
                    children: [
                      // Month selector
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.darkBgSurface
                              : AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تحديد الشهر ▼',
                              style: AppTypography.labelLg.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                              Icons.description,
                              color: AppColors.textOnGold,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '📄 تصدير PDF',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.textOnGold,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate(delay: 100.ms)
                          .scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              // Charts row - matching PRD requirements
              Expanded(
                child: Column(
                  children: [
                    // Chart cards row
                    Row(
                      children: [
                        // Payment ratio chart
                        _buildChartCard(
                          'نسبة الدفع',
                          _buildPieChart(paymentRatioData),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 16),
                        // Monthly revenue chart
                        _buildChartCard(
                          'إيرادات شهرية',
                          _buildBarChart(monthlyRevenueData),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(width: 16),
                        // Monthly progress chart
                        _buildChartCard(
                          'تقدم الشهر',
                          _buildLineChart(monthlyProgressData),
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tabs for different report types
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBgSurface
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTab('تقرير العمال', true, isDarkMode: isDarkMode),
                          const SizedBox(width: 16),
                          _buildTab('تقرير المديونين', false,
                              isDarkMode: isDarkMode),
                          const SizedBox(width: 16),
                          _buildTab('تقرير الكابينات', false,
                              isDarkMode: isDarkMode),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Detailed data table
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.darkBgSurface
                              : AppColors.bgSurface,
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
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.table_chart,
                                  size: 64,
                                  color: isDarkMode
                                      ? AppColors.darkTextBody
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'بيانات مفصلة',
                                  style: AppTypography.h3.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextHead
                                        : AppColors.textHeading,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'سيتم عرض الجداول التفصيلية هنا',
                                  style: AppTypography.bodyMd.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextBody
                                        : AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'التقارير',
          style: AppTypography.h2.copyWith(
            color: isDarkMode
                ? AppColors.darkTextHead
                : AppColors.textHeading,
          ),
        ).animate().fadeIn(duration: 300.ms),
        Row(
          children: [
            // Month selector
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkBgSurface
                    : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode
                      ? AppColors.darkBorder
                      : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'تحديد الشهر ▼',
                    style: AppTypography.labelLg.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
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
                    Icons.description,
                    color: AppColors.textOnGold,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '📄 تصدير PDF',
                    style: AppTypography.labelLg.copyWith(
                      color: AppColors.textOnGold,
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: 100.ms)
                .scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildChartCard(String title, Widget chart,
      {required bool isDarkMode}) {
    return Expanded(
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
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
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: AppTypography.h4.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: chart,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: AppColors.primary,
            value: data['paid'] ?? 40,
            title: 'مدفوع',
            radius: 50,
            titleStyle: AppTypography.labelMd,
          ),
          PieChartSectionData(
            color: AppColors.statusWarning,
            value: data['partial'] ?? 35,
            title: 'جزئي',
            radius: 50,
            titleStyle: AppTypography.labelMd,
          ),
          PieChartSectionData(
            color: AppColors.statusDanger,
            value: data['unpaid'] ?? 25,
            title: 'غير مدفوع',
            radius: 50,
            titleStyle: AppTypography.labelMd,
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildBarChart(List<double> data) {
    return BarChart(
      BarChartData(
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [BarChartRodData(toY: value, color: AppColors.primary)],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const weeks = ['أول', 'ثاني', 'ثالث', 'رابع'];
                final index = value.toInt();
                if (index >= 0 && index < weeks.length) {
                  return Text(
                    weeks[index],
                    style: AppTypography.bodySm,
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLineChart(List<double> data) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              return FlSpot(index.toDouble(), value);
            }).toList(),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const weeks = ['أول', 'ثاني', 'ثالث', 'رابع'];
                final index = value.toInt();
                if (index >= 0 && index < weeks.length) {
                  return Text(
                    weeks[index],
                    style: AppTypography.bodySm,
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive, {required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: AppTypography.labelLg.copyWith(
          color: isActive
              ? AppColors.primary
              : (isDarkMode ? AppColors.darkTextBody : AppColors.textBody),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
