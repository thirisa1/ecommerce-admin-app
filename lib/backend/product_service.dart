import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/product.dart';
import 'storage_service.dart';

class ProductService {
  static final _db = FirebaseFirestore.instance;
  static const _collection = 'produits';

  /// Ajoute un produit dans Firestore + upload image sur Cloudinary si présente.
  static Future<Product> addProduct({
    required String nom,
    required String marque,
    required ProductCategory category,
    required double prix,
    required int quantite,
    required String description,
    required List<BuyerType> acheteurs,
    File? imageFile,
  }) async {
    // 1. Générer un ID Firestore
    final docRef = _db.collection(_collection).doc();
    final productId = docRef.id;

    // 2. Upload image sur Cloudinary si présente
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await StorageService.uploadProductImage(imageFile);
    }

    // 3. Construire le document — noms de champs selon votre BDD
    final data = {
      'nom': nom,
      'marque': marque,
      'categorie': category.label,
      'prix': prix,
      'quantite': quantite,
      'descreption': description, // nom exact dans votre BDD
      'imgProd': imageUrl ?? '',
      'achteurAutoris': acheteurs.map((b) => b.label).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 4. Sauvegarder dans Firestore
    await docRef.set(data);
    debugPrint('[ProductService] ✅ Produit ajouté: $productId');

    // 5. Retourner l'objet Product local
    return Product(
      id: productId,
      name: nom,
      brand: marque,
      category: category,
      quantity: quantite,
      price: prix,
      description: description,
      allowedBuyers: acheteurs,
      imagePath: imageUrl,
    );
  }

  /// Récupère tous les produits depuis Firestore.
  static Future<List<Product>> fetchProducts() async {
    try {
      final snapshot =
          await _db
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        final d = doc.data();
        return Product(
          id: doc.id,
          name: d['nom'] ?? '',
          brand: d['marque'] ?? '',
          category: _categoryFromLabel(d['categorie'] ?? ''),
          quantity: (d['quantite'] ?? 0) as int,
          price: (d['prix'] ?? 0).toDouble(),
          description: d['descreption'] ?? '',
          allowedBuyers: _buyersFromList(d['achteurAutoris']),
          imagePath: d['imgProd'],
        );
      }).toList();
    } on FirebaseException catch (e) {
      debugPrint('[ProductService] ❌ Erreur fetch: ${e.message}');
      return [];
    }
  }

  // ── Helpers de conversion ──

  static ProductCategory _categoryFromLabel(String label) {
    return ProductCategory.values.firstWhere(
      (c) => c.label == label,
      orElse: () => ProductCategory.medical,
    );
  }

  static List<BuyerType> _buyersFromList(dynamic list) {
    if (list == null || list is! List) return [];
    return (list as List)
        .map(
          (e) => BuyerType.values.firstWhere(
            (b) => b.label == e,
            orElse: () => BuyerType.autre,
          ),
        )
        .toList();
  }
}
