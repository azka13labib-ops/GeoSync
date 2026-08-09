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
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(32),
              decoration: AppTheme.glassDecoration,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_rounded, size: 64, color: AppTheme.textSecondary),
                  SizedBox(height: 24),
                  Text(
                    'Segera Hadir',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Fitur Pengajuan Mandiri (Cuti & Lembur) akan hadir di pembaruan selanjutnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
