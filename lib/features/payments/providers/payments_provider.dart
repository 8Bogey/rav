import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_providers.dart';

/// State for payments
class PaymentsState {
  final List<Payment> payments;
  final bool isLoading;
  final String? error;
  final String? filterByMonth; // Format: 'YYYY-MM'
  final int? filterBySubscriberId;
  final int? filterByWorkerId;

  const PaymentsState({
    this.payments = const [],
    this.isLoading = false,
    this.error,
    this.filterByMonth,
    this.filterBySubscriberId,
    this.filterByWorkerId,
  });

  PaymentsState copyWith({
    List<Payment>? payments,
    bool? isLoading,
    String? error,
    String? filterByMonth,
    int? filterBySubscriberId,
    int? filterByWorkerId,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return PaymentsState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterByMonth:
          clearFilters ? null : (filterByMonth ?? this.filterByMonth),
      filterBySubscriberId: clearFilters
          ? null
          : (filterBySubscriberId ?? this.filterBySubscriberId),
      filterByWorkerId:
          clearFilters ? null : (filterByWorkerId ?? this.filterByWorkerId),
    );
  }
}

/// Notifier for managing payments state
/// 
/// This notifier now uses PaymentsService instead of directly accessing DAOs
/// to provide a consistent service layer for all database operations.
class PaymentsNotifier extends StateNotifier<PaymentsState> {
  final Ref _ref;
  late PaymentsService _service;

  PaymentsNotifier(this._ref) : super(const PaymentsState()) {
    _service = _ref.read(paymentsServiceProvider);
    loadPayments();
  }

  /// Load all payments from database
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var payments = await _service.getAllPayments();

      // Apply filters
      if (state.filterByMonth != null) {
        payments = payments.where((p) {
          final monthStr =
              '${p.date.year}-${p.date.month.toString().padLeft(2, '0')}';
          return monthStr == state.filterByMonth;
        }).toList();
      }

      if (state.filterBySubscriberId != null) {
        payments = payments
            .where((p) => p.subscriberId == state.filterBySubscriberId)
            .toList();
      }

      // Sort by date (newest first)
      payments.sort((a, b) => b.date.compareTo(a.date));

      state = state.copyWith(
        payments: payments,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل المدفوعات: $e',
      );
    }
  }

  /// Filter by month
  Future<void> filterByMonth(String? month) async {
    state = state.copyWith(filterByMonth: month);
    await loadPayments();
  }

  /// Filter by subscriber
  Future<void> filterBySubscriber(int? subscriberId) async {
    state = state.copyWith(filterBySubscriberId: subscriberId);
    await loadPayments();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    state = state.copyWith(clearFilters: true);
    await loadPayments();
  }

  /// Add a new payment
  Future<int> addPayment({
    required int subscriberId,
    required double amount,
    required String worker,
    required String cabinet,
    DateTime? date,
  }) async {
    try {
      final payment = Payment(
        id: 0, // Will be auto-generated
        subscriberId: subscriberId,
        amount: amount,
        worker: worker,
        cabinet: cabinet,
        date: date ?? DateTime.now(),
      );
      
      final id = await _service.addPayment(payment);

      await loadPayments();
      return id;
    } catch (e) {
      state = state.copyWith(error: 'فشل إضافة الدفعة: $e');
      rethrow;
    }
  }

  /// Update an existing payment
  Future<void> updatePayment(Payment payment) async {
    try {
      await _service.updatePayment(payment);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث الدفعة: $e');
      rethrow;
    }
  }

  /// Delete a payment
  Future<void> deletePayment(int id) async {
    try {
      await _service.deletePayment(id);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف الدفعة: $e');
      rethrow;
    }
  }

  /// Get payments by subscriber ID
  Future<List<Payment>> getPaymentsBySubscriberId(int subscriberId) async {
    return await _service.getPaymentsBySubscriberId(subscriberId);
  }

  /// Get total amount for a month
  Future<double> getMonthlyTotal(String month) async {
    final payments = await _service.getAllPayments();

    double total = 0;
    for (var payment in payments) {
      final monthStr =
          '${payment.date.year}-${payment.date.month.toString().padLeft(2, '0')}';
      if (monthStr == month) {
        total += payment.amount;
      }
    }

    return total;
  }

  /// Get today's total
  Future<double> getTodayTotal() async {
    final payments = await _service.getAllPayments();

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    double total = 0;
    for (var payment in payments) {
      if (payment.date.isAfter(todayStart) ||
          payment.date.isAtSameMomentAs(todayStart)) {
        total += payment.amount;
      }
    }

    return total;
  }
}

/// Provider for payments state
final paymentsProvider =
    StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  return PaymentsNotifier(ref);
});

/// Provider for a single payment by ID
final paymentByIdProvider =
    FutureProvider.family<Payment?, int>((ref, id) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.getPaymentById(id);
});

/// Provider for payments by subscriber
final paymentsBySubscriberProvider =
    FutureProvider.family<List<Payment>, int>((ref, subscriberId) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.getPaymentsBySubscriberId(subscriberId);
});

/// Provider for monthly totals
final monthlyTotalProvider =
    FutureProvider.family<double, String>((ref, month) async {
  final notifier = ref.read(paymentsProvider.notifier);
  return await notifier.getMonthlyTotal(month);
});

/// Provider for today's total
final todayTotalProvider = FutureProvider<double>((ref) async {
  final notifier = ref.read(paymentsProvider.notifier);
  return await notifier.getTodayTotal();
});
