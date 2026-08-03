// ====================================================================
// GEOSYNC - EMPLOYEE HOME SCREEN (PORTAL ABSENSI)
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class EmployeeHomeScreen extends ConsumerWidget {
  const EmployeeHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal Karyawan - GeoSync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
            tooltip: 'Keluar Akun',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_pin_circle_rounded, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 24),
              Text(
                'Halo, ${user?.fullName ?? "Karyawan"}!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'NIK: ${user?.nik ?? "-"} | Sisa Cuti: ${user?.leaveBalance ?? 0} Hari',
                style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassDecoration,
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.secondaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Modul Absensi Geofencing & Selfie akan dimuat di sini pada tahap Karyawan-001.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
