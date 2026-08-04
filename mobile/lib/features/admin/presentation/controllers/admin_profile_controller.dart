// ====================================================================
// GEOSYNC - ADMIN PROFILE CONTROLLER (RIVERPOD)
// Mengelola penyimpanan dan persistensi data profil Admin HRD
// ====================================================================

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  @override
  AdminProfileState build() {
    final user = ref.read(authControllerProvider).user;
    return AdminProfileState(
      fullName: user?.fullName ?? 'Executive HRD',
      roleTitle: 'Chief Human Resources Officer',
      phone: '0812-3456-7890',
      profileImage: null,
    );
  }

  void updateProfile({
    String? fullName,
    String? roleTitle,
    String? phone,
    File? profileImage,
  }) {
    state = state.copyWith(
      fullName: fullName,
      roleTitle: roleTitle,
      phone: phone,
      profileImage: profileImage,
    );
  }
}
