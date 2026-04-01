import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_providers.dart';
import 'package:mawlid_al_dhaki/core/auth/auth_provider.dart';

/// State for subscribers list
class SubscribersState {
  final List<Subscriber> subscribers;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final int? statusFilter; // null = all, 0-3 = specific status
  final String? cabinetFilter; // null = all cabinets

  const SubscribersState({
    this.subscribers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.statusFilter,
    this.cabinetFilter,
  });

  SubscribersState copyWith({
    List<Subscriber>? subscribers,
    bool? isLoading,
    String? error,
    String? searchQuery,
    int? statusFilter,
    String? cabinetFilter,
    bool clearError = false,
    bool clearStatusFilter = false,
    bool clearCabinetFilter = false,
  }) {
    return SubscribersState(
      subscribers: subscribers ?? this.subscribers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter:
          clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      cabinetFilter:
          clearCabinetFilter ? null : (cabinetFilter ?? this.cabinetFilter),
    );
  }
}

/// Notifier for managing subscribers state
/// 
/// This notifier now uses SubscribersService instead of directly accessing DAOs
/// to provide a consistent service layer for all database operations.
class SubscribersNotifier extends StateNotifier<SubscribersState> {
  final Ref _ref;
  late SubscribersService _service;

  SubscribersNotifier(this._ref) : super(const SubscribersState()) {
    _service = _ref.read(subscribersServiceProvider);
    // Load subscribers on initialization
    loadSubscribers();
  }

  /// Load all subscribers from database
  Future<void> loadSubscribers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ownerId = _ref.read(currentUserIdProvider) ?? '';

