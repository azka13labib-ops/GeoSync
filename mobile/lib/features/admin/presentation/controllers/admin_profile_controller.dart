// ====================================================================
// GEOSYNC - ADMIN PROFILE CONTROLLER (RIVERPOD)
// Mengelola penyimpanan dan persistensi data profil Admin HRD
// ====================================================================

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class AdminProfileState {
  final String fullName;
  final String roleTitle;
  final String phone;
  final File? profileImage;

  const AdminProfileState({
    required this.fullName,
    required this.roleTitle,
    required this.phone,
    this.profileImage,
  });

  AdminProfileState copyWith({
    String? fullName,
    String? roleTitle,
    String? phone,
    File? profileImage,
    bool clearImage = false,
  }) {
    return AdminProfileState(
      fullName: fullName ?? this.fullName,
      roleTitle: roleTitle ?? this.roleTitle,
      phone: phone ?? this.phone,
      profileImage: clearImage ? null : (profileImage ?? this.profileImage),
    );
  }
}

final adminProfileControllerProvider = NotifierProvider<AdminProfileController, AdminProfileState>(
  AdminProfileController.new,
);

class AdminProfileController extends Notifier<AdminProfileState> {
  static const _keyFullName = 'admin_profile_fullname';
  static const _keyRoleTitle = 'admin_profile_roletitle';
  static const _keyPhone = 'admin_profile_phone';
  static const _keyImage = 'admin_profile_imagepath';

  @override
  AdminProfileState build() {
    final user = ref.read(authControllerProvider).user;

    final savedName = LocalStorageService.getString(_keyFullName);
    final savedRole = LocalStorageService.getString(_keyRoleTitle);
    final savedPhone = LocalStorageService.getString(_keyPhone);
    final savedImagePath = LocalStorageService.getString(_keyImage);

    File? imageFile;
    if (savedImagePath != null && File(savedImagePath).existsSync()) {
      imageFile = File(savedImagePath);
    }

    return AdminProfileState(
      fullName: savedName ?? user?.fullName ?? 'Executive HRD',
      roleTitle: savedRole ?? 'Chief Human Resources Officer',
      phone: savedPhone ?? '0812-3456-7890',
      profileImage: imageFile,
    );
  }

  Future<void> updateProfile({
    String? fullName,
    String? roleTitle,
    String? phone,
    File? profileImage,
  }) async {
    File? newImg = profileImage ?? state.profileImage;

    if (profileImage != null) {
      // Simpan gambar secara permanen di local device agar anti-reset saat close app!
      final permPath = await LocalStorageService.savePermanentImage(profileImage, 'hrd_avatar');
      if (permPath != null) {
        await LocalStorageService.setString(_keyImage, permPath);
        newImg = File(permPath);
      }
    }

    if (fullName != null) {
      await LocalStorageService.setString(_keyFullName, fullName);
    }
    if (roleTitle != null) {
      await LocalStorageService.setString(_keyRoleTitle, roleTitle);
    }
    if (phone != null) {
      await LocalStorageService.setString(_keyPhone, phone);
    }

    state = state.copyWith(
      fullName: fullName,
      roleTitle: roleTitle,
      phone: phone,
      profileImage: newImg,
    );
  }
}

