// ====================================================================
// GEOSYNC - ADMIN LEAVE CONTROLLER & PERSISTENCE (RIVERPOD)
// Mengelola pengajuan cuti dengan penyimpanan lokal tahan-reset
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/local_storage_service.dart';

class LeaveRequestItem {
  final String id;
  final String employeeName;
  final String department;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;
  final Color avatarBg;
  final String status; // 'Pending', 'Disetujui', 'Ditolak'

  const LeaveRequestItem({
    required this.id,
    required this.employeeName,
    required this.department,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.avatarBg,
    this.status = 'Pending',
  });

  LeaveRequestItem copyWith({
    String? id,
    String? employeeName,
    String? department,
    String? leaveType,
    String? startDate,
    String? endDate,
    String? reason,
    Color? avatarBg,
    String? status,
  }) {
    return LeaveRequestItem(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      avatarBg: avatarBg ?? this.avatarBg,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeName': employeeName,
    'department': department,
    'leaveType': leaveType,
    'startDate': startDate,
    'endDate': endDate,
    'reason': reason,
    'avatarBgHex': avatarBg.toARGB32(),
    'status': status,
  };

  factory LeaveRequestItem.fromJson(Map<String, dynamic> json) {
    return LeaveRequestItem(
      id: json['id'] as String? ?? 'LV-000',
      employeeName: json['employeeName'] as String? ?? 'Karyawan',
      department: json['department'] as String? ?? 'General',
      leaveType: json['leaveType'] as String? ?? 'Cuti Tahunan',
      startDate: json['startDate'] as String? ?? '5 Agt 2026',
      endDate: json['endDate'] as String? ?? '7 Agt 2026',
      reason: json['reason'] as String? ?? 'Keperluan pribadi.',
      avatarBg: Color(json['avatarBgHex'] as int? ?? 0xFF1E3A8A),
      status: json['status'] as String? ?? 'Pending',
    );
  }
}

final adminLeaveControllerProvider = NotifierProvider<AdminLeaveController, List<LeaveRequestItem>>(
  AdminLeaveController.new,
);

class AdminLeaveController extends Notifier<List<LeaveRequestItem>> {
  static const String _storageKey = 'geosync_real_leave_data_v2';

  @override
  List<LeaveRequestItem> build() {
    final savedJson = LocalStorageService.getJson(_storageKey);
    if (savedJson != null && savedJson is List) {
      try {
        return savedJson
            .map((e) => LeaveRequestItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fallback ke default real list
      }
    }

    final initialList = [
      LeaveRequestItem(
        id: 'LV-2026-01',
        employeeName: 'Risti Pramesti',
        department: 'Public Relations',
        leaveType: 'Cuti Tahunan',
        startDate: '5 Agt 2026',
        endDate: '7 Agt 2026',
        reason: 'Acara pernikahan adik kandung di Bandung.',
        avatarBg: const Color(0xFF1E3A8A),
        status: 'Pending',
      ),
      LeaveRequestItem(
        id: 'LV-2026-02',
        employeeName: 'Citra Kirana',
        department: 'HR & GA',
        leaveType: 'Izin Sakit',
        startDate: '5 Agt 2026',
        endDate: '6 Agt 2026',
        reason: 'Demam tinggi dan gejala influenza, surat dokter terlampir.',
        avatarBg: const Color(0xFF0D9488),
        status: 'Pending',
      ),
      LeaveRequestItem(
        id: 'LV-2026-03',
        employeeName: 'Hendra Gunawan',
        department: 'Engineering',
        leaveType: 'Cuti Tahunan',
        startDate: '8 Agt 2026',
        endDate: '10 Agt 2026',
        reason: 'Liburan tahunan bersama keluarga yang telah direncanakan.',
        avatarBg: const Color(0xFF2563EB),
        status: 'Pending',
      ),
      LeaveRequestItem(
        id: 'LV-2026-04',
        employeeName: 'Bella Saphira',
        department: 'Customer Service',
        leaveType: 'Cuti Tahunan',
        startDate: '1 Agt 2026',
        endDate: '3 Agt 2026',
        reason: 'Keperluan keluarga mendesak di luar kota.',
        avatarBg: const Color(0xFF6A7E8B),
        status: 'Disetujui',
      ),
    ];
    _saveToStorage(initialList);
    return initialList;
  }

  Future<void> _saveToStorage(List<LeaveRequestItem> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await LocalStorageService.setJson(_storageKey, jsonList);
  }

  void updateStatus(String id, String newStatus) {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(status: newStatus);
      }
      return item;
    }).toList();
    state = updated;
    _saveToStorage(updated);
  }

  int get pendingCount => state.where((e) => e.status == 'Pending').length;
}
