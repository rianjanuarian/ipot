import 'package:equatable/equatable.dart';
import 'restaurant.dart';
import 'category.dart';
import 'menu_item.dart';

class MenuResponse extends Equatable {
  final Restaurant restaurant;
  final List<Category> categories;
  final List<MenuItem> items;

  const MenuResponse({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  factory MenuResponse.fromJson(Map<String, dynamic> json) => MenuResponse(
        restaurant:
            Restaurant.fromJson(json['restaurant'] as Map<String, dynamic>),
        categories: (json['categories'] as List)
            .map((c) => Category.fromJson(c as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
        items: (json['items'] as List)
            .map((i) => MenuItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

  List<MenuItem> itemsForCategory(int categoryId) =>
      items.where((i) => i.categoryId == categoryId).toList();

  @override
  List<Object?> get props => [restaurant, categories, items];
}
