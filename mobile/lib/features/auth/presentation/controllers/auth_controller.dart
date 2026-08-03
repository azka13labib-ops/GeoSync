// ====================================================================
// GEOSYNC - AUTH CONTROLLER & RIVERPOD NOTIFIER
// ====================================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/employee_model.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  final EmployeeModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isLoggedIn => user != null;

  AuthState copyWith({
    EmployeeModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository = ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    Future.microtask(() => checkInitialSession());
    return const AuthState();
  }

  Future<void> checkInitialSession() async {
    state = state.copyWith(isLoading: true);
    final user = await _repository.getCurrentEmployee();
    state = state.copyWith(user: user, isLoading: false, clearUser: user == null);
  }

  Future<bool> signIn(String nik, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithNik(nik, password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = state.copyWith(isLoading: false, clearUser: true);
  }
}
