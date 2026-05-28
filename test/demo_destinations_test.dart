import 'package:delivery_app/core/utils/demo_destinations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String labelFor(String key) => switch (key) {
        'place_city_mall' => 'City Mall',
        'place_city_mall_subtitle' => 'Shopping & dining',
        'quick_home' => 'Home',
        'place_home_subtitle' => 'Saved home address',
        'place_nile_city' => 'Nile City Towers',
        'place_nile_city_subtitle' => 'Business district',
        'place_hospital' => 'General Hospital',
        _ => key,
      };

  test('searchPlaces returns popular places when query is empty', () {
    final results = DemoDestinations.searchPlaces('', labelFor: labelFor);

    expect(results, isNotEmpty);
    expect(results.length, lessThanOrEqualTo(DemoDestinations.maxSearchResults));
    expect(results.first.nameKey, 'place_city_mall');
  });

  test('searchPlaces filters by name case-insensitively', () {
    final results = DemoDestinations.searchPlaces('nile', labelFor: labelFor);

    expect(results.length, 1);
    expect(results.first.destinationKey, 'nile_city');
  });

  test('searchPlaces filters by subtitle', () {
    final results =
        DemoDestinations.searchPlaces('business', labelFor: labelFor);

    expect(results.any((p) => p.destinationKey == 'nile_city'), isTrue);
  });

  test('searchPlaces returns empty when nothing matches', () {
    final results =
        DemoDestinations.searchPlaces('zzzzunknown', labelFor: labelFor);

    expect(results, isEmpty);
  });

  test('placeForDestinationKey resolves quick chip keys', () {
    final home = DemoDestinations.placeForDestinationKey('home');
    final airport = DemoDestinations.placeForDestinationKey('airport');

    expect(home?.id, 'home');
    expect(airport?.id, 'airport');
  });

  test('nearPickup returns distinct coords per destination key', () {
    const pickupLat = 30.0;
    const pickupLng = 31.0;

    final mall = DemoDestinations.nearPickup(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      key: 'default',
    );
    final hospital = DemoDestinations.nearPickup(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      key: 'hospital',
    );

    expect(mall.latitude, isNot(equals(hospital.latitude)));
  });
}
