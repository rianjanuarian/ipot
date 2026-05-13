import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ipot_mobile/navigation/app_router.dart';

import 'package:ipot_mobile/state/cart/cart_bloc.dart';
import 'package:ipot_mobile/state/menu/menu_bloc.dart';
import 'package:ipot_mobile/state/order/order_bloc.dart';
import 'package:ipot_mobile/services/hive_service.dart';
import 'package:ipot_mobile/services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await HiveService.init();
  runApp(const IpotApp());
}

class IpotApp extends StatelessWidget {
  const IpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
        BlocProvider<MenuBloc>(create: (_) => MenuBloc()),
        BlocProvider<OrderBloc>(create: (_) => OrderBloc()),
      ],
      child: SyncInitializer(
        child: MaterialApp.router(
          title: "IPOT",
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}

class SyncInitializer extends StatefulWidget {
  final Widget child;
  const SyncInitializer({super.key, required this.child});

  @override
  State<SyncInitializer> createState() => _SyncInitializerState();
}

class _SyncInitializerState extends State<SyncInitializer> {
  SyncService? _syncService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncService = SyncService(context.read<OrderBloc>())..init();
    });
  }

  @override
  void dispose() {
    _syncService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
