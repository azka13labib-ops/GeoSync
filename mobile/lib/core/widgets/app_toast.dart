// ====================================================================
// GEOSYNC - PREMIUM EXECUTIVE TOAST & NOTIFICATIONS
// Menggantikan SnackBar standar dengan tampilan floating dark premium
// ====================================================================

import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    ToastType type = ToastType.success,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    Color accentColor;
    Color iconBgColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        accentColor = const Color(0xFF10B981); // Vibrant Emerald Green
        iconBgColor = const Color(0xFF064E3B);
        iconData = Icons.check_circle_outline_rounded;
        break;
      case ToastType.error:
        accentColor = const Color(0xFFF43F5E); // Premium Rose Pink/Red
        iconBgColor = const Color(0xFF881337);
        iconData = Icons.error_outline_rounded;
        break;
      case ToastType.info:
        accentColor = const Color(0xFF38BDF8); // Electric Sky Blue
        iconBgColor = const Color(0xFF0C4A6E);
        iconData = Icons.info_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.zero,
        duration: const Duration(milliseconds: 3800),
        content: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Deep Slate Navy (Premium Dark)
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 1.5),
                ),
                child: Icon(iconData, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
