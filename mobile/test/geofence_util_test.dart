import 'package:flutter_test/flutter_test.dart';
import 'package:geosync/core/utils/geofence_util.dart';

void main() {
  group('GeofenceUtil Tests', () {
    test('calculateDistance should return 0 for identical coordinates', () {
      const lat = -6.2297862;
      const lon = 106.8259557;
      
      final distance = GeofenceUtil.calculateDistance(lat, lon, lat, lon);
      
      expect(distance, 0.0);
    });

    test('calculateDistance should return accurate distance for known points', () {
      // Monas (Jakarta)
      const lat1 = -6.1753924;
      const lon1 = 106.8271528;
      
      // Bundaran HI (Jakarta)
      const lat2 = -6.1949826;
      const lon2 = 106.8230588;
      
      final distance = GeofenceUtil.calculateDistance(lat1, lon1, lat2, lon2);
      
      // Jarak aktual sekitar 2.2 kilometer (2200 meter)
      expect(distance, inInclusiveRange(2200.0, 2250.0));
    });

    test('calculateDistance should be symmetric', () {
      const lat1 = -6.229;
      const lon1 = 106.825;
      const lat2 = -6.230;
      const lon2 = 106.826;

      final dist1 = GeofenceUtil.calculateDistance(lat1, lon1, lat2, lon2);
      final dist2 = GeofenceUtil.calculateDistance(lat2, lon2, lat1, lon1);

      expect(dist1, equals(dist2));
    });
  });
}
