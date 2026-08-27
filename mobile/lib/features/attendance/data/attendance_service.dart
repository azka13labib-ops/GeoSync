// ====================================================================
// GEOSYNC - ATTENDANCE SERVICE (FIREBASE VERSION)
// Mengirim data absensi ke Firestore.
// Dilengkapi mekanisme antrean (offline queue) otomatis
// jika perangkat sedang tidak memiliki koneksi internet.
// ====================================================================

import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Data payload yang dikirim ke Firestore saat clock-in.
class AttendancePayload {
  final String employeeId;
  final String employeeNik;
  final double latitude;
  final double longitude;
  final double distanceFromOffice;
  final bool isMocked;
  final String status;
  final String? photoUrl;
  final DateTime? deviceTimestamp; // Untuk merekam waktu sebenarnya saat offline

  const AttendancePayload({
    required this.employeeId,
    required this.employeeNik,
    required this.latitude,
    required this.longitude,
    required this.distanceFromOffice,
    required this.isMocked,
    required this.status,
    this.photoUrl,
    this.deviceTimestamp,
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
        if (deviceTimestamp != null) 'device_timestamp': deviceTimestamp!.toIso8601String(),
        // Waktu aktual dokumen diterima server (bisa berbeda jauh dengan device_timestamp jika sempat offline)
        'server_created_at': FieldValue.serverTimestamp(),
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
      deviceTimestamp: json['device_timestamp'] != null ? DateTime.parse(json['device_timestamp']) : null,
    );
  }
}

class AttendanceService {
  static final AttendanceService instance = AttendanceService._();
  AttendanceService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _queueKey = 'offline_attendance_queue';
  bool _isSyncing = false;

  /// Memulai listener koneksi untuk auto-sync ketika internet kembali
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

  /// Insert data absensi ke Firestore atau Queue lokal
  Future<void> clockIn(AttendancePayload payload) async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline = connectivity.contains(ConnectivityResult.none);

    // KARENA Firestore tidak punya trigger otomatis, validasi mock GPS
    // kita enforce secara keras di sisi client sebelum masuk queue/database.
    if (payload.isMocked) {
      throw Exception('Server menolak: Lokasi palsu terdeteksi. Hubungi Admin.');
    }
    
    // Asumsi jarak maksimum adalah 50 meter (bisa diatur)
    if (payload.distanceFromOffice > 50) {
      throw Exception('Server menolak: Anda di luar radius kantor.');
    }

    if (isOffline) {
      await _saveToQueue(payload);
      return; // Berhasil masuk antrean
    }

    try {
      await _firestore.collection('attendance').add(payload.toJson());
    } on FirebaseException catch (e) {
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
    
    // Perlu di-convert ke Map tanpa FieldValue.serverTimestamp 
    // karena FieldValue tidak bisa di JSON encode.
    final jsonMap = {
      'employee_id': payload.employeeId,
      'employee_nik': payload.employeeNik,
      'latitude': payload.latitude,
      'longitude': payload.longitude,
      'distance_from_office': payload.distanceFromOffice,
      'is_mocked': payload.isMocked,
      'status': payload.status,
      if (payload.photoUrl != null) 'photo_url': payload.photoUrl,
      'device_timestamp': payload.deviceTimestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    
    queueStr.add(jsonEncode(jsonMap));
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
        
        await _firestore.collection('attendance').add(payload.toJson());
        debugPrint('[GeoSync-Sync] Berhasil upload absensi tertunda untuk NIK: ${payload.employeeNik}');
      } catch (e) {
        if (e.toString().contains('Failed host lookup') || e.toString().contains('Connection')) {
          failedQueue.add(itemStr);
        }
      }
    }

    await prefs.setStringList(_queueKey, failedQueue);
    _isSyncing = false;
  }
}
