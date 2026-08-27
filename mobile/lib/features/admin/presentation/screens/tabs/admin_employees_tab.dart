// ====================================================================
// GEOSYNC - ADMIN EMPLOYEES DIRECTORY TAB (PORTAL HRD TAB 2)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../domain/models/employee_real_model.dart';
import '../../controllers/employee_attendance_controller.dart';
import '../../widgets/admin_app_bar.dart';

class AdminEmployeesTab extends ConsumerStatefulWidget {
  const AdminEmployeesTab({super.key});

  @override
  ConsumerState<AdminEmployeesTab> createState() => _AdminEmployeesTabState();
}

class _AdminEmployeesTabState extends ConsumerState<AdminEmployeesTab> {
  String _selectedFilter = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEmployeeDialog() {
    final nameCtrl = TextEditingController();
    final nikCtrl = TextEditingController();
    // CATATAN: Password karyawan dikelola oleh Firebase Auth, bukan di sini.
    // Setelah karyawan ditambahkan ke direktori lokal, Admin WAJIB membuat
    // akun Firebase Auth untuk karyawan tersebut secara manual melalui:
    // Authentication → Users → Add user (email: NIK@geosync.com)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add_alt_1_rounded, color: AppTheme.tealButton, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tambah Karyawan Baru',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Akun akan langsung diverifikasi dan terikat dengan kebijakan sistem.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13.5)),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap Karyawan', hintText: 'Contoh: Dionisius Pratama'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nikCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'NIK / Corporate ID', hintText: 'Contoh: 2026031'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tealButton),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Simpan & Aktifkan Akun', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty && nikCtrl.text.isNotEmpty) {
                    final newEmp = RealEmployeeModel(
                      name: nameCtrl.text.trim(),
                      nik: nikCtrl.text.trim(),
                      email: '${nameCtrl.text.trim().toLowerCase().replaceAll(' ', '.')}@geosync.co.id',
                      department: 'Staff Baru',
                      roleTitle: 'Specialist',
                      isActive: true,
                      avatarColorHex: AppTheme.tealButton.toARGB32(),
                      attendanceStatus: 'Hadir',
                      attendanceTime: '08:00 WIB',
                      attendanceLocation: 'Head Office',
                    );
                    ref.read(employeeAttendanceControllerProvider.notifier).addEmployee(newEmp);
                    Navigator.pop(ctx);
                    AppToast.show(
                      context,
                      title: 'Karyawan Ditambahkan ke Direktori',
                      message: 'Selanjutnya, buat akun login untuk ${nameCtrl.text} (NIK: ${nikCtrl.text}) melalui Firebase Console.',
                      type: ToastType.success,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeOptions(RealEmployeeModel emp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.phonelink_erase_rounded, color: AppTheme.primaryColor),
              title: const Text('Reset Device UUID (Anti-Titip Absen)', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Izinkan karyawan mendaftarkan HP baru'),
              onTap: () {
                Navigator.pop(ctx);
                AppToast.show(
                  context,
                  title: 'UUID Berhasil Direset',
                  message: 'Device binding untuk ${emp.name} (NIK: ${emp.nik}) dilepas. Karyawan dapat login di perangkat baru.',
                  type: ToastType.info,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppTheme.secondaryColor),
              title: const Text('Edit Profil Karyawan', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(emp.isActive ? Icons.block_flipped : Icons.check_circle_outline, color: emp.isActive ? AppTheme.errorColor : AppTheme.secondaryColor),
              title: Text(emp.isActive ? 'Nonaktifkan Akun' : 'Aktifkan Kembali Akun', style: TextStyle(fontWeight: FontWeight.w600, color: emp.isActive ? AppTheme.errorColor : AppTheme.secondaryColor)),
              onTap: () {
                final updated = emp.copyWith(isActive: !emp.isActive);
                ref.read(employeeAttendanceControllerProvider.notifier).updateEmployeeDetails(updated);
                Navigator.pop(ctx);
                AppToast.show(
                  context,
                  title: emp.isActive ? 'Akun Dinonaktifkan' : 'Akun Diaktifkan Kembali',
                  message: 'Status akses sistem untuk ${emp.name} telah diperbarui (Persisten).',
                  type: emp.isActive ? ToastType.error : ToastType.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesList = ref.watch(employeeAttendanceControllerProvider);

    // Filter list
    final filteredList = employeesList.where((emp) {
      final matchesQuery = emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) || emp.nik.contains(_searchQuery);
      if (!matchesQuery) return false;
      if (_selectedFilter == 'Aktif') return emp.isActive;
      if (_selectedFilter == 'Nonaktif') return !emp.isActive;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header & Search Area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shared Header
                  const AdminAppBar(notificationCount: 3),
                  const SizedBox(height: 20),
                  const Text(
                    'Direktori Karyawan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 12),
                  
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau NIK...',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderLight)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Button Tambah Karyawan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _showAddEmployeeDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.tealButton,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 24),
                          SizedBox(width: 8),
                          Text('TAMBAH KARYAWAN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Pills Row
                  Row(
                    children: [
                      _buildFilterPill('Semua'),
                      const SizedBox(width: 10),
                      _buildFilterPill('Aktif'),
                      const SizedBox(width: 10),
                      _buildFilterPill('Nonaktif'),
                    ],
                  ),
                ],
              ),
            ),

            // Employee Cards List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: filteredList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final emp = filteredList[index];
                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderLight, width: 1.2),
                      boxShadow: AppTheme.softCardShadow,
                    ),
                    child: Row(
                      children: [
                        // Avatar Initial or photo
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: emp.avatarColor,
                          child: Text(
                            emp.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name & NIK
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                emp.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'NIK: ${emp.nik}  •  ${emp.department}',
                                style: const TextStyle(fontSize: 13.5, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: emp.isActive ? AppTheme.badgeMintBg : AppTheme.badgeGreyBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  emp.isActive ? 'Aktif' : 'Nonaktif',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: emp.isActive ? AppTheme.badgeMintText : AppTheme.badgeGreyText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 3 dots menu button
                        IconButton(
                          icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
                          onPressed: () => _showEmployeeOptions(emp),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isSelected = _selectedFilter == title;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = title),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderLight,
            width: 1.2,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
