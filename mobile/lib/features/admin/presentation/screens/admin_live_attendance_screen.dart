// ====================================================================
// GEOSYNC - ADMIN LIVE ATTENDANCE MONITORING SCREEN
// Daftar lengkap rekam kehadiran real-time hari ini dari tombol "Lihat Semua"
// ====================================================================

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';

class _AttendanceLogItem {
  final String name;
  final String department;
  final String time;
  final String status; // 'Hadir', 'Terlambat', 'Belum Hadir'
  final String location;
  final int delayMinutes;

  const _AttendanceLogItem({
    required this.name,
    required this.department,
    required this.time,
    required this.status,
    required this.location,
    this.delayMinutes = 0,
  });
}

class AdminLiveAttendanceScreen extends StatefulWidget {
  const AdminLiveAttendanceScreen({super.key});

  @override
  State<AdminLiveAttendanceScreen> createState() => _AdminLiveAttendanceScreenState();
}

class _AdminLiveAttendanceScreenState extends State<AdminLiveAttendanceScreen> {
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<_AttendanceLogItem> _logs = const [
    _AttendanceLogItem(name: 'Andi Saputra', department: 'IT Support • NIK: 2024001', time: '08:02 WIB', status: 'Hadir', location: 'Head Office (dalam radius 42m)'),
    _AttendanceLogItem(name: 'Siti Rahmawati', department: 'Finance & Accounting • NIK: 2024002', time: '08:45 WIB', status: 'Terlambat', location: 'Head Office (dalam radius 35m)', delayMinutes: 15),
    _AttendanceLogItem(name: 'Budi Santoso', department: 'Operations • NIK: 2024003', time: '07:58 WIB', status: 'Hadir', location: 'Branch Bandung (dalam radius 18m)'),
    _AttendanceLogItem(name: 'Dewi Kurnia', department: 'HR & GA • NIK: 2024004', time: '08:52 WIB', status: 'Terlambat', location: 'Head Office (dalam radius 50m)', delayMinutes: 22),
    _AttendanceLogItem(name: 'Rudi Hermawan', department: 'Sales & Marketing • NIK: 2024005', time: '08:15 WIB', status: 'Hadir', location: 'Site Surabaya (dalam radius 25m)'),
    _AttendanceLogItem(name: 'Mega Pratiwi', department: 'Customer Service • NIK: 2024006', time: '—', status: 'Belum Hadir', location: 'Belum ada rekam jejak'),
    _AttendanceLogItem(name: 'Fauzan Hidayat', department: 'Engineering • NIK: 2024007', time: '08:10 WIB', status: 'Hadir', location: 'Head Office (dalam radius 30m)'),
    _AttendanceLogItem(name: 'Nisa Lestari', department: 'Public Relations • NIK: 2024008', time: '09:15 WIB', status: 'Terlambat', location: 'Head Office (dalam radius 62m)', delayMinutes: 45),
    _AttendanceLogItem(name: 'Hendra Gunawan', department: 'Logistics • NIK: 2024009', time: '—', status: 'Belum Hadir', location: 'Belum ada rekam jejak'),
    _AttendanceLogItem(name: 'Laila Anggreahini', department: 'Product Management • NIK: 2024010', time: '08:00 WIB', status: 'Hadir', location: 'Head Office (dalam radius 12m)'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_AttendanceLogItem> get _filteredLogs {
    return _logs.where((log) {
      final matchesSearch = log.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          log.department.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedFilter == 'Hadir') return log.status == 'Hadir';
      if (_selectedFilter == 'Terlambat') return log.status == 'Terlambat';
      if (_selectedFilter == 'Belum Hadir') return log.status == 'Belum Hadir';
      return true; // 'Semua'
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monitoring Kehadiran Langsung',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
            ),
            Text(
              'Hari Ini • 4 Agustus 2026',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary.withValues(alpha: 0.8)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.tealButton, size: 24),
            onPressed: () {
              AppToast.show(
                context,
                title: 'Data Disegarkan',
                message: 'Membaca rekam medis absensi terupdate secara waktu-nyata.',
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
          
          // Header Summary Pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSummaryChip('Semua (10)', 'Semua', Icons.people_outline_rounded, AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Hadir Tepat Waktu (5)', 'Hadir', Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Terlambat (3)', 'Terlambat', Icons.alarm_off_rounded, AppTheme.errorColor),
                  const SizedBox(width: 10),
                  _buildSummaryChip('Belum Absen (2)', 'Belum Hadir', Icons.access_time_rounded, Colors.orange),
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
            child: _filteredLogs.isEmpty
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
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return _buildLogCard(log);
                    },
                  ),
          ),
        ],
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

  Widget _buildLogCard(_AttendanceLogItem log) {
    Color statusBg;
    Color statusText;
    IconData statusIcon;

    if (log.status == 'Hadir') {
      statusBg = const Color(0xFFD1FAE5); // Mint Green Light
      statusText = const Color(0xFF065F46);
      statusIcon = Icons.check_circle_rounded;
    } else if (log.status == 'Terlambat') {
      statusBg = const Color(0xFFFEE2E2); // Rose Pink Light
      statusText = const Color(0xFF991B1B);
      statusIcon = Icons.alarm_off_rounded;
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
          onTap: () {
            AppToast.show(
              context,
              title: '${log.name} • ${log.status}',
              message: 'Check-in: ${log.time}\nLokasi: ${log.location}',
              type: log.status == 'Terlambat' ? ToastType.error : (log.status == 'Hadir' ? ToastType.success : ToastType.info),
            );
          },
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF335C67), Color(0xFF4C8A99)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF335C67).withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          log.name[0],
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
                            log.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            log.department,
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
                            log.delayMinutes > 0 ? '${log.status} ${log.delayMinutes}m' : log.status,
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
                        log.time,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.location_on_rounded, size: 16, color: AppTheme.tealButton.withValues(alpha: 0.9)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          log.location,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withValues(alpha: 0.9)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
