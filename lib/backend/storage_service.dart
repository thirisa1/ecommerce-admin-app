import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance;

  /// Upload une image vers Firebase Storage et retourne l'URL de téléchargement.
  /// Retourne null si aucune image ou en cas d'erreur.
  static Future<String?> uploadProductImage({
    required File imageFile,
    required String productId,
  }) async {
    try {
      final ref = _storage.ref().child('produits').child('$productId.jpg');

      final uploadTask = await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('[StorageService] Erreur upload image: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[StorageService] Erreur inattendue: $e');
      return null;
    }
  }
}
