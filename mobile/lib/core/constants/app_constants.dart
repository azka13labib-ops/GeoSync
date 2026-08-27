// ====================================================================
// GEOSYNC - APPLICATION CONSTANTS & ENDPOINTS
// ====================================================================

class AppConstants {
  static const String appName = 'GeoSync';
  static const String appTagline = 'Enterprise Attendance & Geofencing System';

  // Firestore Configuration
  // (Menggunakan firebase_options.dart dari flutterfire CLI)

  // Database Tables
  static const String tableEmployees = 'employees';
  static const String tableDepartments = 'departments';
  static const String tableOfficeLocations = 'office_locations';
  static const String tableWorkHours = 'work_hour_settings';
  static const String tableAttendance = 'attendance';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableAuditLogs = 'audit_logs';
}
