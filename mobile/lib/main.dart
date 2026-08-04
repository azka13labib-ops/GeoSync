// ====================================================================
// GEOSYNC - MAIN ENTRY POINT
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/network/supabase_client.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSupabase.init();

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
