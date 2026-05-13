import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../api/menu_api.dart';
import '../../models/order.dart';
import '../../services/hive_service.dart';
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
    on<SyncPendingOrders>(_onSyncPendingOrders);
  }

  Future<void> _onSubmitOrder(
      SubmitOrder event, Emitter<OrderState> emit) async {
    emit(OrderSubmitting());

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline = connectivityResult.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    if (!isOnline) {
      await HiveService.addToQueue(event.request.toJson());
      emit(OrderQueued());
      return;
    }

    try {
      final order = await _api.createOrder(event.request);
      emit(OrderSuccess(order));
    } catch (e) {
      emit(OrderError('Failed to place order: ${e.toString()}'));
    }
  }

  Future<void> _onSyncPendingOrders(
      SyncPendingOrders event, Emitter<OrderState> emit) async {
    final queue = HiveService.getQueue();
    if (queue.isEmpty) return;

    //queue process
    final items = List<Map<String, dynamic>>.from(queue);
    for (var i = 0; i < items.length; i++) {
      try {
        final request = OrderRequest.fromJson(items[i]);
        final order = await _api.createOrder(request);

        await HiveService.removeFromQueue(0);
        emit(OrderSuccess(order));
      } catch (e) {
        break;
      }
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
