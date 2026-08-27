// ====================================================================
// GEOSYNC - AUTH REPOSITORY (FIREBASE VERSION)
// ====================================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/employee_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  /// Mendapatkan Unique ID Device (menggunakan device_info_plus)
  Future<String> getDeviceUuid() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; // Unique ID Android
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
    } catch (e) {
      deviceId = 'unknown_device';
    }
    return deviceId;
  }

  /// Login menggunakan NIK dan Password via Firebase Auth
  Future<EmployeeModel> signInWithNik(String nik, String password) async {
    final syntheticEmail = '$nik@geosync.com';

    try {
      // 1. Firebase Auth SignIn
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: syntheticEmail,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('Kredensial tidak valid. Gagal mendapatkan sesi user.');
      }

      // 2. Tarik profil karyawan dari Firestore collection `employees`
      final employeeDoc = await _firestore
          .collection(AppConstants.tableEmployees)
          .doc(user.uid)
          .get();

      if (!employeeDoc.exists) {
        await _auth.signOut();
        throw Exception('Profil karyawan tidak ditemukan di database.');
      }

      final data = employeeDoc.data()!;
      data['id'] = employeeDoc.id; // Inject document ID
      var employee = EmployeeModel.fromJson(data);

      // 3. Verifikasi status Aktif
      if (!employee.isActive) {
        await _auth.signOut();
        throw Exception('Akun Anda telah dinonaktifkan. Silakan hubungi HRD/Admin.');
      }

      // 4. JALANKAN MESIN DEVICE BINDING
      final currentDeviceUuid = await getDeviceUuid();

      if (employee.deviceId == null || employee.deviceId!.isEmpty) {
        // Kasus 1: Login pertama kali → Kunci akun ke perangkat saat ini
        await _firestore
            .collection(AppConstants.tableEmployees)
            .doc(employee.id)
            .update({'device_id': currentDeviceUuid});

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
        // Kasus 2: Device berbeda → Mencegah Buddy Punching
        await _auth.signOut();
        throw Exception(
          'Perangkat tidak dikenali. Akun ini telah terikat (binding) pada perangkat lain.\n\n'
          'Jika Anda berganti HP, silakan hubungi Admin untuk melakukan Reset Device UUID.',
        );
      }

      return employee;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Login Gagal: NIK atau Password salah.');
      }
      throw Exception('Login Gagal: ${e.message}');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Mendapatkan Profil Karyawan saat ini
  Future<EmployeeModel?> getCurrentEmployee() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return null;

    try {
      final employeeDoc = await _firestore
          .collection(AppConstants.tableEmployees)
          .doc(currentUser.uid)
          .get();

      if (!employeeDoc.exists) return null;

      final data = employeeDoc.data()!;
      data['id'] = employeeDoc.id;
      return EmployeeModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Keluar (Sign Out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
