// ====================================================================
// GEOSYNC - APPLICATION CONSTANTS & ENDPOINTS
// ====================================================================

import 'supabase_secrets.dart';

class AppConstants {
  static const String appName = 'GeoSync';
  static const String appTagline = 'Enterprise Attendance & Geofencing System';

  // Supabase Configuration (Safeguarded via local gitignored secret module)
  static const String supabaseUrl = SupabaseSecrets.url;
  static const String supabaseAnonKey = SupabaseSecrets.anonKey;

  // Database Tables
  static const String tableEmployees = 'employees';
  static const String tableDepartments = 'departments';
  static const String tableOfficeLocations = 'office_locations';
  static const String tableWorkHours = 'work_hour_settings';
  static const String tableAttendance = 'attendance';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableAuditLogs = 'audit_logs';
}
