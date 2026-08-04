// ====================================================================
// GEOSYNC - ADMIN NOTIFICATIONS CONTROLLER (RIVERPOD)
// Mengelola state dan penghitungan notifikasi yang belum dibaca
// ====================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final adminNotificationControllerProvider = NotifierProvider<AdminNotificationController, List<AdminNotificationItem>>(
  AdminNotificationController.new,
);

class AdminNotificationController extends Notifier<List<AdminNotificationItem>> {
  @override
  List<AdminNotificationItem> build() {
    // Data inisial notifikasi
    return [
      const AdminNotificationItem(
        id: '1',
        title: 'Pengajuan Cuti Menunggu Persetujuan',
        subtitle: 'Budi Santoso (IT Support) mengajukan cuti tahunan 15–18 Okt 2023. Segera tinjau dan berikan keputusan.',
        timeAgo: '5 menit lalu',
        category: NotificationCategory.cuti,
        isRead: false,
      ),
      const AdminNotificationItem(
        id: '2',
        title: 'Pengajuan Cuti Menunggu Persetujuan',
        subtitle: 'Siti Aminah (HR Executive) mengajukan izin sakit 12–13 Okt 2023 dengan surat dokter.',
        timeAgo: '23 menit lalu',
        category: NotificationCategory.cuti,
        isRead: false,
      ),
      const AdminNotificationItem(
        id: '3',
        title: 'Pengajuan Cuti Menunggu Persetujuan',
        subtitle: 'Rudi Hartono (Finance) mengajukan cuti tahunan 20–22 Okt 2023.',
        timeAgo: '1 jam lalu',
        category: NotificationCategory.cuti,
        isRead: false,
      ),
      const AdminNotificationItem(
        id: '4',
        title: '15 Karyawan Terlambat Hari Ini',
        subtitle: 'Tercatat 15 karyawan check-in melewati batas toleransi jam 08:45. Lihat detail laporan absensi.',
        timeAgo: '2 jam lalu',
        category: NotificationCategory.terlambat,
        isRead: true,
      ),
      const AdminNotificationItem(
        id: '5',
        title: '3 Karyawan Belum Check-In',
        subtitle: 'Ahmad Yani, Dewi Pratiwi, dan 1 karyawan lainnya belum melakukan absensi hingga pukul 10.00.',
        timeAgo: '3 jam lalu',
        category: NotificationCategory.terlambat,
        isRead: true,
      ),
      const AdminNotificationItem(
        id: '6',
        title: 'Laporan Bulan September Siap Diunduh',
        subtitle: 'Rekap absensi dan cuti untuk bulan September 2023 telah selesai diproses dan siap diekspor ke XLSX.',
        timeAgo: 'Kemarin',
        category: NotificationCategory.sistem,
        isRead: true,
      ),
    ];
  }

  void markAllAsRead() {
    state = state.map((item) => item.copyWith(isRead: true)).toList();
  }

  void markAsRead(String id) {
    state = state.map((item) {
      if (item.id == id && !item.isRead) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList();
  }
}
