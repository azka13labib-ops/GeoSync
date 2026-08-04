// ====================================================================
// GEOSYNC - ADMIN NOTIFICATIONS CENTER SCREEN
// Halaman pusat notifikasi & to-do list HRD
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';
import '../controllers/admin_notification_controller.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Cuti', 'Terlambat', 'Sistem'];

  List<AdminNotificationItem> _getFilteredNotifications(List<AdminNotificationItem> list) {
    if (_selectedFilter == 'Semua') return list;
    final map = {
      'Cuti': NotificationCategory.cuti,
      'Terlambat': NotificationCategory.terlambat,
      'Sistem': NotificationCategory.sistem,
    };
    return list.where((n) => n.category == map[_selectedFilter]).toList();
  }

  Color _categoryColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.cuti:
        return AppTheme.tealButton;
      case NotificationCategory.terlambat:
        return AppTheme.badgeRedText;
      case NotificationCategory.sistem:
        return AppTheme.primaryColor;
    }
  }

  Color _categoryBgColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.cuti:
        return AppTheme.mintAlertBg;
      case NotificationCategory.terlambat:
        return AppTheme.badgeRedBg;
      case NotificationCategory.sistem:
        return const Color(0xFFE8EEF5);
    }
  }

  IconData _categoryIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.cuti:
        return Icons.assignment_turned_in_rounded;
      case NotificationCategory.terlambat:
        return Icons.access_time_filled_rounded;
      case NotificationCategory.sistem:
        return Icons.info_rounded;
    }
  }

  String _categoryLabel(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.cuti:
        return 'Cuti';
      case NotificationCategory.terlambat:
        return 'Terlambat';
      case NotificationCategory.sistem:
        return 'Sistem';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(adminNotificationControllerProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final filteredNotifications = _getFilteredNotifications(notifications);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount belum dibaca',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(adminNotificationControllerProvider.notifier).markAllAsRead();
                AppToast.show(
                  context,
                  title: 'Semua Telah Dibaca',
                  message: 'Seluruh daftar notifikasi berhasil ditandai sebagai selesai.',
                  type: ToastType.success,
                );
              },
              child: const Text('Tandai Semua', style: TextStyle(color: AppTheme.tealButton, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // Divider tipis di bawah AppBar
          Container(height: 1, color: AppTheme.borderLight),

          // Filter Pills
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : const Color(0xFFF0F4F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(height: 1, color: AppTheme.borderLight),

          // Daftar Notifikasi
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_rounded, size: 60, color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('Tidak ada notifikasi', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (_, __) => Container(height: 1, color: AppTheme.borderLight.withValues(alpha: 0.6)),
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      return _buildNotifCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(AdminNotificationItem item) {
    return InkWell(
      onTap: () {
        ref.read(adminNotificationControllerProvider.notifier).markAsRead(item.id);
      },
      child: Container(
        color: item.isRead ? Colors.white : AppTheme.mintAlertBg.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon kategori
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _categoryBgColor(item.category),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_categoryIcon(item.category), color: _categoryColor(item.category), size: 22),
            ),
            const SizedBox(width: 14),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppTheme.tealButton, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _categoryBgColor(item.category),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _categoryLabel(item.category),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _categoryColor(item.category)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.timeAgo, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
