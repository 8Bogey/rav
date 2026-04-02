import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/features/subscribers/providers/subscribers_provider.dart';
import 'package:mawlid_al_dhaki/features/subscribers/dialogs/subscriber_dialog.dart';
import 'package:mawlid_al_dhaki/shared/utils/app_transitions.dart';

class SubscribersScreen extends ConsumerStatefulWidget {
  const SubscribersScreen({super.key});

  @override
  ConsumerState<SubscribersScreen> createState() => _SubscribersScreenState();
}

class _SubscribersScreenState extends ConsumerState<SubscribersScreen> {
  bool _filterApplied = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final subscribersState = ref.watch(subscribersProvider);
    final selectedCabinet = ref.watch(selectedCabinetFilterProvider);

    // Apply cabinet filter when screen loads or when cabinet changes
    if (selectedCabinet != null && !_filterApplied && !subscribersState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(subscribersProvider.notifier).filterByCabinet(selectedCabinet);
        setState(() {
          _filterApplied = true;
        });
      });
    }

    // Reset filter applied flag when no cabinet is selected
    if (selectedCabinet == null && _filterApplied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _filterApplied = false;
        });
      });
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDarkMode, ref),
          const SizedBox(height: 24),
          _buildFiltersAndSearch(isDarkMode, ref),
          const SizedBox(height: 16),

          // Loading state
          if (subscribersState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error state
          if (subscribersState.error != null && !subscribersState.isLoading)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 64,
                      color: AppColors.statusDanger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء تحميل المشتركين',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subscribersState.error!,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(subscribersProvider.notifier)
                            .loadSubscribers();
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

          // Empty state
          if (!subscribersState.isLoading &&
              subscribersState.error == null &&
              subscribersState.subscribers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 64,
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مشتركين',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط على زر "إضافة مشترك" لإنشاء مشترك جديد',
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

          // Success state with data
          if (!subscribersState.isLoading &&
              subscribersState.error == null &&
              subscribersState.subscribers.isNotEmpty)
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
                child: Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBgSurfaceAlt
                            : AppColors.bgSurfaceAlt,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '#',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'المشترك',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'رقم الجوزة',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'الكابينة',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الدين المتراكم',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'آخر دفعة',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'الحالة',
                              style: AppTypography.labelMd.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Table rows
                    Expanded(
                      child: ListView.builder(
                        itemCount: subscribersState.subscribers.length,
                        itemBuilder: (context, index) {
                          final subscriber =
                              subscribersState.subscribers[index];
                          return _buildSubscriberRow(subscriber, index,
                              isDarkMode: isDarkMode);
                        },
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideY(begin: 0.08, curve: Curves.easeOutBack, duration: 600.ms),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, WidgetRef ref) {
    final selectedCabinet = ref.watch(selectedCabinetFilterProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (selectedCabinet != null) ...[
              GestureDetector(
                onTap: () {
                  ref.read(subscribersProvider.notifier).clearFilters();
                  ref.read(selectedCabinetFilterProvider.notifier).state = null;
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              selectedCabinet != null 
                  ? 'مشتركي $selectedCabinet' 
                  : 'المشتركين',
              style: AppTypography.h2.copyWith(
                color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ).animate().fadeIn(duration: 300.ms),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => const SubscriberDialog(),
            );
            if (result == true) {
              // Refresh the list after adding a subscriber
              ref.read(subscribersProvider.notifier).loadSubscribers();
            }
          },
          child: Container(
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
          ),
        )
            .animate(delay: 50.ms)
            .scaleXY(begin: 0.95, end: 1.0, duration: 150.ms),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFiltersAndSearch(bool isDarkMode, WidgetRef ref) {
    final subscribersState = ref.watch(subscribersProvider);
    final totalCount = subscribersState.subscribers.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter tabs
        Row(
          children: [
            _buildFilterTab(
              'الكل ($totalCount)',
              subscribersState.statusFilter == null,
              isDarkMode: isDarkMode,
              onTap: () {
                ref.read(subscribersProvider.notifier).filterByStatus(null);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              'نشط',
              subscribersState.statusFilter == 1,
              isDarkMode: isDarkMode,
              onTap: () {
                ref.read(subscribersProvider.notifier).filterByStatus(1);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              'موقوف',
              subscribersState.statusFilter == 2,
              isDarkMode: isDarkMode,
              onTap: () {
                ref.read(subscribersProvider.notifier).filterByStatus(2);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              'مقطوع',
              subscribersState.statusFilter == 3,
              isDarkMode: isDarkMode,
              onTap: () {
                ref.read(subscribersProvider.notifier).filterByStatus(3);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterTab(
              'غير نشط',
              subscribersState.statusFilter == 0,
              isDarkMode: isDarkMode,
              onTap: () {
                ref.read(subscribersProvider.notifier).filterByStatus(0);
              },
            ),
          ],
        ),
        
        // Show cabinet filter badge if active
        if (subscribersState.cabinetFilter != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.apps,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'الكابينة: ${subscribersState.cabinetFilter}',
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ref.read(subscribersProvider.notifier).clearFilters();
                    ref.read(selectedCabinetFilterProvider.notifier).state = null;
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),

        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
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
                color:
                    isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: isDarkMode
                    ? AppColors.darkTextBody
                    : AppColors.textSecondary,
              ),
              filled: true,
              fillColor: isDarkMode
                  ? AppColors.darkBgSurfaceAlt
                  : AppColors.bgSurfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onChanged: (value) {
              ref.read(subscribersProvider.notifier).searchSubscribers(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(
    String label,
    bool isActive, {
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : isDarkMode
                  ? AppColors.darkBgSurfaceAlt
                  : AppColors.bgSurfaceAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isActive
                ? AppColors.textOnPrimary
                : isDarkMode
                    ? AppColors.darkTextBody
                    : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriberRow(Subscriber subscriber, int index,
      {required bool isDarkMode}) {
    // Determine status color based on subscriber status
    Color statusColor = AppColors.statusActive;
    String statusText = 'نشط';

    switch (subscriber.status) {
      case 0: // inactive
        statusColor = AppColors.textMuted;
        statusText = 'غير نشط';
        break;
      case 1: // active
        statusColor = AppColors.statusActive;
        statusText = 'نشط';
        break;
      case 2: // suspended
        statusColor = AppColors.statusWarning;
        statusText = 'موقوف';
        break;
      case 3: // disconnected
        statusColor = AppColors.statusDanger;
        statusText = 'مقطوع';
        break;
      default:
        statusColor = AppColors.statusActive;
        statusText = 'نشط';
    }

    // Format the debt display
    final debtDisplay = subscriber.accumulatedDebt > 0
        ? '${subscriber.accumulatedDebt.toStringAsFixed(0)} IQD'
        : 'لا يوجد';

    // Format the last payment date
    final lastPaymentDisplay = '${subscriber.startDate.day}/${subscriber.startDate.month}/${subscriber.startDate.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0
            ? (isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface)
            : (isDarkMode
                ? AppColors.darkBgSurfaceAlt
                : AppColors.bgSurfaceAlt),
      ),
      child: Row(
        children: [
          // Avatar with code
          Expanded(
            flex: 1,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  subscriber.code
                      .substring(0, math.min(3, subscriber.code.length)),
                  style: AppTypography.labelMd.copyWith(
                    color: statusColor,
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
              subscriber.name,
              style: AppTypography.bodyMd.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Code
          Expanded(
            flex: 1,
            child: Text(
              subscriber.code,
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
          ),
          // Cabinet
          Expanded(
            flex: 1,
            child: Text(
              subscriber.cabinet,
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
          ),
          // Debt
          Expanded(
            flex: 2,
            child: Text(
              debtDisplay,
              style: AppTypography.bodyMd.copyWith(
                color: subscriber.accumulatedDebt > 0
                    ? AppColors.statusDanger
                    : AppColors.statusActive,
              ),
            ),
          ),
          // Last payment
          Expanded(
            flex: 1,
            child: Text(
              lastPaymentDisplay,
              style: AppTypography.bodySm.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextMuted
                    : AppColors.textSecondary,
              ),
            ),
          ),
          // Status badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: AppTypography.labelMd.copyWith(
                  color: statusColor,
                ),
              ),
            ),
          ),
          // Delete button
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showDeleteConfirmation(context, ref, subscriber),
            child: Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.statusDanger,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Subscriber subscriber) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        title: Text(
          'حذف مشترك',
          style: AppTypography.h3.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف المشترك "${subscriber.name}"؟',
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTypography.labelLg.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(subscribersProvider.notifier).deleteSubscriber(subscriber.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المشترك بنجاح'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
            ),
            child: Text(
              'حذف',
              style: AppTypography.labelLg.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
