import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final riderTrip = TripEntity(
    id: 't1',
    pickupAddress: 'A',
    dropoffAddress: 'B',
    pickupLat: 1,
    pickupLng: 1,
    dropoffLat: 2,
    dropoffLng: 2,
    status: TripStatus.requested,
    riderId: 'user-001',
    fare: 10,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final driverTrip = riderTrip.copyWith(
    id: 't2',
    driverId: 'user-001',
    riderId: 'user-002',
    status: TripStatus.accepted,
  );

  test('TripQuery.forRider filters by riderId', () {
    final result = TripQuery.forRider([riderTrip, driverTrip], 'user-001');
    expect(result.length, 1);
    expect(result.first.id, 't1');
  });

  test('TripQuery.forDriver filters by driverId', () {
    final result = TripQuery.forDriver([riderTrip, driverTrip], 'user-001');
    expect(result.length, 1);
    expect(result.first.id, 't2');
  });

  test('TripQuery.openOffers excludes own trips', () {
    final result = TripQuery.openOffers([riderTrip, driverTrip], 'user-001');
    expect(result, isEmpty);
  });

  group('driver earnings and stats', () {
    TripEntity completed(String id, double fare, DateTime when) =>
        riderTrip.copyWith(
          id: id,
          driverId: 'driver-x',
          riderId: 'rider-$id',
          status: TripStatus.completed,
          fare: fare,
          updatedAt: when,
        );

    final trips = <TripEntity>[
      completed('c1', 20, DateTime(2026, 6, 1)),
      completed('c2', 30, DateTime(2026, 6, 10)),
      riderTrip.copyWith(
        id: 'c3',
        driverId: 'other',
        status: TripStatus.completed,
        fare: 99,
      ),
      riderTrip.copyWith(
        id: 'c4',
        driverId: 'driver-x',
        status: TripStatus.accepted,
        fare: 15,
      ),
    ];

    test('completedDriverEarnings sums only this driver completed fares', () {
      expect(TripQuery.completedDriverEarnings(trips, 'driver-x'), 50);
    });

    test('completedDriverTripCount counts completed trips', () {
      expect(TripQuery.completedDriverTripCount(trips, 'driver-x'), 2);
    });

    test('driverAverageFare averages completed fares', () {
      expect(TripQuery.driverAverageFare(trips, 'driver-x'), 25);
    });

    test('driverAverageFare is 0 with no completed trips', () {
      expect(TripQuery.driverAverageFare(trips, 'nobody'), 0);
    });

    test('driverEarningsSince filters completed trips by updatedAt', () {
      expect(
        TripQuery.driverEarningsSince(trips, 'driver-x', DateTime(2026, 6, 5)),
        30,
      );
    });
  });
}
