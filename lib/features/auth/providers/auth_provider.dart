import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? errorMessage;

  AuthState({
    required this.isAuthenticated,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isAuthenticated: false));

  Future<void> login(String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For demo purposes, accept any non-empty password as per PRD
    if (password.isEmpty) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'يرجى إدخال كلمة المرور',
      );
      return;
    }
    
    // Successful authentication
    state = state.copyWith(
      isAuthenticated: true,
      errorMessage: null,
    );
  }

  void logout() {
    state = state.copyWith(
      isAuthenticated: false,
      errorMessage: null,
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);