import 'package:equatable/equatable.dart';
import '../../models/order.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
}

class SubmitOrder extends OrderEvent {
  final OrderRequest request;
  const SubmitOrder(this.request);
  @override
  List<Object?> get props => [request];
}

class PollOrderStatus extends OrderEvent {
  final String orderId;
  const PollOrderStatus(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class ResetOrder extends OrderEvent {
  const ResetOrder();
  @override
  List<Object?> get props => [];
}

class SyncPendingOrders extends OrderEvent {
  const SyncPendingOrders();
  @override
  List<Object?> get props => [];
}
