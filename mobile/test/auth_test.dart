import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geosync/features/auth/domain/employee_model.dart';
import 'package:geosync/features/auth/presentation/controllers/auth_controller.dart';
import 'package:geosync/features/auth/data/auth_repository.dart';

// Mock sederhana untuk AuthRepository agar bisa diuji tanpa Supabase asli
class MockAuthRepository implements AuthRepository {
  bool shouldSucceed = true;
  String currentDeviceUuid = 'device-123';
  String? registeredDeviceUuid;

  @override
  Future<EmployeeModel?> getCurrentEmployee() async => null;

  @override
  Future<String> getDeviceUuid() async => currentDeviceUuid;

  @override
  Future<void> signOut() async {}

  @override
  Future<EmployeeModel> signInWithNik(String nik, String password) async {
    if (!shouldSucceed) {
      throw Exception('Login Gagal: Kredensial tidak valid');
    }
    
    // Logika simulasi Device Binding
    if (registeredDeviceUuid != null && registeredDeviceUuid != currentDeviceUuid) {
      throw Exception('Perangkat tidak dikenali. Akun ini telah terikat (binding) pada perangkat lain.');
    }
    
    // Jika belum terikat, ikat sekarang
    registeredDeviceUuid ??= currentDeviceUuid;

    return EmployeeModel(
      id: 'mock-1',
      nik: nik,
      fullName: 'Mock User',
      role: UserRole.employee,
      departmentId: 'ops-1',
      officeLocationId: 'hq-1',
      deviceId: registeredDeviceUuid,
      leaveBalance: 12,
      isActive: true,
    );
  }
}

void main() {
  group('AuthController & Device Binding Logic Tests', () {
    late ProviderContainer container;
    late MockAuthRepository mockRepo;

    setUp(() {
      mockRepo = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Login sukses akan mengembalikan status isLoggedIn = true', () async {
      final controller = container.read(authControllerProvider.notifier);
      
      mockRepo.shouldSucceed = true;
      final result = await controller.signIn('2026001', 'password');
      
      expect(result, isTrue);
      expect(container.read(authControllerProvider).isLoggedIn, isTrue);
    });

    test('Device Binding: Login sukses pada device yang sama', () async {
      final controller = container.read(authControllerProvider.notifier);
      
      mockRepo.shouldSucceed = true;
      mockRepo.registeredDeviceUuid = 'device-123';
      mockRepo.currentDeviceUuid = 'device-123';
      
      final result = await controller.signIn('2026001', 'password');
      expect(result, isTrue);
    });

    test('Device Binding: Login ditolak jika device UUID berbeda (Buddy Punching)', () async {
      final controller = container.read(authControllerProvider.notifier);
      
      mockRepo.shouldSucceed = true;
      mockRepo.registeredDeviceUuid = 'device-123';
      mockRepo.currentDeviceUuid = 'device-456'; // Device baru
      
      final result = await controller.signIn('2026001', 'password');
      expect(result, isFalse); // Harus gagal
      
      final state = container.read(authControllerProvider);
      expect(state.errorMessage, contains('Perangkat tidak dikenali'));
    });

    test('Rate Limiting: Gagal 5 kali memicu lockout (Exponential Backoff)', () async {
      final controller = container.read(authControllerProvider.notifier);
      mockRepo.shouldSucceed = false; // Selalu gagal

      // Lakukan 4 kali percobaan gagal
      for (int i = 1; i <= 4; i++) {
        await controller.signIn('2026001', 'wrong');
        final state = container.read(authControllerProvider);
        expect(state.isLockedOut, isFalse);
        expect(state.failedAttempts, i);
      }

      // Percobaan ke-5 -> Memicu lockout 1 menit
      await controller.signIn('2026001', 'wrong');
      var state = container.read(authControllerProvider);
      
      expect(state.isLockedOut, isTrue);
      expect(state.failedAttempts, 5);
      expect(state.errorMessage, contains('Login diblokir sementara selama 1 menit'));
      
      // Percobaan ke-6 -> Ditolak langsung oleh rate limiter, hitungan tidak naik
      await controller.signIn('2026001', 'wrong');
      state = container.read(authControllerProvider);
      
      expect(state.failedAttempts, 5); // Tetap 5, karena diblokir sebelum coba ke server
      expect(state.errorMessage, contains('Terlalu banyak percobaan'));
    });
  });
}
