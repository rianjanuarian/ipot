import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String tableId;

  const Restaurant({
    required this.id,
    required this.name,
    required this.tableId,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String,
        name: json['name'] as String,
        tableId: json['table_id'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'table_id': tableId,
      };

  @override
  List<Object?> get props => [id, name, tableId];
}
