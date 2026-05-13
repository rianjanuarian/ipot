import 'package:equatable/equatable.dart';

class CustomizationOption extends Equatable {
  final int id;
  final String name;
  final double priceModifier;

  const CustomizationOption({
    required this.id,
    required this.name,
    required this.priceModifier,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) =>
      CustomizationOption(
        id: json['id'] as int,
        name: json['name'] as String,
        priceModifier: (json['price_modifier'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price_modifier': priceModifier,
      };

  @override
  List<Object?> get props => [id, name, priceModifier];
}

class CustomizationGroup extends Equatable {
  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOption> options;

  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) =>
      CustomizationGroup(
        id: json['id'] as int,
        name: json['name'] as String,
        required: json['required'] as bool,
        maxSelections: json['max_selections'] as int,
        options: (json['options'] as List)
            .map((o) => CustomizationOption.fromJson(o as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'required': required,
        'max_selections': maxSelections,
        'options': options.map((o) => o.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, name, required, maxSelections, options];
}
