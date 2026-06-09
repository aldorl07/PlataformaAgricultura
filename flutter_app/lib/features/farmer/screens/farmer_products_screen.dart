import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/farmer_provider.dart';
import '../../catalog/models/product_model.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});

  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        Provider.of<FarmerProvider>(context, listen: false).loadFarmerData(auth.currentUser!.id);
      }
    });
  }

  void _showAddEditProductModal(BuildContext context, {ProductModel? existingProduct}) {
    final isEditing = existingProduct != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final varietyController = TextEditingController(text: existingProduct?.variety ?? '');
    final descriptionController = TextEditingController(text: existingProduct?.description ?? '');
    final priceController = TextEditingController(text: existingProduct?.pricePerUnit.toString() ?? '');
    final stockController = TextEditingController(text: existingProduct?.stock.toInt().toString() ?? '');
    
    String selectedCropType = existingProduct?.cropType ?? AppConstants.cropTypes.first;
    String selectedUnit = existingProduct?.unit ?? AppConstants.units.first;
    DateTime selectedHarvestDate = existingProduct?.harvestDate ?? DateTime.now();

    final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'Editar Cultivo Cosechado' : 'Publicar Nuevo Cultivo 🌾',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      label: 'Nombre del Producto',
                      placeholder: 'Ej. Papa Yungay Orgánica de Altura',
                      controller: nameController,
                      validator: (val) => Validators.validateNotEmpty(val, 'El nombre'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipo de Cultivo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCropType,
                                items: AppConstants.cropTypes.map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(AppConstants.cropNames[c] ?? c),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedCropType = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Variedad',
                            placeholder: 'Ej. Yungay / Amarilla',
                            controller: varietyController,
                            validator: (val) => Validators.validateNotEmpty(val, 'La variedad'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Descripción del Cultivo',
                      placeholder: 'Explica las características de tu parcela o método de cosecha...',
                      controller: descriptionController,
                      maxLines: 3,
                      validator: (val) => Validators.validateNotEmpty(val, 'La descripción'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Precio Unitario (S/.)',
                            placeholder: 'Ej. 1.50',
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: Validators.validatePrice,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Unidad de Medida', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedUnit,
                                items: AppConstants.units.map((u) {
                                  return DropdownMenuItem(value: u, child: Text(u));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedUnit = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Stock Disponible Inicial',
                      placeholder: 'Ej. 500',
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      validator: Validators.validateStock,
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: isEditing ? 'Guardar Cambios' : 'Publicar en Catálogo',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final product = ProductModel(
                            id: isEditing ? existingProduct.id : 'prod_${DateTime.now().millisecondsSinceEpoch}',
                            farmerId: authProvider.currentUser!.id,
                            name: nameController.text.trim(),
                            cropType: selectedCropType,
                            variety: varietyController.text.trim(),
                            description: descriptionController.text.trim(),
                            unit: selectedUnit,
                            pricePerUnit: double.parse(priceController.text),
                            stock: double.parse(stockController.text),
                            photos: isEditing ? existingProduct.photos : [],
                            harvestDate: selectedHarvestDate,
                            isActive: true,
                            createdAt: isEditing ? existingProduct.createdAt : DateTime.now(),
                          );

                          bool success;
                          if (isEditing) {
                            success = await farmerProvider.updateProduct(product);
                          } else {
                            success = await farmerProvider.addProduct(product);
                          }

                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEditing ? 'Cultivo actualizado' : 'Cultivo publicado exitosamente'),
                                backgroundColor: AppColors.primaryLight,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String productId, FarmerProvider farmerProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Cultivo'),
          content: const Text('¿Está seguro de que desea retirar este producto del catálogo? (Se realizará un borrado lógico)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              onPressed: () async {
                await farmerProvider.softDeleteProduct(productId);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Eliminar'),
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
    
    final farmer = Provider.of<FarmerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cultivos cosechados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryDark),
            tooltip: 'Agregar Cultivo',
            onPressed: () => _showAddEditProductModal(context),
          ),
        ],
      ),
      body: farmer.myProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Aún no has publicado cultivos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Presiona el botón "+" para publicar tu primera cosecha', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: farmer.myProducts.length,
              itemBuilder: (context, index) {
                final product = farmer.myProducts[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                      child: const Icon(Icons.eco, color: AppColors.primaryDark),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Variedad: ${product.variety} | Cultivo: ${AppConstants.cropNames[product.cropType] ?? product.cropType}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Precio: ${CurrencyFormatter.format(product.pricePerUnit)} / ${product.unit}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Stock: ${product.stock.toInt()} ${product.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: product.stock < 30 ? AppColors.error : AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                          tooltip: 'Editar',
                          onPressed: () => _showAddEditProductModal(context, existingProduct: product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          tooltip: 'Eliminar',
                          onPressed: () => _showDeleteConfirmation(context, product.id, farmer),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
