import 'package:equatable/equatable.dart';
import 'customization.dart';

class MenuItem extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String? imageUrl;
  final List<CustomizationGroup> customizationGroups;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    required this.customizationGroups,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        categoryId: json['category_id'] as int,
        imageUrl: json['image_url'] as String?,
        customizationGroups: (json['customization_groups'] as List)
            .map((g) => CustomizationGroup.fromJson(g as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category_id': categoryId,
        'image_url': imageUrl,
        'customization_groups':
            customizationGroups.map((g) => g.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [id, name, description, price, categoryId, imageUrl, customizationGroups];
}
