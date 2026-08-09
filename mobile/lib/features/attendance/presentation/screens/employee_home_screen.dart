import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../admin/presentation/controllers/employee_attendance_controller.dart';

class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    
    // Cari status absensi hari ini dari list admin (karena pakai memory lokal yg sama)
    final allEmployees = ref.watch(employeeAttendanceControllerProvider);
    final myAttendance = allEmployees.where((e) => e.nik == user?.nik).firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Beranda', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Latar Belakang Dot Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: const DotPatternPainter(
                dotColor: Color(0xFFCBD5E1),
                spacing: 24,
                radius: 1.5,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Card Modern
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF0A1931)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 36, color: AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo,\n${user?.fullName ?? "Karyawan"}!',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'NIK: ${user?.nik ?? "-"}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                const Text('Status Kehadiran Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                const SizedBox(height: 16),
                
                // Attendance Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.glassDecoration,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(myAttendance?.attendanceStatus).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              myAttendance?.attendanceStatus ?? 'Belum Hadir',
                              style: TextStyle(color: _getStatusColor(myAttendance?.attendanceStatus), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: AppTheme.borderLight),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Waktu Masuk', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                          Text(myAttendance?.attendanceTime ?? '—', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('Ringkasan Pribadi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.event_note_rounded,
                        title: 'Sisa Cuti',
                        value: '${user?.leaveBalance ?? 0} Hari',
                        color: AppTheme.secondaryColor,
                        bgColor: AppTheme.mintAlertBg,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.access_time_rounded,
                        title: 'Total Lembur',
                        value: '0 Jam', // Catatan: Kalkulasi dari overtime controller
                        color: AppTheme.badgeRedText,
                        bgColor: AppTheme.badgeRedBg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: AppTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, height: 1.1)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Hadir':
        return AppTheme.secondaryColor;
      case 'Terlambat':
        return AppTheme.errorColor;
      case 'Cuti':
      case 'Izin':
        return Colors.orange;
      default:
        return AppTheme.textSecondary;
    }
  }
}
