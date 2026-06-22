import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'services/service_locator.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/catalog/providers/catalog_provider.dart';
import 'features/quote/providers/cart_provider.dart';
import 'features/farmer/providers/farmer_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (will fall back to in-memory Mock databases if Firebase config is missing)
  await ServiceLocator.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CatalogProvider>(
          create: (_) => CatalogProvider(),
          update: (_, auth, catalog) {
            final cat = catalog ?? CatalogProvider();
            cat.updateAuth(auth.currentUser?.id);
            return cat;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FarmerProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = AppRouter.router(context);
          
          return MaterialApp.router(
            title: 'Chupaca Directo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system, // Adapts to user OS theme preference
            routerConfig: router,
          );
        },
      ),
    );
  }
}
