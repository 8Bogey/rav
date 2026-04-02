import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/cabinets_service.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/auth/auth_provider.dart';

/// State for cabinets list
class CabinetsState {
  final List<Cabinet> cabinets;
  final bool isLoading;
  final String? error;
  final String sortBy; // 'name', 'completion', 'subscribers'

  const CabinetsState({
    this.cabinets = const [],
    this.isLoading = false,
    this.error,
    this.sortBy = 'completion',
  });

  CabinetsState copyWith({
    List<Cabinet>? cabinets,
    bool? isLoading,
    String? error,
    String? sortBy,
    bool clearError = false,
  }) {
    return CabinetsState(
      cabinets: cabinets ?? this.cabinets,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Notifier for managing cabinets state
/// 
/// This notifier now uses CabinetsService instead of directly accessing DAOs
/// to provide a consistent service layer for all database operations.
class CabinetsNotifier extends StateNotifier<CabinetsState> {
  final Ref _ref;
  late CabinetsService _service;
  String _ownerId = '';

  CabinetsNotifier(this._ref) : super(const CabinetsState()) {
    _service = _ref.read(cabinetsServiceProvider);
    _ownerId = _ref.read(currentUserIdProvider) ?? '';
    loadCabinets();
  }

  /// Load all cabinets from database
  Future<void> loadCabinets() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var cabinets = await _service.getAllCabinets(ownerId: _ownerId);

      // Sort by completion percentage (highest first)
      if (state.sortBy == 'completion') {
        cabinets.sort((a, b) {
          final aPercent = a.totalSubscribers > 0
              ? a.currentSubscribers / a.totalSubscribers
              : 0.0;
          final bPercent = b.totalSubscribers > 0
              ? b.currentSubscribers / b.totalSubscribers
              : 0.0;
          return bPercent.compareTo(aPercent);
        });
      } else if (state.sortBy == 'name') {
        cabinets.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      }

      state = state.copyWith(
        cabinets: cabinets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل الكابينات: $e',
      );
    }
  }

  /// Set sort order
  Future<void> setSortBy(String sortBy) async {
    state = state.copyWith(sortBy: sortBy);
    await loadCabinets();
  }

  /// Add a new cabinet
  Future<String> addCabinet({
    required String name,
    required String letter,
    int totalSubscribers = 0,
    int currentSubscribers = 0,
    double collectedAmount = 0,
    int delayedSubscribers = 0,
    DateTime? completionDate,
  }) async {
    try {
      final cabinet = Cabinet(
        id: '',
        name: name,
        letter: letter,
        totalSubscribers: totalSubscribers,
        currentSubscribers: currentSubscribers,
        collectedAmount: collectedAmount,
        delayedSubscribers: delayedSubscribers,
        completionDate: completionDate,
        version: 1,
        isDeleted: false,
      );
      
      final id = await _service.addCabinet(cabinet, ownerId: _ownerId);

      await loadCabinets();
      return id;
    } catch (e) {
      state = state.copyWith(error: 'فشل إضافة الكابينة: $e');
      rethrow;
    }
  }

  /// Update an existing cabinet
  Future<void> updateCabinet(Cabinet cabinet) async {
    try {
      await _service.updateCabinet(cabinet, ownerId: _ownerId);
      await loadCabinets();
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث الكابينة: $e');
      rethrow;
    }
  }

  /// Delete a cabinet
  Future<void> deleteCabinet(String id) async {
    try {
      await _service.deleteCabinet(id, ownerId: _ownerId);
      await loadCabinets();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف الكابينة: $e');
      rethrow;
    }
  }

  /// Get cabinet by ID
  Future<Cabinet?> getCabinetById(String id) async {
    return await _service.getCabinetById(id, ownerId: _ownerId);
  }

  /// Get cabinet by name
  Future<Cabinet?> getCabinetByName(String name) async {
    return await _service.getCabinetByName(name, ownerId: _ownerId);
  }

  /// Get cabinet by letter
  Future<Cabinet?> getCabinetByLetter(String letter) async {
    final cabinets = await _service.getAllCabinets(ownerId: _ownerId);
    try {
      return cabinets.firstWhere((c) => (c.letter.toUpperCase() ?? c.name.toUpperCase()) == letter.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  /// Calculate completion percentage for a cabinet
  double getCompletionPercentage(Cabinet cabinet) {
    if (cabinet.totalSubscribers == 0) return 0.0;
    return (cabinet.currentSubscribers / cabinet.totalSubscribers) * 100;
  }

  /// Update cabinet stats after payment
  Future<void> updateCabinetStats(String cabinetName, double amount) async {
    try {
      final cabinet = await getCabinetByName(cabinetName);
      if (cabinet != null) {
        await updateCabinet(cabinet.copyWith(
          collectedAmount: cabinet.collectedAmount + amount,
          currentSubscribers: cabinet.currentSubscribers + 1,
        ));
      }
    } catch (e) {
      // Silently fail - stats update shouldn't break payment
      print('Failed to update cabinet stats: $e');
    }
  }
}

/// Provider for cabinets state
final cabinetsProvider =
    StateNotifierProvider<CabinetsNotifier, CabinetsState>((ref) {
  return CabinetsNotifier(ref);
});

/// Provider for a single cabinet by ID
final cabinetByIdProvider =
    FutureProvider.family<Cabinet?, String>((ref, id) async {
  final service = ref.watch(cabinetsServiceProvider);
  final ownerId = ref.watch(currentUserIdProvider) ?? '';
  return await service.getCabinetById(id, ownerId: ownerId);
});

/// Provider for cabinet completion stats
final cabinetStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final cabinets = ref.watch(cabinetsProvider).cabinets;

  int completed = 0;
  int inProgress = 0;
  int notStarted = 0;

  for (var cabinet in cabinets) {
    final percent = cabinet.totalSubscribers > 0
        ? (cabinet.currentSubscribers / cabinet.totalSubscribers) * 100
        : 0.0;

    if (percent >= 100) {
      completed++;
    } else if (percent > 0) {
      inProgress++;
    } else {
      notStarted++;
    }
  }

  return {
    'completed': completed,
    'inProgress': inProgress,
    'notStarted': notStarted,
    'total': cabinets.length,
  };
});
