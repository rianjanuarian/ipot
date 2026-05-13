import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ipot_mobile/state/order/order_bloc.dart';
import 'package:ipot_mobile/state/order/order_event.dart';
import 'package:ipot_mobile/state/order/order_state.dart';
import 'package:ipot_mobile/utils/constants.dart';

class OrderStatusScreen extends StatefulWidget {
  final String orderId;
  const OrderStatusScreen({super.key, required this.orderId});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  Timer? _pollTimer;
  String _status = 'pending';
  int? _estTime;

  static const _statuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'served'
  ];

  static const _statusLabels = {
    'pending': 'Order Received',
    'confirmed': 'Confirmed',
    'preparing': 'Being Prepared',
    'ready': 'Ready for Pickup',
    'served': 'Served',
  };

  static const _statusIcons = {
    'pending': Icons.receipt_long_rounded,
    'confirmed': Icons.check_circle_outline_rounded,
    'preparing': Icons.restaurant_rounded,
    'ready': Icons.shopping_bag_rounded,
    'served': Icons.done_all_rounded,
  };

  static const _statusColors = {
    'pending': Color(0xFFFFC107),
    'confirmed': Color(0xFF9C27B0),
    'preparing': Color(0xFF2196F3),
    'ready': Color(0xFF4CAF50),
    'served': Color(0xFF607D8B),
  };
  @override
  void initState() {
    super.initState();
    // init bloc state if available
    final state = context.read<OrderBloc>().state;
    if (state is OrderSuccess && state.order.id == widget.orderId) {
      _status = state.order.status;
      _estTime = state.order.estimatedPreparationTime;
    } else if (state is OrderStatusUpdated &&
        state.order.id == widget.orderId) {
      _status = state.order.status;
      _estTime = state.order.estimatedPreparationTime;
    }
    _startPolling();
  }

  void _startPolling() {
    context.read<OrderBloc>().add(PollOrderStatus(widget.orderId));
    _pollTimer = Timer.periodic(AppConstants.pollInterval, (_) {
      if (mounted) {
        if (_status == 'served') {
          _pollTimer?.cancel();
          return;
        }
        context.read<OrderBloc>().add(PollOrderStatus(widget.orderId));
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mWidth = MediaQuery.of(context).size.width;
    var mHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderStatusUpdated && state.order.id == widget.orderId) {
          setState(() {
            _status = state.order.status;
            _estTime = state.order.estimatedPreparationTime;
          });
          if (_status == 'served') {
            _pollTimer?.cancel();
          }
        }
        if (state is OrderSuccess && state.order.id == widget.orderId) {
          setState(() {
            _status = state.order.status;
            _estTime = state.order.estimatedPreparationTime;
          });
          if (_status == 'served') {
            _pollTimer?.cancel();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              label: const Text('New Order'),
              onPressed: () {
                context.read<OrderBloc>().add(const ResetOrder());
                context.go('/');
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _StatusIcon(status: _status, statusColors: _statusColors),
                SizedBox(height: mHeight * 0.03),
                Text(
                  'Order #${widget.orderId}',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _statusLabels[_status] ?? _status,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _statusColors[_status] ?? theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_estTime != null && _status == 'preparing')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 4),
                        Text(
                          'Est. preparation: $_estTime mins',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: mHeight * 0.05),
                ..._statuses.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final s = entry.value;
                  final currentIdx = _statuses.indexOf(_status);
                  final isDone = idx <= currentIdx;
                  final isCurrent = idx == currentIdx;

                  return _TimelineStep(
                    label: _statusLabels[s] ?? s,
                    icon: _statusIcons[s] ?? Icons.circle,
                    color: _statusColors[s] ?? Colors.grey,
                    isDone: isDone,
                    isCurrent: isCurrent,
                    isLast: idx == _statuses.length - 1,
                  );
                }),
                const Spacer(),
                if (_status != 'served')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: mWidth * 0.03,
                        height: mWidth * 0.03,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                      ),
                      SizedBox(width: mWidth * 0.02),
                      Text(
                        'Checking status every 5s',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                            fontSize: mWidth * 0.03),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;
  final Map<String, Color> statusColors;

  const _StatusIcon({required this.status, required this.statusColors});

  static const _icons = {
    'pending': Icons.receipt_long_rounded,
    'confirmed': Icons.check_circle_outline_rounded,
    'preparing': Icons.restaurant_rounded,
    'ready': Icons.shopping_bag_rounded,
    'served': Icons.done_all_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status] ?? const Color(0xFFFF6B35);
    final icon = _icons[status] ?? Icons.receipt_long_rounded;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.2), blurRadius: 24, spreadRadius: 4),
        ],
      ),
      child: Icon(icon,
          size: MediaQuery.of(context).size.width * 0.12, color: color),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = isDone ? color : Colors.white24;
    var mWidth = MediaQuery.of(context).size.width;
    var mHeight = MediaQuery.of(context).size.height;
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: mWidth * 0.08,
                height: mHeight * 0.08,
                decoration: BoxDecoration(
                  color: isDone ? color.withOpacity(0.15) : Colors.white10,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: activeColor, width: isCurrent ? 2 : 1),
                ),
                child: Icon(icon,
                    size: mWidth * 0.04,
                    color: isDone ? color : Colors.white30),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    color: isDone ? color.withOpacity(0.4) : Colors.white10,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          SizedBox(width: mWidth * 0.075),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDone ? Colors.blueGrey : Colors.white38,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Current',
                    style: TextStyle(
                        color: color,
                        fontSize: mWidth * 0.03,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
