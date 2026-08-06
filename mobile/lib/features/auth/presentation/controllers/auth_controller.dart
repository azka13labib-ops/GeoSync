// ====================================================================
// GEOSYNC - AUTH CONTROLLER & RIVERPOD NOTIFIER
// Fix #10: Rate limiting client-side untuk mencegah brute-force login
// ====================================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/employee_model.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthState {
  final EmployeeModel? user;
  final bool isLoading;
  final String? errorMessage;

  // FIX #10: Rate limiting state
  final int failedAttempts;
  final DateTime? lockedUntil;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  bool get isLoggedIn => user != null;

  /// True jika akun sedang dalam masa lockout
  bool get isLockedOut {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// Sisa detik lockout (untuk ditampilkan di UI)
  int get lockoutSecondsRemaining {
    if (!isLockedOut) return 0;
    return lockedUntil!.difference(DateTime.now()).inSeconds;
  }

  AuthState copyWith({
    EmployeeModel? user,
    bool? isLoading,
    String? errorMessage,
    int? failedAttempts,
    DateTime? lockedUntil,
    bool clearUser = false,
    bool clearError = false,
    bool clearLockout = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      failedAttempts: clearLockout ? 0 : (failedAttempts ?? this.failedAttempts),
      lockedUntil: clearLockout ? null : (lockedUntil ?? this.lockedUntil),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository = ref.read(authRepositoryProvider);

  // FIX #10: Konfigurasi lockout
  static const int _maxFailedAttempts = 5;
  // Durasi lockout: 2^(n-5) menit (exponential backoff setelah 5 kali gagal)
  // Percobaan ke-5 = 1 menit, ke-6 = 2 menit, ke-7 = 4 menit, dst.
  static Duration _lockoutDuration(int attempt) {
    final extraAttempts = attempt - _maxFailedAttempts;
    final minutes = extraAttempts <= 0 ? 1 : (1 << (extraAttempts - 1));
    // Maksimum 60 menit
    return Duration(minutes: minutes.clamp(1, 60));
  }

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
    // FIX #10: Tolak jika sedang dalam periode lockout
    if (state.isLockedOut) {
      final remaining = state.lockoutSecondsRemaining;
      state = state.copyWith(
        errorMessage:
            'Terlalu banyak percobaan. Coba lagi dalam $remaining detik.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signInWithNik(nik, password);
      // Reset hitungan gagal setelah berhasil login
      state = state.copyWith(
        user: user,
        isLoading: false,
        clearLockout: true,
      );
      return true;
    } catch (e) {
      // FIX #10: Tambah hitungan gagal dan hitung lockout
      final newFailedAttempts = state.failedAttempts + 1;
      DateTime? newLockedUntil;

      if (newFailedAttempts >= _maxFailedAttempts) {
        final lockDuration = _lockoutDuration(newFailedAttempts);
        newLockedUntil = DateTime.now().add(lockDuration);
        final lockMinutes = lockDuration.inMinutes;
        state = state.copyWith(
          isLoading: false,
          failedAttempts: newFailedAttempts,
          lockedUntil: newLockedUntil,
          errorMessage:
              'Login diblokir sementara selama $lockMinutes menit karena '
              '$newFailedAttempts kali percobaan gagal berturut-turut.',
        );
      } else {
        final remaining = _maxFailedAttempts - newFailedAttempts;
        state = state.copyWith(
          isLoading: false,
          failedAttempts: newFailedAttempts,
          errorMessage:
              '${e.toString().replaceAll('Exception: ', '')} '
              '($remaining percobaan tersisa sebelum diblokir sementara)',
        );
      }
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = state.copyWith(isLoading: false, clearUser: true, clearLockout: true);
  }
}
