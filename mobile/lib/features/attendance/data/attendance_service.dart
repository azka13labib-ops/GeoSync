// ====================================================================
// GEOSYNC - ATTENDANCE SERVICE (FIX #6 & FIX #14)
// Mengirim data absensi ke Supabase.
// Fix #14: Dilengkapi mekanisme antrean (offline queue) otomatis
// jika perangkat sedang tidak memiliki koneksi internet.
// ====================================================================

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';

/// Data payload yang dikirim ke Supabase saat clock-in.
class AttendancePayload {
  final String employeeId;
  final String employeeNik;
  final double latitude;
  final double longitude;
  final double distanceFromOffice;
  final bool isMocked;
  final String status;
  final String? photoUrl;

  const AttendancePayload({
    required this.employeeId,
    required this.employeeNik,
    required this.latitude,
    required this.longitude,
    required this.distanceFromOffice,
    required this.isMocked,
    required this.status,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
        'employee_id': employeeId,
        'employee_nik': employeeNik,
        'latitude': latitude,
        'longitude': longitude,
        'distance_from_office': distanceFromOffice,
        'is_mocked': isMocked,
        'status': status,
        if (photoUrl != null) 'photo_url': photoUrl,
      };

  factory AttendancePayload.fromJson(Map<String, dynamic> json) {
    return AttendancePayload(
      employeeId: json['employee_id'],
      employeeNik: json['employee_nik'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      distanceFromOffice: json['distance_from_office'],
      isMocked: json['is_mocked'],
      status: json['status'],
      photoUrl: json['photo_url'],
    );
  }
}

class AttendanceService {
  static final AttendanceService instance = AttendanceService._();
  AttendanceService._();

  final SupabaseClient _supabase = AppSupabase.client;
  static const String _queueKey = 'offline_attendance_queue';
  bool _isSyncing = false;

  /// Memulai listener koneksi untuk auto-sync ketika internet kembali (Fix #14)
  void initOfflineQueueListener() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        syncOfflineQueue();
      }
    });
    // Coba sync saat pertama kali init
    syncOfflineQueue();
  }

  /// Insert data absensi ke Supabase atau Queue lokal (Fix #14)
  Future<void> clockIn(AttendancePayload payload) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);

    if (isOffline) {
      await _saveToQueue(payload);
      return; // Berhasil masuk antrean
    }

    try {
      await _supabase.from('attendance').insert(payload.toJson());
    } on PostgrestException catch (e) {
      if (e.message.contains('GEOFENCE_MOCKED')) {
        throw Exception('Server menolak: Lokasi palsu terdeteksi. Hubungi Admin.');
      } else if (e.message.contains('GEOFENCE_OUT_OF_RANGE')) {
        throw Exception('Server menolak: Anda di luar radius kantor.');
      }
      throw Exception('Gagal menyimpan absensi: ${e.message}');
    } catch (e) {
      // Jika error network/unknown lain, anggap offline dan antre
      await _saveToQueue(payload);
    }
  }

  /// Menyimpan payload ke SharedPreferences saat offline
  Future<void> _saveToQueue(AttendancePayload payload) async {
    final prefs = await SharedPreferences.getInstance();
    final queueStr = prefs.getStringList(_queueKey) ?? [];
    queueStr.add(jsonEncode(payload.toJson()));
    await prefs.setStringList(_queueKey, queueStr);
    debugPrint('[GeoSync-Offline] Absensi disimpan di antrean offline. Total antrean: ${queueStr.length}');
  }

  /// Memproses ulang antrean absensi offline saat koneksi pulih
  Future<void> syncOfflineQueue() async {
    if (_isSyncing) return;
    
    final prefs = await SharedPreferences.getInstance();
    final queueStr = prefs.getStringList(_queueKey) ?? [];
    
    if (queueStr.isEmpty) return;
    
    _isSyncing = true;
    debugPrint('[GeoSync-Sync] Mencoba upload ${queueStr.length} absensi tertunda...');
    
    List<String> failedQueue = [];

    for (final itemStr in queueStr) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(itemStr);
        final payload = AttendancePayload.fromJson(jsonMap);
        
        await _supabase.from('attendance').insert(payload.toJson());
        debugPrint('[GeoSync-Sync] Berhasil upload absensi tertunda untuk NIK: ${payload.employeeNik}');
      } catch (e) {
        // Jika gagal karena ditolak trigger (misal mock GPS), data akan hilang/dibuang (wajar)
        // Jika gagal karena network, simpan kembali
        if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection')) {
          failedQueue.add(itemStr);
        }
      }
    }

    await prefs.setStringList(_queueKey, failedQueue);
    _isSyncing = false;
  }
}
