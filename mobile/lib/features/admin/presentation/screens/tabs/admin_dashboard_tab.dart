// ====================================================================
// GEOSYNC - ADMIN DASHBOARD TAB (PORTAL HRD TAB 1)
// ====================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/services/notification_service.dart';
import '../../controllers/overtime_controller.dart';
import '../../controllers/employee_attendance_controller.dart';
import '../../controllers/admin_profile_controller.dart';
import '../../controllers/admin_leave_controller.dart';
import '../../widgets/admin_app_bar.dart';
import '../admin_live_attendance_screen.dart';

class AdminDashboardTab extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToLeave;
  final VoidCallback onNavigateToOvertime;

  const AdminDashboardTab({super.key, required this.onNavigateToLeave, required this.onNavigateToOvertime});

  @override
  ConsumerState<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends ConsumerState<AdminDashboardTab> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Kirim notifikasi HP otomatis saat portal HRD pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pendingLeave = ref.read(adminLeaveControllerProvider).where((e) => e.status == 'Pending').length;
      if (pendingLeave > 0) {
        await NotificationService.instance.showPendingLeaveNotification(count: pendingLeave);
      }
    });

    // Mulai Realtime Clock
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getRealtimeClock(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s WIB';
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(adminProfileControllerProvider);
    final overtimeList = ref.watch(overtimeControllerProvider);
    final overtimePendingCount = overtimeList.where((e) => e.status == 'Pending').length;
    final leaveList = ref.watch(adminLeaveControllerProvider);
    final leavePendingCount = leaveList.where((e) => e.status == 'Pending').length;

    final allEmployeesAsync = ref.watch(employeeAttendanceControllerProvider);
    final allEmployees = allEmployeesAsync.value ?? [];
    
    final activeCount = allEmployees.where((e) => e.isActive).length;
    final hadirCount = allEmployees.where((e) => e.attendanceStatus == 'Hadir').length;
    final terlambatCount = allEmployees.where((e) => e.attendanceStatus == 'Terlambat').length;
    final recentCheckedIn = allEmployees
        .where((e) => e.attendanceStatus == 'Hadir' || e.attendanceStatus == 'Terlambat')
        .take(4)
        .toList();

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
                'Halo, ${profile.fullName.isNotEmpty ? profile.fullName : 'Admin'}!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Ringkasan aktivitas hari ini.',
                    style: TextStyle(fontSize: 14.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          _getRealtimeClock(_currentTime),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stat Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.groups_rounded,
                      iconBg: const Color(0xFFE8EEF5),
                      iconColor: AppTheme.primaryColor,
                      title: 'Total Aktif',
                      value: '$activeCount',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLiveAttendanceScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.verified_user_outlined,
                      iconBg: AppTheme.mintAlertBg,
                      iconColor: AppTheme.secondaryColor,
                      title: 'Hadir Hari Ini',
                      value: '$hadirCount',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLiveAttendanceScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.access_time_filled_rounded,
                      iconBg: AppTheme.badgeRedBg,
                      iconColor: AppTheme.badgeRedText,
                      title: 'Terlambat',
                      value: '$terlambatCount',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLiveAttendanceScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.event_note_rounded,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: AppTheme.textSecondary,
                      title: 'Cuti Pending',
                      value: '$leavePendingCount',
                      onTap: widget.onNavigateToLeave,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.timer_outlined,
                      iconBg: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'Lembur Aktif',
                      value: '24',
                      onTap: widget.onNavigateToOvertime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.more_time_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Lembur Pending',
                      value: '$overtimePendingCount',
                      onTap: widget.onNavigateToOvertime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

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
                    if (recentCheckedIn.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Belum ada rekam absensi masuk hari ini.', style: TextStyle(color: AppTheme.textSecondary)),
                      )
                    else
                      ...recentCheckedIn.map((emp) {
                        final initials = emp.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
                        return Column(
                          children: [
                            _buildAttendanceRow(
                              name: emp.name,
                              initial: initials.isEmpty ? 'E' : initials,
                              time: emp.attendanceTime,
                              isLate: emp.attendanceStatus == 'Terlambat',
                              avatarBg: emp.avatarColor,
                            ),
                            if (emp != recentCheckedIn.last)
                              const Divider(height: 1, color: AppTheme.borderLight, indent: 20, endIndent: 20),
                          ],
                        );
                      }),
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
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1.2),
        boxShadow: AppTheme.softCardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primaryColor, height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.tealButton),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }
    return cardContent;
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
