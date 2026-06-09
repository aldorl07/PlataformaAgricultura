import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as bg;
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/product_card.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/market_ticker.dart';
import '../providers/catalog_provider.dart';
import '../../quote/providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();

  // Price Range slider local state
  double _minPrice = 0.5;
  double _maxPrice = 20.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final catalog = Provider.of<CatalogProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Filter drawer for mobile
    final drawer = Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Filtros Avanzados'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Crop Type Accordion
                  Text('Tipo de Cultivo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: catalog.selectedCropType,
                    items: ['todos', ...AppConstants.cropTypes].map((c) {
                      final name = c == 'todos' ? 'Todos los cultivos' : (AppConstants.cropNames[c] ?? c);
                      return DropdownMenuItem(value: c, child: Text(name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) catalog.setCropType(val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Community Filter
                  Text('Comunidad de Origen', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: catalog.selectedCommunity.isEmpty ? 'todos' : catalog.selectedCommunity,
                    items: [
                      const DropdownMenuItem(value: 'todos', child: Text('Todas las comunidades')),
                      ...AppConstants.communities.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        catalog.setCommunity(val == 'todos' ? '' : val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Price Range slider
                  Text('Rango de Precios (S/.)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0.5,
                    max: 20.0,
                    divisions: 39,
                    activeColor: AppColors.primaryDark,
                    labels: RangeLabels('S/. ${_minPrice.toStringAsFixed(1)}', 'S/. ${_maxPrice.toStringAsFixed(1)}'),
                    onChanged: (RangeValues vals) {
                      setState(() {
                        _minPrice = vals.start;
                        _maxPrice = vals.end;
                      });
                    },
                    onChangeEnd: (vals) {
                      catalog.setPriceRange(vals.start, vals.end);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Min: S/. ${_minPrice.toStringAsFixed(1)}'),
                      Text('Max: S/. ${_maxPrice.toStringAsFixed(1)}'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Min stock
                  Text('Volumen Disponible Mínimo', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Slider(
                    value: catalog.minStock.clamp(0.0, 500.0),
                    min: 0,
                    max: 500,
                    divisions: 10,
                    activeColor: AppColors.primaryDark,
                    label: '${catalog.minStock.toInt()} unidades',
                    onChanged: (val) {
                      catalog.setMinStock(val);
                    },
                  ),
                  Text('${catalog.minStock.toInt()} unidades disponibles mínimo'),
                  const SizedBox(height: 24),

                  // Only verified toggle
                  SwitchListTile(
                    title: const Text('Solo Productores Verificados'),
                    subtitle: const Text('Muestra agricultores validados por UNCP'),
                    value: catalog.onlyVerified,
                    activeThumbColor: AppColors.primaryDark,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      catalog.setOnlyVerified(val);
                    },
                  ),
                  const SizedBox(height: 32),

                  // Reset button
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _minPrice = 0.5;
                        _maxPrice = 20.0;
                      });
                      catalog.clearFilters();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Limpiar Filtros'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );

    // Ticker items
    final tickerItems = [
      const MarketTickerItem(cropName: 'Papa Yungay', wholesalePrice: 1.80, platformPrice: 1.35, savingPercent: 25),
      const MarketTickerItem(cropName: 'Maíz Choclo', wholesalePrice: 2.50, platformPrice: 1.90, savingPercent: 24),
      const MarketTickerItem(cropName: 'Cebada Grano', wholesalePrice: 2.00, platformPrice: 1.50, savingPercent: 25),
      const MarketTickerItem(cropName: 'Habas Verdes', wholesalePrice: 3.20, platformPrice: 2.40, savingPercent: 25),
      const MarketTickerItem(cropName: 'Zanahoria', wholesalePrice: 1.60, platformPrice: 1.20, savingPercent: 25),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Cultivos'),
        actions: [
          if (auth.isAuthenticated) ...[
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Mis Pedidos',
              onPressed: () => context.push('/buyer/orders'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar Sesión',
              onPressed: () async {
                await auth.signOut();
                if (mounted) context.go('/');
              },
            ),
          ] else ...[
            TextButton(
              onPressed: () => context.push('/login'),
              child: const Text('Iniciar Sesión', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
      drawer: drawer,
      body: Column(
        children: [
          // 1. Transparency Ticker
          MarketTicker(items: tickerItems),
          
          // 2. Search Bar + Filters Trigger Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => catalog.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Buscar papa, maíz, arveja...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                catalog.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Builder(
                  builder: (context) => InkWell(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Grid of Products
          Expanded(
            child: catalog.isLoading
                ? _buildSkeletonGrid()
                : catalog.products.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(catalog, cart),
          ),
        ],
      ),
      // Cart Floating Action Button
      floatingActionButton: cart.items.isNotEmpty
          ? bg.Badge(
              badgeContent: Text(
                cart.items.length.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              position: bg.BadgePosition.topEnd(top: -4, end: -4),
              child: FloatingActionButton(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                onPressed: () {
                  if (auth.isAuthenticated) {
                    context.push('/buyer/simulator');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, inicie sesión para ver su cotización')),
                    );
                    context.push('/login');
                  }
                },
                child: const Icon(Icons.calculate_outlined),
              ),
            )
          : null,
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => SkeletonLoader.productCard(context: context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No se encontraron cultivos frescos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pruebe modificando los filtros o el término de búsqueda', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(CatalogProvider catalog, CartProvider cart) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: catalog.products.length,
      itemBuilder: (context, index) {
        final product = catalog.products[index];
        final farmer = catalog.getFarmerForProduct(product.farmerId);
        final farmerName = farmer?.fullName ?? 'Productor Local';
        final community = farmer?.farmerProfile?.community ?? 'Chupaca';
        final isVerified = farmer?.farmerProfile?.isVerified ?? false;

        return ProductCard(
          product: product,
          farmerName: farmerName,
          farmerCommunity: community,
          isFarmerVerified: isVerified,
          onTap: () => context.push('/catalog/${product.id}'),
          onAddToCart: () {
            cart.addToCart(product, farmerName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} agregado a la cotización'),
                duration: const Duration(seconds: 1),
                action: SnackBarAction(
                  label: 'Ver',
                  textColor: Colors.white,
                  onPressed: () {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    if (auth.isAuthenticated) {
                      context.push('/buyer/simulator');
                    } else {
                      context.push('/login');
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
