import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        sortOrder: json['sort_order'] as int,
      );

  @override
  List<Object?> get props => [id, name, sortOrder];
}
