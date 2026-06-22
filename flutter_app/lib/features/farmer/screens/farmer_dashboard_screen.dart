import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/farmer_provider.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        Provider.of<FarmerProvider>(context, listen: false)
            .loadFarmerData(auth.currentUser!.id);
      }
    });
  }

  void _showQuickStockUpdate(BuildContext context, String productId,
      double currentStock, FarmerProvider farmerProvider) {
    final controller =
        TextEditingController(text: currentStock.toInt().toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar Stock Rápido'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nuevo Stock disponible',
              suffixText: 'unidades',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newStock = double.tryParse(controller.text);
                if (newStock != null && newStock >= 0) {
                  await farmerProvider.quickUpdateStock(productId, newStock);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final auth = Provider.of<AuthProvider>(context);
    final farmer = Provider.of<FarmerProvider>(context);

    // Filter farmer orders for display
    final pendingOrders =
        farmer.myOrders.where((o) => o.status == 'pending').toList();
    final otherOrders =
        farmer.myOrders.where((o) => o.status != 'pending').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Productor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => farmer.loadFarmerData(auth.currentUser!.id),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final router = GoRouter.of(context);
              ScaffoldMessenger.of(context).clearSnackBars();
              await auth.signOut();
              router.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Side Navigation Rail for tablets/desktop
            if (MediaQuery.of(context).size.width > 700)
              NavigationRail(
                selectedIndex: _currentNavIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentNavIndex = index;
                  });
                  if (index == 1) {
                    context.push('/farmer/products');
                  }
                },
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.eco_outlined),
                    selectedIcon: Icon(Icons.eco),
                    label: Text('Mis Cultivos'),
                  ),
                ],
              ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Title
                    Text(
                      '¡Hola, ${auth.currentUser?.fullName.split(' ').first}! 🌿',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Comunidad: ${auth.currentUser?.farmerProfile?.community ?? "Chupaca"}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // 1. KPI Cards Row
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: MediaQuery.of(context).size.width > 600
                          ? 1.4
                          : (MediaQuery.of(context).size.width > 350 ? 1.15 : 0.95),
                      children: [
                        KpiCard(
                          title: 'Ventas del Mes',
                          value: CurrencyFormatter.formatShort(
                              farmer.monthlyRevenue),
                          trendPercentage: 12.5,
                          icon: Icons.monetization_on_outlined,
                          sparklineData: const [
                            400,
                            600,
                            800,
                            1200,
                            1500,
                            1800
                          ],
                        ),
                        KpiCard(
                          title: 'Pedidos Pendientes',
                          value: farmer.pendingOrdersCount.toString(),
                          icon: Icons.shopping_bag_outlined,
                          iconColor: AppColors.warning,
                        ),
                        KpiCard(
                          title: 'Productos Activos',
                          value: farmer.myProducts.length.toString(),
                          icon: Icons.eco_outlined,
                          iconColor: AppColors.primaryLight,
                        ),
                        KpiCard(
                          title: 'Margen Neto Prom.',
                          value: '${farmer.averageNetMargin.toInt()}%',
                          trendPercentage: 23.0,
                          icon: Icons.trending_up,
                          iconColor: AppColors.primaryLight,
                          sparklineData: const [15, 18, 25, 32, 35, 38],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 2. Low Stock Alerts (Variable RF-05)
                    if (farmer.stockAlerts.isNotEmpty) ...[
                      Text(
                        '⚠️ Alertas de Inventario Crítico',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: farmer.stockAlerts.length,
                        itemBuilder: (context, index) {
                          final item = farmer.stockAlerts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isDark
                                ? const Color(0xFF3E1F1F)
                                : const Color(0xFFFFEBEE),
                            child: ListTile(
                              leading: const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.error),
                              title: Text(
                                item.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error),
                              ),
                              subtitle: Text(
                                  'Stock actual: ${item.stock.toInt()} ${item.unit}'),
                              trailing: TextButton.icon(
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Actualizar'),
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error),
                                onPressed: () => _showQuickStockUpdate(
                                    context, item.id, item.stock, farmer),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    // 3. Line Chart (Pre vs Post Platform Profitability comparison - Y3)
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Historial de Ingresos Mensuales (S/.)',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle,
                                        color: Colors.grey, size: 14),
                                    SizedBox(width: 4),
                                    Text('Pre-Plataforma (Intermediarios)',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.circle,
                                        color: AppColors.primaryLight, size: 14),
                                    SizedBox(width: 4),
                                    Text('Con Plataforma (Venta Directa)',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primaryLight)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            AspectRatio(
                              aspectRatio:
                                  MediaQuery.of(context).size.width > 600
                                      ? 3
                                      : 1.7,
                              child: LineChart(
                                LineChartData(
                                  gridData: const FlGridData(
                                      show: true, drawVerticalLine: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: const FlTitlesData(
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  lineBarsData: [
                                    // Historical baseline (Pre-platform intermediation)
                                    LineChartBarData(
                                      spots: const [
                                        FlSpot(0, 1200),
                                        FlSpot(1, 1250),
                                        FlSpot(2, 1180),
                                        FlSpot(3, 1200),
                                        FlSpot(4, 1220),
                                        FlSpot(5, 1200),
                                      ],
                                      isCurved: false,
                                      color: Colors.grey,
                                      dashArray: [5, 5],
                                      barWidth: 2,
                                      dotData: const FlDotData(show: true),
                                    ),
                                    // Post-platform directly to buyers
                                    LineChartBarData(
                                      spots: const [
                                        FlSpot(0, 1200),
                                        FlSpot(1, 1500),
                                        FlSpot(2, 1800),
                                        FlSpot(3, 2400),
                                        FlSpot(4, 3200),
                                        FlSpot(5, 3850),
                                      ],
                                      isCurved: true,
                                      color: AppColors.primaryLight,
                                      barWidth: 4,
                                      dotData: const FlDotData(show: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. Pending Orders Section (Variable RF-09)
                    Text(
                      'Pedidos Pendientes de Confirmación',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    pendingOrders.isEmpty
                        ? const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                  child: Text(
                                      'No tienes pedidos pendientes de aprobación.')),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingOrders.length,
                            itemBuilder: (context, index) {
                              final order = pendingOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pedido #${order.id.substring(0, 8)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          StatusBadge(status: order.status),
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      ...order.items.map((item) => Text(
                                            '• ${item.quantity.toInt()} ${item.unit} de ${item.productName}',
                                            style:
                                                const TextStyle(fontSize: 13),
                                          )),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Monto Total del Pedido: S/. ${order.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppButton(
                                              text: 'Rechazar',
                                              isOutlined: true,
                                              foregroundColor: Colors.grey,
                                              height: 36,
                                              onPressed: () =>
                                                  farmer.updateStatus(
                                                      order.id,
                                                      'cancelled',
                                                      auth.currentUser!.id),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: AppButton(
                                              text: '✓ Aprobar',
                                              backgroundColor:
                                                  AppColors.primaryLight,
                                              height: 36,
                                              onPressed: () =>
                                                  farmer.updateStatus(
                                                      order.id,
                                                      'approved',
                                                      auth.currentUser!.id),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 32),

                    // 5. Historial Orders List
                    Text(
                      'Historial de Despachos',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    otherOrders.isEmpty
                        ? const Center(
                            child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child:
                                Text('No hay registros de despachos previos.'),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: otherOrders.length,
                            itemBuilder: (context, index) {
                              final order = otherOrders[index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                      'Pedido #${order.id.substring(0, 8)}'),
                                  subtitle: Text(
                                      'Total: S/. ${order.totalAmount.toStringAsFixed(2)}'),
                                  trailing: StatusBadge(status: order.status),
                                  onTap: () {
                                    if (order.status == 'approved') {
                                      // Allow Marking as Dispatched
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Coordinar Envío'),
                                          content: const Text(
                                              '¿Desea marcar este pedido como despachado hacia el destino de entrega?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('No'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await farmer.updateStatus(
                                                    order.id,
                                                    'dispatched',
                                                    auth.currentUser!.id);
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child:
                                                  const Text('Sí, Despachar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar for mobile layout
      bottomNavigationBar: MediaQuery.of(context).size.width <= 700
          ? BottomNavigationBar(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
                if (index == 1) {
                  context.push('/farmer/products');
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.eco_outlined),
                  activeIcon: Icon(Icons.eco),
                  label: 'Cultivos',
                ),
              ],
            )
          : null,
    );
  }
}
