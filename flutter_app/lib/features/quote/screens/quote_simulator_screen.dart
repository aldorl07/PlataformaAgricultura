import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/cart_provider.dart';
import '../../auth/providers/auth_provider.dart';

class QuoteSimulatorScreen extends StatefulWidget {
  const QuoteSimulatorScreen({super.key});

  @override
  State<QuoteSimulatorScreen> createState() => _QuoteSimulatorScreenState();
}

class _QuoteSimulatorScreenState extends State<QuoteSimulatorScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    _addressController.text = cart.deliveryAddress;
    _notesController.text = cart.buyerNotes;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context, CartProvider cart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: cart.deliveryDate ?? DateTime.now().add(const Duration(days: 2)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      cart.setDeliveryDate(picked);
    }
  }

  void _submitOrder(CartProvider cart, AuthProvider auth) async {
    if (cart.items.isEmpty) return;
    
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese una dirección de entrega válida')),
      );
      return;
    }

    if (cart.deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una fecha de entrega deseada')),
      );
      return;
    }

    cart.setDeliveryAddress(_addressController.text);
    cart.setBuyerNotes(_notesController.text);

    final success = await cart.checkout(auth.currentUser?.id ?? 'buyer_anonymous');

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primaryLight, size: 28),
                SizedBox(width: 8),
                Text('Intención Formalizada', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Tu pedido ha sido enviado exitosamente. Los agricultores han recibido la reserva de stock y se contactarán contigo pronto para coordinar el despacho.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/catalog');
                },
                child: const Text('Volver al Catálogo'),
              ),
            ],
          );
        },
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cart.errorMessage ?? 'Ocurrió un conflicto al realizar el pedido (stock insuficiente)'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final traditionalCost = cart.subtotal + cart.estimatedSavings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Cotización'),
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step progress or title
                    Text(
                      'Simulador de Costos Chupaca Directo',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Products List Builder
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items.values.elementAt(index);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                                  child: const Icon(Icons.eco_outlined, color: AppColors.primaryDark),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Productor: ${item.farmerName}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'S/. ${item.product.pricePerUnit.toStringAsFixed(2)} / ${item.product.unit}',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline, size: 20),
                                          onPressed: () => cart.updateQuantity(item.product.id, item.quantity - 10),
                                        ),
                                        Text(
                                          '${item.quantity.toInt()}',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline, size: 20),
                                          onPressed: () => cart.updateQuantity(item.product.id, item.quantity + 10),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      CurrencyFormatter.format(item.lineTotal),
                                      style: TextStyle(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                  onPressed: () => cart.removeItem(item.product.id),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Flete/Shipping Simulator fields
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simulador de Envío (Flete)',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Dirección de entrega',
                              placeholder: 'Ej. Calle Real 450, Huancayo',
                              controller: _addressController,
                              prefixIcon: Icons.local_shipping_outlined,
                              onChanged: (val) => cart.setDeliveryAddress(val),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Método de Transporte',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            DropdownButtonFormField<String>(
                              value: cart.transportMethod,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                              items: const [
                                DropdownMenuItem(value: 'shared_freight', child: Text('Flete compartido (S/. 80.00)')),
                                DropdownMenuItem(value: 'own_truck', child: Text('Camión propio (S/. 0.00)')),
                                DropdownMenuItem(value: 'pickup', child: Text('Recojo en parcela (S/. 0.00)')),
                              ],
                              onChanged: (val) {
                                if (val != null) cart.setTransportMethod(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Savings Comparison Graph & Highlight Box (Variable Y2)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B3B20) : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.savings_outlined, color: AppColors.primaryDark),
                              const SizedBox(width: 8),
                              Text(
                                'Ahorro vs Intermediarios',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Al comprar directo a los productores de Chupaca estás ahorrando:',
                            style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'S/. ${cart.estimatedSavings.toStringAsFixed(2)} (≈ ${cart.savingsPercent.toStringAsFixed(1)}%)',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Custom Bar Chart comparing Traditional vs Platform costs
                          const Text('Comparativa de Costo Total (S/.)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          // Traditional Bar
                          Row(
                            children: [
                              const SizedBox(width: 80, child: Text('Tradicional:', style: TextStyle(fontSize: 11))),
                              Expanded(
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'S/. ${traditionalCost.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Platform Bar
                          Row(
                            children: [
                              const SizedBox(width: 80, child: Text('Chupaca D.:', style: TextStyle(fontSize: 11))),
                              Expanded(
                                flex: (cart.totalAmount / traditionalCost * 100).toInt(),
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    'S/. ${cart.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (100 - (cart.totalAmount / traditionalCost * 100)).toInt(),
                                child: const SizedBox(),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cost Breakdown & Summary Card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen de Costos',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow('Subtotal de Productos', CurrencyFormatter.format(cart.subtotal)),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Flete Estimado', CurrencyFormatter.format(cart.shippingCost)),
                            const SizedBox(height: 8),
                            _buildSummaryRow('Comisión de Plataforma (2%)', CurrencyFormatter.format(cart.platformFee)),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              'TOTAL ESTIMADO',
                              CurrencyFormatter.format(cart.totalAmount),
                              isTotal: true,
                            ),
                            const SizedBox(height: 24),
                            
                            // Delivery Date Picker
                            InkWell(
                              onTap: () => _selectDate(context, cart),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month, color: AppColors.primaryDark),
                                        const SizedBox(width: 8),
                                        Text(
                                          cart.deliveryDate != null
                                              ? 'Entrega: ${DateFormat('dd/MM/yyyy').format(cart.deliveryDate!)}'
                                              : 'Seleccionar fecha de entrega',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Notes
                            AppTextField(
                              label: 'Notas de entrega (Opcional)',
                              placeholder: 'Especificaciones sobre empaque o entrega',
                              controller: _notesController,
                              maxLines: 2,
                              onChanged: (val) => cart.setBuyerNotes(val),
                            ),
                            const SizedBox(height: 24),

                            AppButton(
                              text: 'Formalizar Intención de Compra',
                              isLoading: cart.isLoading,
                              onPressed: () => _submitOrder(cart, auth),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No hay productos en tu cotización', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Agrega cultivos desde el catálogo para simular tus costos', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/catalog'),
            child: const Text('Explorar Catálogo'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          val,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 14,
            color: isTotal ? AppColors.primaryDark : null,
          ),
        ),
      ],
    );
  }
}
