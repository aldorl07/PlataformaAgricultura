import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/camera_helper.dart';
import '../../../services/service_locator.dart';
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
        Provider.of<FarmerProvider>(context, listen: false)
            .loadFarmerData(auth.currentUser!.id);
      }
    });
  }

  void _showAddEditProductModal(BuildContext context,
      {ProductModel? existingProduct}) {
    final isEditing = existingProduct != null;
    final formKey = GlobalKey<FormState>();
    final nameController =
        TextEditingController(text: existingProduct?.name ?? '');
    final varietyController =
        TextEditingController(text: existingProduct?.variety ?? '');
    final descriptionController =
        TextEditingController(text: existingProduct?.description ?? '');
    final priceController = TextEditingController(
        text: existingProduct?.pricePerUnit.toString() ?? '');
    final stockController = TextEditingController(
        text: existingProduct?.stock.toInt().toString() ?? '');

    String selectedCropType =
        existingProduct?.cropType ?? AppConstants.cropTypes.first;
    String selectedUnit = existingProduct?.unit ?? AppConstants.units.first;
    DateTime selectedHarvestDate =
        existingProduct?.harvestDate ?? DateTime.now();

    final farmerProvider = Provider.of<FarmerProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Local state variables for image picker
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    List<String> currentPhotos = isEditing ? List.from(existingProduct.photos) : [];
    bool isUploading = false;

    Future<void> pickImage(ImageSource source, StateSetter setModalState) async {
      try {
        if (kIsWeb && source == ImageSource.camera) {
          final webImage = await captureWebImage(context);
          if (webImage != null) {
            setModalState(() {
              selectedImageBytes = webImage['bytes'] as Uint8List;
              selectedImageName = webImage['name'] as String;
            });
          }
          return;
        }

        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          setModalState(() {
            selectedImageBytes = bytes;
            selectedImageName = pickedFile.name;
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al seleccionar imagen: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    void showImageSourceSheet(StateSetter setModalState) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: AppColors.primaryDark),
                  title: const Text('Galería'),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImage(ImageSource.gallery, setModalState);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: AppColors.primaryDark),
                  title: const Text('Cámara'),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickImage(ImageSource.camera, setModalState);
                  },
                ),
              ],
            ),
          );
        },
      );
    }

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
                      isEditing
                          ? 'Editar Cultivo Cosechado'
                          : 'Publicar Nuevo Cultivo 🌾',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Nombre del Producto',
                      placeholder: 'Ej. Papa Yungay Orgánica de Altura',
                      controller: nameController,
                      validator: (val) =>
                          Validators.validateNotEmpty(val, 'El nombre'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipo de Cultivo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
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
                                  if (val != null) {
                                    setModalState(() => selectedCropType = val);
                                  }
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
                            validator: (val) =>
                                Validators.validateNotEmpty(val, 'La variedad'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Descripción del Cultivo',
                      placeholder:
                          'Explica las características de tu parcela o método de cosecha...',
                      controller: descriptionController,
                      maxLines: 3,
                      validator: (val) =>
                          Validators.validateNotEmpty(val, 'La descripción'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Precio Unitario (S/.)',
                            placeholder: 'Ej. 1.50',
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: Validators.validatePrice,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Unidad de Medida',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedUnit,
                                items: AppConstants.units.map((u) {
                                  return DropdownMenuItem(
                                      value: u, child: Text(u));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => selectedUnit = val);
                                  }
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
                    const SizedBox(height: 16),
                    const Text(
                      'Foto del Cultivo (Recomendado)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedImageBytes != null || currentPhotos.isNotEmpty)
                      Stack(
                        children: [
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: selectedImageBytes != null
                                  ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
                                  : Image.network(currentPhotos.first, fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                                onPressed: () {
                                  setModalState(() {
                                    selectedImageBytes = null;
                                    selectedImageName = null;
                                    currentPhotos.clear();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      InkWell(
                        onTap: () => showImageSourceSheet(setModalState),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primaryDark.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primaryDark.withValues(alpha: 0.05),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: AppColors.primaryDark),
                              SizedBox(height: 8),
                              Text(
                                'Añadir Foto del Cultivo',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: isEditing
                          ? 'Guardar Cambios'
                          : 'Publicar en Catálogo',
                      isLoading: isUploading,
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          setModalState(() {
                            isUploading = true;
                          });

                          try {
                            List<String> photos = List.from(currentPhotos);

                            if (selectedImageBytes != null && selectedImageName != null) {
                              final imageUrl = await ServiceLocator.storageService.uploadProductPhoto(
                                selectedImageName!,
                                selectedImageBytes!,
                              ).timeout(
                                const Duration(seconds: 12),
                                onTimeout: () {
                                  throw TimeoutException(
                                    'La subida de la imagen expiró. Esto ocurre en Web si no se ha configurado CORS en Firebase Storage para permitir solicitudes desde localhost.'
                                  );
                                },
                              );
                              photos = [imageUrl];
                            }

                            final product = ProductModel(
                              id: isEditing
                                  ? existingProduct.id
                                  : 'prod_${DateTime.now().millisecondsSinceEpoch}',
                              farmerId: authProvider.currentUser!.id,
                              name: nameController.text.trim(),
                              cropType: selectedCropType,
                              variety: varietyController.text.trim(),
                              description: descriptionController.text.trim(),
                              unit: selectedUnit,
                              pricePerUnit: double.parse(priceController.text),
                              stock: double.parse(stockController.text),
                              photos: photos,
                              harvestDate: selectedHarvestDate,
                              isActive: true,
                              createdAt: isEditing
                                  ? existingProduct.createdAt
                                  : DateTime.now(),
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
                                  content: Text(isEditing
                                      ? 'Cultivo actualizado'
                                      : 'Cultivo publicado exitosamente'),
                                  backgroundColor: AppColors.primaryLight,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al guardar: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } finally {
                            setModalState(() {
                              isUploading = false;
                            });
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

  void _showDeleteConfirmation(
      BuildContext context, String productId, FarmerProvider farmerProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar Cultivo'),
          content: const Text(
              '¿Está seguro de que desea retirar este producto del catálogo? (Se realizará un borrado lógico)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white),
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
                  const Text('Aún no has publicado cultivos',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Presiona el botón "+" para publicar tu primera cosecha',
                      style: TextStyle(color: Colors.grey)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
                      child:
                          const Icon(Icons.eco, color: AppColors.primaryDark),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Variedad: ${product.variety} | Cultivo: ${AppConstants.cropNames[product.cropType] ?? product.cropType}'),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Precio: ${CurrencyFormatter.format(product.pricePerUnit)} / ${product.unit}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Stock: ${product.stock.toInt()} ${product.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: product.stock < 30
                                    ? AppColors.error
                                    : AppColors.primaryDark,
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
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.info),
                          tooltip: 'Editar',
                          onPressed: () => _showAddEditProductModal(context,
                              existingProduct: product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          tooltip: 'Eliminar',
                          onPressed: () => _showDeleteConfirmation(
                              context, product.id, farmer),
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
