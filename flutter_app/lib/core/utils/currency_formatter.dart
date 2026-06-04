import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _penFormat = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/. ',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _penFormat.format(amount);
  }

  static String formatShort(double amount) {
    if (amount >= 1000000) {
      return 'S/. ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'S/. ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return _penFormat.format(amount);
  }

  static String formatWeight(double weight, String unit) {
    final format = NumberFormat.decimalPattern('es_PE');
    return '${format.format(weight)} $unit';
  }
}
