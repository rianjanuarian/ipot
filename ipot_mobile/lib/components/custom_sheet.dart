import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ipot_mobile/components/quantitiy_selector.dart';
import '../models/menu_item.dart';
import '../models/customization.dart';
import '../models/cart_item.dart';
import '../state/cart/cart_bloc.dart';
import '../state/cart/cart_event.dart';
import '../utils/formatters.dart';

class CustomizationSheet extends StatefulWidget {
  final MenuItem item;
  const CustomizationSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, MenuItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: CustomizationSheet(item: item),
      ),
    );
  }

  @override
  State<CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends State<CustomizationSheet> {
  int _quantity = 1;

  // set of selected optionIds
  final Map<int, Set<int>> _selections = {};

  @override
  void initState() {
    super.initState();
    for (final g in widget.item.customizationGroups) {
      _selections[g.id] = {};
    }
  }

  double get _totalPrice {
    double total = widget.item.price;
    for (final g in widget.item.customizationGroups) {
      for (final opt in g.options) {
        if (_selections[g.id]?.contains(opt.id) ?? false) {
          total += opt.priceModifier;
        }
      }
    }
    return total * _quantity;
  }

  bool get _canAddToCart {
    for (final g in widget.item.customizationGroups) {
      if (g.required && (_selections[g.id]?.isEmpty ?? true)) return false;
    }
    return true;
  }

  void _toggleOption(CustomizationGroup group, CustomizationOption option) {
    setState(() {
      final selected = _selections[group.id]!;
      if (selected.contains(option.id)) {
        selected.remove(option.id);
      } else {
        if (group.maxSelections == 1) {
          selected.clear();
        } else if (selected.length >= group.maxSelections) {
          return; // max reached
        }
        selected.add(option.id);
      }
    });
  }

  void _addToCart() {
    final List<SelectedOption> selectedOpts = [];
    for (final g in widget.item.customizationGroups) {
      for (final opt in g.options) {
        if (_selections[g.id]?.contains(opt.id) ?? false) {
          selectedOpts.add(SelectedOption(groupId: g.id, option: opt));
        }
      }
    }
    context.read<CartBloc>().add(AddToCart(
          menuItem: widget.item,
          quantity: _quantity,
          selectedOptions: selectedOpts,
        ));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} added to cart!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    var mWidth = MediaQuery.of(context).size.width;
    var mHeight = MediaQuery.of(context).size.height;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: mWidth * 0.2,
                height: mHeight * 0.005,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                children: [
                  // item header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            SizedBox(height: mHeight * 0.01),
                            Text(item.description,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6))),
                            SizedBox(height: mHeight * 0.01),
                            Text(Formatters.price(item.price),
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: mHeight * 0.02),

                  // custom groups
                  ...item.customizationGroups.map(
                    (group) => _GroupSection(
                      group: group,
                      selectedIds: _selections[group.id] ?? {},
                      onToggle: (opt) => _toggleOption(group, opt),
                    ),
                  ),

                  SizedBox(height: mHeight * 0.015),
                  // qty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quantity',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      QuantitySelector(
                        quantity: _quantity,
                        onIncrement: () => setState(() => _quantity++),
                        onDecrement: () => setState(
                            () => _quantity = (_quantity - 1).clamp(1, 99)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _BottomBar(
              total: _totalPrice,
              enabled: _canAddToCart,
              onAdd: _addToCart,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSection extends StatelessWidget {
  final CustomizationGroup group;
  final Set<int> selectedIds;
  final ValueChanged<CustomizationOption> onToggle;

  const _GroupSection({
    required this.group,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    var mHeight = MediaQuery.of(context).size.height;
    var mWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(group.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(width: mWidth * 0.01),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: group.required
                  ? theme.colorScheme.error.withOpacity(0.12)
                  : theme.colorScheme.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              group.required ? 'Required' : 'Optional',
              style: TextStyle(
                fontSize: mWidth * 0.0,
                color: group.required
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          if (group.maxSelections > 1)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                'Up to ${group.maxSelections}',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ),
            ),
        ]),
        SizedBox(height: mHeight * 0.01),
        ...group.options.map((opt) {
          final isSelected = selectedIds.contains(opt.id);
          final isRadio = group.maxSelections == 1;
          return GestureDetector(
            onTap: () => onToggle(opt),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  isRadio
                      ? Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                          size: 20,
                        )
                      : Icon(
                          isSelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                          size: 20,
                        ),
                  SizedBox(width: mWidth * 0.02),
                  Expanded(
                    child: Text(opt.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ),
                  if (opt.priceModifier != 0)
                    Text(
                      Formatters.priceModifier(opt.priceModifier),
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: mHeight * 0.01),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final double total;
  final bool enabled;
  final VoidCallback onAdd;

  const _BottomBar(
      {required this.total, required this.enabled, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
            top:
                BorderSide(color: theme.colorScheme.outline.withOpacity(0.15))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.06,
        child: ElevatedButton(
          onPressed: enabled ? onAdd : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            'Add to Cart · ${Formatters.price(total)}',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.02),
          ),
        ),
      ),
    );
  }
}
