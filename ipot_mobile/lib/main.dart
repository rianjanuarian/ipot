import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ipot_mobile/navigation/app_router.dart';

import 'package:ipot_mobile/state/cart/cart_bloc.dart';
import 'package:ipot_mobile/state/menu/menu_bloc.dart';
import 'package:ipot_mobile/state/order/order_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
      child: MaterialApp.router(
        title: "IPOT",
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
