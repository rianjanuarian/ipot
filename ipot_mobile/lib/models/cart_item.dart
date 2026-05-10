import 'package:equatable/equatable.dart';
import 'customization.dart';
import 'menu_item.dart';

class SelectedOption extends Equatable {
  final int groupId;
  final CustomizationOption option;

  const SelectedOption({required this.groupId, required this.option});

  @override
  List<Object?> get props => [groupId, option];
}

class CartItem extends Equatable {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final List<SelectedOption> selectedOptions;

  const CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.selectedOptions,
  });

  double get unitPrice {
    final modifiers =
        selectedOptions.fold(0.0, (sum, s) => sum + s.option.priceModifier);
    return menuItem.price + modifiers;
  }

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        menuItem: menuItem,
        quantity: quantity ?? this.quantity,
        selectedOptions: selectedOptions,
      );

  @override
  List<Object?> get props => [id, menuItem, quantity, selectedOptions];
}
