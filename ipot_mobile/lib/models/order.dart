import 'package:equatable/equatable.dart';

class Order extends Equatable {
  final String id;
  final String tableId;
  final String status;
  final int createdAt;
  final int? estimatedPreparationTime;

  const Order({
    required this.id,
    required this.tableId,
    required this.status,
    required this.createdAt,
    this.estimatedPreparationTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'].toString(),
        tableId: json['table_id'] as String,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['createdAt'] as int? ?? 0,
        estimatedPreparationTime: json['estimated_preparation_time'] as int?,
      );

  @override
  List<Object?> get props =>
      [id, tableId, status, createdAt, estimatedPreparationTime];
}

// request model
class OrderItemRequest {
  final int menuItemId;
  final int quantity;
  final List<Map<String, dynamic>> customizations;

  const OrderItemRequest({
    required this.menuItemId,
    required this.quantity,
    required this.customizations,
  });

  Map<String, dynamic> toJson() => {
        'menu_item_id': menuItemId,
        'quantity': quantity,
        'customizations': customizations,
      };

  factory OrderItemRequest.fromJson(Map<String, dynamic> json) =>
      OrderItemRequest(
        menuItemId: json['menu_item_id'] as int,
        quantity: json['quantity'] as int,
        customizations: (json['customizations'] as List)
            .map((c) => c as Map<String, dynamic>)
            .toList(),
      );
}

class OrderRequest {
  final String tableId;
  final List<OrderItemRequest> items;
  final String? customerNote;

  const OrderRequest({
    required this.tableId,
    required this.items,
    this.customerNote,
  });

  Map<String, dynamic> toJson() => {
        'table_id': tableId,
        'items': items.map((i) => i.toJson()).toList(),
        if (customerNote != null && customerNote!.isNotEmpty)
          'customer_note': customerNote,
      };

  factory OrderRequest.fromJson(Map<String, dynamic> json) => OrderRequest(
        tableId: json['table_id'] as String,
        items: (json['items'] as List)
            .map((i) => OrderItemRequest.fromJson(i as Map<String, dynamic>))
            .toList(),
        customerNote: json['customer_note'] as String?,
      );
}
