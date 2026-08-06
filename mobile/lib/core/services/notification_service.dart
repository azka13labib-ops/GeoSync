// ====================================================================
// GEOSYNC - NOTIFICATION SERVICE
// Mengirim push notification nyata ke HP via flutter_local_notifications
// ====================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(initSettings);

    // Minta izin notifikasi (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showPendingLeaveNotification({required int count}) async {
    const androidDetails = AndroidNotificationDetails(
      'geosync_leave_channel',
      'GeoSync - Persetujuan Cuti',
      channelDescription: 'Notifikasi pengajuan cuti karyawan yang menunggu persetujuan HRD',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableLights: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1001, // ID notifikasi
      '📋 GeoSync — Pengajuan Cuti Menunggu',
      '$count pengajuan cuti karyawan sedang menunggu persetujuan Anda.',
      details,
    );
  }

  Future<void> showAttendanceSummaryNotification({required int hadir, required int terlambat}) async {
    const androidDetails = AndroidNotificationDetails(
      'geosync_attendance_channel',
      'GeoSync - Rekap Absensi',
      channelDescription: 'Notifikasi ringkasan absensi harian dari GeoSync HRD',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      1002, // ID notifikasi
      '📊 Ringkasan Kehadiran GeoSync',
      'Hari ini: $hadir Karyawan Hadir, $terlambat Terlambat.',
      details,
    );
  }

  // --- FITUR REAL-TIME BARU (KARYAWAN <-> ADMIN) ---

  Future<void> showClockInNotification({required String employeeName, required String status, required String time}) async {
    const androidDetails = AndroidNotificationDetails(
      'geosync_live_attendance',
      'GeoSync - Live Absensi',
      channelDescription: 'Notifikasi saat karyawan absen masuk',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _plugin.show(
      1003,
      '📍 Karyawan Absen Masuk',
      '$employeeName baru saja absen ($status) pada $time.',
      details,
    );
  }

  Future<void> showApprovalNotification({required String type, required String status}) async {
    const androidDetails = AndroidNotificationDetails(
      'geosync_approval',
      'GeoSync - Status Persetujuan',
      channelDescription: 'Notifikasi balasan persetujuan HRD',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _plugin.show(
      1004,
      'Pembaruan $type',
      'Pengajuan $type Anda telah $status oleh HRD.',
      details,
    );
  }
}
