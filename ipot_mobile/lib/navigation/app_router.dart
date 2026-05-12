import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ipot_mobile/screens/cart_screen.dart';
import 'package:ipot_mobile/screens/menu_screen.dart';
import 'package:ipot_mobile/screens/order_status_screen.dart';
import 'package:ipot_mobile/screens/qr_scanner_screen.dart';
import 'package:ipot_mobile/state/menu/menu_bloc.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/menu/:tableId',
        builder: (context, state) {
          final tableId = state.pathParameters['tableId']!;
          return BlocProvider(
            create: (_) => MenuBloc(),
            child: MenuScreen(tableId: tableId),
          );
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/order-status/:orderId',
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return OrderStatusScreen(orderId: orderId);
        },
      ),
    ],
  );
}
