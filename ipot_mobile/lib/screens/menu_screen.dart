import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ipot_mobile/components/custom_sheet.dart';
import '../state/menu/menu_bloc.dart';
import '../state/menu/menu_event.dart';
import '../state/menu/menu_state.dart';
import '../state/cart/cart_bloc.dart';
import '../state/cart/cart_state.dart';
import '../components/menu_item_card.dart';
import '../components/category_tab_bar.dart';

import '../utils/formatters.dart';

class MenuScreen extends StatefulWidget {
  final String tableId;
  const MenuScreen({super.key, required this.tableId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedCategoryIndex = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchMenu(widget.tableId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          if (state is MenuLoading || state is MenuInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MenuError) {
            return Text(state.message);
          }

          if (state is MenuLoaded) {
            final categories = state.menu.categories;
            final selectedCat = categories.isNotEmpty
                ? categories[_selectedCategoryIndex]
                : null;

            final filtered = state.filteredItems;
            final displayItems = selectedCat != null &&
                    state.filterQuery.isEmpty
                ? filtered.where((i) => i.categoryId == selectedCat.id).toList()
                : filtered;

            return CustomScrollView(
              slivers: [
                AppBar(
                  restaurantName: state.menu.restaurant.name,
                  tableId: widget.tableId,
                ),
                SliverToBoxAdapter(
                  child: SearchBar(
                    controller: _searchController,
                    onChanged: (q) =>
                        context.read<MenuBloc>().add(FilterMenu(q)),
                  ),
                ),
                if (state.filterQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: CategoryTabBar(
                        categories: categories,
                        selectedIndex: _selectedCategoryIndex,
                        onTabSelected: (i) =>
                            setState(() => _selectedCategoryIndex = i),
                      ),
                    ),
                  ),
                if (displayItems.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No items found',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        final item = displayItems[index];
                        return MenuItemCard(
                          item: item,
                          onTap: () => CustomizationSheet.show(context, item),
                        );
                      },
                      childCount: displayItems.length,
                    ),
                  ),
                SliverToBoxAdapter(child: SizedBox(height: mHeight * 0.15)),
              ],
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: CartFab(tableId: widget.tableId),
    );
  }
}

class AppBar extends StatelessWidget {
  final String restaurantName;
  final String tableId;

  const AppBar(
      {super.key, required this.restaurantName, required this.tableId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.go('/'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              restaurantName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Table $tableId',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBar(
      {super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
          prefixIcon: Icon(Icons.search_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.4)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  })
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class CartFab extends StatelessWidget {
  final String tableId;
  const CartFab({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.itemCount == 0) return const SizedBox();
        return FloatingActionButton.extended(
          onPressed: () => context.push('/cart'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            Icons.shopping_cart,
            size: MediaQuery.of(context).size.width * 0.05,
            color: Colors.white,
          ),
          label: Text(
            Formatters.price(state.subtotal),
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
