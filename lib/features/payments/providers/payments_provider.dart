import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_providers.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';

/// State for payments
class PaymentsState {
  final List<Payment> payments;
  final bool isLoading;
  final String? error;
  final String? filterByMonth; // Format: 'YYYY-MM'
  final String? filterBySubscriberId;
  final String? filterByWorkerId;

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
    String? filterBySubscriberId,
    String? filterByWorkerId,
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
  String _ownerId = '';

  PaymentsNotifier(this._ref) : super(const PaymentsState()) {
    _service = _ref.read(paymentsServiceProvider);
    _ownerId = _ref.read(currentUserIdProvider) ?? '';
    loadPayments();
  }

  /// Load all payments from database
  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var payments = await _service.getAllPayments(ownerId: _ownerId);

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
  Future<void> filterBySubscriber(String? subscriberId) async {
    state = state.copyWith(filterBySubscriberId: subscriberId);
    await loadPayments();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    state = state.copyWith(clearFilters: true);
    await loadPayments();
  }

  /// Add a new payment
  Future<String> addPayment({
    required String subscriberId,
    required double amount,
    required String worker,
    required String cabinet,
    DateTime? date,
  }) async {
    try {
      // Create payment with required fields - service will override with proper values
      final payment = Payment(
        id: '',
        ownerId: _ownerId,
        subscriberId: subscriberId,
        amount: amount,
        worker: worker,
        cabinet: cabinet,
        date: date ?? DateTime.now(),
        version: 1,
        inTrash: false,
      );

      final id = await _service.addPayment(payment, ownerId: _ownerId);

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
      await _service.updatePayment(payment, ownerId: _ownerId);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث الدفعة: $e');
      rethrow;
    }
  }

  /// Delete a payment
  Future<void> deletePayment(String id) async {
    try {
      await _service.deletePayment(id, ownerId: _ownerId);
      await loadPayments();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف الدفعة: $e');
      rethrow;
    }
  }

  /// Get payment by ID
  Future<Payment?> getPaymentById(String id) async {
    return await _service.getPaymentById(id, ownerId: _ownerId);
  }

  /// Get payments by subscriber ID
  Future<List<Payment>> getPaymentsBySubscriberId(String subscriberId) async {
    return await _service.getPaymentsBySubscriberId(subscriberId,
        ownerId: _ownerId);
  }
}

/// Provider for payments state
final paymentsProvider =
    StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  return PaymentsNotifier(ref);
});

/// Provider for a single payment by ID
final paymentByIdProvider =
    FutureProvider.family<Payment?, String>((ref, id) async {
  final service = ref.watch(paymentsServiceProvider);
  final ownerId = ref.watch(currentUserIdProvider) ?? '';
  return await service.getPaymentById(id, ownerId: ownerId);
});

/// Provider for payments by subscriber
final paymentsBySubscriberProvider =
    FutureProvider.family<List<Payment>, String>((ref, subscriberId) async {
  final service = ref.watch(paymentsServiceProvider);
  final ownerId = ref.watch(currentUserIdProvider) ?? '';
  return await service.getPaymentsBySubscriberId(subscriberId,
      ownerId: ownerId);
});

/// Provider for total payments amount
final totalPaymentsProvider = Provider<double>((ref) {
  final payments = ref.watch(paymentsProvider).payments;
  return payments.fold(0.0, (double sum, p) => sum + p.amount);
});

/// Provider for monthly payments total
final monthlyPaymentsProvider = Provider.family<double, String>((ref, month) {
  final payments = ref.watch(paymentsProvider).payments;
  return payments
      .where((p) =>
          '${p.date.year}-${p.date.month.toString().padLeft(2, '0')}' == month)
      .fold(0.0, (double sum, p) => sum + p.amount);
});
