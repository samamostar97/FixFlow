import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = 'KM'}) {
    final formatter = NumberFormat('#,##0.00', 'bs');
    return '${formatter.format(amount)} $symbol';
  }
}
