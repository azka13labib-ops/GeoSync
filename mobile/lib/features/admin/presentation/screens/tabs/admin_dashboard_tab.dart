// ====================================================================
// GEOSYNC - ADMIN DASHBOARD TAB (PORTAL HRD TAB 1)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../widgets/admin_app_bar.dart';
import '../admin_live_attendance_screen.dart';

class AdminDashboardTab extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLeave;

  const AdminDashboardTab({super.key, required this.onNavigateToLeave});

  @override
  ConsumerState<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends ConsumerState<AdminDashboardTab> {
  @override
  void initState() {
    super.initState();
    // Kirim notifikasi HP otomatis saat portal HRD pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.instance.showPendingLeaveNotification(count: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;

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

              // Greeting & Subtitle
              Text(
                'Halo, ${user?.fullName.split(' ').first ?? 'Admin'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ringkasan aktivitas hari ini.',
                style: TextStyle(fontSize: 14.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // 2x2 Stat Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.groups_rounded,
                      iconBg: const Color(0xFFE8EEF5),
                      iconColor: AppTheme.primaryColor,
                      title: 'TOTAL KARYAWAN\nAKTIF',
                      value: '1,250',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.verified_user_outlined,
                      iconBg: AppTheme.mintAlertBg,
                      iconColor: AppTheme.secondaryColor,
                      title: 'HADIR HARI INI\n',
                      value: '1,180',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.access_time_filled_rounded,
                      iconBg: AppTheme.badgeRedBg,
                      iconColor: AppTheme.badgeRedText,
                      title: 'TERLAMBAT\n',
                      value: '15',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.event_note_rounded,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: AppTheme.textSecondary,
                      title: 'CUTI PENDING\n',
                      value: '3',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Section Header: Kehadiran Langsung
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kehadiran Langsung',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLiveAttendanceScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.secondaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Attendance Feed Table Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderLight, width: 1.2),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFD),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        border: Border(bottom: BorderSide(color: AppTheme.borderLight, width: 1.2)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Text('KARYAWAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                          Expanded(flex: 2, child: Text('WAKTU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                          Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary, letterSpacing: 0.5))),
                        ],
                      ),
                    ),
                    // Row 1: Ahmad Yani
                    _buildAttendanceRow(
                      name: 'Ahmad\nYani',
                      initial: 'AY',
                      time: '08:00\nWIB',
                      isLate: false,
                      avatarBg: const Color(0xFF3B82F6),
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight, indent: 20, endIndent: 20),
                    // Row 2: Siti Aminah
                    _buildAttendanceRow(
                      name: 'Siti\nAminah',
                      initial: 'SA',
                      time: '08:05\nWIB',
                      isLate: false,
                      avatarBg: const Color(0xFF10B981),
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight, indent: 20, endIndent: 20),
                    // Row 3: Rudi Hartono
                    _buildAttendanceRow(
                      name: 'Rudi\nHartono',
                      initial: 'RH',
                      time: '08:20\nWIB',
                      isLate: true,
                      avatarBg: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow({
    required String name,
    required String initial,
    required String time,
    required bool isLate,
    required Color avatarBg,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Employee Avatar & Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarBg,
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.25),
                  ),
                ),
              ],
            ),
          ),
          // Time
          Expanded(
            flex: 2,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isLate ? FontWeight.w700 : FontWeight.w500,
                color: isLate ? AppTheme.badgeRedText : AppTheme.textPrimary,
                height: 1.3,
              ),
            ),
          ),
          // Status Badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isLate ? AppTheme.badgeRedBg : AppTheme.badgeMintBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLate ? 'Terlambat' : 'Hadir',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isLate ? AppTheme.badgeRedText : AppTheme.badgeMintText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
