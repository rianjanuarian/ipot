import 'package:equatable/equatable.dart';
import '../../models/cart_item.dart';
import '../../models/menu_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
}

class AddToCart extends CartEvent {
  final MenuItem menuItem;
  final int quantity;
  final List<SelectedOption> selectedOptions;

  const AddToCart({
    required this.menuItem,
    required this.quantity,
    required this.selectedOptions,
  });

  @override
  List<Object?> get props => [menuItem.id, quantity, selectedOptions];
}

class RemoveFromCart extends CartEvent {
  final String cartItemId;
  const RemoveFromCart(this.cartItemId);
  @override
  List<Object?> get props => [cartItemId];
}

class UpdateQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;
  const UpdateQuantity({required this.cartItemId, required this.quantity});
  @override
  List<Object?> get props => [cartItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
  @override
  List<Object?> get props => [];
}
