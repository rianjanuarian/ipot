import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();
}

class FetchMenu extends MenuEvent {
  final String tableId;
  const FetchMenu(this.tableId);
  @override
  List<Object?> get props => [tableId];
}

class FilterMenu extends MenuEvent {
  final String query;
  const FilterMenu(this.query);
  @override
  List<Object?> get props => [query];
}
