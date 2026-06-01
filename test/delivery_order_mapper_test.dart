import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/profile/shared/data/mappers/delivery_order_mapper.dart';
import 'package:delivery_app/features/profile/shared/domain/entities/order_entity.dart';

void main() {
  group('DeliveryOrderMapper', () {
    test('maps backend delivery JSON to OrderEntity', () {
      final order = DeliveryOrderMapper.fromDeliveryJson({
        'id': 'del-1',
        'pickupAddress': 'Maadi',
        'dropoffAddress': 'Zamalek',
        'fee': 45.5,
        'status': 'inTransit',
        'createdAt': '2026-06-01T10:00:00.000Z',
      });

      expect(order.id, 'del-1');
      expect(order.title, 'Maadi → Zamalek');
      expect(order.amount, 45.5);
      expect(order.status, OrderStatus.inTransit);
    });

    test('maps delivered status', () {
      final order = DeliveryOrderMapper.fromDeliveryJson({
        'id': 'del-2',
        'pickupAddress': 'A',
        'dropoffAddress': 'B',
        'fee': 30,
        'status': 'delivered',
        'createdAt': '2026-06-01T10:00:00.000Z',
      });

      expect(order.status, OrderStatus.delivered);
    });
  });
}
