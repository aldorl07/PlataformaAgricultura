import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'service_interfaces.dart';
import 'firebase_services.dart';
import 'mock_services.dart';
import 'package:chupaca_directo/firebase_options.dart';
import '../core/constants/app_constants.dart';

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
      storageService = MockStorageService();
      telemetryService = FirebaseTelemetryService();
      
      // Seed data into Firebase Firestore in case database is empty
      await _seedFirestoreIfEmpty();
    } catch (e) {
      // Catch initialization errors and fallback to Mock Services
      authService = MockAuthService();
      firestoreService = MockFirestoreService();
      storageService = MockStorageService();
      telemetryService = MockTelemetryService();
    }
  }

  static Future<void> _seedFirestoreIfEmpty() async {
    try {
      final db = FirebaseFirestore.instance;
      
      // Check if products collection is empty
      final productQuery = await db.collection(FirebaseConstants.products).limit(1).get();
      if (productQuery.docs.isEmpty) {
        debugPrint('Firestore products collection is empty. Seeding database...');
        
        // Initialize mock seed data in memory
        MockDb.initSeedData();
        
        final batch = db.batch();
        
        // 1. Seed users (farmers profiles for product queries)
        for (final user in MockDb.users) {
          final userRef = db.collection(FirebaseConstants.users).doc(user.id);
          batch.set(userRef, user.toMap());
        }
        
        // 2. Seed products
        for (final product in MockDb.products) {
          final productRef = db.collection(FirebaseConstants.products).doc(product.id);
          batch.set(productRef, product.toMap());
        }
        
        // 3. Seed market prices
        for (final price in MockDb.marketPrices) {
          final priceRef = db.collection(FirebaseConstants.marketPrices).doc(price.id);
          batch.set(priceRef, price.toMap());
        }
        
        await batch.commit();
        debugPrint('Firestore successfully seeded with default products, farmers and market prices.');
      } else {
        // Migration: If any product in Firestore has an empty photos list, let's update it with a matching seed image!
        final allProducts = await db.collection(FirebaseConstants.products).get();
        final batch = db.batch();
        bool hasUpdates = false;
        
        final cropPhotos = {
          'papa': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500',
          'maiz': 'https://images.unsplash.com/photo-1551754625-70c9048723ad?w=500',
          'cebada': 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
          'habas': 'https://images.unsplash.com/photo-1592417817098-8f3d6eb19675?w=500',
          'hortalizas': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500',
          'quinua': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
          'arveja': 'https://images.unsplash.com/photo-1587570220977-83b3e2b202bb?w=500',
          'otros': 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?w=500',
        };

        for (final doc in allProducts.docs) {
          final data = doc.data();
          final photos = data['photos'] as List?;
          if (photos == null || photos.isEmpty) {
            final cropType = data['cropType'] as String? ?? 'otros';
            final photoUrl = cropPhotos[cropType] ?? cropPhotos['otros']!;
            batch.update(doc.reference, {
              'photos': [photoUrl]
            });
            hasUpdates = true;
          }
        }
        
        if (hasUpdates) {
          await batch.commit();
          debugPrint('Firestore existing products migrated with realistic crop image URLs.');
        }
      }
    } catch (e) {
      debugPrint('Error seeding or migrating Firestore: $e');
    }
  }
}
