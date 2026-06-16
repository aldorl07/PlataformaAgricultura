import 'package:firebase_core/firebase_core.dart';
import 'service_interfaces.dart';
import 'firebase_services.dart';
import 'mock_services.dart';
import 'package:chupaca_directo/firebase_options.dart';

class ServiceLocator {
  static late final IAuthService authService;
  static late final IFirestoreService firestoreService;
  static late final IStorageService storageService;
  static late final ITelemetryService telemetryService;

  static Future<void> init() async {
    try {
      // Try to initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      authService = FirebaseAuthService();
      firestoreService = FirebaseFirestoreService();
      storageService = FirebaseStorageService();
      telemetryService = FirebaseTelemetryService();
      
      // Seed data into Firebase Firestore in case database is empty
      // In a real production deployment, this would be a one-time migration.
      // For testing, we can run it safely or let the user do it.
    } catch (e) {
      // Catch initialization errors and fallback to Mock Services
      authService = MockAuthService();
      firestoreService = MockFirestoreService();
      storageService = MockStorageService();
      telemetryService = MockTelemetryService();
    }
  }
}
