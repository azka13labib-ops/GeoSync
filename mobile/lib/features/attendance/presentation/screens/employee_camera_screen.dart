// ====================================================================
// GEOSYNC - EMPLOYEE CAMERA & CLOCK-IN SCREEN
// Fix #3: Geofencing nyata dengan Geolocator.distanceBetween()
// Fix #4: Deteksi fake/mock GPS
// Fix #5: Timestamp dari server Supabase (tidak dari device)
// ====================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/geofence_util.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../admin/presentation/controllers/employee_attendance_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/attendance_service.dart';

// -----------------------------------------------------------------------
// KONFIGURASI GEOFENCING KANTOR
// Idealnya dibaca dari tabel `office_locations` di Supabase.
// Untuk saat ini dikonfigurasi di sini — ubah sesuai koordinat kantor asli.
// -----------------------------------------------------------------------
class _OfficeConfig {
  // Koordinat Kantor Pusat GeoSync (contoh: Jakarta Selatan)
  static const double latitude = -6.2297862;
  static const double longitude = 106.8259557;
  // Radius maksimum yang diizinkan dalam meter
  static const double allowedRadiusMeters = 100.0;
  static const String officeName = 'Kantor Pusat GeoSync';
}

// Enum status geofencing agar mudah dikelola di UI
enum GeofenceStatus { checking, inRange, outOfRange, gpsDisabled, permissionDenied, error }

class EmployeeCameraScreen extends ConsumerStatefulWidget {
  const EmployeeCameraScreen({super.key});

  @override
  ConsumerState<EmployeeCameraScreen> createState() => _EmployeeCameraScreenState();
}

