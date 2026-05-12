import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/menu_api.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final MenuApi _api;

  OrderBloc({MenuApi? api})
      : _api = api ?? MenuApi(),
        super(OrderInitial()) {
    on<SubmitOrder>(_onSubmitOrder);
    on<PollOrderStatus>(_onPollOrderStatus);
    on<ResetOrder>(_onResetOrder);
  }

  Future<void> _onSubmitOrder(
      SubmitOrder event, Emitter<OrderState> emit) async {
    emit(OrderSubmitting());
    try {
      final order = await _api.createOrder(event.request);
      emit(OrderSuccess(order));
    } catch (e) {
      emit(OrderError('Failed to place order: ${e.toString()}'));
    }
  }

  Future<void> _onPollOrderStatus(
      PollOrderStatus event, Emitter<OrderState> emit) async {
    try {
      final order = await _api.getOrderStatus(event.orderId);
      emit(OrderStatusUpdated(order));
    } catch (_) {}
  }

  void _onResetOrder(ResetOrder event, Emitter<OrderState> emit) {
    emit(OrderInitial());
  }
}
