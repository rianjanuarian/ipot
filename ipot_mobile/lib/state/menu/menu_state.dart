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
  final bool isFromCache;

  const MenuLoaded({
    required this.menu,
    this.filterQuery = '',
    this.isFromCache = false,
  });

  List<MenuItem> get filteredItems {
    if (filterQuery.isEmpty) return menu.items;
    final q = filterQuery.toLowerCase();
    return menu.items
        .where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q))
        .toList();
  }

  MenuLoaded copyWith({
    MenuResponse? menu,
    String? filterQuery,
    bool? isFromCache,
  }) =>
      MenuLoaded(
        menu: menu ?? this.menu,
        filterQuery: filterQuery ?? this.filterQuery,
        isFromCache: isFromCache ?? this.isFromCache,
      );

  @override
  List<Object?> get props => [menu, filterQuery, isFromCache];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);
  @override
  List<Object?> get props => [message];
}
