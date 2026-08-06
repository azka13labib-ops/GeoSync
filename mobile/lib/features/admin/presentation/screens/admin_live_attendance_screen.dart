// ====================================================================
// GEOSYNC - ADMIN LIVE ATTENDANCE MONITORING SCREEN (30 REAL EMPLOYEES)
// Menampilkan real-time absensi 5-6 Agustus 2026 dengan fitur kendali
// mutlak "Apa Kata Saya" (Set Hadir/Terlambat/Cuti) berpersisten lokal.
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/models/employee_real_model.dart';
import '../controllers/employee_attendance_controller.dart';

class AdminLiveAttendanceScreen extends ConsumerStatefulWidget {
  const AdminLiveAttendanceScreen({super.key});

  @override
  ConsumerState<AdminLiveAttendanceScreen> createState() => _AdminLiveAttendanceScreenState();
}

class _AdminLiveAttendanceScreenState extends ConsumerState<AdminLiveAttendanceScreen> {
  String _selectedFilter = 'Semua';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAttendanceControlSheet(RealEmployeeModel emp) {
    final currentDate = ref.read(selectedAttendanceDateProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: emp.avatarColor,
                    child: Text(
                      emp.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          emp.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                        Text(
                          'NIK: ${emp.nik} • $currentDate',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Kendali Mutlak ("Apa Kata Saya"): Anda memiliki otorisasi penuh mengubah absensi secara instan dan permanen.',
                        style: TextStyle(fontSize: 12.5, color: const Color(0xFF15803D).withValues(alpha: 0.9), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Pilih Status Kehadiran:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 12),

              _buildControlOption(
                title: 'Set Hadir Tepat Waktu (07:55 WIB)',
                subtitle: 'Lokasi: Head Office (dalam radius 24m)',
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF10B981),
                onTap: () {
                  ref.read(employeeAttendanceControllerProvider.notifier).setAttendanceStatus(
                    emp.nik,
                    newStatus: 'Hadir',
                    time: '07:55 WIB',
                    location: 'Head Office (dalam radius 24m)',
                    delayMinutes: 0,
                  );
                  Navigator.pop(ctx);
                  _showSuccessToast(emp.name, 'Hadir Tepat Waktu');
                },
              ),
              _buildControlOption(
                title: 'Set Terlambat Ringan 35 Menit (08:35 WIB)',
                subtitle: 'Lokasi: Head Office (dalam radius 30m)',
                icon: Icons.alarm_rounded,
                iconColor: Colors.orange,
                onTap: () {
                  ref.read(employeeAttendanceControllerProvider.notifier).setAttendanceStatus(
                    emp.nik,
                    newStatus: 'Terlambat',
                    time: '08:35 WIB',
                    location: 'Head Office (dalam radius 30m)',
                    delayMinutes: 35,
                  );
                  Navigator.pop(ctx);
                  _showSuccessToast(emp.name, 'Terlambat (35m)');
                },
              ),
              _buildControlOption(
                title: 'Set Terlambat Berat 75 Menit (09:15 WIB)',
                subtitle: 'Lokasi: Head Office (dalam radius 55m)',
                icon: Icons.alarm_off_rounded,
                iconColor: AppTheme.errorColor,
                onTap: () {
                  ref.read(employeeAttendanceControllerProvider.notifier).setAttendanceStatus(
                    emp.nik,
                    newStatus: 'Terlambat',
                    time: '09:15 WIB',
                    location: 'Head Office (dalam radius 55m)',
                    delayMinutes: 75,
                  );
                  Navigator.pop(ctx);
                  _showSuccessToast(emp.name, 'Terlambat Berat (75m)');
                },
              ),
              _buildControlOption(
                title: 'Set Cuti / Izin Resmi',
                subtitle: 'Keterangan: Cuti Disetujui HR Executive',
                icon: Icons.flight_takeoff_rounded,
                iconColor: const Color(0xFF3B82F6),
                onTap: () {
                  ref.read(employeeAttendanceControllerProvider.notifier).setAttendanceStatus(
                    emp.nik,
                    newStatus: 'Cuti',
                    time: '—',
                    location: 'Cuti Disetujui HR Executive',
                    delayMinutes: 0,
                  );
                  Navigator.pop(ctx);
                  _showSuccessToast(emp.name, 'Cuti Resmi');
                },
              ),
              _buildControlOption(
                title: 'Set Belum Hadir / Reset Absen',
                subtitle: 'Status dikosongkan (belum ada rekam jejak)',
                icon: Icons.restore_rounded,
                iconColor: AppTheme.textSecondary,
                onTap: () {
                  ref.read(employeeAttendanceControllerProvider.notifier).setAttendanceStatus(
                    emp.nik,
                    newStatus: 'Belum Hadir',
                    time: '—',
                    location: 'Belum ada rekam jejak',
                    delayMinutes: 0,
                  );
                  Navigator.pop(ctx);
                  _showSuccessToast(emp.name, 'Belum Hadir / Reset');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessToast(String name, String status) {
    AppToast.show(
      context,
      title: 'Status Diperbarui',
      message: 'Kehadiran $name telah diatur ke "$status" dan tersimpan di database lokal.',
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allEmployees = ref.watch(employeeAttendanceControllerProvider);
    final selectedDate = ref.watch(selectedAttendanceDateProvider);

    final totalCount = allEmployees.length;
    final hadirCount = allEmployees.where((e) => e.attendanceStatus == 'Hadir').length;
    final terlambatCount = allEmployees.where((e) => e.attendanceStatus == 'Terlambat').length;
    final belumCount = allEmployees.where((e) => e.attendanceStatus == 'Belum Hadir').length;
    final cutiCount = allEmployees.where((e) => e.attendanceStatus == 'Cuti').length;

    final filteredLogs = allEmployees.where((emp) {
      final matchesQuery = emp.name.toLowerCase().contains(_searchQuery.toLowerCase()) || emp.nik.contains(_searchQuery);
      if (!matchesQuery) return false;
      if (_selectedFilter == 'Hadir') return emp.attendanceStatus == 'Hadir';
      if (_selectedFilter == 'Terlambat') return emp.attendanceStatus == 'Terlambat';
      if (_selectedFilter == 'Belum Hadir') return emp.attendanceStatus == 'Belum Hadir';
      if (_selectedFilter == 'Cuti') return emp.attendanceStatus == 'Cuti';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text(
              'Monitoring Kehadiran',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
            ),
            Text(
              '30 Karyawan Real & Kendali Absensi',
              style: TextStyle(fontSize: 12, color: AppTheme.tealButton, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.tealButton),
            tooltip: 'Reset Absensi Hari Ini',
            onPressed: () {
              ref.read(employeeAttendanceControllerProvider.notifier).resetDataForCurrentDate();
              AppToast.show(
                context,
                title: 'Absensi Direset',
                message: 'Data absensi untuk $selectedDate dikomparasi ulang ke default awal.',
                type: ToastType.info,
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Container(height: 1, color: AppTheme.borderLight),

          // Date Selector Banner (Dinamis: Kemarin & Hari Ini)
          Container(
            color: const Color(0xFFF8FAFD),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Builder(
              builder: (context) {
                final now = DateTime.now();
                final yesterday = now.subtract(const Duration(days: 1));
                final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
                final strToday = '${now.day} ${months[now.month - 1]} ${now.year}';
                final strYesterday = '${yesterday.day} ${months[yesterday.month - 1]} ${yesterday.year}';
                
                return Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 10),
                    const Text('Hari Monitoring:', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)),
                    const Spacer(),
                    _buildDateSelectorButton(strYesterday, selectedDate == strYesterday),
                    const SizedBox(width: 8),
                    _buildDateSelectorButton(strToday, selectedDate == strToday),
                  ],
                );
              },
            ),
          ),
          Container(height: 1, color: AppTheme.borderLight),
          
          // Header Summary Pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSummaryChip('Semua ($totalCount)', 'Semua', Icons.people_outline_rounded, AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Hadir ($hadirCount)', 'Hadir', Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Terlambat ($terlambatCount)', 'Terlambat', Icons.alarm_off_rounded, AppTheme.errorColor),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Cuti ($cutiCount)', 'Cuti', Icons.flight_takeoff_rounded, const Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Belum Hadir ($belumCount)', 'Belum Hadir', Icons.access_time_rounded, Colors.orange),
                ],
              ),
            ),
          ),

          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIK karyawan...',
                hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFD),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderLight, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.secondaryColor, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // List of Attendance Logs
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada data yang cocok dengan kriteria filter',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final emp = filteredLogs[index];
                      return _buildLogCard(emp);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorButton(String dateText, bool isSelected) {
    final shortText = '${dateText.split(' ')[0]} ${dateText.split(' ')[1].substring(0, 3)}';
    return GestureDetector(
      onTap: () {
        ref.read(selectedAttendanceDateProvider.notifier).state = dateText;
        AppToast.show(
          context,
          title: 'Tanggal Dipilih',
          message: 'Menampilkan data absensi persisten untuk $dateText.',
          type: ToastType.info,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.borderLight, width: 1.2),
        ),
        child: Text(
          shortText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String filterKey, IconData icon, Color color) {
    final isSelected = _selectedFilter == filterKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: isSelected ? Colors.white : color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(RealEmployeeModel emp) {
    Color statusBg;
    Color statusText;
    IconData statusIcon;

    if (emp.attendanceStatus == 'Hadir') {
      statusBg = const Color(0xFFD1FAE5); // Mint Green Light
      statusText = const Color(0xFF065F46);
      statusIcon = Icons.check_circle_rounded;
    } else if (emp.attendanceStatus == 'Terlambat') {
      statusBg = const Color(0xFFFEE2E2); // Rose Pink Light
      statusText = const Color(0xFF991B1B);
      statusIcon = Icons.alarm_off_rounded;
    } else if (emp.attendanceStatus == 'Cuti') {
      statusBg = const Color(0xFFDBEAFE); // Blue Light
      statusText = const Color(0xFF1E40AF);
      statusIcon = Icons.flight_takeoff_rounded;
    } else {
      statusBg = const Color(0xFFF3F4F6); // Grey
      statusText = const Color(0xFF4B5563);
      statusIcon = Icons.access_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showAttendanceControlSheet(emp),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: emp.avatarColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: emp.avatarColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          emp.name[0],
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'NIK: ${emp.nik} • ${emp.department}',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppTheme.textSecondary.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusText),
                          const SizedBox(width: 5),
                          Text(
                            emp.delayMinutes > 0 ? '${emp.attendanceStatus} ${emp.delayMinutes}m' : emp.attendanceStatus,
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: statusText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderLight, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_filled_rounded, size: 16, color: AppTheme.textSecondary.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(
                        emp.attendanceTime,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.location_on_rounded, size: 16, color: AppTheme.tealButton.withValues(alpha: 0.9)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          emp.attendanceLocation,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withValues(alpha: 0.9)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_note_rounded, color: AppTheme.secondaryColor, size: 19),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
