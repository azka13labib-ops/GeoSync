// ====================================================================
// GEOSYNC - ADMIN SYSTEM SETTINGS TAB (PORTAL HRD TAB 5)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../widgets/admin_app_bar.dart';

class AdminSettingsTab extends ConsumerStatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  ConsumerState<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends ConsumerState<AdminSettingsTab> {
  final TextEditingController _leaveDefaultController = TextEditingController(text: '12');
  final TextEditingController _overtimeRate1Controller = TextEditingController(text: '1.5');
  final TextEditingController _overtimeRate2Controller = TextEditingController(text: '2.0');
  final TextEditingController _maxWeeklyHoursController = TextEditingController(text: '14');
  String _exportMonth = 'Agustus 2026';
  String _exportCategory = 'Laporan Lengkap & Payroll Lembur';
  bool _isExporting = false;

  @override
  void dispose() {
    _leaveDefaultController.dispose();
    _overtimeRate1Controller.dispose();
    _overtimeRate2Controller.dispose();
    _maxWeeklyHoursController.dispose();
    super.dispose();
  }

  void _showAddLocationModal() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final radiusCtrl = TextEditingController(text: '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.add_location_alt_rounded, color: AppTheme.tealButton, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tambah Lokasi Kantor',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Kantor / Branch', hintText: 'Contoh: Branch B - Surabaya')),
            const SizedBox(height: 16),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Alamat Lengkap')),
            const SizedBox(height: 16),
            TextField(
              controller: radiusCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Radius Geofencing (Meter)', suffixText: 'meter'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.tealButton),
                onPressed: () {
                  Navigator.pop(ctx);
                  AppToast.show(
                    context,
                    title: 'Lokasi Ditambahkan',
                    message: 'Titik kantor "${nameCtrl.text}" dengan radius ${radiusCtrl.text}m telah aktif.',
                    type: ToastType.success,
                  );
                },
                child: const Text('Simpan Konfigurasi Lokasi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Sign Out', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
        content: const Text('Apakah Anda yakin ingin mengakhiri sesi administrator dan keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shared Header
              const AdminAppBar(notificationCount: 3),
              const SizedBox(height: 24),

              // CARD 1: Lokasi Kantor & Geofencing
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lokasi Kantor & Geofencing', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                        IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.tealButton, size: 26), onPressed: _showAddLocationModal),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Head Office Subcard
                    _buildOfficeCard(
                      name: 'Head Office',
                      address: 'Jl. Jend. Sudirman\nKav. 52',
                      radius: '100m',
                      mapColor: const Color(0xFFC8E6C9),
                    ),
                    const SizedBox(height: 12),

                    // Branch A Subcard
                    _buildOfficeCard(
                      name: 'Branch A',
                      address: 'Kawasan Industri\nBarat',
                      radius: '50m',
                      mapColor: const Color(0xFFBBDEFB),
                    ),
                    const SizedBox(height: 16),

                    // Dashed Button Add Location
                    _buildDashedButton(
                      label: 'Tambah Lokasi Baru',
                      onTap: _showAddLocationModal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CARD 2: Jam Kerja
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Jam Kerja', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 16),
                    _buildTimeRow('Jam Check-In Dibuka', '07:00'),
                    const SizedBox(height: 20),
                    _buildTimeRow('Jam Masuk Resmi', '08:30'),
                    const SizedBox(height: 20),
                    _buildTimeRow('Toleransi Terlambat', '15 menit'),
                    const SizedBox(height: 20),
                    _buildTimeRow('Jam Check-Out Dibuka', '16:30'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CARD 3: Departemen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Departemen', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 14),

                    // IT Dept Subcard
                    _buildDeptCard(icon: Icons.computer_rounded, name: 'IT', count: '12 karyawan'),
                    const SizedBox(height: 12),

                    // HR Dept Subcard
                    _buildDeptCard(icon: Icons.groups_rounded, name: 'HR', count: '5 karyawan'),
                    const SizedBox(height: 16),

                    // Dashed Button Add Dept
                    _buildDashedButton(
                      label: 'Tambah Departemen',
                      onTap: () {
                        AppToast.show(
                          context,
                          title: 'Master Departemen',
                          message: 'Fitur pengelolaan struktur departemen baru siap digunakan.',
                          type: ToastType.info,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // CARD 4: Kebijakan Lembur & Regulasi Ketenagakerjaan
              _buildOvertimePolicyCard(),
              const SizedBox(height: 20),

              // CARD 5: Ekspor & Unduh Laporan Excel (Dipindah dari Tab lama)
              _buildExportReportsCard(),
              const SizedBox(height: 20),

              // CARD 6: Kebijakan Sistem & Akun
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kebijakan Sistem & Akun', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor)),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 16),

                    // Default Saldo Cuti
                    const Text('Default Saldo Cuti Tahunan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _leaveDefaultController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Device UUID Security Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderLight, width: 1),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.security_rounded, color: AppTheme.tealButton, size: 24),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Device UUID security status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                                SizedBox(height: 4),
                                Text(
                                  'Strict matching is enabled for all employee clock-ins to prevent device spoofing.',
                                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Button Ganti Password
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF3F8),
                          foregroundColor: AppTheme.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          AppToast.show(
                            context,
                            title: 'Email Terkirim',
                            message: 'Tautan pengaturan ulang kata sandi telah dikirim ke email administrator Anda.',
                            type: ToastType.success,
                          );
                        },
                        child: const Text('Ganti Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Button Sign Out (Red Outline)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          side: const BorderSide(color: AppTheme.errorColor, width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _confirmSignOut,
                        child: const Text('Sign Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfficeCard({required String name, required String address, required String radius, required Color mapColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
      ),
      child: Row(
        children: [
          // Map Thumbnail Box
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: mapColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.map_rounded, color: AppTheme.primaryColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(radius, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildDeptCard({required IconData icon, required String name, required String count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFD3E4FD), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(count, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary, size: 20), onPressed: () {}),
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.textSecondary, size: 20), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDashedButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.mintAlertBg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.tealButton, width: 1.5, style: BorderStyle.solid),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppTheme.tealButton, size: 22),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.tealButton)),
          ],
        ),
      ),
    );
  }

  Widget _buildOvertimePolicyCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.work_history_rounded, color: AppTheme.tealButton, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Kebijakan & Kompensasi Lembur', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 16),
          const Text('Standar Jam Kerja Normal (Di luar ini dihitung Lembur)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.borderLight)),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Senin - Jumat (Regular Shift)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                Text('08:00 - 17:00 WIB', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.tealButton)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rate Jam 1 (UU Ciptaker)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _overtimeRate1Controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixText: 'x upah',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rate Jam Ke-2 & dst', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _overtimeRate2Controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        suffixText: 'x upah',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Batas Maksimal Lembur Per Minggu (Compliance)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          TextField(
            controller: _maxWeeklyHoursController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixText: 'Jam / minggu (Maks regulasi: 14 jam)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE6FAF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: AppTheme.secondaryColor, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Rumus kompensasi dan batas mingguan telah disesuaikan dengan UU Ketenagakerjaan RI (PP 36/2021).',
                    style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.w500, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportReportsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_rounded, color: AppTheme.secondaryColor, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Ekspor Laporan & Payroll (Excel)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.borderLight),
          const SizedBox(height: 14),
          const Text('Pilih Periode Laporan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: DropdownButton<String>(
              value: _exportMonth,
              isExpanded: true,
              underline: const SizedBox(),
              items: ['Agustus 2026', 'Juli 2026', 'Juni 2026'].map((m) {
                return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryColor)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _exportMonth = val);
              },
            ),
          ),
          const SizedBox(height: 14),
          const Text('Kategori Dokumen', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: DropdownButton<String>(
              value: _exportCategory,
              isExpanded: true,
              underline: const SizedBox(),
              items: [
                'Laporan Lengkap & Payroll Lembur',
                'Rekapitulasi Kehadiran Harian',
                'Log Pengajuan Cuti Karyawan',
              ].map((c) {
                return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.primaryColor)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _exportCategory = val);
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tealButton,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: _isExporting ? null : _triggerDownload,
              icon: _isExporting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : const Icon(Icons.file_download_outlined, color: Colors.white),
              label: Text(_isExporting ? 'Memproses Excel...' : 'Unduh File Excel', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerDownload() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    final cleanMonth = _exportMonth.replaceAll(' ', '_');
    final cleanCat = _exportCategory.split(' ').first;
    final fileName = 'Export_${cleanCat}_$cleanMonth.xlsx';

    setState(() => _isExporting = false);

    if (mounted) {
      AppToast.show(
        context,
        title: 'Ekspor Excel Selesai',
        message: 'File $fileName berhasil dibuat dan disimpan ke folder Unduhan (Downloads).',
        type: ToastType.success,
      );
    }
  }
}
