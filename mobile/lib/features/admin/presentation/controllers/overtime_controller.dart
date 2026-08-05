// ====================================================================
// GEOSYNC - OVERTIME STATE MANAGEMENT (RIVERPOD CONTROLLER)
// Controller pusat manajemen pengajuan lembur, approval & analitik payroll
// Terhubung dengan data real 30 Karyawan dan berpersistensi lokal
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../overtime/models/overtime_request.dart';
import '../../../../../core/services/local_storage_service.dart';

final overtimeControllerProvider = NotifierProvider<OvertimeController, List<OvertimeRequestItem>>(
  OvertimeController.new,
);

class OvertimeController extends Notifier<List<OvertimeRequestItem>> {
  static const String _storageKey = 'geosync_real_overtime_data_v2';

  @override
  List<OvertimeRequestItem> build() {
    final savedJson = LocalStorageService.getJson(_storageKey);
    if (savedJson != null && savedJson is List) {
      try {
        return savedJson
            .map((e) => OvertimeRequestItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fallback jika formatting lama error
      }
    }

    final defaultList = [
      OvertimeRequestItem(
        id: 'OV-2026-001',
        employeeName: 'Dionisius Pratama',
        nik: '2026001',
        department: 'IT Support',
        date: 'Hari Ini, 5 Agt 2026',
        startTime: '17:00',
        endTime: '20:30',
        durationHours: 3.5,
        reason: 'Perbaikan darurat server database production & maintenance rutin malam.',
        hourlyRate: 65000,
        weeklyAccumulatedHours: 8.5, // 8.5 + 3.5 = 12.0 -> mendekati batas
        avatarBg: const Color(0xFF1B4E6B),
        status: 'Pending',
      ),
      OvertimeRequestItem(
        id: 'OV-2026-002',
        employeeName: 'Nadia Maharani',
        nik: '2026002',
        department: 'Finance & Accounting',
        date: 'Hari Ini, 5 Agt 2026',
        startTime: '17:00',
        endTime: '19:00',
        durationHours: 2.0,
        reason: 'Rekapitulasi berkas audit pajak bulanan dan persiapan laporan eksekutif.',
        hourlyRate: 55000,
        weeklyAccumulatedHours: 4.0,
        avatarBg: const Color(0xFF8DA3E8),
        status: 'Pending',
        compensationType: 'Cuti Pengganti (Comp Leave)',
      ),
      OvertimeRequestItem(
        id: 'OV-2026-003',
        employeeName: 'Reza Anugrah',
        nik: '2026003',
        department: 'Operations',
        date: 'Kemarin, 4 Agt 2026',
        startTime: '17:00',
        endTime: '21:30',
        durationHours: 4.5,
        reason: 'Pengawasan proses logistik pengiriman kargo dan pengawasan armada cabang.',
        hourlyRate: 60000,
        weeklyAccumulatedHours: 11.5, // 11.5 + 4.5 = 16.0 -> melebihi batas 14 jam UU!
        avatarBg: const Color(0xFF009688),
        status: 'Pending',
      ),
      OvertimeRequestItem(
        id: 'OV-2026-004',
        employeeName: 'Karina Wulandari',
        nik: '2026012',
        department: 'Finance & Accounting',
        date: '3 Agustus 2026',
        startTime: '17:00',
        endTime: '20:00',
        durationHours: 3.0,
        reason: 'Penutupan pembukuan finansial dan rekonsiliasi perbankan akhir bulan.',
        hourlyRate: 52000,
        weeklyAccumulatedHours: 6.0,
        avatarBg: const Color(0xFFE91E63),
        status: 'Disetujui',
      ),
      OvertimeRequestItem(
        id: 'OV-2026-005',
        employeeName: 'Dimas Anggoro',
        nik: '2026013',
        department: 'Operations',
        date: '2 Agustus 2026',
        startTime: '17:00',
        endTime: '22:00',
        durationHours: 5.0,
        reason: 'Inspeksi mendadak fasilitas regional dan perawatan generator cadangan.',
        hourlyRate: 48000,
        weeklyAccumulatedHours: 12.0,
        avatarBg: const Color(0xFF3F51B5),
        status: 'Disetujui',
      ),
    ];
    _saveToStorage(defaultList);
    return defaultList;
  }

  Future<void> _saveToStorage(List<OvertimeRequestItem> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await LocalStorageService.setJson(_storageKey, jsonList);
  }

  void updateStatus(String id, String newStatus, {String? newCompensationType}) {
    final updated = state.map((item) {
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
    state = updated;
    _saveToStorage(updated);
  }

  void addRequest(OvertimeRequestItem item) {
    final updated = [item, ...state];
    state = updated;
    _saveToStorage(updated);
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
