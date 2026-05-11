import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minQuantity;
  final int maxQuantity;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.minQuantity = 1,
    this.maxQuantity = 99,
  });

  @override
  Widget build(BuildContext context) {
    var mWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Btn(
            icon: Icons.remove_rounded,
            onTap: quantity > minQuantity ? onDecrement : null,
            color: theme.colorScheme.primary,
          ),
          SizedBox(
            width: mWidth * 0.1,
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Btn(
            icon: Icons.add_rounded,
            onTap: quantity < maxQuantity ? onIncrement : null,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const Btn({super.key, required this.icon, this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: MediaQuery.of(context).size.width * 0.05,
          color: onTap != null ? color : color.withOpacity(0.3),
        ),
      ),
    );
  }
}
