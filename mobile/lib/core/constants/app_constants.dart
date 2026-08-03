// ====================================================================
// GEOSYNC - APPLICATION CONSTANTS & ENDPOINTS
// ====================================================================

class AppConstants {
  static const String appName = 'GeoSync';
  static const String appTagline = 'Enterprise Attendance & Geofencing System';

  // Supabase Configuration (Retrieved directly via Supabase MCP)
  static const String supabaseUrl = 'https://xwssuklgdixfbilyluqa.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3c3N1a2xnZGl4ZmJpbHlsdXFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU3MzA2NTUsImV4cCI6MjEwMTMwNjY1NX0.ZNzP-TT_bCrfWjo8QghB8Qkplk_d0pXvhMK0vGPMdC4';

  // Database Tables
  static const String tableEmployees = 'employees';
  static const String tableDepartments = 'departments';
  static const String tableOfficeLocations = 'office_locations';
  static const String tableWorkHours = 'work_hour_settings';
  static const String tableAttendance = 'attendance';
  static const String tableLeaveRequests = 'leave_requests';
  static const String tableAuditLogs = 'audit_logs';
}
