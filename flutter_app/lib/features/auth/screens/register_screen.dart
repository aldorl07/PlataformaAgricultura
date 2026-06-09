import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  final String? initialRole;
  const RegisterScreen({super.key, this.initialRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final PageController _pageController;
  late int _currentStep;

  // Page 1: Role Selection
  late String _selectedRole; // 'farmer' or 'buyer'

  // Page 2: Credentials Form
  final _formKey2 = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Page 3A: Farmer Details
  final _formKey3A = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  String _selectedCommunity = AppConstants.communities.first;
  final _experienceController = TextEditingController(text: '0');
  final List<String> _selectedCrops = [];
  String _preferredContact = 'whatsapp';
  bool _acceptTerms = false;

  // Page 3B: Buyer Details
  final _formKey3B = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _rucController = TextEditingController();
  String _selectedBusinessType = AppConstants.businessTypes.first;
  final _deliveryAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialRole == 'farmer' || widget.initialRole == 'buyer') {
      _selectedRole = widget.initialRole!;
      _currentStep = 1;
    } else {
      _selectedRole = 'farmer';
      _currentStep = 0;
    }
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dniController.dispose();
    _experienceController.dispose();
    _businessNameController.dispose();
    _rucController.dispose();
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep == 0) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (_currentStep == 1) {
      if (_formKey2.currentState!.validate()) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _submitRegistration() async {
    // Validate Page 3 forms
    if (_selectedRole == 'farmer') {
      if (!_formKey3A.currentState!.validate()) return;
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Debe aceptar los términos de investigación')),
        );
        return;
      }
    } else {
      if (!_formKey3B.currentState!.validate()) return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final farmerProfile = _selectedRole == 'farmer'
        ? FarmerProfile(
            dni: _dniController.text.trim(),
            community: _selectedCommunity,
            latitude: -12.06, // Default Chupaca centre coordinates
            longitude: -75.28,
            experienceYears: int.tryParse(_experienceController.text) ?? 0,
            mainCrops: _selectedCrops,
            isVerified: false,
          )
        : null;

    final buyerProfile = _selectedRole == 'buyer'
        ? BuyerProfile(
            businessName: _businessNameController.text.trim(),
            ruc: _rucController.text.trim(),
            businessType: _selectedBusinessType,
            deliveryAddress: _deliveryAddressController.text.trim(),
          )
        : null;

    final success = await auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
      fullName: _nameController.text,
      phone: _phoneController.text,
      preferredContact:
          _selectedRole == 'farmer' ? _preferredContact : 'whatsapp',
      farmerProfile: farmerProfile,
      buyerProfile: buyerProfile,
    );

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al registrar usuario'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.primaryLight, size: 28),
              const SizedBox(width: 8),
              Text(
                '¡Registro Exitoso!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            _selectedRole == 'farmer'
                ? '¡Bienvenido! Tu cuenta ha sido registrada. Un administrador validará tus datos pronto. Mientras tanto, ya puedes acceder al panel de productor.'
                : '¡Bienvenido! Tu cuenta ha sido registrada con éxito. Explora los productos agrícolas de Chupaca en el catálogo.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // pop modal
                if (_selectedRole == 'farmer') {
                  context.go('/farmer/dashboard');
                } else {
                  context.go('/catalog');
                }
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicators
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Paso ${_currentStep + 1} de 3',
                          style: theme.textTheme.titleSmall),
                      Text(
                        _currentStep == 0
                            ? 'Selección de Rol'
                            : (_currentStep == 1
                                ? 'Credenciales de Acceso'
                                : 'Datos del Perfil'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 3,
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                children: [
                  _buildStep1RoleSelection(),
                  _buildStep2Credentials(),
                  _selectedRole == 'farmer'
                      ? _buildStep3AFarmerDetails()
                      : _buildStep3BBuyerDetails(),
                ],
              ),
            ),

            // Navigation Buttons Bottom Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: AppButton(
                        text: 'Atrás',
                        isOutlined: true,
                        onPressed: _previousPage,
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: _currentStep == 2 ? 'Registrarse' : 'Siguiente',
                      onPressed:
                          _currentStep == 2 ? _submitRegistration : _nextPage,
                      isLoading: Provider.of<AuthProvider>(context).isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1RoleSelection() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '¿Cómo deseas utilizar la plataforma?',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona tu rol para personalizar tu experiencia',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Farmer Card
          GestureDetector(
            onTap: () => setState(() => _selectedRole = 'farmer'),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _selectedRole == 'farmer'
                    ? AppColors.primaryDark.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedRole == 'farmer'
                      ? AppColors.primaryDark
                      : Colors.grey.withValues(alpha: 0.2),
                  width: _selectedRole == 'farmer' ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.agriculture,
                        color: AppColors.primaryDark, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌾 Productor Agrícola',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Publica tu cosecha, maneja stock en tiempo real y vende directo sin intermediarios.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Buyer Card
          GestureDetector(
            onTap: () => setState(() => _selectedRole = 'buyer'),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _selectedRole == 'buyer'
                    ? AppColors.primaryDark.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedRole == 'buyer'
                      ? AppColors.primaryDark
                      : Colors.grey.withValues(alpha: 0.2),
                  width: _selectedRole == 'buyer' ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_basket,
                        color: AppColors.secondary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🛒 Comprador / Mayorista',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Busca cultivos frescos, cotiza con calculadora de flete y visualiza tu ahorro real.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Credentials() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            AppTextField(
              label: 'Nombre Completo / Razón Social',
              placeholder: 'Ej. Juan Pérez Quispe',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
              validator: Validators.validateFullName,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Correo Electrónico',
              placeholder: 'ejemplo@correo.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Celular (WhatsApp)',
              placeholder: '+51 9XXXXXXXX',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Contraseña',
              placeholder: 'Mínimo 8 caracteres',
              controller: _passwordController,
              isPassword: true,
              prefixIcon: Icons.lock_outline,
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Confirmar Contraseña',
              placeholder: 'Repite la contraseña',
              controller: _confirmPasswordController,
              isPassword: true,
              prefixIcon: Icons.lock_outline,
              validator: (val) {
                if (val != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3AFarmerDetails() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey3A,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'DNI del Agricultor',
              placeholder: '8 dígitos',
              controller: _dniController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.badge_outlined,
              validator: Validators.validateDni,
            ),
            const SizedBox(height: 20),

            // Community Select
            Text(
              'Comunidad / Distrito de Origen',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedCommunity,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16)),
              items: AppConstants.communities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCommunity = val);
              },
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Años de Experiencia Agrícola',
              placeholder: 'Ej. 12',
              controller: _experienceController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.timeline,
              validator: (val) {
                if (val == null ||
                    int.tryParse(val) == null ||
                    int.parse(val) < 0) {
                  return 'Ingrese un número válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Crops Choice
            Text(
              'Principales Cultivos (Selecciona los aplicables)',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: AppConstants.cropTypes.map((crop) {
                final isSelected = _selectedCrops.contains(crop);
                final displayName = AppConstants.cropNames[crop] ?? crop;
                return ChoiceChip(
                  label: Text(displayName),
                  selected: isSelected,
                  selectedColor: AppColors.primaryDark.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryDark : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Contact Preference
            Text(
              'Método de Contacto Preferido',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            RadioGroup<String>(
              groupValue: _preferredContact,
              onChanged: (val) {
                if (val != null) setState(() => _preferredContact = val);
              },
              child: const Row(
                children: [
                  Radio<String>(
                    value: 'whatsapp',
                    activeColor: AppColors.primaryDark,
                  ),
                  Text('WhatsApp'),
                  SizedBox(width: 16),
                  Radio<String>(
                    value: 'call',
                    activeColor: AppColors.primaryDark,
                  ),
                  Text('Llamada'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Accept research terms (Variable X2 Usability requirement)
            CheckboxListTile(
              value: _acceptTerms,
              activeColor: AppColors.primaryDark,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Autorizo el uso de mis datos para fines del estudio científico de rentabilidad agrícola (Proyecto UNCP Chupaca 2026).',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              onChanged: (val) => setState(() => _acceptTerms = val ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3BBuyerDetails() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey3B,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Razón Social / Nombre Comercial',
              placeholder: 'Ej. Restaurante El Portón',
              controller: _businessNameController,
              prefixIcon: Icons.store_outlined,
              validator: (val) =>
                  Validators.validateNotEmpty(val, 'La razón social'),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'RUC de la Empresa',
              placeholder: '11 dígitos numéricos',
              controller: _rucController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.business_outlined,
              validator: Validators.validateRuc,
            ),
            const SizedBox(height: 20),

            // Business Type
            Text(
              'Tipo de Negocio',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedBusinessType,
              decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16)),
              items: AppConstants.businessTypes.map((t) {
                final disp = AppConstants.businessTypeNames[t] ?? t;
                return DropdownMenuItem(value: t, child: Text(disp));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedBusinessType = val);
              },
            ),
            const SizedBox(height: 20),

            AppTextField(
              label: 'Dirección Principal de Entrega',
              placeholder: 'Ej. Calle Real 123, Huancayo',
              controller: _deliveryAddressController,
              prefixIcon: Icons.location_on_outlined,
              validator: (val) =>
                  Validators.validateNotEmpty(val, 'La dirección'),
            ),
          ],
        ),
      ),
    );
  }
}
