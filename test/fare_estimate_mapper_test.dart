import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/trips/shared/data/mappers/fare_estimate_mapper.dart';
import 'package:delivery_app/features/trips/shared/data/mappers/ride_tier_mapper.dart';

void main() {
  group('RideTierMapper', () {
    test('maps premium tier to backend key', () {
      expect(RideTierMapper.toBackendTierKey('ride_premium'), 'premium');
    });

    test('maps economy tier to null default multiplier', () {
      expect(RideTierMapper.toBackendTierKey('ride_economy'), isNull);
    });
  });

  group('FareEstimateMapper', () {
    test('maps backend fare envelope to FareEstimate', () {
      final estimate = FareEstimateMapper.fromBackendResponse('ride_economy', {
        'fare': 42,
        'distanceKm': 3.5,
        'etaMinutes': 12,
        'currency': 'EGP',
      });

      expect(estimate.tierKey, 'ride_economy');
      expect(estimate.fare, 42);
      expect(estimate.distanceKm, 3.5);
      expect(estimate.baseFare, 5);
    });
  });
}
