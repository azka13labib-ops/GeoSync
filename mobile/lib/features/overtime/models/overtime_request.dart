// ====================================================================
// GEOSYNC - OVERTIME REQUEST MODEL & COMPACT LABOR LAW CALCULATOR
// Data model pengajuan lembur, terintegrasi rumus regulasi Indonesia
// ====================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OvertimeRequestItem {
  final String id;
  final String employeeName;
  final String nik;
  final String department;
  final String date;
  final String startTime;
  final String endTime;
  final double durationHours;
  final String reason;
  final double hourlyRate; // Rate standar per jam, misal Rp 45.000
  final double weeklyAccumulatedHours; // Total jam lembur dalam seminggu ini (untuk cek compliance batas max 14 jam UU Ciptaker)
  final Color avatarBg;
  String status; // 'Pending', 'Disetujui', 'Ditolak'
  String compensationType; // 'Uang Lembur (Rate UU)' atau 'Cuti Pengganti (Comp Leave)'

  OvertimeRequestItem({
    required this.id,
    required this.employeeName,
    required this.nik,
    required this.department,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.reason,
    this.hourlyRate = 45000.0,
    this.weeklyAccumulatedHours = 4.0,
    required this.avatarBg,
    this.status = 'Pending',
    this.compensationType = 'Uang Lembur (Rate UU)',
  });

  // Perhitungan Uang Lembur Berdasarkan Ketentuan UU Ketenagakerjaan (PP 36/2021):
  // Jam pertama bernilai 1.5x upah per jam, jam berikutnya bernilai 2x upah per jam
  double get calculatedCompensation {
    if (compensationType != 'Uang Lembur (Rate UU)') {
      return 0.0; // Jika memilih cuti pengganti, kompensasi finansialnya adalah Rp 0 (masuk ke kuota cuti)
    }
    if (durationHours <= 0) return 0.0;
    if (durationHours <= 1.0) {
      return durationHours * (1.5 * hourlyRate);
    } else {
      final firstHourPay = 1.0 * (1.5 * hourlyRate);
      final remainingHoursPay = (durationHours - 1.0) * (2.0 * hourlyRate);
      return firstHourPay + remainingHoursPay;
    }
  }

  // Format ke mata uang Rupiah
  String get formattedCompensation {
    if (compensationType != 'Uang Lembur (Rate UU)') {
      return '1 Hari Cuti Pengganti';
    }
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(calculatedCompensation);
  }

  // Status compliance terhadap regulasi batas maksimal 14 jam lembur / minggu (UU Ketenagakerjaan RI)
  bool get isNearWeeklyLimit => (weeklyAccumulatedHours + durationHours) >= 12.0 && (weeklyAccumulatedHours + durationHours) < 14.0;
  bool get isExceedingWeeklyLimit => (weeklyAccumulatedHours + durationHours) >= 14.0;
}
