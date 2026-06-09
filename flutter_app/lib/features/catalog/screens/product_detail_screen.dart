import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/catalog_provider.dart';
import '../../quote/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _quantity = 10.0; // default quantity for quote (e.g. 10 kg)

  void _increment() {
    setState(() {
      _quantity += 10.0;
    });
  }

  void _decrement() {
    if (_quantity > 10.0) {
      setState(() {
        _quantity -= 10.0;
      });
    }
  }

  void _openWhatsApp(String phone, String productName) async {
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('+', '');
    final message = Uri.encodeComponent(
      'Hola, vi tu publicación de "$productName" en la plataforma Chupaca Directo y me gustaría consultar sobre una compra.'
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final catalog = Provider.of<CatalogProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    final product = catalog.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => throw Exception('Producto no encontrado'),
    );

    final farmer = catalog.getFarmerForProduct(product.farmerId);
    final farmerName = farmer?.fullName ?? 'Productor Local';
    final community = farmer?.farmerProfile?.community ?? 'Chupaca';
    final experience = farmer?.farmerProfile?.experienceYears ?? 0;
    final isVerified = farmer?.farmerProfile?.isVerified ?? false;
    final contactPhone = farmer?.phone ?? '';

    final lineTotal = product.pricePerUnit * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: product.photos.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.photos.first,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? const Color(0xFF333333) : Colors.grey[200],
                        child: Icon(Icons.eco_outlined, size: 64, color: AppColors.primaryLight.withValues(alpha: 0.5)),
                      ),
                    )
                  : Container(
                      color: isDark ? const Color(0xFF333333) : Colors.grey[200],
                      child: Icon(Icons.eco_outlined, size: 64, color: AppColors.primaryLight.withValues(alpha: 0.5)),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.cropType.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.variety,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Product Name
                  Text(
                    product.name,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Price per unit
                  Text(
                    '${CurrencyFormatter.format(product.pricePerUnit)} / ${product.unit}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Stock
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Stock disponible: ${product.stock.toInt()} ${product.unit}',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Descripción',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Farmer Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, color: AppColors.primaryDark),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    farmerName,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: AppColors.primaryLight, size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Comunidad: $community'),
                              Text('Experiencia: $experience años'),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.phone_android, size: 16),
                                label: const Text('Contactar por WhatsApp'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () => _openWhatsApp(contactPhone, product.name),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Quantity Selector Section
                  Text(
                    'Cantidad a cotizar',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _decrement,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '${_quantity.toInt()} ${product.unit}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _quantity < product.stock ? _increment : null,
                            ),
                          ],
                        ),
                      ),
                      
                      // Line total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Total Estimado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            CurrencyFormatter.format(lineTotal),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA Add Button
                  ElevatedButton(
                    onPressed: product.stock > 0
                        ? () {
                            cart.addToCart(product, farmerName, quantity: _quantity);
                            Navigator.of(context).pop(true);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: Text(product.stock > 0 ? 'Agregar a mi Cotización' : 'Agotado'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
