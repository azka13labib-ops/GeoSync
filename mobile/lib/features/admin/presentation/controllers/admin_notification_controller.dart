// ====================================================================
// GEOSYNC - ADMIN NOTIFICATIONS CONTROLLER (RIVERPOD)
// Mengelola state, persentensi, dan penghitungan notifikasi real (Agustus 2026)
// ====================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/services/local_storage_service.dart';

enum NotificationCategory { cuti, terlambat, sistem }

class AdminNotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;
  final NotificationCategory category;
  final bool isRead;

  const AdminNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
  });

  AdminNotificationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? timeAgo,
    NotificationCategory? category,
    bool? isRead,
  }) {
    return AdminNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeAgo: timeAgo ?? this.timeAgo,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'timeAgo': timeAgo,
    'category': category.name,
    'isRead': isRead,
  };

  factory AdminNotificationItem.fromJson(Map<String, dynamic> json) {
    return AdminNotificationItem(
      id: json['id'] as String? ?? '0',
      title: json['title'] as String? ?? 'Notifikasi',
      subtitle: json['subtitle'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? 'Baru saja',
      category: NotificationCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => NotificationCategory.sistem,
      ),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

final adminNotificationControllerProvider = NotifierProvider<AdminNotificationController, List<AdminNotificationItem>>(
  AdminNotificationController.new,
);

class AdminNotificationController extends Notifier<List<AdminNotificationItem>> {
  static const String _storageKey = 'geosync_real_notifications_v2';

  @override
  List<AdminNotificationItem> build() {
    final savedJson = LocalStorageService.getJson(_storageKey);
    if (savedJson != null && savedJson is List) {
      try {
        return savedJson
            .map((e) => AdminNotificationItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Fallback ke data real baru
      }
    }

    final initialList = [
      const AdminNotificationItem(
        id: '1',
        title: 'Pengajuan Cuti Menunggu Persetujuan',
        subtitle: 'Risti Pramesti (Public Relations) mengajukan cuti tahunan 5–7 Agt 2026. Segera tinjau dan berikan keputusan.',
        timeAgo: '5 menit lalu',
        category: NotificationCategory.cuti,
        isRead: false,
      ),
      const AdminNotificationItem(
        id: '2',
        title: 'Pengajuan Izin Menunggu Persetujuan',
        subtitle: 'Citra Kirana (HR & GA) mengajukan izin sakit 5–6 Agt 2026 dengan surat dokter.',
        timeAgo: '23 menit lalu',
        category: NotificationCategory.cuti,
        isRead: false,
      ),
      const AdminNotificationItem(
        id: '3',
        title: 'Pengajuan Cuti Menunggu Persetujuan',
        subtitle: 'Hendra Gunawan (Engineering) mengajukan cuti tahunan 8–10 Agt 2026.',
        timeAgo: '1 jam lalu',
        category: NotificationCategory.cuti,
        isRead: false,
      ),
      const AdminNotificationItem(
        id: '4',
        title: '4 Karyawan Terlambat Hari Ini (5 Agt 2026)',
        subtitle: 'Tercatat Rudi Kurnia, Bella Saphira, dan 2 karyawan lain check-in melewati batas jam 08:00 WIB.',
        timeAgo: '2 jam lalu',
        category: NotificationCategory.terlambat,
        isRead: true,
      ),
      const AdminNotificationItem(
        id: '5',
        title: '2 Karyawan Belum Check-In Hari Ini',
        subtitle: 'Annisa Rahma (Product) dan Rangga Kurniawan (Sales) belum melakukan absensi hingga pukul 10.00 WIB.',
        timeAgo: '3 jam lalu',
        category: NotificationCategory.terlambat,
        isRead: true,
      ),
      const AdminNotificationItem(
        id: '6',
        title: 'Laporan Bulan Juli 2026 Siap Diunduh',
        subtitle: 'Rekap absensi dan payroll untuk bulan Juli 2026 telah selesai diproses dan siap diekspor ke XLSX.',
        timeAgo: 'Kemarin',
        category: NotificationCategory.sistem,
        isRead: true,
      ),
    ];
    _saveToStorage(initialList);
    return initialList;
  }

  Future<void> _saveToStorage(List<AdminNotificationItem> list) async {
    final jsonList = list.map((e) => e.toJson()).toList();
    await LocalStorageService.setJson(_storageKey, jsonList);
  }

  void markAllAsRead() {
    final updated = state.map((item) => item.copyWith(isRead: true)).toList();
    state = updated;
    _saveToStorage(updated);
  }

  void markAsRead(String id) {
    final updated = state.map((item) {
      if (item.id == id && !item.isRead) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
    state = updated;
    _saveToStorage(updated);
  }
}
