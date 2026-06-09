import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';

// Screens imports (will be created in Fase 7)
import '../features/auth/screens/landing_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/catalog/screens/catalog_screen.dart';
import '../features/catalog/screens/product_detail_screen.dart';
import '../features/quote/screens/quote_simulator_screen.dart';
import '../features/farmer/screens/farmer_dashboard_screen.dart';
import '../features/farmer/screens/farmer_products_screen.dart';
import '../features/buyer/screens/buyer_orders_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final user = authProvider.currentUser;
        final goingToAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        // 1. If not logged in and trying to access protected routes, redirect to login
        if (!loggedIn) {
          if (state.matchedLocation.startsWith('/buyer') ||
              state.matchedLocation.startsWith('/farmer') ||
              state.matchedLocation.startsWith('/admin')) {
            return '/login';
          }
          return null;
        }

        // 2. If logged in and trying to go to auth screens, redirect to their home
        if (goingToAuth) {
          if (user?.role == 'farmer') return '/farmer/dashboard';
          if (user?.role == 'admin') return '/admin/dashboard';
          return '/catalog';
        }

        // 3. Role Guards
        if (state.matchedLocation.startsWith('/farmer') && user?.role != 'farmer') {
          return '/';
        }
        if (state.matchedLocation.startsWith('/admin') && user?.role != 'admin') {
          return '/';
        }
        if (state.matchedLocation.startsWith('/buyer') && user?.role != 'buyer') {
          return '/';
        }

        return null;
      },
      routes: [
        // Public
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            final role = state.uri.queryParameters['role'];
            return RegisterScreen(initialRole: role);
          },
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/catalog/:id',
          builder: (context, state) {
            final productId = state.pathParameters['id']!;
            return ProductDetailScreen(productId: productId);
          },
        ),

        // Buyer Protected
        GoRoute(
          path: '/buyer/simulator',
          builder: (context, state) => const QuoteSimulatorScreen(),
        ),
        GoRoute(
          path: '/buyer/orders',
          builder: (context, state) => const BuyerOrdersScreen(),
        ),

        // Farmer Protected
        GoRoute(
          path: '/farmer/dashboard',
          builder: (context, state) => const FarmerDashboardScreen(),
        ),
        GoRoute(
          path: '/farmer/products',
          builder: (context, state) => const FarmerProductsScreen(),
        ),

        // Admin Protected
        GoRoute(
          path: '/admin/dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Página no encontrada',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Ir al Inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
