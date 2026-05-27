import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/architecture/repositories/trip_repository.dart';
import 'package:delivery_app/core/network/fcm_service.dart';
import 'package:delivery_app/features/home/presentation/bloc/map_bloc.dart';
import 'package:delivery_app/features/trips/presentation/bloc/trip_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}

class MockConnectivity extends Mock implements Connectivity {}

class MockFcmService extends Mock implements FcmService {}

void main() {
  late MockTripRepository tripRepository;
  late MockConnectivity connectivity;

  setUp(() {
    tripRepository = MockTripRepository();
    connectivity = MockConnectivity();
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
  });

  group('TripListBloc', () {
    final trips = [
      TripEntity(
        id: '1',
        pickupAddress: 'A',
        dropoffAddress: 'B',
        pickupLat: 1,
        pickupLng: 1,
        dropoffLat: 2,
        dropoffLng: 2,
        status: TripStatus.requested,
        fare: 10,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];

    blocTest<TripListBloc, TripListState>(
      'emits loaded trips when repository returns data',
      build: () {
        when(() => tripRepository.getCachedTrips()).thenReturn(trips);
        when(() => tripRepository.getTrips()).thenAnswer((_) async => trips);
        return TripListBloc(
          repository: tripRepository,
          connectivity: connectivity,
        );
      },
      act: (bloc) => bloc.add(const TripListLoadRequested()),
      expect: () => [
        const TripListLoading(),
        TripListLoaded(trips: trips, isOffline: false),
      ],
    );
  });

  group('RequestRideBloc', () {
    late MockFcmService fcmService;

    setUp(() {
      fcmService = MockFcmService();
      when(
        () => fcmService.simulateTripNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
          tripId: any(named: 'tripId'),
        ),
      ).thenAnswer((_) async {});
    });

    blocTest<RequestRideBloc, RequestRideState>(
      'emits success when trip is created',
      build: () {
        final trip = TripEntity(
          id: 'new',
          pickupAddress: 'A',
          dropoffAddress: 'B',
          pickupLat: 1,
          pickupLng: 1,
          dropoffLat: 2,
          dropoffLng: 2,
          status: TripStatus.accepted,
          fare: 75,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        when(
          () => tripRepository.requestTrip(
            pickupAddress: any(named: 'pickupAddress'),
            dropoffAddress: any(named: 'dropoffAddress'),
            pickupLat: any(named: 'pickupLat'),
            pickupLng: any(named: 'pickupLng'),
            dropoffLat: any(named: 'dropoffLat'),
            dropoffLng: any(named: 'dropoffLng'),
          ),
        ).thenAnswer((_) async => trip);
        return RequestRideBloc(
          repository: tripRepository,
          fcmService: fcmService,
        );
      },
      act: (bloc) => bloc.add(
        const RequestRideSubmitted(
          pickupAddress: 'A',
          dropoffAddress: 'B',
          pickupLat: 1,
          pickupLng: 1,
          dropoffLat: 2,
          dropoffLng: 2,
        ),
      ),
      expect: () => [
        const RequestRideLoading(),
        isA<RequestRideSuccess>(),
      ],
    );
  });

  blocTest<TrackingBloc, TrackingState>(
    'interpolates route on tracking start',
    build: () => TrackingBloc(),
    act: (bloc) => bloc.add(
      TrackingStarted(
        TripEntity(
          id: '1',
          pickupAddress: 'A',
          dropoffAddress: 'B',
          pickupLat: 30,
          pickupLng: 31,
          dropoffLat: 30.1,
          dropoffLng: 31.1,
          status: TripStatus.inProgress,
          fare: 50,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ),
    ),
    expect: () => [isA<TrackingActive>()],
  );
}
