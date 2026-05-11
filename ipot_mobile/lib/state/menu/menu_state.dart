import 'package:equatable/equatable.dart';
import '../../models/menu_response.dart';
import '../../models/menu_item.dart';

abstract class MenuState extends Equatable {
  const MenuState();
}

class MenuInitial extends MenuState {
  @override
  List<Object?> get props => [];
}

class MenuLoading extends MenuState {
  @override
  List<Object?> get props => [];
}

class MenuLoaded extends MenuState {
  final MenuResponse menu;
  final String filterQuery;

  const MenuLoaded({required this.menu, this.filterQuery = ''});

  List<MenuItem> get filteredItems {
    if (filterQuery.isEmpty) return menu.items;
    final q = filterQuery.toLowerCase();
    return menu.items
        .where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q))
        .toList();
  }

  MenuLoaded copyWith({MenuResponse? menu, String? filterQuery}) => MenuLoaded(
        menu: menu ?? this.menu,
        filterQuery: filterQuery ?? this.filterQuery,
      );

  @override
  List<Object?> get props => [menu, filterQuery];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);
  @override
  List<Object?> get props => [message];
}
