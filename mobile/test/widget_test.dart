import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geosync/main.dart';

void main() {
  testWidgets('GeoSyncApp structural instantiation test', (WidgetTester tester) async {
    expect(const ProviderScope(child: GeoSyncApp()), isA<ProviderScope>());
  });
}
