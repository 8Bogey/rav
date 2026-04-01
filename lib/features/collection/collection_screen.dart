import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/services/settings_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/core/auth/auth_provider.dart';
import 'package:mawlid_al_dhaki/features/collection/payment_registration_dialog.dart';
import 'package:mawlid_al_dhaki/features/payments/providers/payments_provider.dart';
import 'package:mawlid_al_dhaki/features/subscribers/providers/subscribers_provider.dart';
import 'package:mawlid_al_dhaki/features/cabinets/providers/cabinets_provider.dart';

/// Collection status enum
enum CollectionStatus { notPaid, partial, completed }

/// State for collection kanban
class CollectionState {
  final List<Subscriber> notPaid;
  final List<Subscriber> partial;
  final List<Subscriber> completed;
  final bool isLoading;
  final String? error;
  final double totalCollected;
  final double totalRemaining;

  const CollectionState({
    this.notPaid = const [],
    this.partial = const [],
    this.completed = const [],
    this.isLoading = false,
    this.error,
    this.totalCollected = 0,
    this.totalRemaining = 0,
  });

  CollectionState copyWith({
    List<Subscriber>? notPaid,
    List<Subscriber>? partial,
    List<Subscriber>? completed,
    bool? isLoading,
    String? error,
    double? totalCollected,
    double? totalRemaining,
    bool clearError = false,
  }) {
    return CollectionState(
      notPaid: notPaid ?? this.notPaid,
      partial: partial ?? this.partial,
      completed: completed ?? this.completed,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      totalCollected: totalCollected ?? this.totalCollected,
      totalRemaining: totalRemaining ?? this.totalRemaining,
    );
  }
}

/// Provider for collection state
final collectionProvider =
    StateNotifierProvider<CollectionNotifier, CollectionState>((ref) {
  return CollectionNotifier(ref);
});

/// Provider for ampere price (IQD per ampere).
final amperePriceProvider = StateProvider<double>((ref) => 2500.0);

/// One-time initializer that loads the ampere price from persistent settings
/// into [amperePriceProvider] when the collection screen is first built.
final amperePriceInitProvider = FutureProvider<void>((ref) async {
  final database = ref.read(databaseProvider);
  final settingsService = SettingsService(database);
  final savedPrice = await settingsService.getAmperePrice();
  ref.read(amperePriceProvider.notifier).state = savedPrice;
});

/// Notifier for managing collection state
class CollectionNotifier extends StateNotifier<CollectionState> {
  final Ref _ref;
  String _ownerId = '';

  CollectionNotifier(this._ref) : super(const CollectionState()) {
    _ownerId = _ref.read(currentUserIdProvider) ?? '';
    loadCollection();
  }

  Future<void> loadCollection() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final dao = _ref.read(subscribersDaoProvider);
      final subscribers = await dao.getAllSubscribers(ownerId: _ownerId);

      // Categorize subscribers based on their debt status
      // For now, using accumulatedDebt to determine status:
      // - debt > 15000: not paid
      // - debt > 0 && <= 15000: partial
      // - debt == 0: completed
      final notPaid = <Subscriber>[];
      final partial = <Subscriber>[];
      final completed = <Subscriber>[];
      double totalCollected = 0;
      double totalRemaining = 0;

      for (var subscriber in subscribers) {
        if (subscriber.accumulatedDebt > 15000) {
          notPaid.add(subscriber);
          totalRemaining += subscriber.accumulatedDebt;
        } else if (subscriber.accumulatedDebt > 0) {
          partial.add(subscriber);
          totalRemaining += subscriber.accumulatedDebt;
        } else {
          completed.add(subscriber);
          // Assume monthly payment of 15000 for collected calculation
          totalCollected += 15000;
        }
      }

      state = state.copyWith(
        notPaid: notPaid,
        partial: partial,
        completed: completed,
        isLoading: false,
        totalCollected: totalCollected,
        totalRemaining: totalRemaining,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل التحصيلات: $e',
      );
    }
  }

  /// Register a payment for a subscriber
  Future<void> registerPayment({
    required String subscriberId,
    required double amount,
    required String workerName,
    required String cabinetName,
  }) async {
    try {
      // Add payment to database
      final paymentsNotifier = _ref.read(paymentsProvider.notifier);
      await paymentsNotifier.addPayment(
        subscriberId: subscriberId,
        amount: amount,
        worker: workerName,
        cabinet: cabinetName,
      );

      // Update subscriber's debt and cabinet stats
      final subscribersNotifier = _ref.read(subscribersProvider.notifier);
      final cabinetsNotifier = _ref.read(cabinetsProvider.notifier);

      // Get subscriber to update their debt
      final subscriber =
          await subscribersNotifier.getSubscriberById(subscriberId.toString());
      if (subscriber != null) {
        // Update subscriber's accumulated debt
        final updatedSubscriber = subscriber.copyWith(
          accumulatedDebt: subscriber.accumulatedDebt - amount,
        );
        await subscribersNotifier.updateSubscriber(updatedSubscriber);

        // Update cabinet stats
        await cabinetsNotifier.updateCabinetStats(cabinetName, amount);
      }

      // Reload collection data to reflect changes
      await loadCollection();
    } catch (e) {
      state = state.copyWith(error: 'فشل تسجيل الدفعة: $e');
      rethrow;
    }
  }
}

