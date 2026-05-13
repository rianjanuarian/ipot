// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_mobile/models/order.dart';

void main() {
  group('Order Model', () {
    test('fromJson should correctly parse order data', () {
      final json = {
        'id': 1,
        'table_id': 'T001',
        'status': 'preparing',
        'createdAt': 1778602381047,
        'estimated_preparation_time': 15,
      };

      final order = Order.fromJson(json);

      expect(order.id, '1');
      expect(order.tableId, 'T001');
      expect(order.status, 'preparing');
      expect(order.createdAt, 1778602381047);
      expect(order.estimatedPreparationTime, 15);
    });

    test('fromJson should use default values if fields are missing', () {
      final json = {
        'id': 'ORD-99',
        'table_id': 'T002',
      };

      final order = Order.fromJson(json);

      expect(order.id, 'ORD-99');
      expect(order.status, 'pending');
      expect(order.createdAt, 0);
      expect(order.estimatedPreparationTime, isNull);
    });

    test('equatable should return true for identical orders', () {
      final order1 = Order(
        id: '1',
        tableId: 'T1',
        status: 'pending',
        createdAt: 100,
        estimatedPreparationTime: 10,
      );
      final order2 = Order(
        id: '1',
        tableId: 'T1',
        status: 'pending',
        createdAt: 100,
        estimatedPreparationTime: 10,
      );

      expect(order1, equals(order2));
    });
  });
}
