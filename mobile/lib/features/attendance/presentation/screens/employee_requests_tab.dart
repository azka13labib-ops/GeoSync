import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EmployeeRequestsTab extends StatelessWidget {
  const EmployeeRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengajuan Cuti & Lembur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Fitur Pengajuan Mandiri akan hadir di pembaruan selanjutnya.', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}