/// Collection Screen Widget
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure ampere price is loaded from settings once when this screen builds.
    ref.watch(amperePriceInitProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final collectionState = ref.watch(collectionProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDarkMode, ref),
          const SizedBox(height: 16),

          // Loading state
          if (collectionState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error state
          if (collectionState.error != null && !collectionState.isLoading)
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
                      'حدث خطأ أثناء تحميل التحصيلات',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      collectionState.error!,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(collectionProvider.notifier).loadCollection();
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

          // Success state
          if (!collectionState.isLoading && collectionState.error == null) ...[
            // Progress indicator
            _buildProgressIndicator(collectionState, isDarkMode),
            const SizedBox(height: 24),

            // Kanban columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Not paid column
                  _buildKanbanColumn(
                    'لم يدفعوا',
                    collectionState.notPaid,
                    AppColors.statusDangerS,
                    AppColors.statusDanger,
                    isDarkMode,
                    ref,
                  ),
                  const SizedBox(width: 16),
                  // Partial column
                  _buildKanbanColumn(
                    'دفع جزئي',
                    collectionState.partial,
                    AppColors.statusWarningS,
                    AppColors.statusWarning,
                    isDarkMode,
                    ref,
                  ),
                  const SizedBox(width: 16),
                  // Completed column
                  _buildKanbanColumn(
                    'مكتمل',
                    collectionState.completed,
                    AppColors.statusActiveS,
                    AppColors.statusActive,
                    isDarkMode,
                    ref,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode, WidgetRef ref) {
    final now = DateTime.now();
    final monthYear = '${_getArabicMonth(now.month)} ${now.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التحصيل',
              style: AppTypography.h2.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              monthYear,
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkBgSurfaceAlt
                    : AppColors.bgSurfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'سعر الأمبير: ${_formatIQD(ref.watch(amperePriceProvider))} IQD',
                style: AppTypography.labelMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                _showEditPriceDialog(context, isDarkMode, ref);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Icons.edit,
                      color: AppColors.textOnGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تعديل',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.textOnGold,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: 100.ms)
                .scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  Widget _buildProgressIndicator(CollectionState state, bool isDarkMode) {
    final total = state.totalCollected + state.totalRemaining;
    final percentage = total > 0 ? state.totalCollected / total : 0.0;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدم الشهر',
            style: AppTypography.bodyMd.copyWith(
              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor:
                  isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(percentage * 100).toStringAsFixed(0)}% مكتمل',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'جُمع: ${_formatIQD(state.totalCollected)}',
                style: AppTypography.bodyMd.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextHead
                      : AppColors.textHeading,
                ),
              ),
              Text(
                'متبقي: ${_formatIQD(state.totalRemaining)}',
                style: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(
    String title,
    List<Subscriber> items,
    Color backgroundColor,
    Color accentColor,
    bool isDarkMode,
    WidgetRef ref,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Column header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTypography.h4.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextHead
                          : AppColors.textHeading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${items.length}',
                      style: AppTypography.labelMd.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Items list
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'لا يوجد مشتركين',
                        style: AppTypography.bodyMd.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _buildCollectionItem(
                            item, accentColor, isDarkMode, index, ref);
                      },
                    ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildCollectionItem(
    Subscriber subscriber,
    Color accentColor,
    bool isDarkMode,
    int index,
    WidgetRef ref,
  ) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscriber info
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      subscriber.code
                          .substring(0, subscriber.code.length.clamp(1, 3)),
                      style: AppTypography.labelMd.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscriber.name,
                        style: AppTypography.bodyMd.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextHead
                              : AppColors.textHeading,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'كود: ${subscriber.code} | كابينة ${subscriber.cabinet}',
                        style: AppTypography.bodySm.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Amount info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدين المتراكم',
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    Text(
                      '${_formatIQD(subscriber.accumulatedDebt)} IQD',
                      style: AppTypography.h4.copyWith(
                        color: subscriber.accumulatedDebt > 0
                            ? AppColors.statusDanger
                            : AppColors.statusActive,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Show payment registration dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return PaymentRegistrationDialog(
                        subscriber: subscriber,
                        onPaymentRegistered: () {
                          // Refresh collection data after payment
                          ref
                              .read(collectionProvider.notifier)
                              .loadCollection();
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.textOnGold,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  subscriber.accumulatedDebt > 0 ? 'تحصيل →' : 'عرض →',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.textOnGold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms),
    );
  }

  String _formatIQD(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showEditPriceDialog(
      BuildContext context, bool isDarkMode, WidgetRef ref) {
    final priceController = TextEditingController(
      text: ref.read(amperePriceProvider).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        title: Text(
          'تعديل سعر الأمبير',
          style: AppTypography.h3.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'سعر الأمبير (IQD)',
              ),
              style: AppTypography.bodyMd.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceController.text) ?? 2500.0;

              // Save to provider
              ref.read(amperePriceProvider.notifier).state = price;

              // Save to database
              final database = ref.read(databaseProvider);
              final settingsService = SettingsService(database);
              await settingsService.setAmperePrice(price);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث السعر'),
                    backgroundColor: AppColors.statusActive,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
