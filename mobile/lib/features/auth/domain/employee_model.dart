// ====================================================================
// GEOSYNC - EMPLOYEE DOMAIN MODEL (2-ROLE ARCHITECTURE)
// ====================================================================

enum UserRole { admin, employee }

class EmployeeModel {
  final String id;
  final String nik;
  final String fullName;
  final UserRole role;
  final String? departmentId;
  final String? officeLocationId;
  final String? deviceId;
  final String? fcmToken;
  final int leaveBalance;
  final bool isActive;

  const EmployeeModel({
    required this.id,
    required this.nik,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.officeLocationId,
    this.deviceId,
    this.fcmToken,
    required this.leaveBalance,
    required this.isActive,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      nik: json['nik'] as String,
      fullName: json['full_name'] as String,
      role: (json['role'] as String?)?.toUpperCase() == 'ADMIN' ? UserRole.admin : UserRole.employee,
      departmentId: json['department_id'] as String?,
      officeLocationId: json['office_location_id'] as String?,
      deviceId: json['device_id'] as String?,
      fcmToken: json['fcm_token'] as String?,
      leaveBalance: (json['leave_balance'] as num?)?.toInt() ?? 12,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'full_name': fullName,
      'role': role == UserRole.admin ? 'ADMIN' : 'EMPLOYEE',
      'department_id': departmentId,
      'office_location_id': officeLocationId,
      'device_id': deviceId,
      'fcm_token': fcmToken,
      'leave_balance': leaveBalance,
      'is_active': isActive,
    };
  }
}
