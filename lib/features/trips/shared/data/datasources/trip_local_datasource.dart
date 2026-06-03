import 'package:hive/hive.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class TripLocalDataSource {
  TripLocalDataSource(this._box);

  final Box<TripEntity> _box;

  List<TripEntity> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TripEntity? getById(String id) => _box.get(id);

  Future<void> saveAll(List<TripEntity> trips) async {
    final remoteIds = trips.map((t) => t.id).toSet();
    final toDelete = <String>[];
    
    for (final key in _box.keys) {
      final trip = _box.get(key);
      if (trip != null && !trip.isPendingSync && !remoteIds.contains(trip.id)) {
        toDelete.add(key as String);
      }
    }
    
    await _box.deleteAll(toDelete);

    for (final trip in trips) {
      await _box.put(trip.id, trip);
    }
  }

  Future<void> save(TripEntity trip) async {
    await _box.put(trip.id, trip);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

Future<Box<TripEntity>> openTripsBox() async {
  return Hive.openBox<TripEntity>(AppConstants.tripsBox);
}
