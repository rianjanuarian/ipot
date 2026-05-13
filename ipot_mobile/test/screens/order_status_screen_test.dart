import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_mobile/models/order.dart';
import 'package:ipot_mobile/screens/order_status_screen.dart';
import 'package:ipot_mobile/state/order/order_bloc.dart';
import 'package:ipot_mobile/state/order/order_event.dart';
import 'package:ipot_mobile/state/order/order_state.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderBloc extends MockBloc<OrderEvent, OrderState>
    implements OrderBloc {}

void main() {
  late MockOrderBloc mockOrderBloc;

  setUp(() {
    mockOrderBloc = MockOrderBloc();
  });

  Widget createWidgetUnderTest(String orderId) {
    return MaterialApp(
      home: BlocProvider<OrderBloc>.value(
        value: mockOrderBloc,
        child: OrderStatusScreen(orderId: orderId),
      ),
    );
  }

  testWidgets('displays correct status label and icon for pending',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const orderId = '123';
    final order = Order(
      id: orderId,
      tableId: 'T1',
      status: 'pending',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    when(() => mockOrderBloc.state).thenReturn(OrderSuccess(order));

    await tester.pumpWidget(createWidgetUnderTest(orderId));

    expect(find.text('Order #$orderId'), findsOneWidget);
    expect(find.text('Order Received'), findsNWidgets(2));
    expect(find.text('Checking status every 5s'), findsOneWidget);
  });

  testWidgets('displays estimated time when status is preparing',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const orderId = '123';
    final order = Order(
      id: orderId,
      tableId: 'T1',
      status: 'preparing',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      estimatedPreparationTime: 15,
    );

    when(() => mockOrderBloc.state).thenReturn(OrderStatusUpdated(order));

    await tester.pumpWidget(createWidgetUnderTest(orderId));

    expect(find.text('Being Prepared'), findsNWidgets(2));
    expect(find.text('Est. preparation: 15 mins'), findsOneWidget);
  });

  testWidgets('hides polling indicator when status is served', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const orderId = '123';
    final order = Order(
      id: orderId,
      tableId: 'T1',
      status: 'served',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    when(() => mockOrderBloc.state).thenReturn(OrderStatusUpdated(order));

    await tester.pumpWidget(createWidgetUnderTest(orderId));

    expect(find.text('Served'), findsNWidgets(2));
    expect(find.text('Checking status every 5s'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('updates ui when bloc emits new state', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const orderId = '123';
    final orderPending = Order(
      id: orderId,
      tableId: 'T1',
      status: 'pending',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    final orderPreparing = Order(
      id: orderId,
      tableId: 'T1',
      status: 'preparing',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    whenListen(
      mockOrderBloc,
      Stream.fromIterable([OrderStatusUpdated(orderPreparing)]),
      initialState: OrderSuccess(orderPending),
    );

    await tester.pumpWidget(createWidgetUnderTest(orderId));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Being Prepared'), findsNWidgets(2));
    expect(find.text('Order Received'), findsOneWidget);
  });
}
