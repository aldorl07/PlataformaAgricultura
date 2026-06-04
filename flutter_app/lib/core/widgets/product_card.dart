import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/catalog/models/product_model.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final String farmerName;
  final String farmerCommunity;
  final bool isFarmerVerified;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.farmerName,
    required this.farmerCommunity,
    required this.isFarmerVerified,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Stock color calculation
    Color stockColor;
    if (widget.product.stock > 100) {
      stockColor = AppColors.primaryLight;
    } else if (widget.product.stock >= 20) {
      stockColor = AppColors.warning;
    } else {
      stockColor = AppColors.error;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -4, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.12 : 0.05),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary.withOpacity(0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Photo Section
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 10,
                      child: widget.product.photos.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.product.photos.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark ? const Color(0xFF3A3A3A) : Colors.grey[100],
                                child: Icon(
                                  Icons.eco_outlined,
                                  size: 48,
                                  color: AppColors.primaryLight.withOpacity(0.4),
                                ),
                              ),
                            )
                          : Container(
                              color: isDark ? const Color(0xFF3A3A3A) : Colors.grey[100],
                              child: Icon(
                                Icons.eco_outlined,
                                size: 48,
                                color: AppColors.primaryLight.withOpacity(0.4),
                              ),
                            ),
                    ),
                    // Badges overlay
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Row(
                        children: [
                          if (widget.isFarmerVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verificado',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (!widget.isFarmerVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Nuevo',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Text details
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.farmerName} · ${widget.farmerCommunity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : AppColors.neutralDark.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${CurrencyFormatter.format(widget.product.pricePerUnit)} / ${widget.product.unit}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: stockColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.product.stock.toInt()} ${widget.product.unit} disp.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: stockColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: widget.product.stock > 0 ? widget.onAddToCart : null,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            side: const BorderSide(color: AppColors.primaryDark),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.product.stock > 0 ? 'Agregar a Cotización' : 'Sin Stock',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
