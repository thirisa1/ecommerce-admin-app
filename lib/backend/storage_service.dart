import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class StorageService {
  // ── Cloudinary config ──
  static const _cloudName = 'dtthbibks';
  static const _uploadPreset = 'imgsPdfs';
  static const _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload';

  /// Upload une image ou un PDF vers Cloudinary.
  /// [folder] : 'produits' pour les images, 'justificatifs' pour les PDFs
  /// Retourne l'URL publique ou null en cas d'erreur.
  static Future<String?> uploadFile({
    required File file,
    required String folder,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final result = json.decode(utf8.decode(responseData));

      if (response.statusCode == 200) {
        final url = result['secure_url'] as String;
        debugPrint('[Cloudinary] ** Upload réussi: $url');
        return url;
      } else {
        debugPrint('[Cloudinary] # Erreur: ${result['error']['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('[Cloudinary] # Erreur inattendue: $e');
      return null;
    }
  }

  /// Raccourci pour uploader une image produit
  static Future<String?> uploadProductImage(File file) async {
    return uploadFile(file: file, folder: 'produits');
  }

  /// Raccourci pour uploader un justificatif (PDF ou image)
  static Future<String?> uploadJustificatif(File file) async {
    return uploadFile(file: file, folder: 'justificatifs');
  }
}