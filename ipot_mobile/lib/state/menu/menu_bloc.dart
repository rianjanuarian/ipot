import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api/menu_api.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuApi _api;

  MenuBloc({MenuApi? api})
      : _api = api ?? MenuApi(),
        super(MenuInitial()) {
    on<FetchMenu>(_onFetchMenu);
    on<FilterMenu>(_onFilterMenu);
  }

  Future<void> _onFetchMenu(FetchMenu event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      final menu = await _api.getMenu(event.tableId);
      emit(MenuLoaded(menu: menu));
    } catch (e) {
      emit(MenuError('load menu failed: ${e.toString()}'));
    }
  }

  void _onFilterMenu(FilterMenu event, Emitter<MenuState> emit) {
    final current = state;
    if (current is MenuLoaded) {
      emit(current.copyWith(filterQuery: event.query));
    }
  }
}
