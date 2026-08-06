import 'dart:math' as math;

class GeofenceUtil {
  /// Radius bumi dalam meter (standar WGS84)
  static const double earthRadius = 6371000.0;

  /// Menghitung jarak antara dua koordinat latitude dan longitude
  /// Mengembalikan jarak dalam satuan meter.
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var dLat = _degreesToRadians(lat2 - lat1);
    var dLon = _degreesToRadians(lon2 - lon1);

    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    var c = 2 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
