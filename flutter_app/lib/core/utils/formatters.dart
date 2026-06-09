import 'package:intl/intl.dart';

/// Formatting utilities
class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/. ',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrency = NumberFormat.currency(
    locale: 'es_PE',
    symbol: 'S/.',
    decimalDigits: 0,
  );

  static final DateFormat _dateShort = DateFormat('dd/MM/yyyy', 'es_PE');
  static final DateFormat _dateLong = DateFormat('d MMMM yyyy', 'es_PE');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'es_PE');

  /// Format as Peruvian Sol currency: S/. 1,350.00
  static String currency(double amount) => _currency.format(amount);

  /// Compact currency without decimals: S/. 1350
  static String currencyCompact(double amount) =>
      _compactCurrency.format(amount);

  /// Format weight: 500 kg / 1.2 t
  static String weight(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(2)} t';
    }
    return '${kg.toStringAsFixed(0)} kg';
  }

  /// Format percentage: 25.3%
  static String percent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Format percentage as savings label
  static String savings(double percent) {
    return '▼ ${percent.toStringAsFixed(1)}% ahorro';
  }

  /// Short date: 04/06/2026
  static String dateShort(DateTime date) => _dateShort.format(date);

  /// Long date: 4 junio 2026
  static String dateLong(DateTime date) => _dateLong.format(date);

  /// Date + time: 04/06/2026 16:30
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// Format stock badge label
  static String stockLabel(double stock, String unit) {
    return '📦 ${stock.toStringAsFixed(0)} $unit disponibles';
  }

  /// Format price per unit
  static String pricePerUnit(double price, String unit) {
    return '${_currency.format(price)} / $unit';
  }

  /// Calculate savings vs market price
  static double savingsPercent(double marketPrice, double platformPrice) {
    if (marketPrice == 0) return 0;
    return ((marketPrice - platformPrice) / marketPrice) * 100;
  }
}

/// Validation utilities
class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El correo es requerido';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Ingresa un correo válido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es requerido';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 9) return 'Número de teléfono inválido';
    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    final num = double.tryParse(value);
    if (num == null) return 'Ingresa un número válido';
    if (num < 0) return 'El valor debe ser positivo';
    return null;
  }

  static String? dni(String? value) {
    if (value == null || value.isEmpty) return 'El DNI es requerido';
    if (value.length != 8) return 'El DNI debe tener 8 dígitos';
    if (!RegExp(r'^\d{8}$').hasMatch(value)) return 'DNI inválido';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }
}
