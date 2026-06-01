import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/config/environment/env_config.dart';

void main() {
  test('realtimeBaseUrl strips /api suffix from apiBaseUrl', () {
    expect(
      EnvConfig.apiBaseUrl.endsWith('/api') ||
          EnvConfig.apiBaseUrl.contains('10.0.2.2'),
      isTrue,
    );

    final realtime = EnvConfig.realtimeBaseUrl;
    expect(realtime.contains('/api'), isFalse);
    expect(realtime.startsWith('http'), isTrue);
  });
}
