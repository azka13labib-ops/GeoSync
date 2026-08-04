// ====================================================================
// GEOSYNC - ADMIN DASHBOARD TAB (PORTAL HRD TAB 1)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';

class AdminDashboardTab extends ConsumerWidget {
  final VoidCallback onNavigateToLeave;

  const AdminDashboardTab({super.key, required this.onNavigateToLeave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              Row(
                children: [
                  // Logo Icon & Brand Text
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderLight, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo_icon.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.language_rounded, color: AppTheme.primaryColor, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'GeoSync',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  // Notification Bell
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 26),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tidak ada pemberitahuan sistem baru.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  // Admin Avatar Circle
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      (user?.fullName ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
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

              // Mint Alert Banner for Pending Leave Requests
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: AppTheme.mintAlertBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.mintAlertText.withValues(alpha: 0.18), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '3 pengajuan cuti menunggu\nreview',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.mintAlertText,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: onNavigateToLeave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.tealButton,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Lihat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Menampilkan seluruh 1,195 catatan kehadiran hari ini.'),
                          behavior: SnackBarBehavior.floating,
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
