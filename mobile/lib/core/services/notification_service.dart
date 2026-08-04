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
      1002,
      '📊 GeoSync — Rekap Absensi Hari Ini',
      'Hadir: $hadir karyawan | Terlambat: $terlambat karyawan.',
      details,
    );
  }
}
