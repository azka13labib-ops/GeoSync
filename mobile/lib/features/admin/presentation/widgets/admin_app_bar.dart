// ====================================================================
// GEOSYNC - SHARED ADMIN APP BAR WIDGET
// Dipakai konsisten di semua 5 tab Portal HRD
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';
import '../controllers/admin_notification_controller.dart';
import '../controllers/admin_profile_controller.dart';
import '../screens/admin_notifications_screen.dart';
import '../screens/admin_profile_screen.dart';

class AdminAppBar extends ConsumerWidget {
  final int? notificationCount;

  const AdminAppBar({
    super.key,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(adminNotificationControllerProvider);
    final count = notifications.where((n) => !n.isRead).length;
    final profile = ref.watch(adminProfileControllerProvider);
    final initial = profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'A';

    return Row(
      children: [
        // Logo Icon
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderLight, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo_icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.language_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'GeoSync',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryColor,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),

        // Notification Bell dengan Badge
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminNotificationsScreen(),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderLight),
                  boxShadow: AppTheme.softCardShadow,
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: AppTheme.textPrimary,
                  size: 22,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Admin Avatar → Edit Profil
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminProfileScreen(),
            ),
          ),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.borderLight, width: 2),
              boxShadow: AppTheme.softCardShadow,
            ),
            child: profile.profileImage != null
                ? ClipOval(
                    child: Image.file(
                      profile.profileImage!,
                      fit: BoxFit.cover,
                      width: 42,
                      height: 42,
                    ),
                  )
                : Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
