import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../admin/presentation/controllers/employee_attendance_controller.dart';

class EmployeeHistoryScreen extends ConsumerWidget {
  const EmployeeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    
    // Filter history for current user
    final allAttendanceAsync = ref.watch(employeeAttendanceControllerProvider);
    final allAttendance = allAttendanceAsync.value ?? [];
    final myHistory = allAttendance.where((e) => e.nik == user?.nik).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Riwayat Absensi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
          myHistory.isEmpty
              ? const Center(
                  child: Text('Belum ada riwayat absensi.', style: TextStyle(color: AppTheme.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: myHistory.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = myHistory[index];
                    final isLate = item.attendanceStatus == 'Terlambat';
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.glassDecoration,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLate ? AppTheme.errorColor.withValues(alpha: 0.1) : AppTheme.secondaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLate ? Icons.access_time_filled : Icons.check_circle_rounded,
                              color: isLate ? AppTheme.errorColor : AppTheme.secondaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.attendanceStatus, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isLate ? AppTheme.errorColor : AppTheme.secondaryColor)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(item.attendanceTime, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
