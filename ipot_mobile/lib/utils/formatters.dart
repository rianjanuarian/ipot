import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String price(double amount) => _currency.format(amount);

  static String priceModifier(double modifier) {
    if (modifier == 0) return '';
    final sign = modifier > 0 ? '+' : '';
    return '$sign${_currency.format(modifier)}';
  }
}