class _EmployeeCameraScreenState extends ConsumerState<EmployeeCameraScreen> {
  bool _isLoading = false;
  Position? _currentPosition;
  double? _distanceFromOffice; // Jarak aktual user dari kantor (meter)
  bool _isMocked = false;      // Flag untuk fake GPS detection
  GeofenceStatus _geoStatus = GeofenceStatus.checking;
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _startClock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConsentAndDeterminePosition();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
      }
    });
  }

  Future<void> _checkConsentAndDeterminePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsented = prefs.getBool('pdp_consent') ?? false;

    if (!hasConsented) {
      if (mounted) {
        final consentGiven = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Persetujuan Data Pribadi'),
            content: const Text(
              'Sesuai UU Perlindungan Data Pribadi (UU PDP), GeoSync memerlukan akses ke:\n\n'
              '1. Lokasi (GPS) untuk memvalidasi jarak Anda dari kantor.\n'
              '2. Kamera untuk mengambil foto selfie saat absensi.\n\n'
              'Data ini hanya digunakan untuk keperluan absensi perusahaan dan tidak akan dibagikan ke pihak ketiga.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tolak'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Setuju'),
              ),
            ],
          ),
        );

        if (consentGiven == true) {
          await prefs.setBool('pdp_consent', true);
          _determinePosition();
        } else {
          setState(() => _geoStatus = GeofenceStatus.permissionDenied);
        }
      }
    } else {
      _determinePosition();
    }
  }

  /// Mendapatkan posisi GPS dan langsung memvalidasi geofencing.
  Future<void> _determinePosition() async {
    // Pastikan GPS service aktif
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _geoStatus = GeofenceStatus.gpsDisabled);
      return;
    }

    // Cek dan minta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _geoStatus = GeofenceStatus.permissionDenied);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _geoStatus = GeofenceStatus.permissionDenied);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // FIX #4: Cek apakah posisi ini dari mock/fake GPS app
      final isMocked = position.isMocked;

      // FIX #3 & #15: Hitung jarak aktual ke koordinat kantor menggunakan GeofenceUtil
      final distance = GeofenceUtil.calculateDistance(
        position.latitude,
        position.longitude,
        _OfficeConfig.latitude,
        _OfficeConfig.longitude,
      );

      final isInRange = distance <= _OfficeConfig.allowedRadiusMeters;

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _distanceFromOffice = distance;
          _isMocked = isMocked;
          // Jika GPS palsu ATAU di luar radius → blokir
          _geoStatus = (isMocked || !isInRange)
              ? GeofenceStatus.outOfRange
              : GeofenceStatus.inRange;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _geoStatus = GeofenceStatus.error);
    }
  }

  String get _locationStatusText {
    switch (_geoStatus) {
      case GeofenceStatus.checking:
        return 'Mendeteksi lokasi...';
      case GeofenceStatus.inRange:
        final dist = _distanceFromOffice?.toStringAsFixed(0) ?? '?';
        return '${_OfficeConfig.officeName} (~${dist}m dari kantor)';
      case GeofenceStatus.outOfRange:
        if (_isMocked) return '⚠️ Lokasi Palsu Terdeteksi (Fake GPS)';
        final dist = _distanceFromOffice?.toStringAsFixed(0) ?? '?';
        return '📍 Di luar radius • ${dist}m dari kantor (batas: ${_OfficeConfig.allowedRadiusMeters.toStringAsFixed(0)}m)';
      case GeofenceStatus.gpsDisabled:
        return 'GPS tidak aktif — aktifkan di Pengaturan';
      case GeofenceStatus.permissionDenied:
        return 'Izin lokasi ditolak — ubah di Pengaturan';
      case GeofenceStatus.error:
        return 'Gagal mendapatkan lokasi';
    }
  }

  Color get _locationStatusColor {
    switch (_geoStatus) {
      case GeofenceStatus.inRange:
        return AppTheme.secondaryColor;
      case GeofenceStatus.outOfRange:
      case GeofenceStatus.gpsDisabled:
      case GeofenceStatus.permissionDenied:
      case GeofenceStatus.error:
        return AppTheme.errorColor;
      case GeofenceStatus.checking:
        return AppTheme.textSecondary;
    }
  }

  bool get _canClockIn =>
      _geoStatus == GeofenceStatus.inRange && !_isLoading;

  Future<void> _handleClockIn() async {
    // Guard: pastikan sudah in range dan posisi valid
    if (!_canClockIn || _currentPosition == null) return;

    // FIX #4 (double-check): Tolak jika mock GPS
    if (_isMocked) {
      AppToast.show(
        context,
        title: 'Lokasi Palsu Terdeteksi',
        message: 'Absensi tidak dapat diproses karena terdeteksi penggunaan aplikasi fake GPS.',
        type: ToastType.error,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Ambil foto selfie dengan kompresi (Fix #9)
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70,
      );

      if (photo == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Dapatkan data user dari session
      final user = ref.read(authControllerProvider).user;
      if (user == null) throw Exception('Sesi tidak valid. Silakan login ulang.');

      // Hitung keterlambatan (batas masuk jam 08:00)
      int delayMinutes = 0;
      if (_currentTime.hour > 8 || (_currentTime.hour == 8 && _currentTime.minute > 0)) {
        delayMinutes = (_currentTime.hour - 8) * 60 + _currentTime.minute;
      }

      // NOTE (Fix #5): Kita TIDAK mengirim timestamp dari device sebagai
      // sumber kebenaran. Kolom `created_at` di tabel `attendance` memakai
      // DEFAULT now() di level Postgres. Data yang dikirim ke sini hanya
      // untuk keperluan tampilan lokal/cache, bukan untuk disimpan ke DB.
      final timeStr =
          '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')} WIB';
      final locationLabel =
          '${_OfficeConfig.officeName} (${_distanceFromOffice?.toStringAsFixed(0) ?? "?"}m)';

      // Update state lokal (UI langsung responsif untuk admin)
      ref.read(employeeAttendanceControllerProvider.notifier).clockInEmployee(
        employeeNik: user.nik,
        employeeName: user.fullName,
        time: timeStr,
        location: locationLabel,
        delayMinutes: delayMinutes,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        distanceFromOffice: _distanceFromOffice ?? 0,
        isMocked: _isMocked,
        employeeId: user.id,
      );

      // FIX #6: Kirim data absensi ke Supabase (sumber kebenaran)
      // Timestamp diisi oleh server (DEFAULT now() di Postgres), BUKAN dari device.
      await AttendanceService.instance.clockIn(
        AttendancePayload(
          employeeId: user.id,
          employeeNik: user.nik,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          distanceFromOffice: _distanceFromOffice ?? 0,
          isMocked: _isMocked,
          status: delayMinutes > 0 ? 'Terlambat' : 'Hadir',
        ),
      );

      if (mounted) {
        AppToast.show(
          context,
          title: 'Absen Berhasil ✓',
          message: delayMinutes > 0
              ? 'Terlambat $delayMinutes menit. Data absensi tersimpan ke server.'
              : 'Tepat Waktu! Data absensi tersimpan ke server.',
          type: delayMinutes > 0 ? ToastType.info : ToastType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, title: 'Gagal Absen', message: e.toString(), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}:${_currentTime.second.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Live Absensi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Tombol refresh lokasi
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textSecondary),
            tooltip: 'Perbarui Lokasi',
            onPressed: () {
              setState(() => _geoStatus = GeofenceStatus.checking);
              _determinePosition();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Map placeholder
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EEF5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderLight, width: 2),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/map_placeholder.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_geoStatus == GeofenceStatus.checking)
                            const CircularProgressIndicator(color: AppTheme.primaryColor)
                          else
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _locationStatusColor.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Icon(Icons.person_pin_circle_rounded,
                                    color: _locationStatusColor, size: 40),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Geofencing Status Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _locationStatusColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _locationStatusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _locationStatusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _geoStatus == GeofenceStatus.inRange
                                  ? Icons.location_on_rounded
                                  : Icons.location_off_rounded,
                              color: _locationStatusColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _geoStatus == GeofenceStatus.inRange ? 'Dalam Radius Kantor ✓' : 'Status Lokasi',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: _locationStatusColor,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _locationStatusText,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _locationStatusColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Live Clock
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Waktu Indonesia Barat (WIB)',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    // Peringatan timestamp
                    const Text(
                      '* Waktu absen dicatat oleh server, bukan perangkat Anda',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pesan blokir jika di luar radius
                  if (_geoStatus == GeofenceStatus.outOfRange) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.block_rounded, color: AppTheme.errorColor, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _isMocked
                                  ? 'Absensi diblokir: Fake GPS terdeteksi. Nonaktifkan aplikasi lokasi palsu dan coba lagi.'
                                  : 'Absensi diblokir: Anda harus berada dalam radius ${_OfficeConfig.allowedRadiusMeters.toStringAsFixed(0)}m dari kantor.',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _canClockIn ? _handleClockIn : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canClockIn ? AppTheme.primaryColor : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Icon(
                              _canClockIn ? Icons.camera_alt_rounded : Icons.lock_rounded,
                              color: _canClockIn ? Colors.white : Colors.grey.shade500,
                            ),
                      label: Text(
                        _isLoading
                            ? 'Memproses...'
                            : _canClockIn
                                ? 'Absen Masuk (Selfie)'
                                : 'Absen Diblokir',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _canClockIn ? Colors.white : Colors.grey.shade500),
                      ),
                    ),
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
