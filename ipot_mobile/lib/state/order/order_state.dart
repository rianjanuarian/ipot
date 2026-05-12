import 'package:equatable/equatable.dart';
import '../../models/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();
}

class OrderInitial extends OrderState {
  @override
  List<Object?> get props => [];
}

class OrderSubmitting extends OrderState {
  @override
  List<Object?> get props => [];
}

class OrderSuccess extends OrderState {
  final Order order;
  const OrderSuccess(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderStatusUpdated extends OrderState {
  final Order order;
  const OrderStatusUpdated(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}
