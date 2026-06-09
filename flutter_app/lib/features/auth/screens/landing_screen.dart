import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/market_ticker.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Simulated market ticker items
    final tickerItems = [
      const MarketTickerItem(cropName: 'Papa Yungay', wholesalePrice: 1.80, platformPrice: 1.35, savingPercent: 25),
      const MarketTickerItem(cropName: 'Maíz Choclo', wholesalePrice: 2.50, platformPrice: 1.90, savingPercent: 24),
      const MarketTickerItem(cropName: 'Cebada Grano', wholesalePrice: 2.00, platformPrice: 1.50, savingPercent: 25),
      const MarketTickerItem(cropName: 'Habas Verdes', wholesalePrice: 3.20, platformPrice: 2.40, savingPercent: 25),
      const MarketTickerItem(cropName: 'Zanahoria Dulce', wholesalePrice: 1.60, platformPrice: 1.20, savingPercent: 25),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Scrolling Market Price Ticker
              MarketTicker(items: tickerItems),
              
              // 2. Hero Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, Color(0xFF0F3D12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size: 72,
                      color: AppColors.primaryLight,
                    ).animate().scale(duration: 500.ms),
                    const SizedBox(height: 16),
                    Text(
                      'Del campo a tu mesa,\nsin intermediarios',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                    const SizedBox(height: 16),
                    Text(
                      'Plataforma digital agrícola de Chupaca. Conectamos directamente a agricultores locales con mercados mayoristas y restaurantes.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 32),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 500;
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: isWide ? 200 : double.infinity,
                              child: AppButton(
                                text: 'Soy Productor',
                                icon: Icons.agriculture_outlined,
                                backgroundColor: AppColors.primaryLight,
                                onPressed: () => context.push('/register?role=farmer'),
                              ),
                            ),
                            SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 12),
                            SizedBox(
                              width: isWide ? 200 : double.infinity,
                              child: AppButton(
                                text: 'Soy Comprador',
                                icon: Icons.shopping_basket_outlined,
                                backgroundColor: AppColors.secondary,
                                onPressed: () => context.push('/register?role=buyer'),
                              ),
                            ),
                          ],
                        );
                      },
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.push('/login'),
                      child: const Text(
                        'Ya tengo cuenta. Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 3. Trust indicators / Impact Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Impacto del Proyecto Chupaca 2026',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.neutralDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildImpactCard(
                          context,
                          '30+',
                          'Productores',
                          Icons.verified_user_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildImpactCard(
                          context,
                          '25%',
                          'Ahorro Prom.',
                          Icons.trending_down_outlined,
                        ),
                        const SizedBox(width: 12),
                        _buildImpactCard(
                          context,
                          '9',
                          'Distritos',
                          Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 4. How it works
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cómo funciona?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStepRow(
                      context,
                      '1',
                      'Publicación Cosecha',
                      'El productor sube fotos, variedad y stock real de su cultivo.',
                      Icons.camera_alt_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildStepRow(
                      context,
                      '2',
                      'Simulación de Costos',
                      'El comprador cotiza directo, calcula flete y ve su ahorro vs intermediarios.',
                      Icons.calculate_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildStepRow(
                      context,
                      '3',
                      'Entrega Directa',
                      'Se formaliza el pedido. El agricultor gana más, el comprador paga menos.',
                      Icons.handshake_outlined,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 60),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: isDark ? Colors.black26 : Colors.grey[200],
                child: Column(
                  children: [
                    Text(
                      '© 2026 Chupaca Directo',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Taller de Investigación II · UNCP',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImpactCard(BuildContext context, String value, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Card(
        elevation: 1,
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, String step, String title, String desc, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryDark,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
