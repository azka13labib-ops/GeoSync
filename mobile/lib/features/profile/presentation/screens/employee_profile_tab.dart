import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class EmployeeProfileTab extends ConsumerWidget {
  const EmployeeProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  user?.fullName ?? 'Karyawan',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NIK: ${user?.nik ?? "-"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                  ),
                ),
                const SizedBox(height: 40),
                
                Container(
                  decoration: AppTheme.glassDecoration,
                  child: Column(
                    children: [
                      _buildProfileItem(Icons.email_rounded, 'Email', '${user?.nik ?? "-"}@geosync.com'),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      _buildProfileItem(Icons.business_center_rounded, 'Departemen', 'Umum'),
                      const Divider(height: 1, color: AppTheme.borderLight),
                      _buildProfileItem(Icons.phone_rounded, 'Nomor Telepon', '+62 812-3456-7890'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar Akun'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