    try {
      final subscribers = await _service.getAllSubscribers(ownerId: ownerId);

      state = state.copyWith(
        subscribers: subscribers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل المشتركين: $e',
      );
    }
  }

  /// Search subscribers by name or code
  Future<void> searchSubscribers(String query) async {
    state =
        state.copyWith(isLoading: true, searchQuery: query, clearError: true);
    final ownerId = _ref.read(currentUserIdProvider) ?? '';

    try {
      List<Subscriber> subscribers;

      if (query.isEmpty) {
        subscribers = await _service.getAllSubscribers(ownerId: ownerId);
      } else {
        subscribers = await _service.searchSubscribers(query, ownerId: ownerId);
      }

      // Apply status filter if set
      if (state.statusFilter != null) {
        subscribers =
            subscribers.where((s) => s.status == state.statusFilter).toList();
      }

      state = state.copyWith(
        subscribers: subscribers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل البحث: $e',
      );
    }
  }

  /// Filter subscribers by status
  Future<void> filterByStatus(int? status) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ownerId = _ref.read(currentUserIdProvider) ?? '';

    try {
      var subscribers = await _service.getAllSubscribers(ownerId: ownerId);

      if (status != null) {
        subscribers = subscribers.where((s) => s.status == status).toList();
      }

      // Apply cabinet filter if set
      if (state.cabinetFilter != null) {
        subscribers = subscribers.where((s) => s.cabinet == state.cabinetFilter).toList();
      }

      state = state.copyWith(
        subscribers: subscribers,
        isLoading: false,
        statusFilter: status,
        clearStatusFilter: status == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل التصفية: $e',
      );
    }
  }

  /// Filter subscribers by cabinet
  Future<void> filterByCabinet(String? cabinet) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ownerId = _ref.read(currentUserIdProvider) ?? '';

    try {
      var subscribers = await _service.getAllSubscribers(ownerId: ownerId);

      if (cabinet != null && cabinet.isNotEmpty) {
        subscribers = subscribers.where((s) => s.cabinet == cabinet).toList();
      }

      // Apply status filter if set
      if (state.statusFilter != null) {
        subscribers = subscribers.where((s) => s.status == state.statusFilter).toList();
      }

      state = state.copyWith(
        subscribers: subscribers,
        isLoading: false,
        cabinetFilter: cabinet,
        clearCabinetFilter: cabinet == null || cabinet.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل التصفية: $e',
      );
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final ownerId = _ref.read(currentUserIdProvider) ?? '';

    try {
      final subscribers = await _service.getAllSubscribers(ownerId: ownerId);

      state = state.copyWith(
        subscribers: subscribers,
        isLoading: false,
        clearStatusFilter: true,
        clearCabinetFilter: true,
        searchQuery: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل المشتركين: $e',
      );
    }
  }

  /// Add a new subscriber
  Future<String> addSubscriber({
    required String name,
    required String code,
    required String cabinet,
    required String phone,
    required int status,
    required DateTime startDate,
    double accumulatedDebt = 0,
    String? tags,
    String? notes,
  }) async {
    try {
      final ownerId = _ref.read(currentUserIdProvider) ?? '';
      final subscriber = Subscriber(
        id: '', // Will be auto-generated
        ownerId: ownerId,
        name: name,
        code: code,
        cabinet: cabinet,
        phone: phone,
        status: status,
        startDate: startDate,
        accumulatedDebt: accumulatedDebt,
        tags: tags,
        notes: notes,
        version: 1,
        isDeleted: false,
      );
      
      final id = await _service.addSubscriber(subscriber, ownerId: ownerId);

      // Refresh the list
      await loadSubscribers();

      return id;
    } catch (e) {
      state = state.copyWith(error: 'فشل إضافة المشترك: $e');
      rethrow;
    }
  }

  /// Update an existing subscriber
  Future<void> updateSubscriber(Subscriber subscriber) async {
    try {
      final ownerId = _ref.read(currentUserIdProvider) ?? '';
      await _service.updateSubscriber(subscriber, ownerId: ownerId);

      // Refresh the list
      await loadSubscribers();
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث المشترك: $e');
      rethrow;
    }
  }

  /// Delete a subscriber
  Future<void> deleteSubscriber(String id) async {
    try {
      final ownerId = _ref.read(currentUserIdProvider) ?? '';
      await _service.deleteSubscriber(id, ownerId: ownerId);

      // Refresh the list
      await loadSubscribers();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف المشترك: $e');
      rethrow;
    }
  }

  /// Get subscriber by ID
  Future<Subscriber?> getSubscriberById(String id) async {
    final ownerId = _ref.read(currentUserIdProvider) ?? '';
    return await _service.getSubscriberById(id, ownerId: ownerId);
  }

  /// Get subscriber by code
  Future<Subscriber?> getSubscriberByCode(String code) async {
    final ownerId = _ref.read(currentUserIdProvider) ?? '';
    return await _service.getSubscriberByCode(code, ownerId: ownerId);
  }
}

/// Provider for subscribers state
final subscribersProvider =
    StateNotifierProvider<SubscribersNotifier, SubscribersState>((ref) {
  return SubscribersNotifier(ref);
});

/// Provider for a single subscriber by ID
final subscriberByIdProvider =
    FutureProvider.family<Subscriber?, String>((ref, id) async {
  final service = ref.watch(subscribersServiceProvider);
  final ownerId = ref.read(currentUserIdProvider) ?? '';
  return await service.getSubscriberById(id, ownerId: ownerId);
});

/// Provider for subscribers count by status
final subscribersCountProvider = FutureProvider<Map<int, int>>((ref) async {
  final service = ref.watch(subscribersServiceProvider);
  final ownerId = ref.read(currentUserIdProvider) ?? '';
  final subscribers = await service.getAllSubscribers(ownerId: ownerId);

  final counts = <int, int>{};
  for (var subscriber in subscribers) {
    counts[subscriber.status] = (counts[subscriber.status] ?? 0) + 1;
  }

  return counts;
});

/// Provider for selected cabinet filter (used when navigating from cabinets screen)
final selectedCabinetFilterProvider = StateProvider<String?>((ref) => null);
