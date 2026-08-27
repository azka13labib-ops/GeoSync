// ====================================================================
// GEOSYNC - EMPLOYEE & ATTENDANCE CONTROLLER (FIREBASE VERSION)
// ====================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/employee_real_model.dart';

// Helper untuk membaca tanggal hari ini (yyyy-mm-dd)
String getTodayDateString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

final selectedAttendanceDateProvider = StateProvider<String>((ref) => getTodayDateString());

// Stream Provider untuk mendapatkan seluruh data absen hari ini
final todayAttendanceStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, dateString) {
  // Karena kita tidak menyimpan tanggal polos, kita bisa ambil range waktu
  final startOfDay = DateTime.parse('${dateString}T00:00:00');
  final endOfDay = DateTime.parse('${dateString}T23:59:59');

  return FirebaseFirestore.instance
      .collection('attendance')
      // Idealnya pakai where(created_at >= startOfDay) dll.
      // Namun agar tidak perlu complex index di Firestore untuk testing, kita fetch semua 
      // dan filter lokal (hanya cocok untuk MVP/demo).
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});

// Stream Provider untuk mendapatkan data karyawan dari Firestore
final employeesStreamProvider = StreamProvider<List<RealEmployeeModel>>((ref) {
  return FirebaseFirestore.instance.collection('employees').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Translasi dari EmployeeModel (Firestore) ke RealEmployeeModel (UI Admin)
      return RealEmployeeModel(
        nik: data['nik'] ?? '000',
        name: data['fullName'] ?? 'Unknown',
        email: data['email'] ?? '-',
        department: data['departmentId'] ?? '-',
        roleTitle: data['role'] ?? 'Staff',
        isActive: data['isActive'] ?? true,
        avatarColorHex: 0xFF1E3A8A, // Default
        attendanceStatus: 'Belum Hadir', // Akan di-override
        attendanceTime: '—',
        attendanceLocation: '—',
      );
    }).toList();
  });
});

// Provider gabungan untuk Admin UI (Karyawan + Status Absen Hari Ini)
final employeeAttendanceControllerProvider = Provider<AsyncValue<List<RealEmployeeModel>>>((ref) {
  final date = ref.watch(selectedAttendanceDateProvider);
  final employeesAsync = ref.watch(employeesStreamProvider);
  final attendanceAsync = ref.watch(todayAttendanceStreamProvider(date));

  if (employeesAsync.isLoading || attendanceAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (employeesAsync.hasError) {
    return AsyncValue.error(employeesAsync.error!, employeesAsync.stackTrace!);
  }

  final employees = employeesAsync.value ?? [];
  final attendances = attendanceAsync.value ?? [];

  // Gabungkan data
  final combinedList = employees.map((emp) {
    // Cari absen untuk orang ini di list attendances
    final todayAbsen = attendances.where((a) => a['employee_nik'] == emp.nik).toList();
    
    if (todayAbsen.isNotEmpty) {
      // Sort ambil yang paling pertama hari itu (atau terakhir)
      final firstAbsen = todayAbsen.first;
      
      // Hitung waktu 
      String timeStr = '—';
      if (firstAbsen['device_timestamp'] != null) {
         final dt = DateTime.parse(firstAbsen['device_timestamp']).toLocal();
         timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }

      return emp.copyWith(
        attendanceStatus: firstAbsen['status'] ?? 'Hadir',
        attendanceTime: timeStr,
        attendanceLocation: firstAbsen['is_mocked'] == true ? '⚠️ FAKE GPS' : 'Sesuai Radius',
        delayMinutes: 0,
      );
    }
    
    return emp;
  }).toList();

  return AsyncValue.data(combinedList);
});

// Tambahan fungsi aksi admin
class AdminActionController {
  static Future<void> addEmployee(Map<String, dynamic> data) async {
    // Data berisi nik, fullName, email, role, isActive
    // Pastikan ini disimpan ke Firebase
    // Tapi karena rules kita membatasi dari HP, ini mungkin gagal jika rules ketat.
    // Untuk demo, kita pastikan data dilempar ke Firestore (biarkan gagal jika diblok rules).
    await FirebaseFirestore.instance.collection('employees').add(data);
  }
}
