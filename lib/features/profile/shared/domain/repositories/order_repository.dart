import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({bool forceRefresh = false});
  List<OrderEntity> getCachedOrders();
  Future<OrderEntity> createDelivery({
    required String pickupAddress,
    required String dropoffAddress,
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
    required double fee,
    String? packageNotes,
  });
  Future<void> syncPendingChanges();
}
