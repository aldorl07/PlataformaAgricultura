import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../services/service_locator.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quote/models/order_model.dart';

class BuyerOrdersScreen extends StatefulWidget {
  const BuyerOrdersScreen({super.key});

  @override
  State<BuyerOrdersScreen> createState() => _BuyerOrdersScreenState();
}

class _BuyerOrdersScreenState extends State<BuyerOrdersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        final list = await ServiceLocator.firestoreService.getOrders(
          userId: auth.currentUser!.id,
          role: 'buyer',
        );
        setState(() {
          _orders = list;
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  void _confirmReceipt(String orderId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      await ServiceLocator.firestoreService.updateOrderStatus(orderId, 'completed', auth.currentUser!.id);
      await _loadOrders(); // reload
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recepción confirmada. Se ha registrado en la base de datos inmutable.'),
            backgroundColor: AppColors.primaryLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeOrders = _orders.where((o) => o.status != 'completed' && o.status != 'cancelled').toList();
    final pastOrders = _orders.where((o) => o.status == 'completed' || o.status == 'cancelled').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryDark,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryDark,
          tabs: const [
            Tab(text: 'Activos'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(activeOrders, isTabActive: true),
                _buildOrdersList(pastOrders, isTabActive: false),
              ],
            ),
    );
  }

  Widget _buildOrdersList(List<OrderModel> list, {required bool isTabActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isTabActive ? 'No tienes pedidos activos' : 'No tienes pedidos anteriores',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                StatusBadge(status: order.status),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}'),
                Text(
                  'Total: S/. ${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider(),
                    const Text('Detalle de Cultivos', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity.toInt()} ${item.unit} x ${item.productName}'),
                              Text(CurrencyFormatter.format(item.lineTotal)),
                            ],
                          ),
                        )),
                    const Divider(),
                    _buildDetailRow('Subtotal de Productos', CurrencyFormatter.format(order.subtotal)),
                    _buildDetailRow('Flete de Envío', CurrencyFormatter.format(order.shippingCost)),
                    _buildDetailRow('Comisión Plataforma (2%)', CurrencyFormatter.format(order.platformFee)),
                    const SizedBox(height: 8),
                    _buildDetailRow('Total Pagado', CurrencyFormatter.format(order.totalAmount), isBold: true),
                    
                    // Savings badge (Variable Y2)
                    if (order.estimatedSavings > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💰 ¡Ahorraste S/. ${order.estimatedSavings.toStringAsFixed(2)} vs intermediarios tradicionales!',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const Divider(),
                    
                    // Delivery Info
                    const Text('Datos de Entrega', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Dirección: ${order.deliveryAddress}'),
                    if (order.deliveryDate != null)
                      Text('Fecha programada: ${DateFormat('dd/MM/yyyy').format(order.deliveryDate!)}'),
                    if (order.buyerNotes.isNotEmpty)
                      Text('Notas: ${order.buyerNotes}'),
                    const SizedBox(height: 16),
                    
                    // Status Timeline Indicator
                    _buildStatusTimeline(order.status),
                    const SizedBox(height: 20),

                    // Delivery receipt confirmation button (triggers sales log creation Y1/Y3)
                    if (order.status == 'dispatched')
                      AppButton(
                        text: 'Confirmar Recepción de Cosecha',
                        backgroundColor: AppColors.primaryDark,
                        onPressed: () => _confirmReceipt(order.id),
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppColors.primaryDark : null)),
      ],
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = ['pending', 'approved', 'dispatched', 'completed'];
    final labels = ['Solicitado', 'Aprobado', 'Despachado', 'Entregado'];

    int currentIndex = statuses.indexOf(currentStatus.toLowerCase());
    if (currentStatus.toLowerCase() == 'cancelled') return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        final isActive = index <= currentIndex;
        final color = isActive ? AppColors.primaryDark : Colors.grey;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(
                      index < currentIndex
                          ? Icons.check
                          : (index == currentIndex ? Icons.radio_button_checked : Icons.radio_button_off),
                      size: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                ],
              ),
              if (index < 3)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentIndex ? AppColors.primaryDark : Colors.grey[300],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
