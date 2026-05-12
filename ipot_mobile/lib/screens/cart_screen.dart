import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ipot_mobile/components/quantitiy_selector.dart';
import 'package:ipot_mobile/models/cart_item.dart';
import 'package:ipot_mobile/models/order.dart';
import 'package:ipot_mobile/state/cart/cart_bloc.dart';
import 'package:ipot_mobile/state/cart/cart_event.dart';
import 'package:ipot_mobile/state/cart/cart_state.dart';
import 'package:ipot_mobile/state/order/order_bloc.dart';
import 'package:ipot_mobile/state/order/order_event.dart';
import 'package:ipot_mobile/state/order/order_state.dart';
import 'package:ipot_mobile/utils/formatters.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _noteController = TextEditingController();
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _placeOrder(BuildContext context, CartState cartState) {
    final items = cartState.items
        .map((ci) => OrderItemRequest(
              menuItemId: ci.menuItem.id,
              quantity: ci.quantity,
              customizations: ci.selectedOptions
                  .map((s) => {'option_id': s.option.id, 'quantity': 1})
                  .toList(),
            ))
        .toList();

    final tableId =
        GoRouterState.of(context).uri.queryParameters['table_id'] ?? 'T001';

    context.read<OrderBloc>().add(SubmitOrder(OrderRequest(
          tableId: tableId,
          items: items,
          customerNote: _noteController.text.trim(),
        )));
  }

  void _showClearCartConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clear Cart?"),
        content: const Text("This will remove all items from your cart."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(const ClearCart());
              Navigator.pop(ctx);
            },
            child: const Text("Clear All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var mHeight = MediaQuery.of(context).size.height;
    return BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderSuccess) {
            context.read<CartBloc>().add(const ClearCart());
            context.go('/order-status/${state.order.id}');
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Your Order",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            actions: [
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  if (state.items.isEmpty) return const SizedBox();
                  return TextButton(
                    onPressed: () => _showClearCartConfirmation(context),
                    child: const Text("Clear",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
          body: BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
            if (cartState.items.isEmpty) {
              return _EmptyCart(onBrowse: () => context.pop());
            }
            return Column(
              children: [
                Expanded(
                    child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    ...cartState.items.map(
                      (item) => _CartItemTile(
                        item: item,
                        onRemove: () => context
                            .read<CartBloc>()
                            .add(RemoveFromCart(item.id)),
                        onQuantityChange: (qty) => context.read<CartBloc>().add(
                              UpdateQuantity(
                                  cartItemId: item.id, quantity: qty),
                            ),
                      ),
                    ),
                    SizedBox(
                      height: mHeight * 0.03,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.15)),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Any special requests? (optional)',
                          hintStyle: TextStyle(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 14),
                          prefixIcon: Icon(Icons.edit_note_rounded,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.4)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: mHeight * 0.035,
                    ),
                    //summary

                    _SummaryRow(
                      label: 'Total',
                      value: Formatters.price(cartState.subtotal),
                    ),
                  ],
                )),
                _PlaceOrderBar(
                    onPressed: () => _placeOrder(context, cartState)),
              ],
            );
          }),
        ));
  }
}

class _PlaceOrderBar extends StatelessWidget {
  final VoidCallback onPressed;
  const _PlaceOrderBar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var mHeight = MediaQuery.of(context).size.height;
    var mWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        final isLoading = state is OrderSubmitting;
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
                top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.15))),
          ),
          child: SizedBox(
            width: double.infinity,
            height: mHeight * 0.06,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading
                  ? SizedBox(
                      height: mHeight * 0.03,
                      width: mHeight * 0.03,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Place Order',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: mWidth * 0.04)),
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black)),
        Text(value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            )),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onBrowse;
  const _EmptyCart({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    var mHeight = MediaQuery.of(context).size.height;
    var mWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart, size: mHeight * 0.06, color: Colors.black),
          Text('Your cart is empty',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: mWidth * 0.05,
                  fontWeight: FontWeight.bold)),
          const Text('Add items from the menu to get started',
              style: TextStyle(color: Colors.black54)),
          ElevatedButton.icon(
            onPressed: onBrowse,
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text('Browse Menu'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChange;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    var mWidth = MediaQuery.of(context).size.width;

    final theme = Theme.of(context);
    final customText =
        item.selectedOptions.map((s) => s.option.name).join(', ');

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_sweep_rounded,
            color: Colors.red, size: mWidth * 0.06),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.menuItem.name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (customText.isNotEmpty) ...[
              Text(
                customText,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
            ],
            SizedBox(height: mWidth * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Formatters.price(item.unitPrice)} each',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.45)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.price(item.lineTotal),
                      style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                QuantitySelector(
                  quantity: item.quantity,
                  minQuantity: 0,
                  onIncrement: () => onQuantityChange(item.quantity + 1),
                  onDecrement: () => onQuantityChange(item.quantity - 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
