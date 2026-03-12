import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Utilitaire de compression d'images pour reduire la taille
/// des photos avant stockage et conversion en base64.
class ImageCompressor {
  /// Qualite de compression (0-100).
  /// 85 offre un bon compromis entre qualite et taille.
  static const int defaultQuality = 85;

  /// Taille maximale cible en pixels pour le redimensionnement.
  /// Les photos de profil n'ont pas besoin d'etre tres grandes.
  static const int maxDimension = 1024;

  /// Compresse une image et retourne le fichier compresse.
  ///
  /// [imageFile] - Le fichier image original a compresser.
  /// [quality] - Qualite de compression JPEG (0-100, defaut 85).
  /// [maxWidth] - Largeur maximale cible (defaut 1024px).
  /// [maxHeight] - Hauteur maximale cible (defaut 1024px).
  ///
  /// Retourne un [File] compresse ou null en cas d'erreur.
  static Future<File?> compress({
    required File imageFile,
    int quality = defaultQuality,
    int maxWidth = maxDimension,
    int maxHeight = maxDimension,
  }) async {
    try {
      // Obtenir le repertoire temporaire pour stocker l'image compressee
      final tempDir = await getTemporaryDirectory();
      final targetPath = p.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Compresser l'image avec redimensionnement et sauvegarde dans un fichier
      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
        keepExif:
            false, // Supprimer les metadonnees EXIF pour reduire la taille
      );

      if (compressedXFile == null) {
        return null;
      }

      return File(compressedXFile.path);
    } catch (e) {
      // En cas d'erreur, retourner le fichier original
      // pour ne pas bloquer le flux utilisateur
      return imageFile;
    }
  }

  /// Compresse une image et retourne directement les bytes compressee.
  ///
  /// Utile pour obtenir directement les bytes a convertir en base64.
  ///
  /// [imageFile] - Le fichier image original a compresser.
  /// [quality] - Qualite de compression JPEG (0-100, defaut 85).
  /// [maxWidth] - Largeur maximale cible (defaut 1024px).
  /// [maxHeight] - Hauteur maximale cible (defaut 1024px).
  ///
  /// Retourne les bytes compressee ou null en cas d'erreur.
  static Future<List<int>?> compressToBytes({
    required File imageFile,
    int quality = defaultQuality,
    int maxWidth = maxDimension,
    int maxHeight = maxDimension,
  }) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      return compressedBytes?.toList();
    } catch (e) {
      // En cas d'erreur, retourner les bytes originaux
      return await imageFile.readAsBytes();
    }
  }

  /// Obtient la taille d'un fichier en octets.
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Formate une taille de fichier en texte lisible.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes o';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} Mo';
    }
  }
}
