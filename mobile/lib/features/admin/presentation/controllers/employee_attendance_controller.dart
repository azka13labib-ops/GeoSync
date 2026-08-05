// ====================================================================
// GEOSYNC - EMPLOYEE & ATTENDANCE CONTROLLER (RIVERPOD 2.X)
// Mengelola 30 Karyawan Real & Kendali Absensi Mutlak 5-6 Agustus 2026
// ====================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/models/employee_real_model.dart';

// Provider untuk memilih tanggal monitoring (5 Agustus 2026 / 6 Agustus 2026)
final selectedAttendanceDateProvider = StateProvider<String>((ref) => '5 Agustus 2026');

final employeeAttendanceControllerProvider = NotifierProvider<EmployeeAttendanceController, List<RealEmployeeModel>>(
  EmployeeAttendanceController.new,
);

class EmployeeAttendanceController extends Notifier<List<RealEmployeeModel>> {
  static const String _baseKey = 'geosync_employees_real_data_v1_';

  String get _currentDateKey {
    final date = ref.watch(selectedAttendanceDateProvider);
    final sanitizedDate = date.replaceAll(' ', '_').toLowerCase();
    return '$_baseKey$sanitizedDate';
  }

  @override
  List<RealEmployeeModel> build() {
    // Watch perubahan tanggal (5 atau 6 Agustus 2026)
    final dateKey = _currentDateKey;
    final savedData = LocalStorageService.getJson(dateKey);

    if (savedData != null && savedData is List) {
      try {
        return savedData
            .map((e) => RealEmployeeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fallback jika formatting error
      }
    }

    // Jika belum ada di local storage untuk tanggal terpilih:
    final initialList = _getInitialListForDate(ref.read(selectedAttendanceDateProvider));
    _saveToStorage(initialList, dateKey);
    return initialList;
  }

  List<RealEmployeeModel> _getInitialListForDate(String date) {
    if (date == '6 Agustus 2026') {
      // Besok: secara awal semua Belum Hadir (siap dikontrol mutlak oleh Admin "Apa Kata Saya")
      return RealEmployeeModel.initial30Employees.map((e) => e.copyWith(
        attendanceStatus: 'Belum Hadir',
        attendanceTime: '—',
        attendanceLocation: 'Belum ada rekam jejak',
        delayMinutes: 0,
      )).toList();
    }
    return RealEmployeeModel.initial30Employees;
  }

  Future<void> _saveToStorage(List<RealEmployeeModel> list, String key) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await LocalStorageService.setJson(key, jsonList);
  }

  // ---- AKSI KENDALI MUTLAK ADMINISTRATOR ("APA KATA SAYA") ----
  void setAttendanceStatus(
    String nik, {
    required String newStatus,
    required String time,
    required String location,
    int delayMinutes = 0,
  }) {
    final updatedList = state.map((emp) {
      if (emp.nik == nik) {
        return emp.copyWith(
          attendanceStatus: newStatus,
          attendanceTime: time,
          attendanceLocation: location,
          delayMinutes: delayMinutes,
        );
      }
      return emp;
    }).toList();

    state = updatedList;
    _saveToStorage(updatedList, _currentDateKey);
  }

  void addEmployee(RealEmployeeModel employee) {
    final updatedList = [employee, ...state];
    state = updatedList;
    _saveToStorage(updatedList, _currentDateKey);
  }

  void updateEmployeeDetails(RealEmployeeModel employee) {
    final updatedList = state.map((e) => e.nik == employee.nik ? employee : e).toList();
    state = updatedList;
    _saveToStorage(updatedList, _currentDateKey);
  }

  void resetDataForCurrentDate() {
    final date = ref.read(selectedAttendanceDateProvider);
    final defaultList = _getInitialListForDate(date);
    state = defaultList;
    _saveToStorage(defaultList, _currentDateKey);
  }
}
