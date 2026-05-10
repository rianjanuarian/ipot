import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ipot_mobile/screens/menu_screen.dart';
import 'package:ipot_mobile/screens/qr_scanner_screen.dart';

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
        builder: (context, state) => const MenuScreen(),
      ),
    ],
  );
}
