import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final newItem = CartItem(
      id: '${event.menuItem.id}_${DateTime.now().millisecondsSinceEpoch}',
      menuItem: event.menuItem,
      quantity: event.quantity,
      selectedOptions: event.selectedOptions,
    );
    emit(state.copyWith(items: [...state.items, newItem]));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    emit(state.copyWith(
      items: state.items.where((i) => i.id != event.cartItemId).toList(),
    ));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      emit(state.copyWith(
        items: state.items.where((i) => i.id != event.cartItemId).toList(),
      ));
      return;
    }
    final updated = state.items.map((item) {
      if (item.id == event.cartItemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
