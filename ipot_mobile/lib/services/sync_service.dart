import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../state/order/order_bloc.dart';
import '../state/order/order_event.dart';
import './hive_service.dart';

class SyncService {
  final OrderBloc _orderBloc;
  StreamSubscription? _subscription;

  SyncService(this._orderBloc);

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      // check internet
      final isOnline = results.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);

      if (isOnline) {
        _syncPendingOrders();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> _syncPendingOrders() async {
    final queue = HiveService.getQueue();
    if (queue.isEmpty) return;

    if (kDebugMode) {
      print('Syncing ${queue.length} pending orders...');
    }

    _orderBloc.add(const SyncPendingOrders());
  }
}
