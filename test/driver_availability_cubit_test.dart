import 'package:delivery_app/core/cache/datasources/pending_sync_local_datasource.dart';
import 'package:delivery_app/core/cache/entities/pending_sync_entity.dart';
import 'package:delivery_app/core/network/network_status.dart';
import 'package:delivery_app/features/driver/shared/data/datasources/driver_profile_remote_datasource.dart';
import 'package:delivery_app/features/driver/shared/domain/entities/driver_availability.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/driver_availability_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockRemote extends Mock implements DriverProfileRemoteDataSource {}

class _MockNetworkStatus extends Mock implements NetworkStatus {}

class _MockPendingSync extends Mock implements PendingSyncLocalDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRemote remote;
  late _MockNetworkStatus networkStatus;
  late _MockPendingSync pendingSync;

  setUpAll(() {
    registerFallbackValue(
      PendingSyncEntity(
        id: 'fallback',
        action: SyncAction.updateDriverAvailability,
        payload: const {},
        createdAt: DateTime(2020),
      ),
    );
  });

  setUp(() {
    remote = _MockRemote();
    networkStatus = _MockNetworkStatus();
    pendingSync = _MockPendingSync();
    when(() => pendingSync.enqueueOrReplace(any())).thenAnswer((_) async {});
    when(() => pendingSync.remove(any())).thenAnswer((_) async {});
    when(() => remote.updateAvailability(any()))
        .thenAnswer((_) async => 'online');
  });

  Future<DriverAvailabilityCubit> buildCubit() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    return DriverAvailabilityCubit(
      sharedPreferences: prefs,
      remote: remote,
      networkStatus: networkStatus,
      pendingSync: pendingSync,
    );
  }

  group('DriverAvailabilityCubit.lockOnTrip', () {
    test('enqueues an availability sync when offline', () async {
      when(() => networkStatus.isOnline).thenAnswer((_) async => false);
      final cubit = await buildCubit();

      cubit.lockOnTrip();

      await untilCalled(() => pendingSync.enqueueOrReplace(any()));
      final captured = verify(
        () => pendingSync.enqueueOrReplace(captureAny()),
      ).captured.single as PendingSyncEntity;

      expect(captured.action, SyncAction.updateDriverAvailability);
      expect(captured.payload['status'], DriverAvailability.onTrip.storageKey);
      expect(cubit.state.availability, DriverAvailability.onTrip);

      await cubit.close();
    });

    test('pushes the on-trip status to the backend when online', () async {
      when(() => networkStatus.isOnline).thenAnswer((_) async => true);
      final cubit = await buildCubit();

      cubit.lockOnTrip();

      await untilCalled(() => remote.updateAvailability(any()));
      verify(
        () => remote.updateAvailability(DriverAvailability.onTrip.storageKey),
      ).called(1);
      expect(cubit.state.availability, DriverAvailability.onTrip);

      await cubit.close();
    });
  });
}
