/// App-wide constants for "Chupaca Directo"
class AppConstants {
  AppConstants._();

  static const String appName = 'Chupaca Directo';
  static const String appTagline = 'Del campo a tu mesa, sin intermediarios';
  static const String researchProject = 'Proyecto de Investigación UNCP 2026';

  /// 9 Distritos de la Provincia de Chupaca
  static const List<String> chupacaDistricts = [
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

  /// Tipos de cultivos
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

  static const Map<String, String> cropTypeLabels = {
    'papa': 'Papa',
    'maiz': 'Maíz',
    'cebada': 'Cebada',
    'habas': 'Habas',
    'hortalizas': 'Hortalizas',
    'quinua': 'Quinua',
    'arveja': 'Arveja',
    'otros': 'Otros',
  };

  static const Map<String, String> cropTypeEmojis = {
    'papa': '🥔',
    'maiz': '🌽',
    'cebada': '🌾',
    'habas': '🫘',
    'hortalizas': '🥬',
    'quinua': '🌿',
    'arveja': '🟢',
    'otros': '🌱',
  };

  /// Unidades de medida
  static const List<String> units = ['kg', 'arroba', 'saco', 'tonelada'];
  static const Map<String, String> unitLabels = {
    'kg': 'Kilogramo (kg)',
    'arroba': 'Arroba',
    'saco': 'Saco',
    'tonelada': 'Tonelada',
  };

  /// Tipos de negocio (compradores)
  static const List<Map<String, String>> businessTypes = [
    {'value': 'wholesale_market', 'label': 'Mercado Mayorista'},
    {'value': 'restaurant', 'label': 'Restaurante'},
    {'value': 'exporter', 'label': 'Exportador'},
    {'value': 'retail', 'label': 'Tienda Minorista'},
    {'value': 'other', 'label': 'Otro'},
  ];

  /// Métodos de contacto
  static const List<Map<String, String>> contactMethods = [
    {'value': 'whatsapp', 'label': 'WhatsApp'},
    {'value': 'call', 'label': 'Llamada telefónica'},
    {'value': 'email', 'label': 'Correo electrónico'},
  ];

  /// Order statuses
  static const Map<String, String> orderStatusLabels = {
    'pending': 'Pendiente',
    'approved': 'Aprobado',
    'dispatched': 'Despachado',
    'completed': 'Completado',
    'cancelled': 'Cancelado',
  };

  /// Platform fee percentage
  static const double platformFeePercent = 0.02; // 2%

  /// Stock thresholds (kg)
  static const double stockHighThreshold = 100;
  static const double stockMediumThreshold = 20;

  /// Trust stats for landing page
  static const List<Map<String, String>> trustStats = [
    {'value': '30+', 'label': 'Productores Verificados'},
    {'value': '9', 'label': 'Distritos de Chupaca'},
    {'value': '25%', 'label': 'Ahorro vs. Intermediarios'},
  ];

  /// How it works steps
  static const List<Map<String, String>> howItWorksSteps = [
    {
      'number': '1',
      'icon': '📤',
      'title': 'El productor publica su cosecha',
      'desc': 'Con fotos y precios justos directamente desde su parcela.',
    },
    {
      'number': '2',
      'icon': '🔍',
      'title': 'El comprador busca y filtra',
      'desc': 'Por cultivo, comunidad y precio. Simula costos en tiempo real.',
    },
    {
      'number': '3',
      'icon': '🤝',
      'title': 'Compra directa, sin intermediarios',
      'desc': 'Más ganancia para el agricultor, menos costo para el comprador.',
    },
  ];

  /// Reference market prices (seed data)
  static const List<Map<String, dynamic>> seedMarketPrices = [
    {'cropType': 'papa', 'cropName': 'Papa Blanca', 'pricePerKg': 1.80, 'market': 'Mercado Mayorista Huancayo'},
    {'cropType': 'maiz', 'cropName': 'Maíz Amarillo', 'pricePerKg': 1.50, 'market': 'Mercado Mayorista Huancayo'},
    {'cropType': 'cebada', 'cropName': 'Cebada', 'pricePerKg': 1.20, 'market': 'Mercado Mayorista Huancayo'},
    {'cropType': 'habas', 'cropName': 'Habas Verdes', 'pricePerKg': 2.40, 'market': 'Mercado Mayorista Huancayo'},
    {'cropType': 'hortalizas', 'cropName': 'Hortalizas Mixtas', 'pricePerKg': 1.60, 'market': 'Mercado Mayorista Huancayo'},
  ];

  /// Chupaca platform prices (lower)
  static const List<Map<String, dynamic>> platformPrices = [
    {'cropType': 'papa', 'cropName': 'Papa Blanca', 'pricePerKg': 1.35},
    {'cropType': 'maiz', 'cropName': 'Maíz Amarillo', 'pricePerKg': 1.15},
    {'cropType': 'cebada', 'cropName': 'Cebada', 'pricePerKg': 0.95},
    {'cropType': 'habas', 'cropName': 'Habas Verdes', 'pricePerKg': 1.90},
    {'cropType': 'hortalizas', 'cropName': 'Hortalizas Mixtas', 'pricePerKg': 1.25},
  ];
}
