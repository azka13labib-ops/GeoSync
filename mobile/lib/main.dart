// ====================================================================
// GEOSYNC - MAIN ENTRY POINT
// ====================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/constants/app_constants.dart';
import 'core/network/supabase_client.dart';
import 'core/services/notification_service.dart';
import 'core/services/local_storage_service.dart';
import 'features/attendance/data/attendance_service.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // FIX #13: Crash Reporting Initialization
  try {
    await Firebase.initializeApp();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (e) {
    debugPrint('Firebase init failed. Crashlytics will not work. Run "flutterfire configure". Error: $e');
  }

  await AppSupabase.init();
  await LocalStorageService.init(); // Inisialisasi penyimpanan persistem lokal
  AttendanceService.instance.initOfflineQueueListener(); // Fix #14: Offline Queue Sync
  await NotificationService.instance.init(); // Inisialisasi sistem notifikasi HP

  runApp(
    const ProviderScope(
      child: GeoSyncApp(),
    ),
  );
}

class GeoSyncApp extends ConsumerWidget {
  const GeoSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
