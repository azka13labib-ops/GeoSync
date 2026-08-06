// ====================================================================
// GEOSYNC - AUTH REPOSITORY & DEVICE UUID BINDING ENGINE (S1.3 & S1.4)
// ====================================================================

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/employee_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepository(supabase, const FlutterSecureStorage());
});

class AuthRepository {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;
  static const String _storageKeyDeviceId = 'geosync_cached_device_uuid';

  AuthRepository(this._supabase, this._secureStorage);

  /// Helper untuk mengambil UUID Hardware perangkat secara aman dan stabil
  Future<String> getDeviceUuid() async {
    // 1. Cek apakah UUID perangkat sudah tersimpan di secure storage lokal
    String? cachedUuid = await _secureStorage.read(key: _storageKeyDeviceId);
    if (cachedUuid != null && cachedUuid.isNotEmpty) {
      return cachedUuid;
    }

    // 2. Jika belum ada, ambil dari Device Info hardware native
    final deviceInfo = DeviceInfoPlugin();
    String generatedUuid;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Kombinasikan id build dan board/model sebagai identitas perangkat unik
        generatedUuid = 'AND-${androidInfo.id}-${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        generatedUuid = 'IOS-${iosInfo.identifierForVendor ?? const Uuid().v4()}';
      } else {
        // Fallback untuk desktop/web test lokal
        generatedUuid = 'GEN-${const Uuid().v4()}';
      }
    } catch (e) {
      generatedUuid = 'ERR-${const Uuid().v4()}';
    }

    // 3. Simpan di secure storage agar stabil sepanjang masa instalasi app
    await _secureStorage.write(key: _storageKeyDeviceId, value: generatedUuid);
    return generatedUuid;
  }

  /// Login Universal (Admin & Employee) menggunakan NIK dan Password
  ///
  /// Semua login wajib melalui Supabase Auth (NIK@geosync.com).
  /// Untuk keperluan testing/demo, buat akun nyata melalui Supabase Auth Dashboard:
  ///   1. Buka: https://app.supabase.com → Authentication → Users → Invite User
  ///   2. Email format: `<NIK>@geosync.com`, contoh: 2026001@geosync.com
  ///   3. Set role & profile di tabel `employees` setelah akun dibuat.
  /// JANGAN menaruh kredensial apa pun di kode sumber.
  Future<EmployeeModel> signInWithNik(String nik, String password) async {
    // 1. Format email sintetis: NIK@geosync.com
    final syntheticEmail = '$nik@geosync.com';

    try {
      final AuthResponse authRes = await _supabase.auth.signInWithPassword(
        email: syntheticEmail,
        password: password,
      );

      final user = authRes.user;
      if (user == null) {
        throw const AuthException('Kredensial tidak valid. Gagal mendapatkan sesi user.');
      }

      // 2. Tarik profil karyawan dari tabel public.employees
      final employeeData = await _supabase
          .from(AppConstants.tableEmployees)
          .select()
          .eq('id', user.id)
          .single();

      var employee = EmployeeModel.fromJson(employeeData);

      // 3. Verifikasi apakah akun dalam status Aktif
      if (!employee.isActive) {
        await _supabase.auth.signOut();
        throw Exception('Akun Anda telah dinonaktifkan. Silakan hubungi HRD/Admin.');
      }

      // 4. JALANKAN MESIN DEVICE BINDING (Khusus untuk role EMPLOYEE maupun proteksi Admin)
      final currentDeviceUuid = await getDeviceUuid();

      if (employee.deviceId == null || employee.deviceId!.isEmpty) {
        // Kasus 1: Login pertama kali -> Kunci akun ke perangkat saat ini
        await _supabase
            .from(AppConstants.tableEmployees)
            .update({'device_id': currentDeviceUuid})
            .eq('id', employee.id);

        // Update objek lokal dengan UUID yang dicatatkan
        employee = EmployeeModel(
          id: employee.id,
          nik: employee.nik,
          fullName: employee.fullName,
          role: employee.role,
          departmentId: employee.departmentId,
          officeLocationId: employee.officeLocationId,
          deviceId: currentDeviceUuid,
          fcmToken: employee.fcmToken,
          leaveBalance: employee.leaveBalance,
          isActive: employee.isActive,
        );
      } else if (employee.deviceId != currentDeviceUuid) {
        // Kasus 2: Mencegah Buddy Punching / Titip Absen! Device ID Tidak Cocok!
        await _supabase.auth.signOut();
        throw Exception(
          'Perangkat tidak dikenali. Akun ini telah terikat (binding) pada perangkat lain.\n\n'
          'Jika Anda berganti HP, silakan hubungi Admin untuk melakukan Reset Device UUID.',
        );
      }

      return employee;
    } on AuthException catch (e) {
      throw Exception('Login Gagal: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Mendapatkan Profil Karyawan saat ini (Sesi AKTIF)
  Future<EmployeeModel?> getCurrentEmployee() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return null;

    try {
      final employeeData = await _supabase
          .from(AppConstants.tableEmployees)
          .select()
          .eq('id', currentUser.id)
          .single();

      return EmployeeModel.fromJson(employeeData);
    } catch (e) {
      return null;
    }
  }

  /// Keluar (Sign Out)
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
