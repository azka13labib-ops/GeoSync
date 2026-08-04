// ====================================================================
// GEOSYNC - GO ROUTER ROLE-BASED NAVIGATION GUARD
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/admin/presentation/screens/admin_main_screen.dart';
import '../features/attendance/presentation/screens/employee_home_screen.dart';
import '../features/auth/domain/employee_model.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/login_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.uri.toString() == '/login';

      // 1. Jika belum login dan mencoba masuk ke rute lain -> tendang ke /login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // 2. Jika sudah login dan masih di halaman login -> arahkan berdasarkan ROLE!
      if (isLoggedIn && isLoggingIn) {
        final role = authState.user?.role;
        if (role == UserRole.admin) {
          return '/admin/dashboard';
        } else {
          return '/employee/home';
        }
      }

      // 3. Pengecekan perlindungan silang (Karyawan dilarang ke rute /admin)
      if (isLoggedIn && state.uri.toString().startsWith('/admin') && authState.user?.role != UserRole.admin) {
        return '/employee/home';
      }

      return null; // Tetap di rute saat ini
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/employee/home',
        name: 'employee-home',
        builder: (context, state) => const EmployeeHomeScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminMainScreen(),
      ),
    ],
  );
});
