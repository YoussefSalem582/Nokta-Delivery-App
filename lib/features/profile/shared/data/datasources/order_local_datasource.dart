import 'package:hive/hive.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';
import 'package:delivery_app/core/utils/constants.dart';

class OrderLocalDataSource {
  OrderLocalDataSource(this._box);

  final Box<OrderEntity> _box;

  List<OrderEntity> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveAll(List<OrderEntity> orders) async {
    final remoteIds = orders.map((o) => o.id).toSet();
    final toDelete = _box.keys.where((k) => !remoteIds.contains(k)).toList();
    await _box.deleteAll(toDelete);

    for (final order in orders) {
      await _box.put(order.id, order);
    }
  }

  Future<void> save(OrderEntity order) async {
    await _box.put(order.id, order);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}

Future<Box<OrderEntity>> openOrdersBox() async {
  return Hive.openBox<OrderEntity>(AppConstants.ordersBox);
}
