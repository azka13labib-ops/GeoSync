// ====================================================================
// GEOSYNC - ADMIN PROFILE EDIT SCREEN
// Halaman edit profil Admin HRD
// ====================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/admin_profile_controller.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;
  File? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(adminProfileControllerProvider);
    _nameController = TextEditingController(text: profile.fullName);
    _roleController = TextEditingController(text: profile.roleTitle);
    _phoneController = TextEditingController(text: profile.phone);
    _selectedImage = profile.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // tutup bottom sheet
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Ubah Foto Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.tealButton, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700)); // simulasi loading
    ref.read(adminProfileControllerProvider.notifier).updateProfile(
          fullName: _nameController.text.trim(),
          roleTitle: _roleController.text.trim(),
          phone: _phoneController.text.trim(),
          profileImage: _selectedImage,
        );
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.pop(context);
      AppToast.show(
        context,
        title: 'Profil Berhasil Diperbarui',
        message: 'Perubahan data profil dan foto Anda telah sukses disimpan pada sistem.',
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final profile = ref.watch(adminProfileControllerProvider);
    final initials = profile.fullName.isNotEmpty
        ? profile.fullName[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 1, color: AppTheme.borderLight),

            // Avatar Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      children: [
                        // Avatar lingkaran
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: AppTheme.softCardShadow,
                          ),
                          child: _selectedImage != null
                              ? ClipOval(child: Image.file(_selectedImage!, fit: BoxFit.cover))
                              : Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                                  ),
                                ),
                        ),
                        // Tombol kamera
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppTheme.tealButton,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName.isNotEmpty ? profile.fullName : 'Admin HRD',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.mintAlertBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Administrator',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tealButton),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Form Fields
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppTheme.borderLight),
                  const SizedBox(height: 20),

                  // Nama Lengkap
                  _buildFormField(
                    label: 'Nama Lengkap',
                    controller: _nameController,
                    icon: Icons.person_rounded,
                    hint: 'Masukkan nama lengkap',
                  ),
                  const SizedBox(height: 20),

                  // Jabatan
                  _buildFormField(
                    label: 'Jabatan',
                    controller: _roleController,
                    icon: Icons.work_rounded,
                    hint: 'Misal: HR Executive, Super Admin',
                  ),
                  const SizedBox(height: 20),

                  // No. Telepon
                  _buildFormField(
                    label: 'No. Telepon',
                    controller: _phoneController,
                    icon: Icons.phone_rounded,
                    hint: 'Misal: 0812-xxxx-xxxx',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),

                  // Akun — Read Only (gunakan NIK sebagai identifier)
                  _buildReadOnlyField(
                    label: 'Akun Login',
                    value: 'NIK: ${user?.nik ?? '-'}',
                    icon: Icons.email_rounded,
                    note: 'Login menggunakan NIK, tidak dapat diubah',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // NIK Info — Read Only
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppTheme.borderLight),
                  const SizedBox(height: 20),
                  _buildReadOnlyField(
                    label: 'NIK Karyawan',
                    value: user?.nik ?? '-',
                    icon: Icons.badge_rounded,
                    note: 'NIK tidak dapat diubah',
                  ),
                  const SizedBox(height: 20),
                  _buildReadOnlyField(
                    label: 'Role Sistem',
                    value: 'Administrator',
                    icon: Icons.admin_panel_settings_rounded,
                    note: 'Hubungi Super Admin untuk perubahan role',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Simpan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.tealButton,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.tealButton, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFD),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.tealButton, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required String note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 12),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppTheme.textSecondary, size: 12),
            const SizedBox(width: 4),
            Text(note, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }
}
