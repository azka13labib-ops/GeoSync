// ====================================================================
// GEOSYNC - OVERTIME STATE MANAGEMENT (RIVERPOD CONTROLLER)
// Controller pusat manajemen pengajuan lembur, approval & analitik payroll
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../overtime/models/overtime_request.dart';
import '../../../../../core/theme/app_theme.dart';

final overtimeControllerProvider = NotifierProvider<OvertimeController, List<OvertimeRequestItem>>(
  OvertimeController.new,
);

class OvertimeController extends Notifier<List<OvertimeRequestItem>> {
  @override
  List<OvertimeRequestItem> build() {
    return [
      OvertimeRequestItem(
        id: 'OV-001',
        employeeName: 'Budi Santoso',
        nik: '2023001',
        department: 'IT Support',
        date: 'Hari Ini, 5 Agt',
        startTime: '17:00',
        endTime: '20:30',
        durationHours: 3.5,
        reason: 'Perbaikan darurat server database production & maintenance rutin malam.',
        hourlyRate: 50000,
        weeklyAccumulatedHours: 8.5, // 8.5 + 3.5 = 12.0 -> mendekati batas
        avatarBg: const Color(0xFF1B4E6B),
        status: 'Pending',
      ),
      OvertimeRequestItem(
        id: 'OV-002',
        employeeName: 'Siti Aminah',
        nik: '2023002',
        department: 'HR Executive',
        date: 'Hari Ini, 5 Agt',
        startTime: '17:00',
        endTime: '19:00',
        durationHours: 2.0,
        reason: 'Rekapitulasi berkas audit karyawan baru dan evaluasi akhir bulan.',
        hourlyRate: 45000,
        weeklyAccumulatedHours: 4.0,
        avatarBg: const Color(0xFF8DA3E8),
        status: 'Pending',
        compensationType: 'Cuti Pengganti (Comp Leave)',
      ),
      OvertimeRequestItem(
        id: 'OV-003',
        employeeName: 'Andi Wijaya',
        nik: '2023004',
        department: 'Operations Lead',
        date: 'Kemarin, 4 Agt',
        startTime: '17:00',
        endTime: '21:30',
        durationHours: 4.5,
        reason: 'Pengawasan proses logistik pengiriman kargo akhir hari kustomer utama.',
        hourlyRate: 55000,
        weeklyAccumulatedHours: 11.5, // 11.5 + 4.5 = 16.0 -> melebihi batas 14 jam UU!
        avatarBg: const Color(0xFF90BBE0),
        status: 'Pending',
      ),
      OvertimeRequestItem(
        id: 'OV-004',
        employeeName: 'Rina Melati',
        nik: '2022045',
        department: 'Finance Officer',
        date: '3 Agustus 2026',
        startTime: '17:00',
        endTime: '20:00',
        durationHours: 3.0,
        reason: 'Penutupan pembukuan finansial (Closing Bulan Juli 2026).',
        hourlyRate: 48000,
        weeklyAccumulatedHours: 6.0,
        avatarBg: const Color(0xFF6A7E8B),
        status: 'Disetujui',
      ),
      OvertimeRequestItem(
        id: 'OV-005',
        employeeName: 'Hendra Saputra',
        nik: '2021102',
        department: 'Field Staff',
        date: '2 Agustus 2026',
        startTime: '17:00',
        endTime: '22:00',
        durationHours: 5.0,
        reason: 'Kunjungan lapangan tambahan di area luar kota.',
        hourlyRate: 40000,
        weeklyAccumulatedHours: 12.0,
        avatarBg: AppTheme.secondaryColor,
        status: 'Disetujui',
      ),
    ];
  }

  void updateStatus(String id, String newStatus, {String? newCompensationType}) {
    state = state.map((item) {
      if (item.id == id) {
        return OvertimeRequestItem(
          id: item.id,
          employeeName: item.employeeName,
          nik: item.nik,
          department: item.department,
          date: item.date,
          startTime: item.startTime,
          endTime: item.endTime,
          durationHours: item.durationHours,
          reason: item.reason,
          hourlyRate: item.hourlyRate,
          weeklyAccumulatedHours: item.weeklyAccumulatedHours,
          avatarBg: item.avatarBg,
          status: newStatus,
          compensationType: newCompensationType ?? item.compensationType,
        );
      }
      return item;
    }).toList();
  }

  void addRequest(OvertimeRequestItem item) {
    state = [item, ...state];
  }

  // Statistik & Analytics untuk Payroll & HR Report
  int get pendingCount => state.where((e) => e.status == 'Pending').length;
  int get approvedCount => state.where((e) => e.status == 'Disetujui').length;
  
  double get totalApprovedHours => state
      .where((e) => e.status == 'Disetujui')
      .fold(0.0, (sum, item) => sum + item.durationHours);

  double get totalPayrollExpense => state
      .where((e) => e.status == 'Disetujui' && e.compensationType == 'Uang Lembur (Rate UU)')
      .fold(0.0, (sum, item) => sum + item.calculatedCompensation);
}
