class AppConstants {
  static const String appName = 'Chupaca Directo';
  static const String appTagline = 'Del campo a tu mesa, sin intermediarios';

  // Chupaca Communities / Districts
  static const List<String> communities = [
    'Chupaca',
    'Tres de Diciembre',
    'Ahuac',
    'Chongos Bajo',
    'Huachac',
    'Huamancaca Chico',
    'San Juan de Iscos',
    'Yanacancha',
    'San Juan de Jarpa',
  ];

  // Crop Categories
  static const List<String> cropTypes = [
    'papa',
    'maiz',
    'cebada',
    'habas',
    'hortalizas',
    'quinua',
    'arveja',
    'otros',
  ];

  // Map representation of Crop readable names
  static const Map<String, String> cropNames = {
    'papa': 'Papa',
    'maiz': 'Maíz',
    'cebada': 'Cebada',
    'habas': 'Habas',
    'hortalizas': 'Hortalizas',
    'quinua': 'Quinua',
    'arveja': 'Arveja',
    'otros': 'Otros',
  };

  // Units of measurement
  static const List<String> units = [
    'kg',
    'arroba',
    'saco',
    'tonelada',
  ];

  // Roles
  static const String roleFarmer = 'farmer';
  static const String roleBuyer = 'buyer';
  static const String roleAdmin = 'admin';

  // Buyer Business Types
  static const List<String> businessTypes = [
    'wholesale_market',
    'restaurant',
    'exporter',
    'retail',
    'other',
  ];

  static const Map<String, String> businessTypeNames = {
    'wholesale_market': 'Mercado Mayorista',
    'restaurant': 'Restaurante',
    'exporter': 'Exportador',
    'retail': 'Comercio Minorista',
    'other': 'Otro',
  };

  // Preferred Contact
  static const List<String> contactMethods = [
    'whatsapp',
    'call',
    'email',
  ];
}

class FirebaseConstants {
  static const String users = 'users';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String salesLogs = 'sales_logs';
  static const String marketPrices = 'market_prices';
  static const String telemetryEvents = 'telemetry_events';
}
