// ====================================================================
// GEOSYNC - EMPLOYEE & ATTENDANCE CONTROLLER (RIVERPOD 2.X)
// Mengelola 30 Karyawan Real & Kendali Absensi Mutlak 5-6 Agustus 2026
// ====================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/models/employee_real_model.dart';

// Helper untuk membaca tanggal real hari ini
String getTodayIndonesianDate() {
  final now = DateTime.now();
  final months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return '${now.day} ${months[now.month - 1]} ${now.year}';
}

// Provider untuk memilih tanggal monitoring (secara default membaca tanggal HARI INI secara dinamis)
final selectedAttendanceDateProvider = StateProvider<String>((ref) => getTodayIndonesianDate());

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
    // Watch perubahan tanggal monitoring
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
    // Untuk tanggal baru (termasuk 6 Agustus dst, selain 5 Agustus yang ada dummy awal 22 hadir),
    // secara default semua Belum Hadir sampai di-absen oleh Admin atau check-in mandiri.
    if (date != '5 Agustus 2026') {
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
